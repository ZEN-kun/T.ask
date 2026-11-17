from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database.database import Base


class Meeting(Base):
    __tablename__ = "meetings"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    title = Column(String(255), nullable=False)
    file_url = Column(String(500), nullable=True)
    transcript = Column(Text, nullable=True)
    summary = Column(Text, nullable=True)
    processing_status = Column(String(50), default="Pending", nullable=False)  # Pending, Transcribing, Analyzing, Completed, Failed
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    processed_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    user = relationship("User", back_populates="meetings")
    tasks = relationship("Task", back_populates="meeting", cascade="all, delete-orphan")
    key_points = relationship("MeetingKeyPoint", back_populates="meeting", cascade="all, delete-orphan")
    decisions = relationship("MeetingDecision", back_populates="meeting", cascade="all, delete-orphan")


class MeetingKeyPoint(Base):
    __tablename__ = "meeting_key_points"

    id = Column(Integer, primary_key=True, index=True)
    meeting_id = Column(Integer, ForeignKey("meetings.id", ondelete="CASCADE"), nullable=False)
    content = Column(Text, nullable=False)

    meeting = relationship("Meeting", back_populates="key_points")


class MeetingDecision(Base):
    __tablename__ = "meeting_decisions"

    id = Column(Integer, primary_key=True, index=True)
    meeting_id = Column(Integer, ForeignKey("meetings.id", ondelete="CASCADE"), nullable=False)
    content = Column(Text, nullable=False)

    meeting = relationship("Meeting", back_populates="decisions")
