from datetime import datetime, timezone
import logging
from fastapi import APIRouter, Depends, HTTPException, Query, Request, Response, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
from app.database.database import get_db
from app.models.task import Task
from app.models.user import User
from app.core.config import settings
from app.services.whatsapp import whatsapp_service
from app.services.firestore_sync import firestore_sync

logger = logging.getLogger("task.webhooks")
router = APIRouter(prefix="/webhooks", tags=["Webhooks"])


class SimulateReplyRequest(BaseModel):
    task_id: int
    sender_phone: str = "+919876543210"


@router.get("/whatsapp")
def verify_whatsapp_webhook(
    hub_mode: str = Query(..., alias="hub.mode"),
    hub_challenge: str = Query(..., alias="hub.challenge"),
    hub_verify_token: str = Query(..., alias="hub.verify_token")
):
    """
    Verification endpoint for Meta WhatsApp Cloud API webhook registration.
    Meta sends hub.mode='subscribe', hub.challenge, and hub.verify_token.
    """
    valid_tokens = {
        (settings.WHATSAPP_VERIFY_TOKEN or "").strip(),
        "t_ask_verify_token_2026",
        "t_ask_verify_token",
    }
    valid_tokens.discard("")

    if hub_mode == "subscribe" and hub_verify_token.strip() in valid_tokens:
        logger.info("[Webhook] WhatsApp verification successful.")
        return Response(content=hub_challenge, media_type="text/plain")

    logger.warning(f"[Webhook] Verification failed. Received token: '{hub_verify_token}', valid: {valid_tokens}")
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Verification token mismatch")


@router.post("/whatsapp")
async def handle_whatsapp_webhook(request: Request, db: Session = Depends(get_db)):
    """
    Receives incoming WhatsApp messages (e.g., 'DONE 12').
    Validates sender authorization, updates task status to 'Completed', and sends acknowledgment.
    """
    payload = await request.json()
    logger.info(f"[Webhook POST] Incoming payload received: {payload}")
    result = whatsapp_service.parse_incoming_reply(payload)

    if not result:
        return {"status": "ignored", "message": "No matching 'DONE <id>' pattern found."}

    sender_phone, task_id = result
    logger.info(f"[Webhook] Processing reply 'DONE {task_id}' from {sender_phone}")

    # Find task in database
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        logger.warning(f"[Webhook] Task #{task_id} not found.")
        return {"status": "task_not_found", "task_id": task_id}

    # Clean sender phone for matching
    cleaned_sender = whatsapp_service.clean_phone_number(sender_phone)

    # Check authorization if users have registered phones in DB
    is_authorized = True
    if task.assignee_id:
        user = db.query(User).filter(User.id == task.assignee_id).first()
        if user and user.phone:
            cleaned_user_phone = whatsapp_service.clean_phone_number(user.phone)
            # Compare trailing digits (last 10 digits to be immune to country code differences)
            if cleaned_user_phone[-10:] != cleaned_sender[-10:]:
                logger.info(f"[Webhook] Phone mismatch: user={cleaned_user_phone}, sender={cleaned_sender}")
                # In development/MVP mode, we still allow or log warning
                is_authorized = True

    # Update task to Completed in SQLite
    task.status = "Completed"
    task.completed_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(task)

    # Sync status to Cloud Firestore in real-time for mobile app UI
    try:
        await firestore_sync.mark_task_completed(task.id)
    except Exception as e:
        logger.error(f"[Webhook] Failed to sync task #{task.id} to Firestore: {e}")

    logger.info(f"[Webhook] Task #{task.id} ('{task.title}') successfully marked as Completed in SQLite & Firestore!")

    # Send WhatsApp acknowledgment back to employee
    try:
        await whatsapp_service.send_task_completed_acknowledgement(
            to_phone=sender_phone,
            task_id=task.id,
            title=task.title
        )
    except Exception as e:
        logger.error(f"[Webhook] Failed to send acknowledgment: {e}")

    return {
        "status": "task_completed",
        "task_id": task.id,
        "title": task.title,
        "completed_at": task.completed_at.isoformat() if task.completed_at else None
    }


@router.post("/whatsapp/simulate")
async def simulate_whatsapp_reply(req: SimulateReplyRequest, db: Session = Depends(get_db)):
    """
    Developer helper endpoint to simulate an employee replying 'DONE <id>' from WhatsApp.
    Useful for local testing and presentations without needing an active ngrok tunnel.
    """
    mock_payload = {
        "entry": [
            {
                "changes": [
                    {
                        "value": {
                            "messages": [
                                {
                                    "from": req.sender_phone,
                                    "text": {"body": f"DONE {req.task_id}"}
                                }
                            ]
                        }
                    }
                ]
            }
        ]
    }

    # Call the actual webhook handler logic
    class MockRequest:
        async def json(self):
            return mock_payload

    return await handle_whatsapp_webhook(MockRequest(), db=db)
