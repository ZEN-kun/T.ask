import pytest
from datetime import date
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from app.database.database import Base, get_db
from app.main import app
from app.models.user import User
from app.models.meeting import Meeting
from app.models.task import Task
from app.core.security import get_password_hash, verify_password, create_access_token, decode_access_token
from app.services.ai_processor import AIMeetingProcessor
from app.services.whatsapp import whatsapp_service

# Test SQLite in-memory database with StaticPool so all connections share the DB
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base.metadata.create_all(bind=engine)


def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)


def test_password_and_jwt_security():
    password = "secret_password_123"
    hashed = get_password_hash(password)
    assert verify_password(password, hashed)
    assert not verify_password("wrong_password", hashed)

    token = create_access_token(subject=42)
    decoded_sub = decode_access_token(token)
    assert decoded_sub == "42"


def test_health_check():
    response = client.get("/api/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["motto"] == "What are your task?"


def test_auth_and_user_flow():
    # 1. Register
    reg_res = client.post(
        "/api/auth/register",
        json={
            "name": "Alex",
            "email": "alex@example.com",
            "password": "mypassword123",
            "phone": "+1234567890",
        },
    )
    assert reg_res.status_code == 201
    data = reg_res.json()
    assert "access_token" in data
    token = data["access_token"]
    user_id = data["user"]["id"]

    # 2. Login
    login_res = client.post(
        "/api/auth/login",
        json={"email": "alex@example.com", "password": "mypassword123"},
    )
    assert login_res.status_code == 200
    assert login_res.json()["user"]["email"] == "alex@example.com"

    # 3. Get /me
    me_res = client.get("/api/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert me_res.status_code == 200
    assert me_res.json()["name"] == "Alex"


@pytest.mark.asyncio
async def test_ai_fallback_and_meeting_processing():
    processor = AIMeetingProcessor()
    transcript = (
        "Alex: I will finish the API testing by Friday.\n"
        "Sarah: I will write the documentation before Monday.\n"
        "Manager: We decided to deploy the prototype next week."
    )
    result = await processor.analyze_meeting_transcript(transcript)
    assert len(result.tasks) >= 2
    assert any("API testing" in t.title for t in result.tasks)
    assert any(t.assignee_name == "Alex" for t in result.tasks)
    assert len(result.decisions) >= 1


def test_meeting_and_task_crud():
    # Login to get token
    login_res = client.post(
        "/api/auth/login",
        json={"email": "alex@example.com", "password": "mypassword123"},
    )
    token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # Create meeting
    create_m_res = client.post(
        "/api/meetings",
        data={
            "title": "Sprint Planning",
            "transcript": "Alex: I will complete the dashboard tasks by Friday.",
        },
        headers=headers,
    )
    assert create_m_res.status_code == 201
    meeting_id = create_m_res.json()["id"]

    # Process meeting
    proc_res = client.post(f"/api/meetings/{meeting_id}/process", headers=headers)
    assert proc_res.status_code == 200
    detail = proc_res.json()
    assert detail["summary"] is not None
    assert len(detail["tasks"]) >= 1

    task_id = detail["tasks"][0]["id"]

    # Check Dashboard Stats
    stats_res = client.get("/api/meetings/dashboard/stats", headers=headers)
    assert stats_res.status_code == 200
    stats = stats_res.json()
    assert stats["total_meetings"] >= 1
    assert stats["total_tasks"] >= 1
    assert stats["pending_tasks"] >= 1

    # Update Task Status
    patch_res = client.patch(
        f"/api/tasks/{task_id}",
        json={"status": "Completed"},
        headers=headers,
    )
    assert patch_res.status_code == 200
    assert patch_res.json()["status"] == "Completed"


def test_whatsapp_webhook_parsing():
    payload = {
        "entry": [
            {
                "changes": [
                    {
                        "value": {
                            "messages": [
                                {
                                    "from": "+1234567890",
                                    "text": {"body": "DONE 12"},
                                }
                            ]
                        }
                    }
                ]
            }
        ]
    }
    parsed = whatsapp_service.parse_incoming_reply(payload)
    assert parsed is not None
    phone, task_id = parsed
    assert phone == "+1234567890"
    assert task_id == 12
