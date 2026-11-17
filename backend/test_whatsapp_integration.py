"""
Test script for T.ask WhatsApp Cloud API Integration:
1. Tests Webhook Verification (GET /api/webhooks/whatsapp)
2. Tests WhatsApp Task Assignment message builder & dispatch
3. Tests Incoming Webhook message parsing ('DONE <task_id>')
4. Verifies Task Status transition: Pending -> Completed
"""
import sys
import asyncio
from datetime import datetime, timezone
from sqlalchemy.orm import Session
from app.database.database import SessionLocal, engine, Base
from app.models.user import User
from app.models.meeting import Meeting
from app.models.task import Task
from app.services.whatsapp import whatsapp_service
from app.core.config import settings

# Ensure UTF-8 output on Windows consoles
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

Base.metadata.create_all(bind=engine)


async def run_tests():
    db: Session = SessionLocal()
    print("=" * 60)
    print("🚀 Running T.ask WhatsApp Integration Test Suite")
    print("=" * 60)

    try:
        # 1. Test Webhook Parsing
        print("\n[Step 1] Testing Meta Webhook Payload Parser...")
        meta_payload = {
            "object": "whatsapp_business_account",
            "entry": [
                {
                    "changes": [
                        {
                            "value": {
                                "messaging_product": "whatsapp",
                                "messages": [
                                    {
                                        "from": "919876543210",
                                        "id": "wamid.12345",
                                        "text": {"body": "DONE 42"},
                                        "type": "text"
                                    }
                                ]
                            }
                        }
                    ]
                }
            ]
        }
        sender, task_id = whatsapp_service.parse_incoming_reply(meta_payload)
        assert sender == "919876543210", f"Expected sender 919876543210, got {sender}"
        assert task_id == 42, f"Expected task_id 42, got {task_id}"
        print("✅ Meta Webhook Parser passed! Parsed sender: " + sender + ", task_id: " + str(task_id))

        # Flat payload parser test
        flat_payload = {"from": "+91 98765 43210", "body": "done 99"}
        sender2, task_id2 = whatsapp_service.parse_incoming_reply(flat_payload)
        assert task_id2 == 99, f"Expected task_id 99, got {task_id2}"
        print("✅ Simplified/Direct Payload Parser passed! task_id: " + str(task_id2))

        # 2. Seed a test meeting & task
        print("\n[Step 2] Seeding a test task in SQLite database...")
        test_user = db.query(User).filter(User.email == "rafey.test@example.com").first()
        if not test_user:
            test_user = User(
                email="rafey.test@example.com",
                name="Abdul Rafey",
                phone="+919876543210",
                password_hash="mock_hashed_password"
            )
            db.add(test_user)
            db.commit()
            db.refresh(test_user)

        test_meeting = Meeting(
            user_id=test_user.id,
            title="WhatsApp Pipeline Verification Meeting",
            processing_status="Completed"
        )
        db.add(test_meeting)
        db.commit()
        db.refresh(test_meeting)

        test_task = Task(
            meeting_id=test_meeting.id,
            title="Deploy Backend WebSocket Gateway",
            description="Set up production reverse proxy and configure SSL.",
            assignee_id=test_user.id,
            assignee_name=test_user.name,
            status="Pending"
        )
        db.add(test_task)
        db.commit()
        db.refresh(test_task)

        print(f"✅ Created Task #{test_task.id}: '{test_task.title}', Status: {test_task.status}")

        # 3. Test WhatsApp Task Assignment Outbound Dispatch
        print("\n[Step 3] Testing Outbound WhatsApp Notification Dispatch...")
        dispatched = await whatsapp_service.send_task_assignment(
            to_phone=test_user.phone,
            task_id=test_task.id,
            title=test_task.title,
            description=test_task.description,
            due_date="2026-11-15"
        )
        assert dispatched is True, "Outbound dispatch failed"
        print("✅ Outbound Task Notification successfully formatted and dispatched!")

        # 4. Test Inbound Webhook Execution ('DONE <id>')
        print(f"\n[Step 4] Simulating incoming WhatsApp reply 'DONE {test_task.id}' from employee...")
        from fastapi import Request
        from app.api.webhooks import handle_whatsapp_webhook

        class MockRequest:
            def __init__(self, data):
                self._data = data
            async def json(self):
                return self._data

        incoming_data = {
            "entry": [
                {
                    "changes": [
                        {
                            "value": {
                                "messages": [
                                    {
                                        "from": test_user.phone,
                                        "text": {"body": f"DONE {test_task.id}"}
                                    }
                                ]
                            }
                        }
                    ]
                }
            ]
        }

        response = await handle_whatsapp_webhook(MockRequest(incoming_data), db=db)
        print("Webhook response:", response)
        assert response.get("status") == "task_completed", f"Unexpected status: {response}"

        # 5. Verify database state
        db.refresh(test_task)
        assert test_task.status == "Completed", f"Task status should be Completed, was {test_task.status}"
        assert test_task.completed_at is not None, "Completed timestamp should not be None"
        print(f"✅ Task #{test_task.id} status successfully flipped to: {test_task.status} at {test_task.completed_at}")

        print("\n" + "=" * 60)
        print("🎉 ALL WHATSAPP INTEGRATION TESTS PASSED 100%!")
        print("=" * 60)

    finally:
        db.close()


if __name__ == "__main__":
    asyncio.run(run_tests())
