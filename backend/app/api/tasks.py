from datetime import datetime, timezone
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from app.database.database import get_db
from app.models.task import Task
from app.models.meeting import Meeting
from app.models.user import User
from app.schemas.task import TaskCreate, TaskUpdate, TaskResponse
from app.api.deps import get_current_user
from app.services.task_resequencer import resequence_all_tasks
from app.services.firestore_sync import firestore_sync

router = APIRouter(prefix="/tasks", tags=["Tasks"])


@router.get("", response_model=List[TaskResponse])
def get_tasks(
    status_filter: Optional[str] = Query(None, alias="status"),
    meeting_id: Optional[int] = Query(None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    query = (
        db.query(Task)
        .join(Meeting, Task.meeting_id == Meeting.id)
        .filter(Meeting.user_id == current_user.id)
    )

    if status_filter:
        query = query.filter(Task.status == status_filter)
    if meeting_id:
        query = query.filter(Task.meeting_id == meeting_id)

    return query.order_by(Task.due_date.asc().nullslast(), Task.id.desc()).all()


@router.get("/{task_id}", response_model=TaskResponse)
def get_task(
    task_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    task = (
        db.query(Task)
        .join(Meeting, Task.meeting_id == Meeting.id)
        .filter(Task.id == task_id, Meeting.user_id == current_user.id)
        .first()
    )
    if not task:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found.")
    return task


@router.post("", response_model=TaskResponse, status_code=status.HTTP_201_CREATED)
def create_task(
    task_in: TaskCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Verify meeting belongs to user
    meeting = (
        db.query(Meeting)
        .filter(Meeting.id == task_in.meeting_id, Meeting.user_id == current_user.id)
        .first()
    )
    if not meeting:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Associated meeting not found.")

    task = Task(
        meeting_id=task_in.meeting_id,
        title=task_in.title,
        description=task_in.description,
        assignee_id=task_in.assignee_id,
        assignee_name=task_in.assignee_name,
        due_date=task_in.due_date,
        status="Pending",
    )
    db.add(task)
    db.commit()
    db.refresh(task)
    return task


@router.patch("/{task_id}", response_model=TaskResponse)
def update_task(
    task_id: int,
    task_update: TaskUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    task = (
        db.query(Task)
        .join(Meeting, Task.meeting_id == Meeting.id)
        .filter(Task.id == task_id, Meeting.user_id == current_user.id)
        .first()
    )
    if not task:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found.")

    update_data = task_update.model_dump(exclude_unset=True)

    if "status" in update_data:
        new_status = update_data["status"]
        if new_status == "Completed" and task.status != "Completed":
            task.completed_at = datetime.now(timezone.utc)
        elif new_status == "Pending":
            task.completed_at = None

    for field, value in update_data.items():
        setattr(task, field, value)

    db.commit()
    db.refresh(task)
    return task


@router.delete("/{task_id}", status_code=status.HTTP_200_OK)
async def delete_task(
    task_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    task = (
        db.query(Task)
        .join(Meeting, Task.meeting_id == Meeting.id)
        .filter(Task.id == task_id, Meeting.user_id == current_user.id)
        .first()
    )
    if not task:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found.")

    db.delete(task)
    db.commit()

    # Re-sequence remaining tasks in SQLite
    resequenced_map = resequence_all_tasks(db)

    # Sync to Cloud Firestore
    try:
        await firestore_sync.delete_task_and_sync(
            deleted_task_id=task_id,
            resequenced_map=resequenced_map
        )
    except Exception as e:
        print(f"Error syncing task deletion to Firestore: {e}")

    return {
        "status": "success",
        "message": f"Task #{task_id} deleted and remaining tasks re-sequenced.",
        "resequenced_tasks_count": len(resequenced_map)
    }
