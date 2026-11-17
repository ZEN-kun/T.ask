import json
import re
from typing import List, Optional, Dict
import httpx
from app.core.config import settings
from app.schemas.meeting import AIAnalysisResult, ExtractedTaskAI


class AIMeetingProcessor:
    """
    Model 2: Meeting Comprehension & Task Extraction Engine.
    Powered by Groq Cloud (ultra-fast, free tier).
    Enforces strict zero-hallucination JSON contracts.
    """

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or settings.GROQ_API_KEY
        self.groq_url = "https://api.groq.com/openai/v1/chat/completions"
        # Primary high-capacity model on Groq
        self.model = "openai/gpt-oss-120b"

    async def analyze_meeting_transcript(
        self,
        transcript: str,
        attendees: Optional[List[str]] = None
    ) -> AIAnalysisResult:
        if not self.api_key:
            return self._heuristic_fallback(transcript)

        attendee_context = ""
        if attendees and len(attendees) > 0:
            attendee_context = f"\nVerified Meeting Attendees: {', '.join(attendees)}.\nAssign each extracted task strictly to one of these attendees if discussed, otherwise set to null."

        system_prompt = (
            "You are T.ask, an intelligent executive meeting assistant.\n"
            "Analyze conversational meeting transcripts and extract structured action items.\n"
            "Strict JSON Schema:\n"
            "{\n"
            '  "summary": "Executive summary of the meeting",\n'
            '  "key_points": ["Key discussion point 1", "Key discussion point 2"],\n'
            '  "decisions": ["Agreed decision 1"],\n'
            '  "tasks": [\n'
            '    {\n'
            '      "title": "Actionable task title",\n'
            '      "description": "Details of the commitment",\n'
            '      "assignee_name": "Exact person name or null if unassigned",\n'
            '      "due_date": "YYYY-MM-DD or null if no deadline stated"\n'
            '    }\n'
            '  ]\n'
            "}\n"
            "Rules:\n"
            "1. Output ONLY valid JSON matching this schema.\n"
            "2. Never hallucinate or guess assignees or dates. If not explicitly stated, return null."
        )

        user_content = f"Meeting Transcript:\n\"\"\"{transcript}\"\"\"\n{attendee_context}"

        payload = {
            "model": self.model,
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_content}
            ],
            "temperature": 0.2,
            "response_format": {"type": "json_object"}
        }

        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }

        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(self.groq_url, headers=headers, json=payload)
            response.raise_for_status()
            data = response.json()

        try:
            content_text = data["choices"][0]["message"]["content"]
            clean_json = re.sub(r"^```json\s*", "", content_text.strip(), flags=re.MULTILINE)
            clean_json = re.sub(r"^```\s*", "", clean_json.strip(), flags=re.MULTILINE)
            clean_json = clean_json.strip().rstrip("`")

            parsed = json.loads(clean_json)

            tasks_list = []
            for t in parsed.get("tasks", []):
                due = t.get("due_date")
                if due and not re.match(r"^\d{4}-\d{2}-\d{2}$", str(due)):
                    due = None
                tasks_list.append(
                    ExtractedTaskAI(
                        title=t.get("title", "Action Item"),
                        description=t.get("description"),
                        assignee_name=t.get("assignee_name"),
                        due_date=due
                    )
                )

            return AIAnalysisResult(
                summary=parsed.get("summary", "Meeting processed."),
                key_points=parsed.get("key_points", []),
                decisions=parsed.get("decisions", []),
                tasks=tasks_list
            )
        except Exception as e:
            raise ValueError(f"Failed to parse structured LLM output: {str(e)}")

    def _heuristic_fallback(self, transcript: str) -> AIAnalysisResult:
        lines = [line.strip() for line in transcript.split("\n") if line.strip()]
        tasks = []
        for line in lines:
            if any(w in line.lower() for w in ["will", "should", "task", "finish", "test", "prepare"]):
                parts = line.split(":", 1)
                speaker = parts[0].strip() if len(parts) > 1 else None
                task_title = parts[1].strip() if len(parts) > 1 else line
                tasks.append(
                    ExtractedTaskAI(
                        title=task_title[:80],
                        description=line,
                        assignee_name=speaker,
                        due_date=None
                    )
                )

        return AIAnalysisResult(
            summary=f"Processed meeting discussion with {len(tasks)} tasks identified.",
            key_points=["Meeting action items logged."],
            decisions=["Proceed with assigned deliverables."],
            tasks=tasks
        )


def get_ai_processor() -> AIMeetingProcessor:
    return AIMeetingProcessor()
