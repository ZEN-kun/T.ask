from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field, ConfigDict
from app.schemas.task import TaskResponse


class KeyPointResponse(BaseModel):
    id: int
    content: str

    model_config = ConfigDict(from_attributes=True)


class DecisionResponse(BaseModel):
    id: int
    content: str

    model_config = ConfigDict(from_attributes=True)


class MeetingBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)


class MeetingCreate(MeetingBase):
    transcript: Optional[str] = None


class MeetingResponse(MeetingBase):
    id: int
    user_id: int
    file_url: Optional[str] = None
    transcript: Optional[str] = None
    summary: Optional[str] = None
    processing_status: str
    created_at: datetime
    processed_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)


class MeetingDetailResponse(MeetingResponse):
    key_points: List[KeyPointResponse] = []
    decisions: List[DecisionResponse] = []
    tasks: List[TaskResponse] = []


class ExtractedTaskAI(BaseModel):
    title: str
    description: Optional[str] = None
    assignee_name: Optional[str] = None
    due_date: Optional[str] = None


class AIAnalysisResult(BaseModel):
    summary: str
    key_points: List[str] = []
    decisions: List[str] = []
    tasks: List[ExtractedTaskAI] = []


class DashboardStats(BaseModel):
    total_meetings: int
    total_tasks: int
    pending_tasks: int
    completed_tasks: int
    overdue_tasks: int
    upcoming_tasks: List[TaskResponse]
    recent_meetings: List[MeetingResponse]
