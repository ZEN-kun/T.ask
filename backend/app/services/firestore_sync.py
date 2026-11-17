import logging
from datetime import datetime, timezone
from typing import List, Dict, Any, Optional
import httpx

logger = logging.getLogger("task.firestore")

FIRESTORE_API_KEY = "AIzaSyBGQBs4EXb2K45MgmXDLdLQkVHaDvqwlSs"
PROJECT_ID = "task-db-346b7"
BASE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"


class FirestoreSyncService:
    @staticmethod
    def clean_phone(phone: str) -> str:
        """Ensures phone is formatted with country code (e.g. 917981929830)."""
        import re
        digits = re.sub(r"[^\d]", "", phone or "")
        if digits.startswith("0") and len(digits) == 11:
            digits = digits[1:]
        if len(digits) == 10 and digits[0] in "6789":
            digits = "91" + digits
        return digits

    async def get_all_users(self) -> List[Dict[str, Any]]:
        """
        Dynamically fetches all registered users from Cloud Firestore.
        Returns list of dicts: [{'name': '...', 'phone': '...', 'uid': '...', 'role': '...'}]
        """
        url = f"{BASE_URL}/users?key={FIRESTORE_API_KEY}"
        users = []
        try:
            async with httpx.AsyncClient(timeout=8.0) as client:
                r = await client.get(url)
                if r.status_code == 200:
                    data = r.json()
                    docs = data.get("documents", [])
                    for doc in docs:
                        fields = doc.get("fields", {})
                        name = fields.get("name", {}).get("stringValue", "").strip()
                        raw_phone = fields.get("phone", {}).get("stringValue", "").strip()
                        uid = fields.get("uid", {}).get("stringValue", "")
                        role = fields.get("role", {}).get("stringValue", "employee")

                        cleaned = self.clean_phone(raw_phone)
                        if name:
                            users.append({
                                "name": name,
                                "phone": cleaned,
                                "uid": uid,
                                "role": role,
                            })
                    logger.info(f"[Firestore] Fetched {len(users)} registered users dynamically.")
                else:
                    logger.warning(f"[Firestore] Failed to query users: {r.status_code} - {r.text}")
        except Exception as e:
            logger.error(f"[Firestore] Exception querying users: {e}")

        # Fallback to known team directory if Firestore query fails
        if not users:
            users = [
                {"name": "Abdul Rafey Mohammed", "phone": "918008658174", "role": "employee"},
                {"name": "Syed Najeeb Ullah Hussainy", "phone": "917207300924", "role": "employee"},
                {"name": "Zen", "phone": "917981929830", "role": "employee"},
                {"name": "Mohammed Hifzan", "phone": "917981929830", "role": "manager"},
            ]
        return users

    async def mark_task_completed(self, task_id: int) -> bool:
        """
        Updates task status to 'Completed' in Cloud Firestore so the Flutter app updates in real-time.
        """
        url = (
            f"{BASE_URL}/tasks/{task_id}?"
            f"updateMask.fieldPaths=status&updateMask.fieldPaths=completed_at&key={FIRESTORE_API_KEY}"
        )
        now_iso = datetime.now(timezone.utc).isoformat()
        payload = {
            "fields": {
                "status": {"stringValue": "Completed"},
                "completed_at": {"stringValue": now_iso},
            }
        }
        try:
            async with httpx.AsyncClient(timeout=8.0) as client:
                r = await client.patch(url, json=payload)
                if r.status_code == 200:
                    logger.info(f"[Firestore] Task #{task_id} successfully marked as Completed in Cloud Firestore!")
                    return True
                else:
                    logger.warning(f"[Firestore] Could not patch Task #{task_id}: {r.status_code} - {r.text}")
                    return False
        except Exception as e:
            logger.error(f"[Firestore] Exception updating Task #{task_id}: {e}")
            return False


    async def delete_meeting_and_sync(
        self,
        meeting_id: int,
        deleted_task_ids: List[int],
        resequenced_map: Dict[int, int]
    ):
        """
        Deletes meeting and associated tasks from Cloud Firestore, then updates
        any tasks whose ID changed due to re-sequencing.
        """
        async with httpx.AsyncClient(timeout=10.0) as client:
            # 1. Delete meeting document
            try:
                m_url = f"{BASE_URL}/meetings/{meeting_id}?key={FIRESTORE_API_KEY}"
                await client.delete(m_url)
                logger.info(f"[Firestore] Deleted meeting #{meeting_id}")
            except Exception as e:
                logger.warning(f"[Firestore] Error deleting meeting #{meeting_id}: {e}")

            # 2. Delete associated tasks
            for tid in deleted_task_ids:
                try:
                    t_url = f"{BASE_URL}/tasks/{tid}?key={FIRESTORE_API_KEY}"
                    await client.delete(t_url)
                    logger.info(f"[Firestore] Deleted task #{tid}")
                except Exception as e:
                    logger.warning(f"[Firestore] Error deleting task #{tid}: {e}")

            # 3. Re-sequence remaining tasks in Firestore
            await self._apply_resequencing(client, resequenced_map)

    async def delete_task_and_sync(
        self,
        deleted_task_id: int,
        resequenced_map: Dict[int, int]
    ):
        """
        Deletes a single task from Cloud Firestore and updates re-sequenced task IDs.
        """
        async with httpx.AsyncClient(timeout=10.0) as client:
            try:
                t_url = f"{BASE_URL}/tasks/{deleted_task_id}?key={FIRESTORE_API_KEY}"
                await client.delete(t_url)
                logger.info(f"[Firestore] Deleted task #{deleted_task_id}")
            except Exception as e:
                logger.warning(f"[Firestore] Error deleting task #{deleted_task_id}: {e}")

            await self._apply_resequencing(client, resequenced_map)

    async def _apply_resequencing(self, client: httpx.AsyncClient, resequenced_map: Dict[int, int]):
        """
        Transfers existing Firestore task documents from old IDs to new consecutive IDs.
        """
        if not resequenced_map:
            return

        for old_id, new_id in sorted(resequenced_map.items()):
            try:
                old_url = f"{BASE_URL}/tasks/{old_id}?key={FIRESTORE_API_KEY}"
                get_res = await client.get(old_url)
                if get_res.status_code == 200:
                    doc_data = get_res.json()
                    fields = doc_data.get("fields", {})

                    # Update internal id field if it exists
                    if "id" in fields:
                        fields["id"] = {"integerValue": str(new_id)}

                    new_url = f"{BASE_URL}/tasks/{new_id}?key={FIRESTORE_API_KEY}"
                    post_res = await client.patch(new_url, json={"fields": fields})
                    if post_res.status_code in (200, 201):
                        await client.delete(old_url)
                        logger.info(f"[Firestore] Re-sequenced task doc #{old_id} -> #{new_id}")
                    else:
                        logger.warning(f"[Firestore] Could not write new task #{new_id}: {post_res.text}")
            except Exception as e:
                logger.error(f"[Firestore] Error migrating task #{old_id} to #{new_id}: {e}")


firestore_sync = FirestoreSyncService()
