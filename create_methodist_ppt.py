import os
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE

def build_presentation():
    prs = Presentation()
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)

    # Color Palette matching Methodist College Template & Modern Executive Theme
    HEADER_OCHRE = RGBColor(204, 102, 0)   # #CC6600 Methodist College Ochre
    PRIMARY_DARK = RGBColor(15, 23, 42)    # Slate 900
    TEXT_DARK = RGBColor(30, 41, 59)       # Slate 800
    TEXT_MUTED = RGBColor(100, 116, 139)   # Slate 500
    ACCENT_BLUE = RGBColor(37, 99, 235)    # Blue 600
    ACCENT_GREEN = RGBColor(22, 163, 74)   # Emerald 600
    ACCENT_RED = RGBColor(220, 38, 38)     # Red 600
    CARD_BG = RGBColor(248, 250, 252)      # Slate 50
    CARD_BORDER = RGBColor(226, 232, 240)  # Border
    WHITE = RGBColor(255, 255, 255)

    logo_path = os.path.abspath('methodist_logo.png')

    blank_layout = prs.slide_layouts[6]

    def add_base_header(slide, title_text):
        # White background
        bg = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(7.5))
        bg.fill.solid()
        bg.fill.fore_color.rgb = WHITE
        bg.line.fill.background()

        # Ochre Title Banner
        banner = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0.6), Inches(0.4), Inches(10.8), Inches(0.95))
        banner.fill.solid()
        banner.fill.fore_color.rgb = HEADER_OCHRE
        banner.line.fill.background()

        tf = banner.text_frame
        tf.word_wrap = True
        tf.margin_left = Inches(0.3)
        tf.margin_top = Inches(0.2)
        p = tf.paragraphs[0]
        p.text = title_text
        p.font.name = 'Georgia'
        p.font.size = Pt(26)
        p.font.bold = True
        p.font.color.rgb = WHITE

        # Methodist Logo at top right
        if os.path.exists(logo_path):
            slide.shapes.add_picture(logo_path, Inches(11.6), Inches(0.35), width=Inches(1.15))

        # Bottom subtle footer
        footer_box = slide.shapes.add_textbox(Inches(0.6), Inches(7.05), Inches(12.133), Inches(0.35))
        ftf = footer_box.text_frame
        ftf.margin_top = ftf.margin_bottom = ftf.margin_left = ftf.margin_right = 0
        fp = ftf.paragraphs[0]
        fp.text = "T.ask: Automated Task Assigner and Manager | Department of CSE, Methodist College of Engg. & Tech."
        fp.font.name = 'Calibri'
        fp.font.size = Pt(9.5)
        fp.font.color.rgb = TEXT_MUTED

    def add_card(slide, left, top, width, height, title, points, title_color=HEADER_OCHRE, bg_color=CARD_BG, border_color=CARD_BORDER):
        card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, top, width, height)
        card.fill.solid()
        card.fill.fore_color.rgb = bg_color
        card.line.color.rgb = border_color
        card.line.width = Pt(1.2)

        tf = card.text_frame
        tf.word_wrap = True
        tf.margin_left = Inches(0.25)
        tf.margin_right = Inches(0.25)
        tf.margin_top = Inches(0.2)
        tf.margin_bottom = Inches(0.2)

        p_title = tf.paragraphs[0]
        p_title.text = title
        p_title.font.name = 'Calibri'
        p_title.font.size = Pt(15)
        p_title.font.bold = True
        p_title.font.color.rgb = title_color
        p_title.space_after = Pt(8)

        for pt in points:
            p = tf.add_paragraph()
            p.text = "• " + pt
            p.font.name = 'Calibri'
            p.font.size = Pt(12)
            p.font.color.rgb = TEXT_DARK
            p.space_after = Pt(6)

    # =========================================================================
    # SLIDE 1: TITLE SLIDE
    # =========================================================================
    s1 = prs.slides.add_slide(blank_layout)
    bg1 = s1.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(7.5))
    bg1.fill.solid()
    bg1.fill.fore_color.rgb = PRIMARY_DARK
    bg1.line.fill.background()

    # Top accent band
    band = s1.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(0.2))
    band.fill.solid()
    band.fill.fore_color.rgb = HEADER_OCHRE
    band.line.fill.background()

    # Methodist Logo on Title
    if os.path.exists(logo_path):
        s1.shapes.add_picture(logo_path, Inches(5.95), Inches(0.8), width=Inches(1.4))

    # College Heading Box
    cbox = s1.shapes.add_textbox(Inches(1.0), Inches(2.35), Inches(11.333), Inches(1.2))
    ctf = cbox.text_frame
    ctf.word_wrap = True
    cp1 = ctf.paragraphs[0]
    cp1.alignment = PP_ALIGN.CENTER
    cp1.text = "METHODIST COLLEGE OF ENGINEERING & TECHNOLOGY"
    cp1.font.name = 'Georgia'
    cp1.font.size = Pt(19)
    cp1.font.bold = True
    cp1.font.color.rgb = WHITE

    cp2 = ctf.add_paragraph()
    cp2.alignment = PP_ALIGN.CENTER
    cp2.text = "Affiliated to Osmania University | Approved by AICTE, New Delhi\nDepartment of Computer Science & Engineering"
    cp2.font.name = 'Calibri'
    cp2.font.size = Pt(13)
    cp2.font.color.rgb = RGBColor(203, 213, 225)
    cp2.space_before = Pt(4)

    # Project Title Card
    pbox = s1.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(1.5), Inches(3.7), Inches(10.333), Inches(1.75))
    pbox.fill.solid()
    pbox.fill.fore_color.rgb = RGBColor(30, 41, 59)
    pbox.line.color.rgb = HEADER_OCHRE
    pbox.line.width = Pt(2)

    ptf = pbox.text_frame
    ptf.word_wrap = True
    ptf.margin_top = Inches(0.2)
    pp1 = ptf.paragraphs[0]
    pp1.alignment = PP_ALIGN.CENTER
    pp1.text = "T.ask: Automated Task Assigner and Manager"
    pp1.font.name = 'Georgia'
    pp1.font.size = Pt(28)
    pp1.font.bold = True
    pp1.font.color.rgb = RGBColor(251, 191, 36) # Gold / Ochre Glow

    pp2 = ptf.add_paragraph()
    pp2.alignment = PP_ALIGN.CENTER
    pp2.text = 'Motto: "What are your Tasks?"'
    pp2.font.name = 'Georgia'
    pp2.font.size = Pt(15)
    pp2.font.italic = True
    pp2.font.color.rgb = RGBColor(148, 163, 184)
    pp2.space_before = Pt(6)

    # Presenters & Supervisor Footer Box
    fbox = s1.shapes.add_textbox(Inches(1.5), Inches(5.7), Inches(10.333), Inches(1.2))
    ftf = fbox.text_frame
    ftf.word_wrap = True
    fp1 = ftf.paragraphs[0]
    fp1.alignment = PP_ALIGN.CENTER
    fp1.text = "A Major Project Presentation Submitted in Partial Fulfillment for the Award of the Degree of\nBachelor of Engineering in Computer Science & Engineering"
    fp1.font.name = 'Calibri'
    fp1.font.size = Pt(12)
    fp1.font.color.rgb = RGBColor(226, 232, 240)

    fp2 = ftf.add_paragraph()
    fp2.alignment = PP_ALIGN.CENTER
    fp2.text = "Academic Year 2026-2027"
    fp2.font.name = 'Calibri'
    fp2.font.size = Pt(12)
    fp2.font.bold = True
    fp2.font.color.rgb = HEADER_OCHRE
    fp2.space_before = Pt(4)

    # =========================================================================
    # SLIDE 2: TABLE OF CONTENTS (Exact Match with Uploaded Slide)
    # =========================================================================
    s2 = prs.slides.add_slide(blank_layout)
    add_base_header(s2, "Table of Contents")

    # Column 1 (Items 1-8)
    toc_box1 = s2.shapes.add_textbox(Inches(1.0), Inches(1.65), Inches(5.2), Inches(5.1))
    ttf1 = toc_box1.text_frame
    ttf1.word_wrap = True
    toc_items_col1 = [
        "Abstract",
        "Introduction",
        "Problem Statement",
        "Objective",
        "Scope of Project",
        "Literature Survey",
        "Related Work",
        "Technology",
    ]
    for i, item in enumerate(toc_items_col1):
        p = ttf1.paragraphs[0] if i == 0 else ttf1.add_paragraph()
        p.text = "•  " + item
        p.font.name = 'Calibri'
        p.font.size = Pt(17)
        p.font.color.rgb = TEXT_DARK
        p.space_after = Pt(13)

    # Column 2 (Items 9-16)
    toc_box2 = s2.shapes.add_textbox(Inches(6.8), Inches(1.65), Inches(5.8), Inches(5.1))
    ttf2 = toc_box2.text_frame
    ttf2.word_wrap = True
    toc_items_col2 = [
        "Proposed Methodology",
        "Advantages and Limitations",
        "Proposed Architecture",
        "Diagram",
        "Implementation",
        "Project Timeline",
        "Conclusion",
        "PO/PSO & SDGs Mapped",
    ]
    for i, item in enumerate(toc_items_col2):
        p = ttf2.paragraphs[0] if i == 0 else ttf2.add_paragraph()
        p.text = "•  " + item
        p.font.name = 'Calibri'
        p.font.size = Pt(17)
        p.font.color.rgb = TEXT_DARK
        p.space_after = Pt(13)

    # =========================================================================
    # SLIDE 3: ABSTRACT
    # =========================================================================
    s3 = prs.slides.add_slide(blank_layout)
    add_base_header(s3, "Abstract")

    add_card(s3, Inches(0.8), Inches(1.65), Inches(5.6), Inches(4.9), "Executive Overview", [
        "Modern corporate and academic teams spend 35%–50% of work hours in meetings, producing crucial decisions that frequently remain undocumented.",
        "Due to human memory decay, over 50% of spoken commitments are forgotten within just one hour of meeting conclusion.",
        "T.ask is an AI-driven, end-to-end task automation ecosystem designed to bridge spoken discussions and actual workplace execution.",
        "Accepts multi-format audio (.mp4, .mp3, .wav) and verbal text notes, converting them into structured, actionable, and trackable task registries.",
    ])

    add_card(s3, Inches(6.8), Inches(1.65), Inches(5.6), Inches(4.9), "Core Innovation & Impact", [
        "Speech-to-Text Pipeline: Powered by AssemblyAI for speech diarization and speaker timestamp accuracy.",
        "LLM Intelligence: Employs Google Gemini 1.5 with enforced Pydantic JSON contracts for structured decision and task extraction without hallucinations.",
        "Zero-Friction WhatsApp Loop: Dispatches immediate task notifications to assignees via WhatsApp Cloud API.",
        "Two-Way Status Closure: Assignees reply 'DONE <id>' on WhatsApp to automatically complete tasks in the database and mobile dashboard.",
        "Cross-Platform Delivery: Built with Flutter for a responsive glassmorphic mobile client on Android, iOS, and Web.",
    ])

    # =========================================================================
    # SLIDE 4: INTRODUCTION
    # =========================================================================
    s4 = prs.slides.add_slide(blank_layout)
    add_base_header(s4, "Introduction")

    add_card(s4, Inches(0.8), Inches(1.65), Inches(3.6), Inches(4.9), "1. The Context", [
        "Meetings are the primary vehicle for organizational alignment, strategy, and project planning.",
        "High volume of verbal commitments, deadlines, and technical dependencies are spoken daily.",
        "Traditional note-taking is manual, subjective, incomplete, and creates administrative fatigue.",
    ])

    add_card(s4, Inches(4.8), Inches(1.65), Inches(3.6), Inches(4.9), "2. The Cognitive Gap", [
        "The Ebbinghaus Forgetting Curve shows immediate, exponential loss of unrecorded meeting context.",
        "Remarks like 'someone should test this endpoint' lack assigned ownership and are lost.",
        "Managers waste 4–6 hours weekly chasing manual updates across disparate communication channels.",
    ])

    add_card(s4, Inches(8.8), Inches(1.65), Inches(3.6), Inches(4.9), "3. The T.ask Mission", [
        "Convert passive audio into immediate, structured action with zero administrative friction.",
        "Deliver clear answers to three vital post-meeting questions: What happened? What needs to be done? Who owns it?",
        "Establish seamless two-way WhatsApp accountability without forcing complex software logins.",
    ])

    # =========================================================================
    # SLIDE 5: PROBLEM STATEMENT
    # =========================================================================
    s5 = prs.slides.add_slide(blank_layout)
    add_base_header(s5, "Problem Statement")

    add_card(s5, Inches(0.8), Inches(1.65), Inches(5.6), Inches(2.35), "1. Critical Information Loss", [
        "Subjective manual minutes miss up to 40% of technical decisions and deadlines.",
        "Audio recordings exist in silos; listening to 1-hour recordings for a 30-second task is impractical.",
    ], title_color=ACCENT_RED)

    add_card(s5, Inches(6.8), Inches(1.65), Inches(5.6), Inches(2.35), "2. Orphaned & Ambiguous Tasks", [
        "Spoken action items frequently lack explicit assignees, exact due dates, or priority levels.",
        "Without structured extraction, tasks linger in confusion until deadline failure occurs.",
    ], title_color=ACCENT_RED)

    add_card(s5, Inches(0.8), Inches(4.2), Inches(5.6), Inches(2.35), "3. Portal Fatigue & Low Adoption", [
        "Traditional enterprise project management tools (Jira, Asana) require manual logins.",
        "Over 50% employee drop-off in updating task status due to complex multi-step UI portals.",
    ], title_color=ACCENT_RED)

    add_card(s5, Inches(6.8), Inches(4.2), Inches(5.6), Inches(2.35), "4. Disconnected Follow-Up Cycles", [
        "Unresolved tasks from past meetings are forgotten in follow-up discussions.",
        "No consolidated executive audit trail tracking who created, reassigned, or completed tasks.",
    ], title_color=ACCENT_RED)

    # =========================================================================
    # SLIDE 6: OBJECTIVE
    # =========================================================================
    s6 = prs.slides.add_slide(blank_layout)
    add_base_header(s6, "Objective")

    add_card(s6, Inches(0.8), Inches(1.65), Inches(3.6), Inches(4.9), "Automated Extraction", [
        "Eliminate manual meeting documentation entirely.",
        "Ingest raw audio recordings (.mp4, .mp3, .wav) and verbal notes.",
        "Extract structured tasks, assignees, deadlines, and priorities using Gemini 1.5 LLM.",
        "Generate comprehensive meeting summaries, key points, and verified decisions.",
    ])

    add_card(s6, Inches(4.8), Inches(1.65), Inches(3.6), Inches(4.9), "Seamless Accountability", [
        "Integrate two-way WhatsApp Cloud API notifications for instant task delivery.",
        "Allow team members to complete tasks via simple text replies ('DONE <task_id>').",
        "Provide automated reminders and escalation alerts before deadlines expire.",
        "Flag ambiguous or missing information instead of hallucinating details.",
    ])

    add_card(s6, Inches(8.8), Inches(1.65), Inches(3.6), Inches(4.9), "Executive Visibility", [
        "Deliver a cross-platform Flutter mobile application featuring real-time statistics.",
        "Live metric counters: Total Tasks, Pending, Completed, and Overdue.",
        "Interactive manager dashboard with team member assignment and filtering.",
        "Full historical archive ensuring seamless continuity between related meetings.",
    ])

    # =========================================================================
    # SLIDE 7: SCOPE OF PROJECT
    # =========================================================================
    s7 = prs.slides.add_slide(blank_layout)
    add_base_header(s7, "Scope of Project")

    add_card(s7, Inches(0.8), Inches(1.65), Inches(5.6), Inches(4.9), "In-Scope Capabilities (Implemented)", [
        "Meeting Audio Ingestion: Native file picker supporting .mp4 video/audio, .mp3, .wav, and .m4a.",
        "Speech Transcription: Multi-speaker diarization and accurate punctuation via AssemblyAI.",
        "LLM Context Parsing: Gemini 1.5 Pro/Flash structured JSON extraction with strict Pydantic schemas.",
        "Authentication & Security: Role-based hierarchy (Manager & Employee) with persistent 'Remember Me' sessions.",
        "WhatsApp Automation: Instant outbound dispatch of tasks and bidirectional inbound webhook for status closure.",
        "Mobile Experience: Flutter UI with glassmorphic dark/light theme, riverpod state, and fluid page transitions.",
    ], title_color=ACCENT_GREEN)

    add_card(s7, Inches(6.8), Inches(1.65), Inches(5.6), Inches(4.9), "Target Users & Future Scope", [
        "Primary Target Beneficiaries:",
        "  • Corporate project teams & software engineering squads.",
        "  • Startups and SMBs requiring lightweight task coordination.",
        "  • Academic institutions, project guides, and research labs.",
        "Future Enhancements (Phase 2 & 3):",
        "  • Live real-time audio streaming during ongoing meetings.",
        "  • On-device local LLM execution (Llama-3 / Mistral) for offline corporate privacy.",
        "  • Native calendar synchronization (Google Calendar / Outlook).",
    ], title_color=ACCENT_BLUE)

    # =========================================================================
    # SLIDE 8: LITERATURE SURVEY
    # =========================================================================
    s8 = prs.slides.add_slide(blank_layout)
    add_base_header(s8, "Literature Survey")

    add_card(s8, Inches(0.8), Inches(1.65), Inches(5.6), Inches(2.35), "1. Transformer Architectures in NLP", [
        "Reference: Vaswani et al. (2017) - 'Attention Is All You Need'",
        "Significance: Self-attention mechanisms enable large language models to capture long-range semantic dependencies across multi-paragraph meeting transcripts.",
        "Application: Forms the algorithmic backbone of Gemini 1.5 LLM task extraction.",
    ])

    add_card(s8, Inches(6.8), Inches(1.65), Inches(5.6), Inches(2.35), "2. Automated Speech Recognition (ASR)", [
        "Reference: Radford et al. / OpenAI (2022) - 'Robust Speech Recognition'",
        "Significance: Demonstrates deep neural acoustic models achieving near-human word error rates across noisy audio, varied accents, and domain-specific terminology.",
        "Application: Implemented via AssemblyAI for enterprise audio diarization.",
    ])

    add_card(s8, Inches(0.8), Inches(4.2), Inches(5.6), Inches(2.35), "3. Human Memory Decay in Organizations", [
        "Reference: Cognitive Psychology & Ebbinghaus Forgetting Curve Studies",
        "Significance: Empirical evidence proves humans forget over 50% of spoken information within 1 hour and 70% within 24 hours without structured external memory.",
        "Application: Establishes the necessity for automated post-meeting task registries.",
    ])

    add_card(s8, Inches(6.8), Inches(4.2), Inches(5.6), Inches(2.35), "4. Conversational Task Management", [
        "Reference: ACM CHI Conference on Human Factors in Computing Systems",
        "Significance: User studies demonstrate 40%+ higher task completion compliance when alerts are delivered through daily chat apps (WhatsApp) vs. web portals.",
        "Application: Guided our zero-friction two-way WhatsApp closed-loop architecture.",
    ])

    # =========================================================================
    # SLIDE 9: RELATED WORK & COMPARATIVE ANALYSIS
    # =========================================================================
    s9 = prs.slides.add_slide(blank_layout)
    add_base_header(s9, "Related Work")

    # Comparison Table
    table_shape = s9.shapes.add_table(6, 5, Inches(0.8), Inches(1.65), Inches(11.733), Inches(4.9))
    table = table_shape.table

    table.columns[0].width = Inches(2.5)
    table.columns[1].width = Inches(2.2)
    table.columns[2].width = Inches(2.2)
    table.columns[3].width = Inches(2.2)
    table.columns[4].width = Inches(2.633)

    headers = ["Feature", "Otter.ai / Fireflies", "Jira / Asana", "WhatsApp Groups", "T.ask (Proposed)"]
    for col_idx, text in enumerate(headers):
        cell = table.cell(0, col_idx)
        cell.fill.solid()
        cell.fill.fore_color.rgb = HEADER_OCHRE if col_idx != 4 else RGBColor(180, 83, 9)
        p = cell.text_frame.paragraphs[0]
        p.text = text
        p.font.name = 'Calibri'
        p.font.size = Pt(13)
        p.font.bold = True
        p.font.color.rgb = WHITE
        p.alignment = PP_ALIGN.CENTER

    rows_data = [
        ["Speech-to-Text Transcription", "Yes (High Accuracy)", "No (Text Only)", "No", "Yes (AssemblyAI)"],
        ["Automated Task Extraction", "Generic Summary Only", "No (Manual Entry)", "No", "Yes (Structured LLM)"],
        ["Assignee & Deadline Binding", "No (Unassigned text)", "Manual Selection", "No", "Yes (Contextual AI)"],
        ["Bidirectional Task Closure", "No", "Portal Login Required", "Unstructured Chat", "Yes ('DONE <id>' Bot)"],
        ["Unified Mobile Dashboard", "Transcript View Only", "Complex Kanban Board", "Chaotic Chat Feed", "Yes (Glassmorphic Flutter)"],
    ]

    for row_idx, row in enumerate(rows_data):
        for col_idx, val in enumerate(row):
            cell = table.cell(row_idx + 1, col_idx)
            cell.fill.solid()
            cell.fill.fore_color.rgb = CARD_BG if col_idx != 4 else RGBColor(254, 243, 199) # Highlight proposed
            p = cell.text_frame.paragraphs[0]
            p.text = val
            p.font.name = 'Calibri'
            p.font.size = Pt(12)
            if col_idx == 4:
                p.font.bold = True
                p.font.color.rgb = RGBColor(146, 64, 14)
            else:
                p.font.color.rgb = TEXT_DARK
            p.alignment = PP_ALIGN.CENTER if col_idx > 0 else PP_ALIGN.LEFT

    # =========================================================================
    # SLIDE 10: TECHNOLOGY
    # =========================================================================
    s10 = prs.slides.add_slide(blank_layout)
    add_base_header(s10, "Technology")

    add_card(s10, Inches(0.8), Inches(1.65), Inches(3.6), Inches(4.9), "Client & Mobile Frontend", [
        "Framework: Flutter 3.x (Dart 3.x) for cross-platform Android, iOS, and Web execution.",
        "State Management: Riverpod 2.6 for robust, reactive dependency injection.",
        "Navigation: GoRouter 14.x with custom cross-fade & shared-axis page transitions.",
        "UI Design: Glassmorphism architecture with adaptive Light/Dark mode support.",
        "Media Handling: Native file_picker and image_picker plugins for mobile files.",
    ])

    add_card(s10, Inches(4.8), Inches(1.65), Inches(3.6), Inches(4.9), "Backend & AI Engines", [
        "Server Framework: Python 3.12 with FastAPI for high-throughput asynchronous REST APIs.",
        "Validation: Pydantic v2 ensuring strict type enforcement and schema validation.",
        "Large Language Model: Google Gemini 1.5 Pro / Flash with temperature-controlled parsing.",
        "Speech Recognition: AssemblyAI providing state-of-the-art multi-speaker transcription.",
        "ORM & Modeling: SQLAlchemy with SQLite (prototype) / PostgreSQL (production).",
    ])

    add_card(s10, Inches(8.8), Inches(1.65), Inches(3.6), Inches(4.9), "Messaging & Infrastructure", [
        "Notification Gateway: Meta WhatsApp Cloud API / Webhook integration.",
        "Two-Way Webhooks: Bidirectional HTTP callbacks for asynchronous task completion.",
        "Security: BCrypt password hashing, JWT bearer tokens, and OAuth2 standard.",
        "Persistent Storage: SharedPreferences & Cloud Firestore for real-time syncing.",
        "DevOps: Docker containerization, Uvicorn ASGI server, and GitHub Actions CI/CD.",
    ])

    # =========================================================================
    # SLIDE 11: PROPOSED METHODOLOGY
    # =========================================================================
    s11 = prs.slides.add_slide(blank_layout)
    add_base_header(s11, "Proposed Methodology")

    stages = [
        ("Step 1: Input Ingestion", ["Manager uploads meeting audio (.mp4, .mp3, .wav) or types verbal transcript notes.", "Flutter client verifies formats and dispatches multipart payload to FastAPI backend."]),
        ("Step 2: Speech-to-Text", ["Backend forwards audio stream to AssemblyAI ASR engine.", "Generates speaker-diarized text with millisecond timestamps and punctuation."]),
        ("Step 3: AI Understanding", ["Google Gemini 1.5 processes transcript with structured prompt guidelines.", "Extracts: Executive Summary, Key Points, Decisions, and Action Items."]),
        ("Step 4: Schema Validation", ["Pydantic validates fields, ISO dates, and assignee references.", "Flags ambiguities (missing due date, unclear assignee) without hallucinating."]),
        ("Step 5: Storage & Dispatch", ["Records saved to database with unique Task IDs and deadlines.", "Outbound WhatsApp webhook dispatches personalized task alerts to team members."]),
        ("Step 6: Closed-Loop Reply", ["Assignee replies 'DONE <id>' on WhatsApp.", "Backend validates sender phone, marks task completed, and updates Flutter dashboard live."]),
    ]

    for i, (stitle, spoints) in enumerate(stages):
        col = i % 3
        row = i // 3
        l = Inches(0.8 + col * 4.0)
        t = Inches(1.65 + row * 2.5)
        add_card(s11, l, t, Inches(3.6), Inches(2.3), stitle, spoints, title_color=ACCENT_BLUE)

    # =========================================================================
    # SLIDE 12: ADVANTAGES AND LIMITATIONS
    # =========================================================================
    s12 = prs.slides.add_slide(blank_layout)
    add_base_header(s12, "Advantages and Limitations")

    add_card(s12, Inches(0.8), Inches(1.65), Inches(5.6), Inches(4.9), "Key Advantages", [
        "Massive Time Savings: Reduces post-meeting administrative documentation by up to 90%.",
        "Zero Employee Portal Friction: Assignees receive and close tasks directly inside WhatsApp without downloading new apps or remembering passwords.",
        "Zero Hallucination Guarantee: Prompt constraints mandate returning null/flagged status rather than guessing ambiguous dates or assignees.",
        "End-to-End Traceability: Immutable audit trail preserving the meeting context, exact audio excerpt, and completion timestamp for every task.",
        "Executive Glassmorphic UI: High-visibility dashboard metrics (Total, Pending, Completed, Overdue) with seamless theme transitions.",
    ], title_color=ACCENT_GREEN)

    add_card(s12, Inches(6.8), Inches(1.65), Inches(5.6), Inches(4.9), "Limitations & Mitigations", [
        "Audio Clarity Dependency: Heavy background noise or severely overlapping voices can reduce transcription accuracy. (Mitigated by AssemblyAI noise filtering).",
        "Cloud Connectivity: Current implementation requires active internet for Gemini and AssemblyAI cloud APIs. (Phase 2 planned for local offline LLMs).",
        "Indian Accent Nuances: Highly localized colloquial terms require attendee selection hints. (Mitigated by our Flutter Attendee Chip selector).",
        "WhatsApp Rate Limits: Standard Meta API tier limits message burst volume. (Mitigated by asynchronous queue scheduling via APScheduler).",
    ], title_color=ACCENT_RED)

    # =========================================================================
    # SLIDE 13: PROPOSED ARCHITECTURE
    # =========================================================================
    s13 = prs.slides.add_slide(blank_layout)
    add_base_header(s13, "Proposed Architecture")

    add_card(s13, Inches(0.8), Inches(1.65), Inches(3.6), Inches(4.9), "1. Client Layer (Flutter)", [
        "Mobile App: Cross-platform frontend for Android & iOS.",
        "Presentation: Glassmorphic UI with dynamic Light/Dark mode.",
        "State Management: Riverpod providers for real-time reactivity.",
        "Local Cache: SharedPreferences with auto-login 'Remember Me'.",
        "Media Module: Native Android/iOS document & audio picker.",
    ])

    add_card(s13, Inches(4.8), Inches(1.65), Inches(3.6), Inches(4.9), "2. Application & API Layer", [
        "FastAPI Server: Asynchronous non-blocking REST endpoints.",
        "Authentication: JWT OAuth2 tokens with BCrypt password hashing.",
        "Task Extraction Engine: Orchestrates Gemini 1.5 prompt pipelines.",
        "Webhook Handler: Bi-directional WhatsApp message processing.",
        "Validation Pipeline: Enforces Pydantic models on all AI outputs.",
    ])

    add_card(s13, Inches(8.8), Inches(1.65), Inches(3.6), Inches(4.9), "3. Services & Data Layer", [
        "ASR Engine: AssemblyAI Speech-to-Text with speaker diarization.",
        "LLM Provider: Google Gemini 1.5 Pro & Flash API.",
        "Messaging Provider: Meta WhatsApp Cloud API Gateway.",
        "Database: Cloud Firestore for live real-time sync + SQLite/PostgreSQL.",
        "Audit Logging: Comprehensive event history for every action item.",
    ])

    # =========================================================================
    # SLIDE 14: DIAGRAM (Visual System Flowchart)
    # =========================================================================
    s14 = prs.slides.add_slide(blank_layout)
    add_base_header(s14, "Diagram")

    # Visual System Architecture Flowchart
    nodes = [
        ("1. Input", "Meeting Audio\n(.mp4, .mp3, .wav)\nor Text Notes", Inches(0.8), Inches(2.2), Inches(2.0), Inches(1.5), RGBColor(59, 130, 246)),
        ("2. Mobile App", "Flutter Client\n(Riverpod +\nGlassmorphic UI)", Inches(3.3), Inches(2.2), Inches(2.0), Inches(1.5), RGBColor(99, 102, 241)),
        ("3. Backend", "FastAPI Server\n(Async Routes +\nPydantic Validation)", Inches(5.8), Inches(2.2), Inches(2.0), Inches(1.5), RGBColor(16, 185, 129)),
        ("4. AI Engine", "AssemblyAI (ASR)\nGoogle Gemini 1.5\n(Structured LLM)", Inches(8.3), Inches(2.2), Inches(2.0), Inches(1.5), RGBColor(245, 158, 11)),
        ("5. Database", "Cloud Firestore\n& PostgreSQL\n(Audit Trail)", Inches(10.8), Inches(2.2), Inches(1.8), Inches(1.5), RGBColor(14, 165, 233)),
    ]

    for title, desc, l, t, w, h, col in nodes:
        shape = s14.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, l, t, w, h)
        shape.fill.solid()
        shape.fill.fore_color.rgb = col
        shape.line.color.rgb = WHITE
        shape.line.width = Pt(1.5)

        tf = shape.text_frame
        tf.word_wrap = True
        tf.margin_top = Inches(0.15)
        p0 = tf.paragraphs[0]
        p0.text = title
        p0.alignment = PP_ALIGN.CENTER
        p0.font.name = 'Calibri'
        p0.font.size = Pt(12)
        p0.font.bold = True
        p0.font.color.rgb = WHITE

        p1 = tf.add_paragraph()
        p1.text = desc
        p1.alignment = PP_ALIGN.CENTER
        p1.font.name = 'Calibri'
        p1.font.size = Pt(10.5)
        p1.font.color.rgb = WHITE
        p1.space_before = Pt(4)

    # Arrows between top nodes
    for i in range(4):
        arrow = s14.shapes.add_shape(MSO_SHAPE.RIGHT_ARROW, Inches(2.85 + i * 2.5), Inches(2.8), Inches(0.4), Inches(0.3))
        arrow.fill.solid()
        arrow.fill.fore_color.rgb = HEADER_OCHRE
        arrow.line.fill.background()

    # Bottom Two-Way WhatsApp Loop Card
    wa_card = s14.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(4.3), Inches(11.8), Inches(2.3))
    wa_card.fill.solid()
    wa_card.fill.fore_color.rgb = RGBColor(240, 253, 244) # Emerald light
    wa_card.line.color.rgb = RGBColor(34, 197, 94)
    wa_card.line.width = Pt(1.5)

    wt = wa_card.text_frame
    wt.word_wrap = True
    wt.margin_left = Inches(0.3)
    wt.margin_top = Inches(0.2)
    wp0 = wt.paragraphs[0]
    wp0.text = "Two-Way WhatsApp Closed-Loop Workflow"
    wp0.font.name = 'Georgia'
    wp0.font.size = Pt(16)
    wp0.font.bold = True
    wp0.font.color.rgb = RGBColor(21, 128, 61)

    steps = [
        "1. Outbound Dispatch: Backend sends WhatsApp message: '📋 Task: Fix Auth API | Due: Friday 5 PM | Reply DONE 42 when completed.'",
        "2. Direct Reception: Assignee receives prompt on their personal phone with zero software login required.",
        "3. Inbound Webhook Closure: Assignee replies 'DONE 42'. Meta WhatsApp Cloud Webhook invokes FastAPI endpoint.",
        "4. Live Synchronization: Task status changes to 'completed' in Firestore; Flutter Dashboard updates instantly with celebratory indicator.",
    ]
    for step in steps:
        p = wt.add_paragraph()
        p.text = "• " + step
        p.font.name = 'Calibri'
        p.font.size = Pt(11.5)
        p.font.color.rgb = TEXT_DARK
        p.space_before = Pt(4)

    # =========================================================================
    # SLIDE 15: IMPLEMENTATION
    # =========================================================================
    s15 = prs.slides.add_slide(blank_layout)
    add_base_header(s15, "Implementation")

    add_card(s15, Inches(0.8), Inches(1.65), Inches(5.6), Inches(4.9), "Frontend & UI Modules (Flutter)", [
        "Executive Glassmorphic Interface: Custom GlossyCard, GlossyBackground, and dynamic theme switching.",
        "Theme Modes: Light theme (bright professional default) & Dark theme (translucent glass selected pills).",
        "Attendee Chip Selector: Allows managers to tag employees to guide LLM name binding for Indian names.",
        "Smooth Page Transitions: 240ms cross-fade between main tabs and 280ms shared-axis on detail views.",
        "Audio/Document Picker: Integrated official file_picker 13.x with Android media permissions.",
        "Profile Avatar Module: Camera & Gallery image_picker integration with automatic image compression.",
        "Persistent Auto-Login: 'Remember Me' preference caching user credentials securely across restarts.",
    ])

    add_card(s15, Inches(6.8), Inches(1.65), Inches(5.6), Inches(4.9), "Backend & Intelligence Modules (FastAPI)", [
        "Asynchronous Endpoints: Non-blocking meeting upload, processing, and webhook listeners.",
        "Multi-Stage Processing Pipeline: Clear progress stages (Uploading → Transcribing → Understanding → Storing).",
        "LLM Prompt Engineering: Rigorous system prompts enforcing strict JSON schemas for summary & tasks.",
        "Zero-Hallucination Parsing: If an assignee or deadline isn't mentioned, prompt explicitly sets null.",
        "WhatsApp Webhook Engine: Parses inbound SMS/WhatsApp payloads and transitions task states.",
        "Database & Security: SQLAlchemy models, BCrypt encryption, and JWT token authentication.",
    ])

    # =========================================================================
    # SLIDE 16: PROJECT TIMELINE
    # =========================================================================
    s16 = prs.slides.add_slide(blank_layout)
    add_base_header(s16, "Project Timeline")

    timeline_data = [
        ("Phase 1: Weeks 1–3", "Problem Definition & Literature Survey", "Researched cognitive memory decay, studied transformer architectures, benchmarked competitors, drafted project synopsis."),
        ("Phase 2: Weeks 4–6", "System Architecture & API Modeling", "Designed client-server blueprint, modeled SQLAlchemy database schemas, built FastAPI prototype, established Git repository."),
        ("Phase 3: Weeks 7–9", "AI & Speech Pipeline Integration", "Integrated AssemblyAI speech-to-text, configured Google Gemini 1.5 structured JSON parsing, built WhatsApp Cloud API dispatcher."),
        ("Phase 4: Weeks 10–12", "Flutter Mobile App & UI Overhaul", "Developed Riverpod state management, built glassmorphic design system, implemented light/dark themes and attendee picker chips."),
        ("Phase 5: Weeks 13–14", "Testing, Verification & APK Build", "Conducted unit & integration testing, optimized Android SDK Gradle 9.3/AGP build, compiled standalone release APK (app-release.apk)."),
        ("Phase 6: Weeks 15–16", "Documentation & Academic Mapping", "Completed project report, mapped PO/PSO & UN SDGs, prepared demonstration videos, finalized PowerPoint presentation."),
    ]

    for i, (phase, title, desc) in enumerate(timeline_data):
        row = i // 2
        col = i % 2
        l = Inches(0.8 + col * 6.0)
        t = Inches(1.65 + row * 1.7)
        add_card(s16, l, t, Inches(5.6), Inches(1.5), f"{phase}: {title}", [desc], title_color=HEADER_OCHRE)

    # =========================================================================
    # SLIDE 17: CONCLUSION
    # =========================================================================
    s17 = prs.slides.add_slide(blank_layout)
    add_base_header(s17, "Conclusion")

    add_card(s17, Inches(0.8), Inches(1.65), Inches(5.6), Inches(4.9), "Key Achievements", [
        "Successfully Bridged the Verbal-to-Action Gap: Transformed ephemeral meeting conversations into structured, trackable organizational assets.",
        "Eliminated Human Memory Decay: Safeguarded critical decisions, deadlines, and technical commitments immediately after meetings.",
        "Pioneered Zero-Friction Task Closure: Proved that two-way WhatsApp interaction dramatically boosts task completion rates without portal fatigue.",
        "Delivered Production-Ready Software: Fully functional Flutter mobile application backed by asynchronous FastAPI microservices and verified release APK.",
    ], title_color=ACCENT_GREEN)

    add_card(s17, Inches(6.8), Inches(1.65), Inches(5.6), Inches(4.9), "Future Roadmap", [
        "Real-Time Stream Processing: Live audio capture and real-time task extraction during ongoing Google Meet & Zoom calls.",
        "On-Device Private LLM: Local model inference (Llama 3 / Mistral) running entirely on corporate private servers for sensitive discussions.",
        "Vernacular Language Support: Multi-lingual speech recognition supporting Hindi, Telugu, and code-mixed Indian English conversations.",
        "Predictive Workload Balancing: AI-driven workload distribution suggesting assignees based on historical velocity and capacity.",
    ], title_color=ACCENT_BLUE)

    # =========================================================================
    # SLIDE 18: PO/PSO & SDGS MAPPED
    # =========================================================================
    s18 = prs.slides.add_slide(blank_layout)
    add_base_header(s18, "PO/PSO & SDGs Mapped")

    add_card(s18, Inches(0.8), Inches(1.65), Inches(3.6), Inches(4.9), "Program Outcomes (PO)", [
        "PO1 (Engineering Knowledge): Applied principles of distributed systems, AI/LLMs, and RESTful APIs.",
        "PO2 (Problem Analysis): Formulated solutions for workplace information fragmentation and memory decay.",
        "PO3 (Design of Solutions): Engineered modular architecture with Flutter, FastAPI, and WhatsApp Webhooks.",
        "PO5 (Modern Tool Usage): Utilized Flutter, Riverpod, Gemini 1.5, AssemblyAI, Git, and Docker.",
        "PO8 (Ethics): Implemented strict data privacy, BCrypt hashing, and role-based access control.",
        "PO12 (Life-Long Learning): Mastered prompt engineering and modern mobile cross-platform paradigms.",
    ], title_color=HEADER_OCHRE)

    add_card(s18, Inches(4.8), Inches(1.65), Inches(3.6), Inches(4.9), "Program Specific (PSO)", [
        "PSO1: Ability to develop enterprise software applications using modern full-stack architectures and mobile technologies.",
        "  • Implemented through our Flutter client and FastAPI backend microservices.",
        "PSO2: Application of AI, natural language processing, and cloud services to real-world productivity challenges.",
        "  • Demonstrated via automated meeting diarization, LLM task extraction, and WhatsApp automation.",
    ], title_color=ACCENT_BLUE)

    add_card(s18, Inches(8.8), Inches(1.65), Inches(3.6), Inches(4.9), "UN SDGs Mapped", [
        "SDG 8: Decent Work & Economic Growth",
        "  • Reduces administrative burnout, streamlines workplace productivity, and prevents missed deadlines.",
        "SDG 9: Industry, Innovation & Infrastructure",
        "  • Fosters cutting-edge AI integration in enterprise workflows and communication tools.",
        "SDG 12: Responsible Consumption",
        "  • Promotes paperless office management by completely digitizing meeting minutes and task tracking.",
    ], title_color=ACCENT_GREEN)

    # =========================================================================
    # SLIDE 19: THANK YOU & Q&A
    # =========================================================================
    s19 = prs.slides.add_slide(blank_layout)
    bg19 = s19.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(7.5))
    bg19.fill.solid()
    bg19.fill.fore_color.rgb = PRIMARY_DARK
    bg19.line.fill.background()

    # Top accent band
    band19 = s19.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(0.2))
    band19.fill.solid()
    band19.fill.fore_color.rgb = HEADER_OCHRE
    band19.line.fill.background()

    # Methodist Logo on Thank You
    if os.path.exists(logo_path):
        s19.shapes.add_picture(logo_path, Inches(5.95), Inches(1.2), width=Inches(1.4))

    tybox = s19.shapes.add_textbox(Inches(1.5), Inches(2.8), Inches(10.333), Inches(3.8))
    tytf = tybox.text_frame
    tytf.word_wrap = True

    tp0 = tytf.paragraphs[0]
    tp0.alignment = PP_ALIGN.CENTER
    tp0.text = "Thank You!"
    tp0.font.name = 'Georgia'
    tp0.font.size = Pt(44)
    tp0.font.bold = True
    tp0.font.color.rgb = RGBColor(251, 191, 36)

    tp1 = tytf.add_paragraph()
    tp1.alignment = PP_ALIGN.CENTER
    tp1.text = 'T.ask: "What are your Tasks?"'
    tp1.font.name = 'Georgia'
    tp1.font.size = Pt(20)
    tp1.font.italic = True
    tp1.font.color.rgb = WHITE
    tp1.space_before = Pt(8)

    tp2 = tytf.add_paragraph()
    tp2.alignment = PP_ALIGN.CENTER
    tp2.text = "Questions & Suggestions Are Welcome"
    tp2.font.name = 'Calibri'
    tp2.font.size = Pt(16)
    tp2.font.color.rgb = RGBColor(148, 163, 184)
    tp2.space_before = Pt(20)

    tp3 = tytf.add_paragraph()
    tp3.alignment = PP_ALIGN.CENTER
    tp3.text = "Department of Computer Science & Engineering\nMethodist College of Engineering & Technology, Hyderabad"
    tp3.font.name = 'Calibri'
    tp3.font.size = Pt(13)
    tp3.font.color.rgb = RGBColor(203, 213, 225)
    tp3.space_before = Pt(12)

    # Save presentation
    output_path = os.path.abspath("T.ask_Methodist_College_Presentation.pptx")
    prs.save(output_path)
    print(f"Presentation generated successfully at: {output_path}")

if __name__ == "__main__":
    build_presentation()
