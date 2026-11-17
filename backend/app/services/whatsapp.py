import logging
import os
import re
from typing import Optional, Dict, Any, Tuple
from dotenv import dotenv_values
import httpx
from app.core.config import settings

logger = logging.getLogger("task.whatsapp")
logging.basicConfig(level=logging.INFO)


class WhatsAppService:
    def __init__(self):
        self.access_token = settings.WHATSAPP_ACCESS_TOKEN
        self.phone_number_id = settings.WHATSAPP_PHONE_NUMBER_ID
        self.verify_token = settings.WHATSAPP_VERIFY_TOKEN or "t_ask_verify_token_2026"

    def _refresh_credentials(self):
        """Hot-reloads credentials from .env so token updates apply without restarting Uvicorn."""
        env_path = os.path.join(os.getcwd(), ".env")
        if os.path.exists(env_path):
            vals = dotenv_values(env_path)
            if vals.get("WHATSAPP_ACCESS_TOKEN"):
                self.access_token = vals["WHATSAPP_ACCESS_TOKEN"].strip()
            if vals.get("WHATSAPP_PHONE_NUMBER_ID"):
                self.phone_number_id = vals["WHATSAPP_PHONE_NUMBER_ID"].strip()
            if vals.get("WHATSAPP_VERIFY_TOKEN"):
                self.verify_token = vals["WHATSAPP_VERIFY_TOKEN"].strip()

    @staticmethod
    def clean_phone_number(phone: str) -> str:
        """Strips symbols and ensures clean digit string with country code for WhatsApp API (e.g. 917981929830)."""
        cleaned = re.sub(r"[^\d]", "", phone or "")
        if cleaned.startswith("0") and len(cleaned) == 11:
            cleaned = cleaned[1:]
        # Auto-prepend India country code (91) for standard 10-digit mobile numbers
        if len(cleaned) == 10 and cleaned[0] in "6789":
            cleaned = "91" + cleaned
        return cleaned

    async def send_raw_message(self, to_phone: str, message_body: str) -> bool:
        """
        Sends a WhatsApp text message. If API credentials are not yet configured,
        logs the message body cleanly in simulation mode and returns True.
        """
        self._refresh_credentials()
        cleaned_phone = self.clean_phone_number(to_phone)
        if not cleaned_phone:
            logger.warning("[WhatsApp] Cannot send message: empty or invalid recipient phone number.")
            return False

        if not self.access_token or not self.phone_number_id:
            logger.info(
                f"\n--- [WhatsApp SIMULATOR: Outbound to +{cleaned_phone}] ---\n"
                f"{message_body}\n"
                f"----------------------------------------------------------"
            )
            return True

        url = f"https://graph.facebook.com/v20.0/{self.phone_number_id}/messages"
        headers = {
            "Authorization": f"Bearer {self.access_token}",
            "Content-Type": "application/json"
        }
        payload = {
            "messaging_product": "whatsapp",
            "to": cleaned_phone,
            "type": "text",
            "text": {"body": message_body}
        }

        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                res = await client.post(url, headers=headers, json=payload)
                if res.status_code in (200, 201):
                    logger.info(f"[WhatsApp] Successfully dispatched to +{cleaned_phone}")
                    return True
                else:
                    logger.error(f"[WhatsApp API Error] HTTP {res.status_code}: {res.text}")
                    return False
        except Exception as e:
            logger.error(f"[WhatsApp Network Exception] Failed to send message to +{cleaned_phone}: {e}")
            return False

    async def send_task_assignment(
        self,
        to_phone: str,
        task_id: int,
        title: str,
        description: Optional[str] = None,
        due_date: Optional[str] = None
    ) -> bool:
        """
        Sends task assignment notification via WhatsApp Cloud API matching exact T.ask specs:
        *T.ask*
        _What are your task?_

        📋 *New Task Assigned*
        *Task:* ...
        *Description:* ...
        *Due:* ...
        *Task ID:* <id>
        To mark completed, reply:
        `DONE <id>`
        """
        message_body = (
            f"*T.ask*\n"
            f"_What are your Tasks?_\n\n"
            f"📋 *New Task Assigned*\n\n"
            f"*Task:* {title}\n"
            f"*Description:* {description or 'N/A'}\n"
            f"*Due:* {due_date or 'No deadline specified'}\n\n"
            f"*Task ID:* {task_id}\n\n"
            f"To mark completed, reply:\n"
            f"`DONE {task_id}`"
        )
        return await self.send_raw_message(to_phone, message_body)

    async def send_task_completed_acknowledgement(
        self,
        to_phone: str,
        task_id: int,
        title: str
    ) -> bool:
        """
        Sends an instant WhatsApp confirmation back when assignee replies 'DONE <task_id>'.
        """
        message_body = (
            f"*T.ask*\n"
            f"_What are your Tasks?_\n\n"
            f"✅ *Task #{task_id} Completed!*\n\n"
            f"*Task:* {title}\n"
            f"*Status:* Completed\n\n"
            f"Great job! Your manager's dashboard and records have been updated in real-time."
        )
        return await self.send_raw_message(to_phone, message_body)

    def parse_incoming_reply(self, payload: Dict[str, Any]) -> Optional[Tuple[str, int]]:
        """
        Extracts sender phone and task_id from incoming WhatsApp webhook if body matches 'DONE <id>'.
        Supports both Meta Cloud API webhook format and simplified direct/test payloads.
        Returns (sender_phone, task_id) or None.
        """
        try:
            # 1. Check for Meta Cloud API nested structure
            if "entry" in payload and payload["entry"]:
                entry = payload["entry"][0]
                changes = entry.get("changes", [])
                if changes:
                    value = changes[0].get("value", {})
                    messages = value.get("messages", [])
                    if messages:
                        msg = messages[0]
                        sender = msg.get("from")
                        body = msg.get("text", {}).get("body", "").strip()
                        match = re.search(r"\bDONE\s*#?\s*(\d+)\b", body, re.IGNORECASE)
                        if match and sender:
                            return sender, int(match.group(1))

            # 2. Check for flat / direct test payload (e.g. {"from": "91...", "body": "DONE 10"})
            sender = payload.get("from") or payload.get("sender") or payload.get("phone")
            body = (
                payload.get("body")
                or payload.get("text")
                or payload.get("message")
                or ""
            )
            if isinstance(body, dict):
                body = body.get("body", "")
            body = str(body).strip()

            match = re.search(r"\bDONE\s*#?\s*(\d+)\b", body, re.IGNORECASE)
            if match and sender:
                return str(sender), int(match.group(1))

        except Exception as e:
            logger.error(f"[WhatsApp Parse Error] Could not parse payload: {e}")
            return None

        return None


whatsapp_service = WhatsAppService()
