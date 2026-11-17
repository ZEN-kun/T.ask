from datetime import datetime, date, timezone
import asyncio
import os
import shutil
from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Body, Depends, HTTPException, UploadFile, File, Form, status
from sqlalchemy.orm import Session
from app.database.database import get_db
from app.models.meeting import Meeting, MeetingKeyPoint, MeetingDecision
from app.models.task import Task
from app.models.user import User
from app.schemas.meeting import (
    MeetingResponse,
    MeetingDetailResponse,
    DashboardStats,
)
from app.schemas.task import TaskResponse
from app.api.deps import get_current_user
from app.services.transcription import (
    get_transcription_service,
    is_document_file,
    extract_text_from_document,
)
from app.services.ai_processor import get_ai_processor
from app.services.fuzzy_matcher import FuzzyNameMatcher
from app.services.whatsapp import whatsapp_service
from app.services.firestore_sync import firestore_sync
from app.services.task_resequencer import resequence_all_tasks

router = APIRouter(prefix="/meetings", tags=["Meetings"])

UPLOAD_DIR = os.path.join(os.getcwd(), "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)


@router.get("/dashboard/stats", response_model=DashboardStats)
def get_dashboard_stats(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    total_meetings = db.query(Meeting).filter(Meeting.user_id == current_user.id).count()

    tasks_query = (
        db.query(Task)
        .join(Meeting, Task.meeting_id == Meeting.id)
        .filter(Meeting.user_id == current_user.id)
    )
    total_tasks = tasks_query.count()
    pending_tasks = tasks_query.filter(Task.status == "Pending").count()
    completed_tasks = tasks_query.filter(Task.status == "Completed").count()

    today = date.today()
    overdue_tasks = tasks_query.filter(
        Task.status == "Pending",
        Task.due_date < today
    ).count()

    upcoming_tasks = (
        tasks_query.filter(Task.status == "Pending")
        .order_by(Task.due_date.asc().nullslast())
        .limit(5)
        .all()
    )

    recent_meetings = (
        db.query(Meeting)
        .filter(Meeting.user_id == current_user.id)
        .order_by(Meeting.created_at.desc())
        .limit(5)
        .all()
    )

    return DashboardStats(
        total_meetings=total_meetings,
        total_tasks=total_tasks,
        pending_tasks=pending_tasks,
        completed_tasks=completed_tasks,
        overdue_tasks=overdue_tasks,
        upcoming_tasks=[TaskResponse.model_validate(t) for t in upcoming_tasks],
        recent_meetings=[MeetingResponse.model_validate(m) for m in recent_meetings],
    )


@router.get("", response_model=List[MeetingResponse])
def get_meetings(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return (
        db.query(Meeting)
        .filter(Meeting.user_id == current_user.id)
        .order_by(Meeting.created_at.desc())
        .all()
    )


@router.post("", response_model=MeetingResponse, status_code=status.HTTP_201_CREATED)
async def create_meeting(
    title: str = Form(...),
    transcript: Optional[str] = Form(None),
    audio_file: Optional[UploadFile] = File(None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    file_path = None
    if audio_file:
        safe_name = os.path.basename(audio_file.filename or "upload.bin")
        file_path = os.path.join(UPLOAD_DIR, f"{int(datetime.now().timestamp())}_{safe_name}")
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(audio_file.file, buffer)

        # If uploaded file is a text/Word document (.txt, .doc, .docx), extract transcript immediately
        if is_document_file(safe_name):
            doc_text = extract_text_from_document(file_path)
            if doc_text:
                transcript = f"{transcript}\n{doc_text}".strip() if transcript else doc_text

    meeting = Meeting(
        user_id=current_user.id,
        title=title,
        file_url=file_path,
        transcript=transcript,
        processing_status="Pending"
    )
    db.add(meeting)
    db.commit()
    db.refresh(meeting)
    return meeting


@router.get("/{meeting_id}", response_model=MeetingDetailResponse)
def get_meeting(
    meeting_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    meeting = (
        db.query(Meeting)
        .filter(Meeting.id == meeting_id, Meeting.user_id == current_user.id)
        .first()
    )
    if not meeting:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Meeting not found.")
    return meeting


@router.delete("/{meeting_id}", status_code=status.HTTP_200_OK)
async def delete_meeting(
    meeting_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Permanently deletes a meeting and its cascading items (tasks, key points, decisions).
    Re-sequences all remaining tasks so their IDs are consecutive: 1, 2, ..., N.
    Syncs deletions and re-sequenced task IDs to Cloud Firestore in real-time.
    """
    meeting = (
        db.query(Meeting)
        .filter(Meeting.id == meeting_id, Meeting.user_id == current_user.id)
        .first()
    )
    if not meeting:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Meeting not found.")

    # 1. Collect task IDs for Firestore cleanup
    deleted_task_ids = [t.id for t in meeting.tasks]

    # 2. Delete uploaded audio/document file if present
    if meeting.file_url and os.path.exists(meeting.file_url):
        try:
            os.remove(meeting.file_url)
        except Exception as e:
            print(f"Could not remove file {meeting.file_url}: {e}")

    # 3. Delete meeting from SQLite (cascades to tasks, key_points, decisions)
    db.delete(meeting)
    db.commit()

    # 4. Re-sequence all remaining tasks in SQLite
    resequenced_map = resequence_all_tasks(db)

    # 5. Sync to Cloud Firestore in real-time
    try:
        await firestore_sync.delete_meeting_and_sync(
            meeting_id=meeting_id,
            deleted_task_ids=deleted_task_ids,
            resequenced_map=resequenced_map
        )
    except Exception as e:
        print(f"Error syncing meeting deletion to Firestore: {e}")

    return {
        "status": "success",
        "message": f"Meeting #{meeting_id} deleted successfully.",
        "resequenced_tasks_count": len(resequenced_map)
    }


@router.post("/{meeting_id}/process", response_model=MeetingDetailResponse)
async def process_meeting(
    meeting_id: int,
    payload: Optional[Dict[str, Any]] = Body(default=None),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    meeting = (
        db.query(Meeting)
        .filter(Meeting.id == meeting_id, Meeting.user_id == current_user.id)
        .first()
    )
    if not meeting:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Meeting not found.")

    ext_attendees = (payload or {}).get("attendees") or []
    manager_phone = (payload or {}).get("manager_phone") or ""
    manager_name = (payload or {}).get("manager_name") or ""
    participant_names = [a.get("name") for a in ext_attendees if isinstance(a, dict) and a.get("name")]
    if manager_name:
        participant_names.append(manager_name)

    # 1. Step: Model 1 Speech-to-Text / Document Extraction (if file uploaded)
    if not meeting.transcript and meeting.file_url:
        meeting.processing_status = "Transcribing"
        db.commit()
        try:
            stt = get_transcription_service()
            transcript_text = await stt.transcribe_audio(
                meeting.file_url,
                participant_names=participant_names or None,
            )
            meeting.transcript = transcript_text
            db.commit()
        except Exception as e:
            meeting.processing_status = "Failed"
            db.commit()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Transcription failed: {str(e)}"
            )

    if not meeting.transcript:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No transcript or audio provided to process."
        )

    # 2. Step: Model 2 Comprehension & Task Mining via Groq AI
    meeting.processing_status = "Analyzing"
    db.commit()

    try:
        ai_processor = get_ai_processor()
        result = await ai_processor.analyze_meeting_transcript(meeting.transcript)

        meeting.summary = result.summary
        meeting.processing_status = "Completed"
        meeting.processed_at = datetime.now(timezone.utc)

        # Clear prior items if re-processing
        db.query(MeetingKeyPoint).filter(MeetingKeyPoint.meeting_id == meeting.id).delete()
        db.query(MeetingDecision).filter(MeetingDecision.meeting_id == meeting.id).delete()
        db.query(Task).filter(Task.meeting_id == meeting.id).delete()

        # Add key points
        for kp in result.key_points:
            db.add(MeetingKeyPoint(meeting_id=meeting.id, content=kp))

        # Add decisions
        for dec in result.decisions:
            db.add(MeetingDecision(meeting_id=meeting.id, content=dec))

        # Merge any attendees passed from Firebase (mobile client)
        ext_attendees = (payload or {}).get("attendees") or []
        manager_phone = (payload or {}).get("manager_phone") or ""
        manager_name = (payload or {}).get("manager_name") or ""
        print(f"\n=======================================================")
        print(f"🔍 [Meeting #{meeting.id} DEBUG] Starting AI & WhatsApp Pipeline")
        print(f"📥 Received Attendees ({len(ext_attendees)}): {ext_attendees}")
        print(f"👤 Manager Info: Name='{manager_name}', Phone='{manager_phone}'")
        print(f"=======================================================")

        # 1. Dynamically fetch ALL live registered users from Cloud Firestore
        firestore_users = await firestore_sync.get_all_users()
        user_dicts = []
        for fu in firestore_users:
            user_dicts.append({
                "id": None,
                "name": fu["name"],
                "phone": fu["phone"] or "",
                "role": fu.get("role", "employee"),
            })

        # Add any explicitly passed attendees from Flutter client if not present
        existing_names = {u["name"].lower() for u in user_dicts if u.get("name")}
        for att in ext_attendees:
            if isinstance(att, dict) and att.get("name"):
                if att["name"].lower() not in existing_names:
                    user_dicts.append({
                        "id": None,
                        "name": att.get("name"),
                        "phone": att.get("phone") or "",
                    })
                    existing_names.add(att["name"].lower())

        if manager_name and manager_name.lower() not in existing_names:
            user_dicts.append({
                "id": None,
                "name": manager_name,
                "phone": manager_phone or "917981929830",
            })
            existing_names.add(manager_name.lower())

        # Also include SQLite users
        for u in db.query(User).all():
            if u.name and u.name.lower() not in existing_names:
                user_dicts.append({"id": u.id, "name": u.name, "phone": u.phone or ""})

        print(f"📋 Full Candidate Pool for Matching: {user_dicts}")
        task_phone_list: List[Optional[str]] = []

        for task_item in result.tasks:
            parsed_due_date = None
            if task_item.due_date:
                try:
                    parsed_due_date = datetime.strptime(task_item.due_date, "%Y-%m-%d").date()
                except ValueError:
                    parsed_due_date = None

            # Model 3: Fuzzy match spoken name to actual user account / attendee
            matched_user, score, _ = FuzzyNameMatcher.match_name_to_participants(
                spoken_name=task_item.assignee_name,
                participants=user_dicts
            )

            resolved_user_id = matched_user["id"] if matched_user and isinstance(matched_user.get("id"), int) else None
            resolved_user_name = matched_user["name"] if matched_user else task_item.assignee_name
            resolved_phone = matched_user.get("phone") if matched_user else None

            print(f"🎯 [Matcher] Spoken: '{task_item.assignee_name}' -> Matched: '{resolved_user_name}' (+{resolved_phone}) | Score: {score}")

            task = Task(
                meeting_id=meeting.id,
                title=task_item.title,
                description=task_item.description,
                assignee_id=resolved_user_id,
                assignee_name=resolved_user_name,
                due_date=parsed_due_date,
                status="Pending",
            )
            db.add(task)
            task_phone_list.append(resolved_phone)

        db.commit()
        db.refresh(meeting)

        # 3. Model 4: Auto-dispatch Task Assignment via WhatsApp (concurrently)
        print(f"🚀 [WhatsApp Dispatch] Sending {len(meeting.tasks)} task notifications...")
        dispatch_coroutines = []
        for idx, task in enumerate(meeting.tasks):
            dest_phone = task_phone_list[idx] if idx < len(task_phone_list) else None
            if not dest_phone and task.assignee_id:
                u = db.query(User).filter(User.id == task.assignee_id).first()
                if u and u.phone:
                    dest_phone = u.phone

            # Direct name lookup in dynamic user pool if fuzzy score was marginal
            if not dest_phone and task.assignee_name:
                low = task.assignee_name.lower().strip()
                for ud in user_dicts:
                    u_name = ud.get("name", "").lower()
                    if u_name and (u_name in low or low in u_name):
                        dest_phone = ud.get("phone")
                        if dest_phone:
                            break

            print(f"  📤 Task #{task.id} ('{task.title}') -> Assignee: '{task.assignee_name}' -> Target Phone: +{dest_phone}")

            if dest_phone:
                dispatch_coroutines.append(
                    whatsapp_service.send_task_assignment(
                        to_phone=dest_phone,
                        task_id=task.id,
                        title=task.title,
                        description=task.description,
                        due_date=task.due_date.isoformat() if task.due_date else None,
                    )
                )

        if dispatch_coroutines:
            results = await asyncio.gather(*dispatch_coroutines, return_exceptions=True)
            for idx, res in enumerate(results):
                status_icon = "✅ SUCCESS" if res is True else f"❌ ERROR: {res}"
                print(f"  📥 Task #{meeting.tasks[idx].id} WhatsApp Result: {status_icon}")
        else:
            print("  ⚠️ No valid phone numbers found for tasks. WhatsApp dispatch skipped.")

        return meeting

    except Exception as e:
        meeting.processing_status = "Failed"
        db.commit()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"AI processing failed: {str(e)}"
        )
