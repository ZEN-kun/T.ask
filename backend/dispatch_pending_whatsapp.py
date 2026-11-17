"""
Script to dispatch any pending tasks to WhatsApp.
Can be run anytime after refreshing Meta WhatsApp access token.
"""
import sys
import asyncio
from app.database.database import SessionLocal
from app.models.task import Task
from app.models.meeting import Meeting
from app.models.user import User
from app.services.whatsapp import whatsapp_service

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")


async def dispatch_pending(meeting_id: int = None):
    db = SessionLocal()
    try:
        query = db.query(Task).filter(Task.status == "Pending")
        if meeting_id:
            query = query.filter(Task.meeting_id == meeting_id)

        tasks = query.order_by(Task.id.desc()).all()
        print(f"Found {len(tasks)} pending tasks.")

        # Known phone numbers from Firestore / registrations
        phone_map = {
            "zen": "917981929830",
            "mohammed hifzan": "917981929830",
            "hifzan": "917981929830",
            "syed najeeb": "917207300924",
            "najeeb": "917207300924",
            "syed najeeb ullah hussainy": "917207300924",
            "abdul rafey": "919876543210",
        }

        for t in tasks:
            assignee = (t.assignee_name or "").lower().strip()
            dest_phone = None
            for key, num in phone_map.items():
                if key in assignee or assignee in key:
                    dest_phone = num
                    break

            if not dest_phone:
                dest_phone = "917981929830"  # fallback to manager

            print(f"Dispatching Task #{t.id} ('{t.title}') -> {t.assignee_name} (+{dest_phone})...")
            success = await whatsapp_service.send_task_assignment(
                to_phone=dest_phone,
                task_id=t.id,
                title=t.title,
                description=t.description,
                due_date=t.due_date.isoformat() if t.due_date else None,
            )
            print(f"Result: {'✅ SENT' if success else '❌ FAILED'}")
    finally:
        db.close()


if __name__ == "__main__":
    m_id = int(sys.argv[1]) if len(sys.argv) > 1 else None
    asyncio.run(dispatch_pending(m_id))
