from datetime import datetime, date
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict


class TaskBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    assignee_name: Optional[str] = None
    due_date: Optional[date] = None


class TaskCreate(TaskBase):
    meeting_id: int
    assignee_id: Optional[int] = None


class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    assignee_name: Optional[str] = None
    assignee_id: Optional[int] = None
    due_date: Optional[date] = None
    status: Optional[str] = Field(None, pattern="^(Pending|Completed)$")


class TaskResponse(TaskBase):
    id: int
    meeting_id: int
    assignee_id: Optional[int] = None
    status: str
    created_at: datetime
    completed_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)
