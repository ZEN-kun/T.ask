import asyncio
import os
import sys
from dotenv import load_dotenv

# Force utf-8 stdout for Windows PowerShell
sys.stdout.reconfigure(encoding='utf-8')

load_dotenv("c:/Users/hifzu/Downloads/T.ask/backend/.env")

from app.services.ai_processor import AIMeetingProcessor
from app.services.fuzzy_matcher import FuzzyNameMatcher

async def test_live_groq_pipeline():
    print("==================================================")
    print("Testing Model 2 (Groq AI) & Model 3 (Fuzzy Matcher)")
    print("==================================================")

    processor = AIMeetingProcessor()

    sample_transcript = """
    Manager: Good morning team. Let's do a quick sync on our sprint deliverables.
    Rafey: I have already started working on the authentication endpoints. I will complete the API testing by Friday, 2026-11-13.
    Hifzan: Sounds good. I will finalize the database schema migration and write the documentation before Monday, 2026-11-16.
    Najeeb: I'll assist Hifzan with the schema review.
    Manager: Perfect. We decided that after testing is done, we will deploy the release candidate to staging next Tuesday.
    """

    # Simulated registered employees in Firestore under this manager
    registered_participants = [
        {"uid": "emp_101", "name": "Abdul Rafey Mohammed", "phone": "+918008658174"},
        {"uid": "emp_102", "name": "Mohammed Hifzan", "phone": "+917981929830"},
        {"uid": "emp_103", "name": "Syed Najeeb Ullah Hussainy", "phone": "+917207300924"},
    ]

    attendee_names = [p["name"] for p in registered_participants]

    print("\n1. Sending transcript to Groq Cloud...")
    result = await processor.analyze_meeting_transcript(
        transcript=sample_transcript,
        attendees=attendee_names
    )

    print("\n[SUCCESS] Model 2 Analysis Completed!")
    print(f"Summary: {result.summary}")
    print(f"\nKey Points ({len(result.key_points)}):")
    for kp in result.key_points:
        print(f"  * {kp}")
    print(f"\nDecisions ({len(result.decisions)}):")
    for d in result.decisions:
        print(f"  * {d}")

    print(f"\n2. Running Model 3 (Fuzzy Matcher) on {len(result.tasks)} Extracted Tasks:")
    print("--------------------------------------------------")
    for i, task in enumerate(result.tasks, start=1):
        matched_emp, score, needs_clarification = FuzzyNameMatcher.match_name_to_participants(
            spoken_name=task.assignee_name,
            participants=registered_participants
        )

        resolved_name = matched_emp["name"] if matched_emp else "Unassigned / Ambiguous"
        emp_id = matched_emp["uid"] if matched_emp else "None"

        print(f"Task #{i}: {task.title}")
        print(f"  - Spoken Assignee : '{task.assignee_name}'")
        print(f"  - Model 3 Match   : {resolved_name} (UID: {emp_id})")
        print(f"  - Match Confidence: {score * 100:.0f}%")
        print(f"  - Due Date        : {task.due_date}")
        print(f"  - Needs Clarify   : {needs_clarification}")
        print()

if __name__ == "__main__":
    asyncio.run(test_live_groq_pipeline())
