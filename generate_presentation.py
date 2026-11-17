import sys
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE

def create_presentation():
    prs = Presentation()
    # 16:9 Widescreen dimensions
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)

    # Color Palette
    PRIMARY = RGBColor(15, 23, 42)      # Slate 900
    SECONDARY = RGBColor(37, 99, 235)   # Royal Blue 600
    ACCENT = RGBColor(14, 165, 233)     # Light Sky Blue
    DARK_TEXT = RGBColor(30, 41, 59)    # Slate 800
    MUTED_TEXT = RGBColor(100, 116, 139)# Slate 500
    BG_LIGHT = RGBColor(248, 250, 252)  # Slate 50
    CARD_BG = RGBColor(255, 255, 255)   # White
    CARD_BORDER = RGBColor(226, 232, 240)
    SUCCESS = RGBColor(22, 163, 74)     # Emerald 600
    ALERT = RGBColor(220, 38, 38)       # Red 600

    def add_header(slide, title_text, category_text=None):
        # Header banner container
        header_box = slide.shapes.add_textbox(Inches(0.8), Inches(0.4), Inches(11.7), Inches(1.1))
        tf = header_box.text_frame
        tf.word_wrap = True
        tf.margin_left = tf.margin_top = tf.margin_right = tf.margin_bottom = 0

        if category_text:
            p_cat = tf.paragraphs[0]
            p_cat.text = category_text.upper()
            p_cat.font.size = Pt(11)
            p_cat.font.bold = True
            p_cat.font.color.rgb = SECONDARY
            p_cat.space_after = Pt(4)
            p_title = tf.add_paragraph()
        else:
            p_title = tf.paragraphs[0]

        p_title.text = title_text
        p_title.font.size = Pt(24)
        p_title.font.bold = True
        p_title.font.color.rgb = PRIMARY

        # Accent line
        line = slide.shapes.add_shape(
            MSO_SHAPE.RECTANGLE, Inches(0.8), Inches(1.5), Inches(11.733), Inches(0.04)
        )
        line.fill.solid()
        line.fill.fore_color.rgb = SECONDARY
        line.line.color.rgb = SECONDARY

    def add_card(slide, left, top, width, height, title, items, border_color=CARD_BORDER):
        # Background shape for card
        shape = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, top, width, height)
        shape.fill.solid()
        shape.fill.fore_color.rgb = CARD_BG
        shape.line.color.rgb = border_color
        shape.line.width = Pt(1.5)

        tf = shape.text_frame
        tf.word_wrap = True
        tf.margin_left = Inches(0.25)
        tf.margin_right = Inches(0.25)
        tf.margin_top = Inches(0.25)
        tf.margin_bottom = Inches(0.25)

        p_title = tf.paragraphs[0]
        p_title.text = title
        p_title.font.size = Pt(16)
        p_title.font.bold = True
        p_title.font.color.rgb = SECONDARY
        p_title.space_after = Pt(12)

        for item in items:
            p = tf.add_paragraph()
            p.text = "• " + item
            p.font.size = Pt(13)
            p.font.color.rgb = DARK_TEXT
            p.space_after = Pt(8)

    blank_layout = prs.slide_layouts[6]

    # ==================== SLIDE 1: Title Slide ====================
    s1 = prs.slides.add_slide(blank_layout)
    bg1 = s1.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(7.5))
    bg1.fill.solid()
    bg1.fill.fore_color.rgb = PRIMARY
    bg1.line.fill.background()

    # Title box
    tbox = s1.shapes.add_textbox(Inches(1.2), Inches(1.5), Inches(10.9), Inches(4.5))
    ttf = tbox.text_frame
    ttf.word_wrap = True

    p0 = ttf.paragraphs[0]
    p0.text = "DEPARTMENT OF ARTIFICIAL INTELLIGENCE & MACHINE LEARNING (CSE-AIML)"
    p0.font.size = Pt(12)
    p0.font.bold = True
    p0.font.color.rgb = ACCENT
    p0.space_after = Pt(18)

    p1 = ttf.add_paragraph()
    p1.text = "T.ask"
    p1.font.size = Pt(50)
    p1.font.bold = True
    p1.font.color.rgb = RGBColor(255, 255, 255)

    p2 = ttf.add_paragraph()
    p2.text = "Automated Task Assigner and Manager"
    p2.font.size = Pt(26)
    p2.font.bold = True
    p2.font.color.rgb = RGBColor(226, 232, 240)
    p2.space_after = Pt(8)

    p3 = ttf.add_paragraph()
    p3.text = 'Motto: "What are your task?"'
    p3.font.size = Pt(18)
    p3.font.italic = True
    p3.font.color.rgb = ACCENT
    p3.space_after = Pt(36)

    p4 = ttf.add_paragraph()
    p4.text = "B.E. V Semester Mini-Project Presentation"
    p4.font.size = Pt(14)
    p4.font.color.rgb = RGBColor(203, 213, 225)

    p5 = ttf.add_paragraph()
    p5.text = "Team: Mohammed Hifzan (160724733155)  |  Abdul Rafey Mohammed (160724733131)  |  Syed Najeeb Ullah Hussainy (160724733190)"
    p5.font.size = Pt(13)
    p5.font.color.rgb = RGBColor(148, 163, 184)

    # ==================== SLIDE 2: Table of Contents ====================
    s2 = prs.slides.add_slide(blank_layout)
    add_header(s2, "Presentation Outline", "Agenda")

    toc_items = [
        ("01", "Abstract", "Executive summary of T.ask, core workflow, motivation, and system impact."),
        ("02", "Introduction", "The meeting-to-task dilemma, core identity, goals, and target audience."),
        ("03", "Existing System", "Traditional meeting documentation tools, shortcomings, and procedural gaps."),
        ("04", "Proposed System", "Architecture, AI orchestration, end-to-end pipeline, and WhatsApp loop."),
        ("05", "Literature Survey", "Analysis of existing literature, NLP models, STT, and comparative matrix."),
    ]

    for idx, (num, title, desc) in enumerate(toc_items):
        top = Inches(1.8 + idx * 1.0)
        card = s2.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(1.0), top, Inches(11.333), Inches(0.85))
        card.fill.solid()
        card.fill.fore_color.rgb = CARD_BG
        card.line.color.rgb = CARD_BORDER

        tf = card.text_frame
        tf.word_wrap = True
        tf.margin_left = Inches(0.3)
        tf.margin_top = Inches(0.15)

        p = tf.paragraphs[0]
        p.text = f"{num}   {title}"
        p.font.size = Pt(16)
        p.font.bold = True
        p.font.color.rgb = SECONDARY

        p_desc = tf.add_paragraph()
        p_desc.text = f"      {desc}"
        p_desc.font.size = Pt(12)
        p_desc.font.color.rgb = MUTED_TEXT

    # ==================== SLIDE 3: 1. Abstract ====================
    s3 = prs.slides.add_slide(blank_layout)
    add_header(s3, "Executive Abstract", "1. Abstract")

    add_card(
        s3, Inches(0.8), Inches(1.8), Inches(5.6), Inches(5.1),
        "Project Foundation & Motivation",
        [
            "T.ask (Automated Task Assigner and Manager) is an AI-powered system designed to turn verbal conversations into actionable work.",
            "Traditional meetings suffer from incomplete note-taking, ambiguous action items, and missed deadlines due to manual tracking.",
            "T.ask bridges the gap between discussion and execution by combining Speech-to-Text (AssemblyAI), NLP (Google Gemini + LangChain), and Cross-Platform Mobile (Flutter).",
            "Answers the fundamental question after every meeting: 'What happened? What needs to happen? Who needs to do it?'"
        ]
    )

    add_card(
        s3, Inches(6.8), Inches(1.8), Inches(5.7), Inches(5.1),
        "End-to-End System Workflow",
        [
            "Multi-Modal Input: Accepts meeting audio recordings or pre-existing raw transcripts via Flutter.",
            "Intelligent NLP Extraction: Extracts concise summaries, key points, decisions, and actionable tasks with assignees & deadlines.",
            "Automated Notification & WhatsApp Reply: Assigns tasks directly to employees and dispatches alerts via WhatsApp Cloud API.",
            "Zero-Friction Completion: Assignees reply 'DONE <task_id>' via WhatsApp to auto-update task status without opening a portal.",
            "Role-Based Visibility: Provides real-time dashboards for pending, completed, and overdue task monitoring."
        ]
    )

    # ==================== SLIDE 4: Abstract Key Highlights ====================
    s4 = prs.slides.add_slide(blank_layout)
    add_header(s4, "Abstract — Highlights & Keywords", "1. Abstract")

    highlights = [
        ("Domain & Platform", [
            "Domain: Artificial Intelligence & Process Automation",
            "Platform: Flutter (Cross-platform Android) + FastAPI (Python)",
            "Database: SQLite (Prototype) / PostgreSQL (Production)"
        ]),
        ("Core AI Pipeline", [
            "Transcription: AssemblyAI (Speaker diarization & timestamps)",
            "Intelligence: Google Gemini (Structured JSON task extraction)",
            "Delivery: WhatsApp Cloud API bi-directional webhook"
        ]),
        ("Key Academic Keywords", [
            "Task Automation, Meeting Summarization, Audio Transcription",
            "Assignee Identification, Deadline Detection, Natural Language Processing",
            "Large Language Models (LLMs), Workplace Productivity"
        ]),
    ]

    for idx, (title, items) in enumerate(highlights):
        left = Inches(0.8 + idx * 4.0)
        add_card(s4, left, Inches(1.8), Inches(3.7), Inches(5.1), title, items)

    # ==================== SLIDE 5: 2. Introduction ====================
    s5 = prs.slides.add_slide(blank_layout)
    add_header(s5, "The Workplace Meeting Dilemma", "2. Introduction")

    add_card(
        s5, Inches(0.8), Inches(1.8), Inches(5.6), Inches(5.1),
        "The Reality of Modern Meetings",
        [
            "Organizations spend up to 35-50% of work hours in meetings, discussing strategic plans and delegating duties.",
            "Human Recall Decay: Studies reveal that over 50% of spoken meeting details are forgotten within 1 hour after the session ends.",
            "Manual Overhead: Designating a human scribe distracts participants from actively contributing to strategic deliberations.",
            "Disjointed Workflows: Notes recorded in notebooks or chat threads are disconnected from task management software."
        ]
    )

    add_card(
        s5, Inches(6.8), Inches(1.8), Inches(5.7), Inches(5.1),
        "Consequences of Unmanaged Tasks",
        [
            "Unclear Accountability: 'Someone should test the API' leaves tasks orphaned without an explicit owner.",
            "Vague Deadlines: Phrases like 'finish it soon' lead to severe timeline slippage.",
            "Managerial Fatigue: Team leads spend excessive time manually pinging team members for status updates.",
            "Late Delay Discovery: Managers often discover delays only when deadlines have already passed."
        ]
    )

    # ==================== SLIDE 6: 2. Introduction - T.ask Philosophy ====================
    s6 = prs.slides.add_slide(blank_layout)
    add_header(s6, "T.ask: Concept & Complete Lifecycle", "2. Introduction")

    add_card(
        s6, Inches(0.8), Inches(1.8), Inches(11.7), Inches(2.2),
        "The Core Identity: 'What are your task?'",
        [
            "T.ask answers that question by automatically parsing conversational dialogue into structured responsibilities.",
            "Not just another recording or transcription app: T.ask is an automated task assigner and progress manager.",
            "Designed to transform passive conversational agreements into active accountability."
        ]
    )

    add_card(
        s6, Inches(0.8), Inches(4.3), Inches(11.7), Inches(2.6),
        "Full Lifecycle of Meeting-Generated Work",
        [
            "1. Meeting: Audio recorded or transcript submitted via Flutter mobile client.",
            "2. Transcription & AI Understanding: AssemblyAI generates text; Google Gemini extracts summary & tasks.",
            "3. Validation & Assignment: Tasks verified, structured JSON validated, and assignees linked.",
            "4. Notification & Tracking: WhatsApp alerts sent; real-time dashboard tracks Pending / Completed / Overdue.",
            "5. Feedback Loop: Assignee replies 'DONE <id>' to automatically close tasks with an audit trail."
        ]
    )

    # ==================== SLIDE 7: 2. Introduction - Objectives & Users ====================
    s7 = prs.slides.add_slide(blank_layout)
    add_header(s7, "Objectives and Target Beneficiaries", "2. Introduction")

    add_card(
        s7, Inches(0.8), Inches(1.8), Inches(5.6), Inches(5.1),
        "Key Project Objectives",
        [
            "Automate Meeting-to-Task Conversion: Zero manual documentation required to produce actionable items.",
            "Minimize Forgotten Responsibilities: Explicit identification of assignees and deadlines.",
            "Non-Intrusive Task Closure: Mobile and WhatsApp integration for frictionless progress reporting.",
            "Reliability & Safety: JSON schema enforcement preventing LLM hallucinations.",
            "Auditability: Clear record of meeting origins for every extracted action item."
        ]
    )

    add_card(
        s7, Inches(6.8), Inches(1.8), Inches(5.7), Inches(5.1),
        "Target Users & Application Domains",
        [
            "Corporate & Software Teams: Daily standups, sprint retrospectives, client requirement sessions.",
            "Startups & Small Businesses: Fast-moving teams without dedicated project administrators.",
            "Academic & Research Groups: Student teams, faculty committees, and research collaboration.",
            "Healthcare & Legal Meetings: Structured documentation of case discussions and administrative duties."
        ]
    )

    # ==================== SLIDE 8: 3. Existing System ====================
    s8 = prs.slides.add_slide(blank_layout)
    add_header(s8, "Current Methodologies & Solutions", "3. Existing System")

    systems = [
        ("Manual Note-Taking & Scribes", [
            "A human participant takes notes in Google Docs, Word, or physical paper.",
            "High cognitive load on the note-taker.",
            "Biased, incomplete, and highly inconsistent note quality."
        ]),
        ("Transcription Tools (Otter / Teams)", [
            "AI speech-to-text tools provide full transcripts and generic paragraph summaries.",
            "Generate massive walls of text without parsing individual commitments.",
            "Do not assign tasks or track deadlines."
        ]),
        ("Project Managers (Jira / Asana)", [
            "Enterprise boards require manual ticket creation after the meeting.",
            "High friction: requires entering titles, descriptions, assignees, and dates manually.",
            "Frequently neglected due to administrative fatigue."
        ])
    ]

    for idx, (title, items) in enumerate(systems):
        left = Inches(0.8 + idx * 4.0)
        add_card(s8, left, Inches(1.8), Inches(3.7), Inches(5.1), title, items)

    # ==================== SLIDE 9: 3. Existing System - Limitations ====================
    s9 = prs.slides.add_slide(blank_layout)
    add_header(s9, "Critical Limitations of Existing Systems", "3. Existing System")

    add_card(
        s9, Inches(0.8), Inches(1.8), Inches(5.6), Inches(5.1),
        "Procedural & Technical Bottlenecks",
        [
            "Disconnected Architecture: Transcription tools and task management platforms exist in total isolation.",
            "Lack of Natural Entity Binding: Generic summarizers cannot reliably correlate 'who' agreed to do 'what' by 'when'.",
            "High Friction Barriers: Employees resist logging into heavy enterprise web portals merely to check a task box.",
            "Absence of Automated Verification: No mechanism to flag ambiguous statements (e.g., 'we should fix this soon')."
        ],
        border_color=ALERT
    )

    add_card(
        s9, Inches(6.8), Inches(1.8), Inches(5.7), Inches(5.1),
        "Organizational Consequences",
        [
            "Lost Action Items: Critical commitments made during verbal discussion are lost forever.",
            "Managerial Overhead: Team leaders waste hours every week conducting follow-up interrogations.",
            "Delayed Project Delivery: Bottlenecks remain invisible until project deadlines are breached.",
            "Lack of Audit Trail: Dispute over what was actually agreed upon in previous sessions."
        ],
        border_color=ALERT
    )

    # ==================== SLIDE 10: 4. Proposed System - Architecture ====================
    s10 = prs.slides.add_slide(blank_layout)
    add_header(s10, "Proposed Architecture & Pipeline", "4. Proposed System")

    add_card(
        s10, Inches(0.8), Inches(1.8), Inches(3.7), Inches(5.1),
        "Client & Backend",
        [
            "Flutter Mobile Client: Modern Riverpod state management, responsive UI, meeting upload, and live status boards.",
            "FastAPI Python Server: High-performance asynchronous REST API handling auth, orchestration, and DB operations.",
            "SQLAlchemy ORM: Relational schema tracking Users, Meetings, Key Points, Decisions, and Tasks."
        ]
    )

    add_card(
        s10, Inches(4.8), Inches(1.8), Inches(3.7), Inches(5.1),
        "AI & Intelligence Layer",
        [
            "AssemblyAI Speech-to-Text: Enterprise-grade audio-to-text with timestamps and speaker diarization.",
            "Google Gemini 1.5 Flash: Few-shot prompting enforcing strict JSON schemas for structured action item extraction.",
            "Hallucination Guardrails: Heuristic fallbacks and validation ensuring unassigned tasks are flagged rather than fabricated."
        ]
    )

    add_card(
        s10, Inches(8.8), Inches(1.8), Inches(3.7), Inches(5.1),
        "Notification & Action",
        [
            "WhatsApp Cloud API: Direct dispatch of task assignments to employee phones.",
            "Bi-Directional Webhook: Assignees simply reply 'DONE <task_id>' via WhatsApp.",
            "Automatic Status Closure: Server validates sender phone against task ID and marks task Completed."
        ]
    )

    # ==================== SLIDE 11: 4. Proposed System - Modules ====================
    s11 = prs.slides.add_slide(blank_layout)
    add_header(s11, "Core Modules & Technical Implementation", "4. Proposed System")

    modules = [
        ("Authentication & Security", [
            "JWT-based bearer authentication.",
            "Direct bcrypt password hashing.",
            "Role isolation ensuring users only access their authorized tasks."
        ]),
        ("Meeting Processing Engine", [
            "Dual input mode: Audio recording upload or direct transcript text paste.",
            "Live multi-stage progress tracking (Uploading → Transcribing → Analyzing → Storing).",
            "Automatic decomposition into Summary, Key Points, Decisions, and Tasks."
        ]),
        ("Intelligent Task Lifecycle", [
            "Structured task schema: title, description, assignee_name, due_date, status.",
            "Statuses: Pending → Completed (Phase 1) with Overdue alerts.",
            "Two-way WhatsApp sync eliminating enterprise app fatigue."
        ]),
        ("Interactive Dashboard", [
            "Instant statistics: Total, Pending, Completed, Overdue counters.",
            "Upcoming tasks timeline and recent meetings history.",
            "One-tap status updates with instant database synchronization."
        ])
    ]

    for idx, (title, items) in enumerate(modules):
        col = idx % 2
        row = idx // 2
        left = Inches(0.8 + col * 6.0)
        top = Inches(1.8 + row * 2.6)
        add_card(s11, left, top, Inches(5.7), Inches(2.4), title, items)

    # ==================== SLIDE 12: 4. Proposed System - Advantages ====================
    s12 = prs.slides.add_slide(blank_layout)
    add_header(s12, "Key Advantages of T.ask", "4. Proposed System")

    advantages = [
        ("End-to-End Automation", "Eliminates the entire manual post-meeting pipeline: transcription, note summarization, task generation, and assignment occur without human intervention."),
        ("WhatsApp Native Interaction", "Employees do not need to download or keep opening heavy tools; they receive direct notifications and reply 'DONE <id>' to complete work."),
        ("Strict AI Contract & Reliability", "Enforces rigid JSON schema validation. If an assignee or deadline was not specified in the discussion, it flags it rather than hallucinating."),
        ("Accountability & Transparency", "Every task maintains an immutable link back to its source meeting transcript, eliminating ambiguity over who agreed to what."),
        ("Lightweight & Cross-Platform", "Built on Flutter and FastAPI for rapid performance, offline resilience, and cross-platform mobile compatibility.")
    ]

    for idx, (title, desc) in enumerate(advantages):
        top = Inches(1.8 + idx * 1.0)
        card = s12.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), top, Inches(11.733), Inches(0.88))
        card.fill.solid()
        card.fill.fore_color.rgb = CARD_BG
        card.line.color.rgb = CARD_BORDER

        tf = card.text_frame
        tf.word_wrap = True
        tf.margin_left = Inches(0.25)
        tf.margin_top = Inches(0.12)

        p = tf.paragraphs[0]
        p.text = f"✔   {title}"
        p.font.size = Pt(15)
        p.font.bold = True
        p.font.color.rgb = SUCCESS

        p_desc = tf.add_paragraph()
        p_desc.text = f"      {desc}"
        p_desc.font.size = Pt(12)
        p_desc.font.color.rgb = DARK_TEXT

    # ==================== SLIDE 13: 5. Literature Survey ====================
    s13 = prs.slides.add_slide(blank_layout)
    add_header(s13, "Related Work & Literature Review", "5. Literature Survey")

    surveys = [
        ("Meeting Summarization via LLMs", "Vaswani et al. / Brown et al.", [
            "Demonstrated transformer self-attention effectiveness in conversational abstraction.",
            "Limitation: Traditional models produce passive summaries without extracting structured entity relations (assignees, dates)."
        ]),
        ("Speech Recognition & Diarization", "Radford et al. (Whisper) / AssemblyAI", [
            "Conformer architectures provide >95% accuracy in conversational English speech-to-text.",
            "Proves automated transcription is viable for noisy meeting environments with multiple speakers."
        ]),
        ("Action Item Extraction in Discourse", "Purver et al. / Gruenstein et al.", [
            "Analyzed dialog acts (commitments, requests) to identify actionable tasks in speech.",
            "Showed keyword heuristics fail; LLM few-shot context reasoning is required to detect implicit delegation."
        ]),
        ("Mobile & Conversational UX in PM", "Dabbish et al. / Bellotti et al.", [
            "Found task tracking tools fail when friction is high. Integrating alerts into existing channels (chat/messaging) increases task completion rates by 40%."
        ])
    ]

    for idx, (title, author, items) in enumerate(surveys):
        col = idx % 2
        row = idx // 2
        left = Inches(0.8 + col * 6.0)
        top = Inches(1.8 + row * 2.6)
        
        card = s13.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, top, Inches(5.7), Inches(2.4))
        card.fill.solid()
        card.fill.fore_color.rgb = CARD_BG
        card.line.color.rgb = CARD_BORDER

        tf = card.text_frame
        tf.word_wrap = True
        tf.margin_left = Inches(0.25)
        tf.margin_top = Inches(0.15)

        p = tf.paragraphs[0]
        p.text = title
        p.font.size = Pt(15)
        p.font.bold = True
        p.font.color.rgb = SECONDARY

        p_auth = tf.add_paragraph()
        p_auth.text = f"Key Research: {author}"
        p_auth.font.size = Pt(11)
        p_auth.font.italic = True
        p_auth.font.color.rgb = MUTED_TEXT
        p_auth.space_after = Pt(6)

        for item in items:
            p_it = tf.add_paragraph()
            p_it.text = "• " + item
            p_it.font.size = Pt(12)
            p_it.font.color.rgb = DARK_TEXT

    # ==================== SLIDE 14: 5. Literature Survey - Comparative Matrix ====================
    s14 = prs.slides.add_slide(blank_layout)
    add_header(s14, "Comparative Analysis: Existing Tools vs T.ask", "5. Literature Survey")

    # Table layout
    rows, cols = 6, 6
    left = Inches(0.8)
    top = Inches(1.8)
    width = Inches(11.733)
    height = Inches(4.8)

    table_shape = s14.shapes.add_table(rows, cols, left, top, width, height)
    table = table_shape.table

    # Column widths
    table.columns[0].width = Inches(2.8)
    for c in range(1, 6):
        table.columns[c].width = Inches(1.78)

    headers = ["Feature / Capability", "Manual Notes", "Otter.ai", "Fireflies.ai", "Jira / Asana", "T.ask (Proposed)"]
    for i, h in enumerate(headers):
        cell = table.cell(0, i)
        cell.text = h
        cell.fill.solid()
        cell.fill.fore_color.rgb = PRIMARY
        p = cell.text_frame.paragraphs[0]
        p.font.bold = True
        p.font.size = Pt(12)
        p.font.color.rgb = RGBColor(255, 255, 255)
        p.alignment = PP_ALIGN.CENTER

    data = [
        ["Audio Speech-to-Text", "❌ No", "✔ Yes", "✔ Yes", "❌ No", "✔ Yes (AssemblyAI)"],
        ["Meeting Summarization", "Manual", "✔ Generic", "✔ Generic", "❌ No", "✔ Structured (Gemini)"],
        ["Automated Task Extraction", "❌ No", "Partial (Highlights)", "Partial", "❌ Manual Entry", "✔ Full Action Items"],
        ["Assignee & Deadline Binding", "Manual", "❌ No", "❌ Limited", "Manual", "✔ Automatic NLP Link"],
        ["WhatsApp Two-Way Closure", "❌ No", "❌ No", "❌ No", "❌ Web Only", "✔ 'DONE <id>' Loop"]
    ]

    for r_idx, row in enumerate(data, start=1):
        for c_idx, val in enumerate(row):
            cell = table.cell(r_idx, c_idx)
            cell.text = val
            cell.fill.solid()
            if c_idx == 5:
                # Highlight T.ask column
                cell.fill.fore_color.rgb = RGBColor(238, 242, 255)
            else:
                cell.fill.fore_color.rgb = CARD_BG if r_idx % 2 == 1 else RGBColor(248, 250, 252)

            p = cell.text_frame.paragraphs[0]
            p.font.size = Pt(11)
            p.font.color.rgb = SECONDARY if c_idx == 5 else DARK_TEXT
            if c_idx == 5 or c_idx == 0:
                p.font.bold = True
            if c_idx > 0:
                p.alignment = PP_ALIGN.CENTER

    # ==================== SLIDE 15: Conclusion & Future Scope ====================
    s15 = prs.slides.add_slide(blank_layout)
    add_header(s15, "Conclusion & Future Scope", "Looking Ahead")

    add_card(
        s15, Inches(0.8), Inches(1.8), Inches(5.6), Inches(5.1),
        "Project Conclusion",
        [
            "T.ask successfully bridges the long-standing disconnect between verbal meeting decisions and post-meeting task completion.",
            "By integrating speech recognition, LLM intelligence, mobile accessibility, and instant messaging, it creates a zero-friction workflow.",
            "Substantially reduces meeting documentation overhead while dramatically increasing organizational accountability and deadline compliance."
        ]
    )

    add_card(
        s15, Inches(6.8), Inches(1.8), Inches(5.7), Inches(5.1),
        "Future Enhancements (Phase 2 & 3)",
        [
            "Real-Time Live Task Extraction: On-the-fly task detection during live audio calls.",
            "Biometric Speaker Identification: Mapping voice signatures directly to registered employee accounts.",
            "Multi-Platform Integrations: Escalations via Slack, Microsoft Teams, and Google Calendar sync.",
            "Workload Balancing: Workload-aware recommendations before tasks are finalized.",
            "On-Device Private AI: Local processing for enterprise confidentiality."
        ]
    )

    # ==================== SLIDE 16: Thank You Slide ====================
    s16 = prs.slides.add_slide(blank_layout)
    bg16 = s16.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(7.5))
    bg16.fill.solid()
    bg16.fill.fore_color.rgb = PRIMARY
    bg16.line.fill.background()

    tbox16 = s16.shapes.add_textbox(Inches(1.5), Inches(2.2), Inches(10.333), Inches(3.5))
    ttf16 = tbox16.text_frame
    ttf16.word_wrap = True

    p_ty = ttf16.paragraphs[0]
    p_ty.text = "Thank You!"
    p_ty.font.size = Pt(54)
    p_ty.font.bold = True
    p_ty.font.color.rgb = RGBColor(255, 255, 255)
    p_ty.alignment = PP_ALIGN.CENTER
    p_ty.space_after = Pt(12)

    p_qa = ttf16.add_paragraph()
    p_qa.text = "Questions & Answers"
    p_qa.font.size = Pt(24)
    p_qa.font.color.rgb = ACCENT
    p_qa.alignment = PP_ALIGN.CENTER
    p_qa.space_after = Pt(28)

    p_cr = ttf16.add_paragraph()
    p_cr.text = "T.ask — What are your task?\nAI-Powered Meeting & Task Management System"
    p_cr.font.size = Pt(14)
    p_cr.font.color.rgb = RGBColor(148, 163, 184)
    p_cr.alignment = PP_ALIGN.CENTER

    output_path = r"c:\Users\hifzu\Downloads\T.ask\T.ask_Presentation.pptx"
    prs.save(output_path)
    print(f"Presentation saved successfully to: {output_path}")

if __name__ == "__main__":
    create_presentation()
