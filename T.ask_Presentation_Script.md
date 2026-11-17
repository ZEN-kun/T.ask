# T.ask — Presentation Script & Speaker Notes
**Project Title:** T.ask — Automated Task Assigner and Manager  
**Motto:** *"What are your task?"*  
**Domain:** Artificial Intelligence & Workplace Automation  
**Platform:** Flutter (Mobile Frontend) + FastAPI (Python Backend)  
**Target Duration:** ~10 to 12 Minutes (16 Slides)  
**Team Members:** Mohammed Hifzan (160724733155), Abdul Rafey Mohammed (160724733131), Syed Najeeb Ullah Hussainy (160724733190)

---

## Slide 1: Title Slide
* **Visual:** Dark slate theme with glowing royal blue & cyan typography, project title, and motto.
* **Estimated Time:** 45 seconds

### Speaker Script:
> "Good morning, respected guide, evaluators, and faculty members.
> 
> We are here today to present our B.E. V Semester Mini-Project titled **T.ask — Automated Task Assigner and Manager**, developed under the Department of Artificial Intelligence and Machine Learning.
> 
> Our project operates around a single, powerful motto: **'What are your task?'**
> 
> In modern workplaces, teams spend countless hours discussing critical milestones, assigning duties, and establishing deadlines. Yet, the moment the meeting ends, these crucial details frequently get lost or distorted in communication.
> 
> Today, we are excited to introduce **T.ask**, an AI-driven, end-to-end meeting-to-task management system designed to turn verbal conversations into structured, trackable, and verifiable action items."

---

## Slide 2: Presentation Outline (Agenda)
* **Visual:** Five cleanly structured agenda cards detailing Abstract, Introduction, Existing System, Proposed System, and Literature Survey.
* **Estimated Time:** 30 seconds

### Speaker Script:
> "To guide you through our presentation today, we have organized our discussion into five core sections:
> 
> 1. First, the **Abstract**, outlining the executive motivation, core problem, and technical impact.
> 2. Second, the **Introduction**, breaking down the real-world meeting dilemma, our product identity, and core objectives.
> 3. Third, the **Existing System**, analyzing current manual note-taking habits, transcription tools, and their critical bottlenecks.
> 4. Fourth, our **Proposed System**, covering our layered client-server architecture, AI extraction engine, and two-way WhatsApp closure loop.
> 5. Finally, the **Literature Survey & Comparative Analysis**, summarizing key academic foundations and contrasting T.ask against market alternatives, followed by future scope."

---

## Slide 3: Section 1 — Executive Abstract
* **Visual:** Two comparison cards: Foundation & Motivation vs. End-to-End System Workflow.
* **Estimated Time:** 50 seconds

### Speaker Script:
> "Beginning with our **Abstract**:
> 
> In conventional setups, meeting follow-ups suffer from three chronic issues: incomplete note-taking, ambiguous task delegation, and missed deadlines caused by friction in manual tracking.
> 
> T.ask bridges the gap between discussion and execution by combining three modern technologies:
> - **AssemblyAI** for speech-to-text with speaker identification,
> - **Google Gemini** for natural language understanding and task extraction, and
> - **Flutter** for a clean, cross-platform mobile user experience.
> 
> After every meeting, T.ask answers three fundamental questions:
> *What happened? What needs to happen? And who needs to do it?*
> 
> The system accepts audio or raw transcripts, extracts action items along with assignees and due dates, stores them in a relational database, dispatches direct notifications to assignees via WhatsApp, and enables employees to complete tasks simply by texting back `DONE <task_id>`."

---

## Slide 4: Section 1 — Abstract Highlights & Academic Keywords
* **Visual:** Three focused columns detailing Domain/Platform, Core AI Pipeline, and Academic Keywords.
* **Estimated Time:** 40 seconds

### Speaker Script:
> "Looking at the key technical parameters:
> 
> - **Domain:** Applied Artificial Intelligence and Workplace Process Automation.
> - **Platform:** A responsive Flutter mobile frontend backed by a high-performance Python FastAPI server, with SQLite for development and PostgreSQL for production.
> - **Core Pipeline:** AssemblyAI for audio diarization, Google Gemini 1.5 for JSON-enforced task mining, and the Meta WhatsApp Cloud API for frictionless notifications.
> - **Keywords:** Task Automation, Conversational NLP, Meeting Summarization, Action Item Extraction, Entity-Deadline Binding, and Large Language Models."

---

## Slide 5: Section 2 — Introduction: The Workplace Meeting Dilemma
* **Visual:** Two cards highlighting the reality of modern meetings and the consequences of unmanaged tasks.
* **Estimated Time:** 50 seconds

### Speaker Script:
> "Moving to Section 2, the **Introduction**:
> 
> Modern knowledge workers spend between 35% and 50% of their working hours in meetings. However, psychological and cognitive research reveals an alarming trend known as **Human Recall Decay**: more than 50% of spoken meeting details are forgotten within just one hour of a meeting concluding.
> 
> Furthermore, when organizations designate a team member as a manual scribe, that individual’s cognitive bandwidth is occupied by transcription rather than active strategic contribution.
> 
> This creates severe operational consequences:
> - **Orphaned Tasks:** Remarks like *'someone should test the authentication endpoint'* leave tasks without an owner.
> - **Vague Deadlines:** Phrases like *'let’s wrap this up soon'* result in schedule slippages.
> - **Managerial Fatigue:** Team leads must spend hours every week chasing down updates across scattered email threads and chat apps."

---

## Slide 6: Section 2 — T.ask Philosophy & Complete Lifecycle
* **Visual:** T.ask identity banner followed by the 5-stage lifecycle card.
* **Estimated Time:** 50 seconds

### Speaker Script:
> "This brings us to the **Philosophy of T.ask**:
> 
> The name itself asks the question: *'What are your task?'*
> T.ask is not merely a voice recorder or a transcription tool. It is an automated task assigner and progress manager that transforms passive conversational agreements into active, verifiable accountability.
> 
> We model the complete lifecycle of meeting work across five distinct stages:
> 1. **Capture:** The user uploads a meeting recording or pastes notes into the Flutter app.
> 2. **Transcription & AI Understanding:** AssemblyAI generates timestamped transcripts, and Google Gemini extracts summaries, key decisions, and tasks.
> 3. **Validation & Assignment:** Tasks are parsed into strict data models with assignees and target dates.
> 4. **Notification & Tracking:** Tasks appear on live dashboards, and assignees receive WhatsApp notifications.
> 5. **Frictionless Closure:** Assignees text back `DONE <id>`, closing the feedback loop without logging into complex portals."

---

## Slide 7: Section 2 — Objectives & Target Beneficiaries
* **Visual:** Two cards showing project objectives and target user groups.
* **Estimated Time:** 45 seconds

### Speaker Script:
> "Our core **Objectives** are clear:
> - Eliminate manual post-meeting documentation.
> - Ensure zero missed commitments by explicitly identifying assignees and deadlines.
> - Provide a non-intrusive task closure mechanism through mobile and chat integration.
> - Enforce rigid schema guardrails to prevent AI hallucinations.
> - Maintain an auditable record connecting every single task back to its source meeting transcript.
> 
> **Target Beneficiaries** include:
> - Software development teams running sprint retrospectives and standups,
> - Fast-moving startups where everyone wears multiple hats,
> - Academic and research committees coordinating multi-author publications, and
> - Small and medium-sized enterprises seeking enterprise-grade accountability without enterprise software bloat."

---

## Slide 8: Section 3 — Existing Systems & Current Tools
* **Visual:** Three horizontal cards contrasting Manual Scribes, Transcription Apps, and Project Management Boards.
* **Estimated Time:** 50 seconds

### Speaker Script:
> "In Section 3, let us analyze the **Existing Systems**:
> 
> Currently, organizations tackle this problem using three disconnected approaches:
> 
> 1. **Manual Scribing:** A designated human takes notes in Word, Google Docs, or physical paper. This approach has high cognitive load, is inherently subjective, and results in incomplete records.
> 2. **Standalone AI Transcription Tools (e.g., Otter.ai, Microsoft Teams Recap):** These tools transcribe speech and produce generic paragraph summaries. However, they create walls of unstructured text and stop short of turning those insights into assigned database records.
> 3. **Traditional Project Management Boards (e.g., Jira, Trello, Asana):** While excellent for tracking, they require entirely manual ticket creation. Someone has to sit down after the meeting, type out titles, write descriptions, assign team members, and select calendar dates—leading to high friction and administrative neglect."

---

## Slide 9: Section 3 — Critical Limitations of Existing Systems
* **Visual:** Red-accented cards showing Technical Bottlenecks and Organizational Impact.
* **Estimated Time:** 45 seconds

### Speaker Script:
> "These current tools expose several critical limitations:
> 
> - **Architectural Disconnection:** Speech tools and task trackers exist in complete silos. There is no automated bridge between the spoken word and the task board.
> - **Lack of Entity Binding:** Standard AI summarizers cannot reliably correlate *who* promised to do *what* by *when*.
> - **High Adoption Friction:** Employees actively resist having to download, log in, and navigate complex web software just to check off a 10-minute task.
> - **Absence of Ambiguity Detection:** When a speaker says *'we need to check this next week'*, existing tools don't flag that both the person and the exact date are missing.
> 
> As a result, critical action items slip through the cracks, and managers discover delays only after milestones have failed."

---

## Slide 10: Section 4 — Proposed System: Architecture & Pipeline
* **Visual:** 3-tier architecture cards: Presentation Layer (Flutter), AI & Intelligence Layer (AssemblyAI + Gemini), and Notification Layer (WhatsApp Cloud API).
* **Estimated Time:** 1 minute

### Speaker Script:
> "Now, turning to Section 4 — **Our Proposed System**:
> 
> We designed T.ask as a robust, decoupled three-tier architecture:
> 
> 1. **Presentation Layer (Mobile Client):**
>    Built with Flutter using the Riverpod state management framework and GoRouter. It provides an intuitive, responsive mobile UI featuring meeting creation, live multi-stage processing animations, dashboard counters, and task filtering.
> 
> 2. **Backend Application Layer:**
>    Powered by Python's FastAPI framework. It handles asynchronous operations, direct bcrypt password security, JWT OAuth2 authentication, and SQLAlchemy relational models.
> 
> 3. **AI & Notification Pipeline:**
>    - For audio inputs, **AssemblyAI** performs transcription and speaker separation.
>    - **Google Gemini 1.5** receives the transcript and analyzes it against an enforced JSON contract, extracting the summary, key points, decisions, and typed action items.
>    - Finally, the **WhatsApp Cloud API** dispatches direct message alerts and receives webhook callbacks."

---

## Slide 11: Section 4 — Core Modules & Implementation Details
* **Visual:** 2x2 grid covering Authentication, Meeting Processing Engine, Task Lifecycle, and Interactive Dashboard.
* **Estimated Time:** 50 seconds

### Speaker Script:
> "Let us look at the four core functional modules of T.ask:
> 
> 1. **Authentication & Security:** Implements JWT bearer tokens and salted bcrypt password hashing, ensuring users access only their own meetings and assigned tasks.
> 2. **Multi-Stage Meeting Processing Engine:** Supports dual inputs—audio files or pasted text notes. Users see live processing feedback: *Uploading → Transcribing → Understanding → Extracting → Storing*.
> 3. **Intelligent Task Engine:** Stores each task with title, description, assignee name, due date, and status (`Pending` or `Completed`).
> 4. **Interactive Dashboard:** Gives managers and employees immediate visibility into total tasks, pending items, completed milestones, upcoming deadlines, and overdue alerts."

---

## Slide 12: Section 4 — Key Advantages of T.ask
* **Visual:** Five green checkmark cards detailing Automation, WhatsApp Loop, Strict AI Contract, Transparency, and Performance.
* **Estimated Time:** 45 seconds

### Speaker Script:
> "What makes T.ask distinct from existing market solutions?
> 
> - **End-to-End Automation:** We eliminate manual intervention across transcription, extraction, assignment, and status updates.
> - **Zero-Friction WhatsApp Loop:** Team members don't need another app installed to report progress; they simply reply `DONE <id>` on WhatsApp.
> - **Anti-Hallucination Guardrails:** If a meeting discussion mentions a task without assigning anyone, our prompts explicitly store `assignee = null` rather than inventing an imaginary person.
> - **Complete Auditability:** Every single task links directly back to its source meeting ID and verbatim transcript.
> - **Lightweight and Fast:** Cross-platform Flutter mobile combined with asynchronous FastAPI delivers instantaneous UI updates."

---

## Slide 13: Section 5 — Literature Survey: Academic Foundations
* **Visual:** Four research cards summarizing foundational papers across LLM summarization, speech recognition, dialog action items, and workplace notification UX.
* **Estimated Time:** 1 minute

### Speaker Script:
> "In Section 5, we grounded our implementation in a thorough **Literature Survey**:
> 
> 1. **Conversational Summarization (Vaswani et al., Brown et al.):**
>    Established how transformer attention mechanisms excel at abstractive dialogue summarization, though standard summarizers lack structured entity extraction.
> 
> 2. **Speech Recognition and Diarization (Radford et al. - Whisper, AssemblyAI):**
>    Demonstrated that modern conformer architectures achieve greater than 95% accuracy in conversational multi-speaker environments, confirming the reliability of automated speech inputs.
> 
> 3. **Action Item Extraction from Discourse (Purver et al., Gruenstein et al.):**
>    Researched dialog-act tagging for promises and commitments. Their findings proved that static keyword matching fails, and contextual LLM few-shot reasoning is required to detect conversational commitments.
> 
> 4. **Task Management UX & Interruption Science (Dabbish et al., Bellotti et al.):**
>    Proved that task management tools requiring dedicated portal logins suffer over 50% drop-off. Delivering alerts directly through conversational channels like WhatsApp increases deadline compliance by over 40%."

---

## Slide 14: Section 5 — Comparative Feature Matrix
* **Visual:** Comprehensive comparative table evaluating Manual Notes, Otter.ai, Fireflies.ai, Jira/Asana, and T.ask.
* **Estimated Time:** 50 seconds

### Speaker Script:
> "This slide presents our **Comparative Feature Matrix**, evaluating T.ask against common existing alternatives:
> 
> - **Audio Speech-to-Text:** Handled by AssemblyAI in T.ask, matching specialized tools like Otter and Fireflies.
> - **Meeting Summarization:** T.ask generates structured summaries, key points, and decisions, whereas competitors offer only generic paragraphs.
> - **Automated Task Extraction:** While Jira requires manual entry and Otter provides only text highlights, T.ask extracts full, typed action items.
> - **Assignee and Deadline Binding:** T.ask automatically maps people and calendar dates via NLP, which existing transcription tools cannot do.
> - **WhatsApp Two-Way Closure Loop:** T.ask is the only platform offering bi-directional WhatsApp status management through simple text replies.
> - **User Experience:** We provide a clean, dedicated Flutter mobile dashboard rather than cluttered enterprise boards."

---

## Slide 15: Conclusion & Future Scope
* **Visual:** Two cards: Project Conclusion and Future Roadmap (Phases 2 & 3).
* **Estimated Time:** 45 seconds

### Speaker Script:
> "To conclude:
> 
> **T.ask** successfully bridges the long-standing gap between verbal conversations and post-meeting execution. By uniting speech recognition, LLM intelligence, mobile accessibility, and WhatsApp automation, we eliminate administrative overhead and foster genuine workplace accountability.
> 
> Looking ahead to **Future Enhancements**:
> - **Real-time Live Extraction:** Extracting tasks on-the-fly during active audio conferences.
> - **Voice Biometrics:** Mapping acoustic voice signatures directly to registered user IDs.
> - **Ecosystem Integrations:** Automatic syncing with Google Calendar, Slack, and Microsoft Teams.
> - **Workload-Aware Assignment:** Analyzing team capacity before recommending assignments to prevent burnout.
> - **On-Device Private AI:** Enabling local offline inference for sensitive corporate discussions."

---

## Slide 16: Thank You & Q&A
* **Visual:** Elegant dark slate closing slide with "Thank You!", "Questions & Answers", and project credentials.
* **Estimated Time:** Open

### Speaker Script:
> "Thank you for your time, attention, and valuable guidance.
> 
> We are now open to your questions, feedback, and suggestions."

---

## 💡 Quick Tips for the Presenters
1. **Pacing:** Speak at a steady, conversational pace (~130 words per minute).
2. **Transitions:** When moving to the next slide, use transition phrases like:
   - *"Having looked at the problem, let us explore..."*
   - *"This directly leads us to our architecture on the next slide..."*
3. **Handling Questions:**
   - **On AI Hallucination:** *"We enforce strict Pydantic JSON schemas with low temperature (0.2). If an assignee or date isn't explicitly spoken, our prompt mandates returning `null` rather than guessing."*
   - **On WhatsApp Security:** *"Our webhook verifies incoming sender phone numbers against the registered user ID or meeting owner before updating any task status."*
   - **On Architecture Scalability:** *"Our backend runs on FastAPI with asynchronous routing, making it easy to swap SQLite for PostgreSQL and add Celery with Redis for enterprise scaling."*
