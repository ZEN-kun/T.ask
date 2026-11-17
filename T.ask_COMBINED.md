# T.ask — Combined Project Specification & Development Guide

> **Project Name:** T.ask (Automated Task Assigner and Manager)
> **Motto:** *What are your task?* (keep this wording exactly)
> **Type:** AI-powered meeting-to-task management app
> **Primary Platform:** Flutter (mobile) + Python backend
> **Purpose of this file:** Single source of truth for Antigravity / any coding agent

The period in `T.ask` is part of the visual identity.

---

# 0. Decisions Already Made (read first)

These resolve conflicts between the earlier documents. Do not re-debate them.

| Topic | Decision |
|---|---|
| Backend framework | **FastAPI** (Python). Easier AI integration, typed schemas. |
| Database | **SQLite** for prototype, **PostgreSQL** for final. |
| State management | **Riverpod** only. Do not mix frameworks. |
| Scheduling | **APScheduler** for prototype, **Celery + Redis** only if scaled later. |
| AI orchestration | **Gemini** for analysis. **LangChain** is allowed for structured output/prompt management, but only add it if it simplifies things. Don't overengineer the MVP. |
| Scope | Build **Phase 1 (MVP)** first. Phase 2 and Phase 3 are planned, not to be built early. |
| Auth roles | MVP = simple login. Role-based access (Admin/Manager/Employee) comes in Phase 2, but design the user model so roles can be added. |

---

# 1. Project Overview

T.ask converts meeting discussions into structured, actionable, trackable tasks.

**Core workflow:**

```text
Meeting → Transcription → AI Understanding → Summary → Task Extraction
→ Assignment → Notification → Tracking → Completion
```

**Full long-term lifecycle:**

```text
Meeting → Understanding → Task Extraction → Validation → Assignment →
Notification → Tracking → Reminder → Escalation → Follow-up → Analytics
```

Users upload meeting audio or a transcript through the Flutter app. Audio is transcribed with **AssemblyAI**. The transcript is analysed by **Google Gemini** (optionally with **LangChain**) to produce a summary, key points, decisions, and tasks with assignees and deadlines. Tasks are stored in a database, shown in the app, and sent to assignees via **WhatsApp**, where they can reply to mark tasks done.

T.ask is not just a transcription tool. The goal is:

> **Turn conversations into action.**

After every meeting it answers: **What happened? What needs to happen? Who needs to do it?**

---

# 2. Problem Statement

Meetings produce decisions, responsibilities and deadlines, but:

- People don't take complete notes.
- Tasks are created manually after meetings.
- Responsibilities and deadlines are unclear or forgotten.
- Managers must manually follow up.
- Task status is scattered across chats, notes and spreadsheets.
- Employees miss reminders; delays are discovered too late.
- Work is unevenly distributed.
- Previous meeting decisions are lost in follow-up meetings.
- No reliable record of who created, changed, reassigned or completed a task.

T.ask automatically turns meeting discussions into structured tasks and manages them across their lifecycle.

---

# 3. Objectives

- Automate meeting-to-task conversion.
- Reduce manual documentation.
- Minimise missed responsibilities and forgotten deadlines.
- Improve accountability.
- Provide notifications, reminders, and escalation.
- Help managers track tasks and workload.
- Flag incomplete/ambiguous tasks instead of guessing.
- Improve AI reliability via validation and confidence scoring.
- Keep meeting and task history.
- Provide analytics and follow-up continuity.
- Keep a full audit trail.

**Target users:** corporate teams, startups, project/dev/research teams, managers, HR, educational institutions, student organizations, small and medium businesses.

---

# 4. Scope by Phase

## Phase 1 — MVP (build this first)

- Flutter app
- Register / login / logout
- Dashboard
- Meeting upload (audio + transcript)
- Audio transcription (AssemblyAI)
- Gemini meeting analysis → summary, key points, decisions, tasks
- Task list, task details, status change (Pending → Completed)
- Database
- Basic FastAPI backend
- Basic WhatsApp: send task + `DONE <task_id>` reply (can land late in MVP)

## Phase 2 — Intelligent Features

- Role-based access (Admin / Manager / Employee)
- Task clarification (missing assignee/deadline, ambiguity)
- Confidence scores
- Manager review/confirmation before assignment
- Automatic deadline reminders
- Overdue detection + escalation
- Employee dashboard and manager dashboard
- Meeting history (searchable)
- Workload-aware assignment (recommendations only)
- Analytics dashboard
- Audit trail
- Priority field
- Follow-up meeting intelligence

## Phase 3 — Future

- Real-time transcription, live task extraction
- Voice identification for participant mapping
- Email, push, Slack, Microsoft Teams notifications
- Google Calendar / Outlook integration
- Chatbot to query meetings, semantic search
- Task dependencies, recurring tasks
- AI priority prediction, performance forecasting
- Multilingual support
- Video processing, in-app recording
- Local/private AI, on-device processing
- Organization accounts, team workspaces
- Data retention controls, encryption at rest

**Do not let Phase 2/3 distract from Phase 1.**

---

# 5. Core Product Identity

- **Name:** T.ask
- **Motto:** "What are your task?"
- **Concept:** The name is a simple question. T.ask answers it by identifying tasks that come out of meetings and showing who needs to do what.

---

# 6. Processing Pipeline

```text
User
  |
  v
Flutter App
  |
  v
Backend API
  |
  +--> Audio file
  |       |
  |       v
  |   Speech-to-Text (AssemblyAI)
  |       |
  |       v
  |   Transcript
  |
  +--> Transcript file (skip STT)
  |
  v
AI Processing (Gemini [+ LangChain])
  |
  +--> Summary
  +--> Key Points
  +--> Decisions
  +--> Tasks (title, description, assignee, due date, status)
  |
  v
Validation
  |
  v
Database
  |
  +--> Flutter Dashboard
  +--> WhatsApp Notification
```

**Extended workflow (Phase 2):**

```text
User Login → Role Verification → Upload Audio/Transcript
→ (Audio? AssemblyAI : use transcript)
→ Gemini + LangChain → Summary, Key Points, Decisions, Tasks,
  Assignees, Deadlines, Confidence Scores
→ Task Clarification / Validation
→ Workload Analysis
→ Manager Review / Confirmation
→ Store Meeting + Tasks
→ WhatsApp Notification
→ Employee Dashboard
→ Status Monitoring
→ Deadline Reminder
→ Completed?  Yes → Close
              No  → Deadline crossed? → Mark Overdue → Escalate to Manager/HR → Audit Trail
→ Analytics → Meeting History → Follow-Up Intelligence
```

---

# 7. Features

## 7.1 User Authentication (Phase 1)

- Register, login, logout, profile.
- Users only access info relevant to them.
- Start simple, but design so secure production auth (JWT, hashed passwords with bcrypt/Werkzeug-style hashing) can be added.

## 7.2 Dashboard (Phase 1)

Shows: total meetings, total tasks, pending, completed, overdue, upcoming deadlines, recent meetings.

```text
------------------------------------------------
 T.ask
 What are your task?

 [Total Tasks] [Pending] [Completed] [Overdue]

 Upcoming Tasks
 ┌────────────────────────────────────────────┐
 │ Prepare project report       Due: 12 Oct  │
 │ Assigned: Alex              Pending       │
 └────────────────────────────────────────────┘

 Recent Meetings
 ┌────────────────────────────────────────────┐
 │ Project Review              07 Oct 2026   │
 │ 8 tasks extracted                         │
 └────────────────────────────────────────────┘
------------------------------------------------
```

## 7.3 Meeting Upload (Phase 1)

Inputs: audio file, existing transcript. (Video and in-app recording are later.)

Meeting metadata: title, date/time, participants, organizer, department/project, uploaded file, processing status.

## 7.4 Speech-to-Text (Phase 1)

- Use **AssemblyAI**.
- Output: full transcript, speaker labels and timestamps where available.
- **Flutter must never hold the AssemblyAI key.**

```text
Flutter → upload → Backend → AssemblyAI → Transcript → Backend → Flutter
```

Implement behind an interface so it can be swapped:

```text
SpeechToTextService
    +-- AssemblyAIService
    +-- FutureLocalSTTService
```

## 7.5 AI Meeting Analysis (Phase 1)

Gemini generates: summary, key points, decisions, tasks, assignees, deadlines. (Phase 2 adds priority, dependencies, ambiguity flags, confidence.)

Always **preserve the original transcript** so AI output can be reviewed against it.

## 7.6 Task Extraction (Phase 1)

Example: *"Rafey will complete the API integration by Friday."*

```text
Task: Complete API integration
Assignee: Rafey
Deadline: Friday
Source: Meeting transcript
Status: Pending
```

## 7.7 Task Management (Phase 1)

Minimum lifecycle: `Pending → Completed`.

Display per task: title, description, assignee, due date, status, source meeting.

## 7.8 WhatsApp Integration (Phase 1 late / Phase 2)

Use **WhatsApp Cloud API** (or supported provider). Example message:

```text
T.ask

New Task Assigned

Task: Complete API testing
Description: Finish testing the authentication API.
Due: 10 Oct 2026

Task ID: 12

Reply:
DONE 12
```

Flow:

```text
T.ask Backend → WhatsApp Cloud API → Assigned User
User replies "DONE 12" → Webhook → Backend
→ Validate task ID + sender → Update DB → Task = Completed
```

Rules:
- Credentials stay on the backend only.
- Validate webhook requests.
- Validate task IDs **and that the sender is authorized for that task** before changing status.

## 7.9 Role-Based Access (Phase 2)

- **Admin:** manage users/employees, settings, view all meetings/tasks/analytics, audit logs.
- **Manager / Team Lead:** upload meetings, review extracted tasks, assign/reassign, view workload, track progress, team analytics, receive overdue escalations.
- **Employee:** view assigned tasks, deadlines, update status, receive reminders, view completed/pending work.

## 7.10 Task Clarification (Phase 2)

If info is missing (e.g. *"Complete the report soon."*), **flag it, don't invent it.**

Clarification states: missing assignee, missing deadline, ambiguous description, multiple possible assignees, unclear date, uncertain dependency.

Manager corrects/confirms before assignment.

## 7.11 Confidence Score (Phase 2)

| Field | Extracted Value | Confidence |
|---|---|---:|
| Task | Prepare financial report | 96% |
| Assignee | Ahmed | 91% |
| Deadline | 12 October | 73% |

Low-confidence fields are auto-flagged for user verification.

## 7.12 Automatic Reminders (Phase 2)

- 24 hours before deadline
- On the deadline day
- Configurable extras

Delivered via WhatsApp first; later email, push, Slack, Teams.

## 7.13 Overdue Escalation (Phase 2)

If a deadline passes without completion:

1. Mark task overdue.
2. Notify assigned employee.
3. Notify manager / HR / team lead.
4. Record in audit trail.
5. Show in manager's overdue dashboard.

## 7.14 Employee Dashboard (Phase 2)

Assigned, pending, in-progress, completed, overdue tasks; upcoming deadlines; priority tasks; recent notifications; direct status updates.

## 7.15 Meeting History (Phase 2)

Searchable record: title, date, participants, audio, transcript, summary, key points, decisions, extracted tasks, completion info.

## 7.16 Analytics Dashboard (Phase 2)

Total / completed / pending / overdue tasks, completion %, average completion time, per-employee distribution and workload, tasks per meeting, deadline compliance rate, completion trends, department performance.

## 7.17 Workload-Aware Assignment (Phase 2)

Before assigning, consider: active tasks, upcoming deadlines, overdue tasks, priority, estimated workload.

Example alert:
> "This employee currently has 8 active tasks and 3 upcoming deadlines. Consider reassignment."

**Recommend only. Never auto-reassign unless explicitly configured.**

## 7.18 Follow-Up Meeting Intelligence (Phase 2)

For related meetings, surface from earlier ones: assigned/completed/pending/overdue tasks, unresolved decisions, previous deadlines, points needing follow-up.

Example: *"The database schema task from the previous meeting is still pending."*

## 7.19 Audit Trail (Phase 2)

Events: meeting uploaded, transcript generated, AI analysis completed, task created/edited/assigned/reassigned, deadline modified, status changed, task completed, reminder sent, task escalated, user login, role changed.

Record: user, action, object affected, previous value, updated value, date, time.

---

# 8. AI Output Contract

AI must return **structured JSON**, not free text. The backend validates it before saving. **Never blindly trust AI output.**

## Phase 1 contract

```json
{
  "summary": "The team discussed the upcoming product release and assigned development and documentation tasks.",
  "key_points": [
    "Product release is planned for next week.",
    "Documentation must be completed before release."
  ],
  "decisions": [
    "The release will proceed after final testing."
  ],
  "tasks": [
    {
      "title": "Complete API testing",
      "description": "Finish testing the authentication and task APIs.",
      "assignee_name": "Alex",
      "due_date": "2026-10-10"
    },
    {
      "title": "Prepare documentation",
      "description": "Prepare the user documentation for the release.",
      "assignee_name": "Sarah",
      "due_date": "2026-10-11"
    }
  ]
}
```

## Phase 2 additional task fields

```text
priority
confidence_score (per field or overall)
clarification_required (bool) + clarification_reason
meeting_id
created_at
completed_at
```

## Reliability rules

- Unknown assignee → `assignee = null` (never invent a person).
- No due date mentioned → `due_date = null` (never invent a deadline).
- Validate: required fields, date formats, task structure, assignee existence where possible, duplicate tasks, hallucinated values.

---

# 9. Task Status Model

**Phase 1:**

```text
Pending → Completed
```

**Phase 2 full model:**

```text
Extracted
    ↓
Needs Review
    ↓
Confirmed
    ↓
Assigned
    ↓
Pending
    ↓
In Progress
   /       \
Completed  Overdue
              ↓
          Escalated
              ↓
          Completed
```

Also allowed later: `Cancelled`.

---

# 10. System Architecture

## 10.1 Presentation Layer — Flutter

Authentication, meeting upload, meeting history, dashboards, task status updates, analytics visualisation, notifications, clarification UI.

## 10.2 Backend Layer — FastAPI (Python)

Handles all sensitive operations: REST API, auth, authorization, meetings, employees, tasks, DB access, AI service calls, notification logic, reminder scheduling, escalation, analytics APIs, audit logging.

## 10.3 AI / NLP Layer

- **AssemblyAI:** transcription, speaker-aware output, timestamps.
- **Google Gemini:** understanding, summary, key points, decisions, task/assignee/deadline extraction, ambiguity detection.
- **LangChain (optional):** workflow orchestration, prompt management, structured output, multi-step processing, context management, retrieval of historical meetings for follow-up intelligence.

## 10.4 Data Layer

Users, employees, roles, meetings, transcripts, summaries, tasks, deadlines, statuses, notifications, escalations, analytics, audit logs.

SQLite (prototype) → PostgreSQL (final).

## 10.5 Notification & Automation Layer

WhatsApp Cloud API; APScheduler (prototype) or Celery + Redis (scale) for reminders, overdue checks, escalations, follow-up alerts.

---

# 11. Database Entities

## Phase 1

```text
users
-----
id, name, email, phone, password_hash, created_at

meetings
--------
id, user_id, title, file_url, transcript, summary,
processing_status, created_at, processed_at

tasks
-----
id, meeting_id, title, description,
assignee_id, assignee_name, due_date, status,
created_at, completed_at

meeting_key_points
------------------
id, meeting_id, content

meeting_decisions
-----------------
id, meeting_id, content
```

## Phase 2 additions

```text
users:   + role, employee_id

employees
---------
employee_id, name, department, designation, email,
whatsapp_number, manager_id, active

meeting_participants
--------------------
meeting_id, employee_id

tasks:   + priority, confidence_score, clarification_required, updated_at

notifications
-------------
notification_id, task_id, employee_id, notification_type,
message, sent_at, delivery_status

escalations
-----------
escalation_id, task_id, escalated_to, reason, timestamp

audit_logs
----------
audit_id, user_id, action, entity_type, entity_id,
old_value, new_value, timestamp
```

---

# 12. API Endpoints (starting contract, may evolve)

```text
Auth
POST   /api/auth/register
POST   /api/auth/login
GET    /api/auth/me

Meetings
POST   /api/meetings
GET    /api/meetings
GET    /api/meetings/{meeting_id}
POST   /api/meetings/{meeting_id}/process

Tasks
GET    /api/tasks
GET    /api/tasks/{task_id}
POST   /api/tasks
PATCH  /api/tasks/{task_id}
DELETE /api/tasks/{task_id}

Webhooks
POST   /api/webhooks/whatsapp
```

Phase 2 will add: employees, analytics, audit logs, notifications, escalations.

---

# 13. Backend Structure

```text
backend/
│
├── app/
│   ├── main.py
│   │
│   ├── api/
│   │   ├── auth.py
│   │   ├── meetings.py
│   │   ├── tasks.py
│   │   └── webhooks.py
│   │
│   ├── models/
│   │   ├── user.py
│   │   ├── meeting.py
│   │   └── task.py
│   │
│   ├── schemas/
│   │   ├── meeting.py
│   │   └── task.py
│   │
│   ├── services/
│   │   ├── transcription.py
│   │   ├── ai_processor.py
│   │   ├── whatsapp.py
│   │   └── task_manager.py
│   │
│   ├── database/
│   │   ├── database.py
│   │   └── models.py
│   │
│   └── core/
│       ├── config.py
│       └── security.py
│
└── requirements.txt
```

---

# 14. Flutter Structure

Feature-oriented, modular.

```text
lib/
│
├── main.dart
│
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme.dart
│
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── utils/
│   └── widgets/
│
├── features/
│   ├── auth/       (data, models, screens, widgets)
│   ├── dashboard/  (models, screens, widgets)
│   ├── meetings/   (data, models, screens, widgets)
│   ├── tasks/      (data, models, screens, widgets)
│   └── profile/    (screens, widgets)
│
└── services/
    ├── api_service.dart
    ├── auth_service.dart
    └── storage_service.dart
```

Structure may adjust, but keep it modular.

## Screens

1. **Splash** — shows `T.ask` + `What are your task?`, then routes to auth or dashboard.
2. **Login** — email, password; login / create account.
3. **Dashboard** — stats, upcoming tasks, recent meetings, quick "process meeting" action.
4. **Meetings list** — title, date, task count, processing status.
5. **Create/Process Meeting** — Upload Audio / Upload Transcript (Video later) → Process. Show progress:
   `Uploading... → Transcribing... → Understanding meeting... → Extracting tasks... → Saving results... → Completed`
6. **Meeting Details** — title, date, summary, key points, decisions, transcript, extracted tasks.
7. **Tasks** — All / Pending / Completed / Overdue. Card:
   ```text
   Complete API testing

   Assigned to: Alex
   Due: 10 Oct 2026

   Status: Pending
   ```
8. **Task Details** — title, description, assignee, due date, status, source meeting, created date, completion date; authorized users can update status.

Phase 2 screens: employee dashboard, manager dashboard, clarification/review screen, analytics, overdue dashboard, audit log viewer.

---

# 15. Tech Stack

| Component | Technology |
|---|---|
| Mobile app | Flutter (Dart) |
| State management | Riverpod |
| Backend | FastAPI (Python) |
| REST API | FastAPI endpoints |
| Speech-to-text | AssemblyAI |
| Generative AI | Google Gemini |
| AI orchestration | LangChain (optional) |
| Database | SQLite (prototype) / PostgreSQL (final) |
| Auth | JWT |
| Password security | bcrypt / equivalent |
| Messaging | WhatsApp Cloud API |
| Scheduling | APScheduler → Celery + Redis |
| Charts | Flutter chart library |
| File storage | Local / cloud storage |
| Version control | Git + GitHub |

## Flutter dependencies (add only when needed)

```text
State:      flutter_riverpod
Networking: dio
Routing:    go_router
Models:     json_serializable, freezed (optional)
Files:      file_picker
Secure:     flutter_secure_storage
Local DB:   drift / sqflite / hive (only if required)
```

Do not add everything at the start. Choose the minimum for the current milestone.

---

# 16. Environment Variables

Never hard-code secrets. Backend `.env`:

```env
DATABASE_URL=
GEMINI_API_KEY=
ASSEMBLYAI_API_KEY=

WHATSAPP_ACCESS_TOKEN=
WHATSAPP_PHONE_NUMBER_ID=
WHATSAPP_VERIFY_TOKEN=

JWT_SECRET=
```

Flutter must not contain any server-side secrets. Never commit `.env`.

---

# 17. UI/UX Principles

Modern, clean, professional, minimal, productivity-focused. Avoid unnecessary animation and clutter.

1. Dashboard understood immediately.
2. Meeting processing clearly shows progress.
3. AI-generated info is easy to scan.
4. Task statuses are obvious.
5. Deadlines are visually noticeable.
6. Errors explain what went wrong.
7. Every network operation has a loading state.

---

# 18. Error Handling

| Case | Message |
|---|---|
| Network failure | "Unable to connect to the server. Please try again." |
| Invalid file | "This file format is not supported." |
| Transcription failure | "We couldn't transcribe this recording. Please try again." |
| AI failure | "The meeting could not be analyzed. Please try again." |
| Task not found | "Task not found." |

Errors must **never** expose API keys, stack traces, DB credentials, or internal server paths.

Every network-dependent screen handles: **Loading, Success, Empty, Error**.

---

# 19. Security Requirements

**Never:**
- Store API keys in Flutter.
- Commit `.env` files.
- Expose DB credentials.
- Trust AI-generated user identity without validation.
- Let users modify another user's tasks.
- Trust WhatsApp task IDs without checking authorization.

**Must:**
- Validate all API input.
- Authenticate users and authorize task changes.
- Validate AI JSON.
- Validate webhook requests.
- Use HTTPS in production.
- Keep secrets in env vars or a secret manager.

---

# 20. Privacy

Meeting transcripts can contain sensitive company data. Privacy-first for the MVP:

- HTTPS everywhere.
- Never expose transcripts publicly.
- Restrict DB access.
- Avoid logging full transcripts and API keys.
- Allow deletion of meeting data in a future version.

Future: local transcription, local AI, on-device processing, retention controls, encryption at rest.

---

# 21. Milestones

| # | Milestone | Deliverables |
|---|---|---|
| 1 | Foundation | Flutter + backend projects, Git repo, architecture, env config, theme, routing |
| 2 | Authentication | Login, register, logout, auth state |
| 3 | Dashboard | UI, counters, recent meetings, upcoming tasks |
| 4 | Meeting management | Upload audio, create meeting, list, details |
| 5 | Transcription | Audio → Backend → AssemblyAI → Transcript |
| 6 | AI processing | Transcript → Gemini → JSON → Validation → DB |
| 7 | Task management | List, details, filtering, status updates, due dates, assignees |
| 8 | WhatsApp | Task notification, webhook, `DONE <task_id>`, auto-complete |
| 9 | Testing | Auth, upload, transcription, AI extraction, invalid AI output, DB, assignment, webhook, authorization |
| 10 | Deployment | Flutter → Android APK / Web; FastAPI → cloud server; PostgreSQL; Gemini + AssemblyAI + WhatsApp Cloud API |

Phase 2 milestones begin only after Milestone 10 works end to end.

## Suggested development order

```text
1.  Initialize Flutter project
2.  Create folder architecture
3.  Create theme and routing
4.  Build authentication screens
5.  Build dashboard
6.  Build meetings screens
7.  Build tasks screens
8.  Create backend
9.  Connect Flutter to backend
10. Implement database
11. Implement file upload
12. Implement transcription
13. Implement Gemini processing
14. Validate and store tasks
15. Display generated tasks
16. Implement WhatsApp
17. Implement webhook
18. Add error handling
19. Add tests
20. Prepare deployment
```

**Do not jump into AI integration before the basic app architecture works.**

---

# 22. Testing Strategy

**Unit:** task parsing, date parsing, status transitions, AI response validation, API model serialization.

**Widget:** login screen, dashboard, task card, meeting card, task status UI.

**Integration (full flow):**

```text
Login → Upload Meeting → Process → Transcript → AI Analysis
→ Task Created → Task Displayed → Task Completed
```

---

# 23. Coding Agent Rules (Antigravity / any agent)

1. **Understand before changing.** Inspect structure, dependencies, and how the current feature works. Avoid unnecessary rewrites.
2. **Small changes.** After each meaningful change: format, run static analysis, run relevant tests, fix errors before moving on.
3. **Don't invent APIs.** Use official docs for Gemini, AssemblyAI, WhatsApp Cloud API, and any other external service.
4. **Never hard-code secrets** (API keys, tokens, passwords, JWT secrets, DB passwords).
5. **Preserve existing work.** Don't delete working functionality just to simplify.
6. **Explain major decisions:** what changed, why, which files, how it was tested.
7. **Keep Flutter and backend separate.** No server-side logic or secrets in Flutter.
8. **Use typed models.** Prefer typed Dart models over big untyped `Map<String, dynamic>`.
9. **Handle Loading / Success / Empty / Error** on every network screen.
10. **Don't overengineer the MVP.** Build the smallest reliable version first.

---

# 24. Example End-to-End Scenario

Transcript:

```text
Manager: Alex, please finish the API testing by Friday.
Alex:    Sure. I'll complete it by Friday.
Manager: Sarah, prepare the release documentation before Monday.
         The database schema should also be reviewed.
```

T.ask output:

```text
Summary:
The team discussed release preparation and assigned testing,
documentation, and a schema review.

Tasks:
1. Complete API testing        | Alex  | Friday | Pending
2. Prepare release docs        | Sarah | Monday | Pending
3. Review database schema      | (none)| (none) | Clarification Required   <-- Phase 2: flagged, low confidence
```

Then:

```text
WhatsApp → Alex

Task Assigned: Complete API testing
Task ID: 12
Reply DONE 12 when completed.
```

Alex replies `DONE 12` → Backend validates → `Task 12: Pending → Completed` → Flutter shows `Status: Completed`.

Phase 2 behaviour on the same meeting:
- Task 3 flagged for manager clarification before assignment.
- Reminder sent 24h before each deadline.
- If a task passes its deadline: marked overdue, employee + manager notified, escalation logged, analytics updated.
- Next related meeting shows still-unresolved tasks from this one.

---

# 25. Success Criteria (MVP)

A user can:

1. Open the Flutter app.
2. Log in.
3. Upload a meeting recording.
4. Start processing.
5. Receive a transcript.
6. Receive an AI-generated summary.
7. View key points and decisions.
8. View automatically extracted tasks.
9. See assignees and due dates.
10. Have tasks stored in the database.
11. Change task status.
12. Receive a task through WhatsApp.
13. Reply `DONE <task_id>`.
14. See the task marked completed.

The whole flow must work **without manually editing the database.**

---

# 26. Priorities

```text
HIGH
────────────────────────
Flutter foundation
Authentication
Dashboard
Meeting upload
Backend API
Database
Transcription
AI task extraction
Task management

MEDIUM
────────────────────────
WhatsApp integration
Notifications / reminders
Clarification + confidence scoring
Advanced filtering
Analytics

LOW / FUTURE
────────────────────────
Calendar integration
Advanced AI features
Local AI
Organizations
Advanced analytics
```

---

# 27. Source of Truth

This document defines the intended behaviour and architecture of T.ask.

If implementation details conflict with it:

1. Preserve the core product goal.
2. Prefer the simplest reliable implementation.
3. Don't introduce unnecessary technologies.
4. Ask for clarification only when a decision materially changes the architecture.
5. Update this document when an important architectural decision is finalized.

---

## T.ask

### *What are your task?*

**Meeting → Understanding → Tasks → Assignment → Action**
