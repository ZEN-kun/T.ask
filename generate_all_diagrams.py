import os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches

os.makedirs('diagram_images', exist_ok=True)

# -------------------------------------------------------------
# Color definitions matching Methodist Ochre + Modern Tech Slate
# -------------------------------------------------------------
OCHRE = '#CC6600'
DARK_SLATE = '#0F172A'
MID_SLATE = '#1E293B'
LIGHT_BG = '#F8FAFC'
CARD_BG = '#FFFFFF'
BORDER_GRAY = '#CBD5E1'
BLUE_ACCENT = '#1D4ED8'
GREEN_ACCENT = '#15803D'
RED_ACCENT = '#B91C1C'
PURPLE_ACCENT = '#6D28D9'
TEAL_ACCENT = '#0F766E'

# 1. METHODOLOGY WORKFLOW DIAGRAM
def generate_methodology_diagram():
    fig, ax = plt.subplots(figsize=(10, 6.2), dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 6.2)
    ax.axis('off')

    # Background
    bg = patches.FancyBboxPatch((0.1, 0.1), 9.8, 6.0, boxstyle="round,pad=0.1,rounding_size=0.15",
                                facecolor='#F1F5F9', edgecolor=BORDER_GRAY, linewidth=1.5)
    ax.add_patch(bg)

    ax.text(5.0, 5.8, "T.ask Continuous Closed-Loop Methodology Pipeline", ha='center', va='center',
            fontsize=13, fontweight='bold', color=DARK_SLATE, family='sans-serif')

    steps = [
        ("1. Input Ingestion", "Audio (.mp3, .wav, .m4a)\nWritten Notes / Docs\nVoice Memos", '#EFF6FF', BLUE_ACCENT),
        ("2. Speech Diarization", "AssemblyAI Speech-to-Text\nSpeaker Labeling (Diarization)\nTimestamp Alignment", '#FEF3C7', OCHRE),
        ("3. AI Understanding", "Google Gemini 1.5 Context Analysis\nKey Decisions & Summaries\nAction Items Extraction", '#F3E8FF', PURPLE_ACCENT),
        ("4. Schema Validation", "Pydantic V2 Validation\nAssignee, Deadline & Priority\nFirestore Cloud Sync", '#ECFDF5', GREEN_ACCENT),
        ("5. Task Dispatch", "WhatsApp Cloud API Alert\nFlutter Push Notifications\nDirect Action Links", '#ECFEFF', TEAL_ACCENT),
        ("6. 2-Way Closure", "Assignee Replies 'DONE <ID>'\nWebhook Auto-Resolves\nReal-time Dashboard Metrics", '#FEF2F2', RED_ACCENT)
    ]

    # Positions in a 2x3 grid
    coords = [
        (0.6, 3.2), (3.7, 3.2), (6.8, 3.2),
        (6.8, 0.7), (3.7, 0.7), (0.6, 0.7)
    ]

    for (title, desc, bg_col, border_col), (x, y) in zip(steps, coords):
        box = patches.FancyBboxPatch((x, y), 2.6, 1.8, boxstyle="round,pad=0.08,rounding_size=0.12",
                                     facecolor=bg_col, edgecolor=border_col, linewidth=1.8)
        ax.add_patch(box)
        # Header banner inside box
        hdr = patches.FancyBboxPatch((x, y + 1.25), 2.6, 0.55, boxstyle="round,pad=0.04,rounding_size=0.1",
                                     facecolor=border_col, edgecolor=border_col)
        ax.add_patch(hdr)
        ax.text(x + 1.3, y + 1.52, title, ha='center', va='center',
                fontsize=9.5, fontweight='bold', color='white', family='sans-serif')
        ax.text(x + 1.3, y + 0.65, desc, ha='center', va='center',
                fontsize=8, color=MID_SLATE, family='sans-serif', linespacing=1.35)

    # Arrows between steps
    arrow_kw = dict(arrowstyle="-|>", mutation_scale=15, linewidth=2, color=OCHRE)
    # 1 -> 2
    ax.annotate("", xy=(3.6, 4.1), xytext=(3.25, 4.1), arrowprops=arrow_kw)
    # 2 -> 3
    ax.annotate("", xy=(6.7, 4.1), xytext=(6.35, 4.1), arrowprops=arrow_kw)
    # 3 -> 4 (Down)
    ax.annotate("", xy=(8.1, 2.6), xytext=(8.1, 3.1), arrowprops=arrow_kw)
    # 4 -> 5 (Left)
    ax.annotate("", xy=(6.4, 1.6), xytext=(6.75, 1.6), arrowprops=arrow_kw)
    # 5 -> 6 (Left)
    ax.annotate("", xy=(3.3, 1.6), xytext=(3.65, 1.6), arrowprops=arrow_kw)
    # 6 -> 1 (Continuous loop upward)
    ax.annotate("", xy=(1.9, 3.1), xytext=(1.9, 2.6),
                arrowprops=dict(arrowstyle="-|>", mutation_scale=15, linewidth=2, color=GREEN_ACCENT, linestyle='--'))
    ax.text(1.9, 2.85, "Continuous Sync", ha='center', va='center', fontsize=7.5,
            fontweight='bold', color=GREEN_ACCENT, backgroundcolor='white')

    plt.tight_layout()
    out_path = 'diagram_images/methodology_workflow.png'
    plt.savefig(out_path, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"Generated {out_path}")

# 2. SYSTEM ARCHITECTURE DIAGRAM
def generate_architecture_diagram():
    fig, ax = plt.subplots(figsize=(10, 6.2), dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 6.2)
    ax.axis('off')

    bg = patches.FancyBboxPatch((0.1, 0.1), 9.8, 6.0, boxstyle="round,pad=0.1,rounding_size=0.15",
                                facecolor='#F8FAFC', edgecolor=BORDER_GRAY, linewidth=1.5)
    ax.add_patch(bg)

    ax.text(5.0, 5.8, "T.ask 5-Tier Layered System Architecture", ha='center', va='center',
            fontsize=13, fontweight='bold', color=DARK_SLATE, family='sans-serif')

    layers = [
        ("Presentation Layer", "Flutter 3.x Mobile App  |  Material 3 Dark UI  |  Dashboard, Tasks, Meetings, Audio Picker",
         '#EFF6FF', BLUE_ACCENT, 4.75),
        ("State & ViewModel Layer", "Riverpod State Notifiers  |  Clean MVVM Pattern  |  AsyncValue Caching & Navigation",
         '#F3E8FF', PURPLE_ACCENT, 3.70),
        ("API & Gateway Layer", "FastAPI Python REST Endpoints  |  Pydantic Schemas  |  WhatsApp Inbound Webhooks",
         '#FEF3C7', OCHRE, 2.65),
        ("AI & Speech Processing Layer", "AssemblyAI (STT & Diarization)  |  Google Gemini 1.5 Pro (Semantic Extraction & Prioritization)",
         '#ECFDF5', GREEN_ACCENT, 1.60),
        ("Persistence & Integration Layer", "Google Cloud Firestore  |  WhatsApp Cloud API Gateway  |  APScheduler Background Workers",
         '#FEF2F2', RED_ACCENT, 0.55)
    ]

    for title, desc, bg_col, border_col, y in layers:
        card = patches.FancyBboxPatch((0.5, y), 9.0, 0.9, boxstyle="round,pad=0.06,rounding_size=0.1",
                                     facecolor=bg_col, edgecolor=border_col, linewidth=1.8)
        ax.add_patch(card)
        ax.text(0.7, y + 0.60, title, ha='left', va='center',
                fontsize=10, fontweight='bold', color=border_col, family='sans-serif')
        ax.text(0.7, y + 0.25, desc, ha='left', va='center',
                fontsize=8.5, color=MID_SLATE, family='sans-serif')

    # Connecting bi-directional arrows between layers
    arrow_kw = dict(arrowstyle="<|-|>", mutation_scale=12, linewidth=1.8, color='#64748B')
    for y_mid in [4.68, 3.63, 2.58, 1.53]:
        ax.annotate("", xy=(5.0, y_mid + 0.05), xytext=(5.0, y_mid - 0.05), arrowprops=arrow_kw)

    plt.tight_layout()
    out_path = 'diagram_images/system_architecture.png'
    plt.savefig(out_path, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"Generated {out_path}")

# 3. USE CASE DIAGRAM
def generate_use_case_diagram():
    fig, ax = plt.subplots(figsize=(10, 6.2), dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 6.2)
    ax.axis('off')

    # System boundary box
    sys_box = patches.FancyBboxPatch((2.2, 0.3), 5.6, 5.5, boxstyle="round,pad=0.1,rounding_size=0.15",
                                     facecolor='#F8FAFC', edgecolor=OCHRE, linewidth=2, linestyle='-')
    ax.add_patch(sys_box)
    ax.text(5.0, 5.55, "T.ask Management Platform System Boundary", ha='center', va='center',
            fontsize=11, fontweight='bold', color=DARK_SLATE, family='sans-serif')

    # Left Actor: Manager
    ax.plot([1.0], [4.3], marker='o', markersize=14, color=BLUE_ACCENT)
    ax.plot([1.0, 1.0], [4.1, 3.6], color=BLUE_ACCENT, linewidth=2) # body
    ax.plot([0.7, 1.3], [3.9, 3.9], color=BLUE_ACCENT, linewidth=2) # arms
    ax.plot([1.0, 0.7], [3.6, 3.1], color=BLUE_ACCENT, linewidth=2) # left leg
    ax.plot([1.0, 1.3], [3.6, 3.1], color=BLUE_ACCENT, linewidth=2) # right leg
    ax.text(1.0, 2.85, "Manager /\nMeeting Host", ha='center', va='center',
            fontsize=8.5, fontweight='bold', color=DARK_SLATE)

    # Left Actor: Employee
    ax.plot([1.0], [1.8], marker='o', markersize=14, color=TEAL_ACCENT)
    ax.plot([1.0, 1.0], [1.6, 1.1], color=TEAL_ACCENT, linewidth=2)
    ax.plot([0.7, 1.3], [1.4, 1.4], color=TEAL_ACCENT, linewidth=2)
    ax.plot([1.0, 0.7], [1.1, 0.6], color=TEAL_ACCENT, linewidth=2)
    ax.plot([1.0, 1.3], [1.1, 0.6], color=TEAL_ACCENT, linewidth=2)
    ax.text(1.0, 0.35, "Employee /\nAssignee", ha='center', va='center',
            fontsize=8.5, fontweight='bold', color=DARK_SLATE)

    # Right Actor: Gemini AI & AssemblyAI
    ax.plot([9.0], [4.5], marker='s', markersize=16, color=PURPLE_ACCENT)
    ax.text(9.0, 4.0, "<<Service>>\nAssemblyAI &\nGemini 1.5", ha='center', va='center',
            fontsize=8, fontweight='bold', color=PURPLE_ACCENT)

    # Right Actor: WhatsApp API
    ax.plot([9.0], [1.8], marker='s', markersize=16, color=GREEN_ACCENT)
    ax.text(9.0, 1.3, "<<Gateway>>\nWhatsApp Cloud\nAPI & Webhook", ha='center', va='center',
            fontsize=8, fontweight='bold', color=GREEN_ACCENT)

    # Use cases (ellipses)
    use_cases = [
        ("Upload Audio / Meeting Notes", 4.8),
        ("Transcribe & Diarize Audio", 4.1),
        ("Extract Tasks & Assignees", 3.4),
        ("Review & Edit Tasks in App", 2.7),
        ("Receive WhatsApp Notification", 2.0),
        ("Reply 'DONE' to Complete Task", 1.3),
        ("View Real-Time Metrics & Overdue", 0.6)
    ]

    uc_patches = []
    for text, y in use_cases:
        ellipse = patches.Ellipse((5.0, y), 3.8, 0.52, facecolor='#FFFFFF',
                                  edgecolor=DARK_SLATE, linewidth=1.4)
        ax.add_patch(ellipse)
        ax.text(5.0, y, text, ha='center', va='center', fontsize=8, fontweight='bold', color=MID_SLATE)
        uc_patches.append((5.0, y))

    # Connect lines Manager -> UC 0, 3, 6
    ax.plot([1.3, 3.1], [3.9, 4.8], color='#64748B', linewidth=1.2)
    ax.plot([1.3, 3.1], [3.9, 2.7], color='#64748B', linewidth=1.2)
    ax.plot([1.3, 3.1], [3.9, 0.6], color='#64748B', linewidth=1.2)

    # Connect Employee -> UC 3, 4, 5
    ax.plot([1.3, 3.1], [1.4, 2.7], color='#64748B', linewidth=1.2)
    ax.plot([1.3, 3.1], [1.4, 2.0], color='#64748B', linewidth=1.2)
    ax.plot([1.3, 3.1], [1.4, 1.3], color='#64748B', linewidth=1.2)

    # Connect AI Service -> UC 1, 2
    ax.plot([8.3, 6.9], [4.5, 4.1], color=PURPLE_ACCENT, linewidth=1.2, linestyle='--')
    ax.plot([8.3, 6.9], [4.5, 3.4], color=PURPLE_ACCENT, linewidth=1.2, linestyle='--')

    # Connect WhatsApp -> UC 4, 5
    ax.plot([8.3, 6.9], [1.8, 2.0], color=GREEN_ACCENT, linewidth=1.2, linestyle='--')
    ax.plot([8.3, 6.9], [1.8, 1.3], color=GREEN_ACCENT, linewidth=1.2, linestyle='--')

    plt.tight_layout()
    out_path = 'diagram_images/use_case_diagram.png'
    plt.savefig(out_path, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"Generated {out_path}")

# 4. SEQUENCE DIAGRAM
def generate_sequence_diagram():
    fig, ax = plt.subplots(figsize=(10, 6.2), dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 6.2)
    ax.axis('off')

    bg = patches.FancyBboxPatch((0.1, 0.1), 9.8, 6.0, boxstyle="round,pad=0.1,rounding_size=0.15",
                                facecolor='#F8FAFC', edgecolor=BORDER_GRAY, linewidth=1.5)
    ax.add_patch(bg)

    ax.text(5.0, 5.85, "T.ask End-to-End Execution Sequence Diagram", ha='center', va='center',
            fontsize=12, fontweight='bold', color=DARK_SLATE, family='sans-serif')

    lifelines = [
        ("Host / Manager", 1.0, BLUE_ACCENT),
        ("Flutter App", 2.6, TEAL_ACCENT),
        ("FastAPI Backend", 4.2, OCHRE),
        ("AssemblyAI + Gemini", 5.8, PURPLE_ACCENT),
        ("Firestore DB", 7.4, GREEN_ACCENT),
        ("WhatsApp / Assignee", 9.0, RED_ACCENT)
    ]

    for name, x, col in lifelines:
        # Header box
        hdr = patches.FancyBboxPatch((x - 0.7, 5.2), 1.4, 0.45, boxstyle="round,pad=0.03,rounding_size=0.08",
                                     facecolor=col, edgecolor=col)
        ax.add_patch(hdr)
        ax.text(x, 5.42, name, ha='center', va='center', fontsize=7.5, fontweight='bold', color='white')
        # Vertical dashed lifeline
        ax.plot([x, x], [5.1, 0.4], color='#94A3B8', linestyle='--', linewidth=1.2)

    messages = [
        (1.0, 2.6, 4.8, "1. Select audio / notes", BLUE_ACCENT),
        (2.6, 4.2, 4.3, "2. POST /process-meeting (multipart)", TEAL_ACCENT),
        (4.2, 5.8, 3.8, "3. STT Diarize & Gemini Extract", OCHRE),
        (5.8, 4.2, 3.3, "4. Structured Tasks JSON", PURPLE_ACCENT),
        (4.2, 7.4, 2.8, "5. Persist Tasks & Status", GREEN_ACCENT),
        (4.2, 9.0, 2.3, "6. Dispatch WhatsApp task alerts", RED_ACCENT),
        (9.0, 4.2, 1.7, "7. Inbound reply 'DONE <ID>'", RED_ACCENT),
        (4.2, 7.4, 1.2, "8. Update status: COMPLETED", GREEN_ACCENT),
        (4.2, 2.6, 0.7, "9. Live Stream Update to UI", TEAL_ACCENT)
    ]

    for x1, x2, y, txt, col in messages:
        ax.annotate("", xy=(x2, y), xytext=(x1, y),
                    arrowprops=dict(arrowstyle="-|>", mutation_scale=10, linewidth=1.5, color=col))
        mid_x = (x1 + x2) / 2
        ax.text(mid_x, y + 0.13, txt, ha='center', va='bottom',
                fontsize=6.8, fontweight='bold', color=DARK_SLATE,
                bbox=dict(boxstyle="round,pad=0.15", facecolor='white', edgecolor='none', alpha=0.85))

    plt.tight_layout()
    out_path = 'diagram_images/sequence_diagram.png'
    plt.savefig(out_path, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"Generated {out_path}")

# 5. CLASS DIAGRAM
def generate_class_diagram():
    fig, ax = plt.subplots(figsize=(10, 6.2), dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 6.2)
    ax.axis('off')

    bg = patches.FancyBboxPatch((0.1, 0.1), 9.8, 6.0, boxstyle="round,pad=0.1,rounding_size=0.15",
                                facecolor='#F8FAFC', edgecolor=BORDER_GRAY, linewidth=1.5)
    ax.add_patch(bg)

    ax.text(5.0, 5.85, "T.ask Object-Oriented Domain UML Class Diagram", ha='center', va='center',
            fontsize=12, fontweight='bold', color=DARK_SLATE, family='sans-serif')

    classes = [
        ("AppUser", 0.5, 3.2, 2.7, 2.2,
         ["+ id: String", "+ name: String", "+ email: String", "+ phone: String", "+ role: UserRole"],
         ["+ login(): Boolean", "+ getAssignedTasks(): List", "+ updatePresence(): Void"],
         BLUE_ACCENT),

        ("Meeting", 3.7, 3.2, 2.7, 2.2,
         ["+ id: String", "+ title: String", "+ audioUrl: String", "+ transcript: String", "+ status: MeetingStatus"],
         ["+ uploadAudio(): Void", "+ transcribe(): String", "+ extractTasks(): List"],
         OCHRE),

        ("TaskModel", 6.9, 3.2, 2.7, 2.2,
         ["+ id: String", "+ meetingId: String", "+ title: String", "+ priority: Priority", "+ status: TaskStatus"],
         ["+ markCompleted(): Void", "+ reassign(user): Void", "+ escalate(): Void"],
         GREEN_ACCENT),

        ("WhatsAppWebhook", 1.8, 0.5, 3.0, 1.9,
         ["+ messageId: String", "+ senderPhone: String", "+ commandText: String", "+ timestamp: DateTime"],
         ["+ parseCommand(): Tuple", "+ verifySignature(): Boolean"],
         PURPLE_ACCENT),

        ("DashboardMetrics", 5.6, 0.5, 3.0, 1.9,
         ["+ totalTasks: Int", "+ pendingCount: Int", "+ completedCount: Int", "+ overdueCount: Int"],
         ["+ calculateVelocity(): Float", "+ streamRealtime(): Stream"],
         TEAL_ACCENT)
    ]

    for title, x, y, w, h, attrs, methods, col in classes:
        # Box outline
        card = patches.FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.04,rounding_size=0.08",
                                     facecolor='#FFFFFF', edgecolor=col, linewidth=1.6)
        ax.add_patch(card)
        # Class Header
        hdr = patches.FancyBboxPatch((x, y + h - 0.45), w, 0.45, boxstyle="round,pad=0.02,rounding_size=0.06",
                                     facecolor=col, edgecolor=col)
        ax.add_patch(hdr)
        ax.text(x + w / 2, y + h - 0.22, title, ha='center', va='center',
                fontsize=8.5, fontweight='bold', color='white')

        # Attributes
        attr_txt = "\n".join(attrs)
        ax.text(x + 0.12, y + h - 0.55, attr_txt, ha='left', va='top',
                fontsize=6.8, color=MID_SLATE, family='monospace', linespacing=1.2)

        # Divider line
        div_y = y + 0.8
        ax.plot([x, x + w], [div_y, div_y], color=BORDER_GRAY, linewidth=1.0)

        # Methods
        meth_txt = "\n".join(methods)
        ax.text(x + 0.12, div_y - 0.1, meth_txt, ha='left', va='top',
                fontsize=6.8, color=MID_SLATE, family='monospace', linespacing=1.2)

    # Association lines with multiplicities
    # AppUser (1) ---- (0..*) Meeting
    ax.plot([3.2, 3.7], [4.3, 4.3], color='#475569', linewidth=1.4)
    ax.text(3.3, 4.45, "1", fontsize=7.5, fontweight='bold', color=DARK_SLATE)
    ax.text(3.55, 4.45, "*", fontsize=8.5, fontweight='bold', color=DARK_SLATE)

    # Meeting (1) ---- (1..*) TaskModel
    ax.plot([6.4, 6.9], [4.3, 4.3], color='#475569', linewidth=1.4)
    ax.text(6.5, 4.45, "1", fontsize=7.5, fontweight='bold', color=DARK_SLATE)
    ax.text(6.75, 4.45, "1..*", fontsize=7.5, fontweight='bold', color=DARK_SLATE)

    # WhatsAppWebhook updates TaskModel
    ax.plot([4.8, 6.9], [1.45, 3.3], color=PURPLE_ACCENT, linestyle='--', linewidth=1.3)
    ax.text(5.7, 2.2, "<<updates>>", fontsize=7, color=PURPLE_ACCENT, rotation=35)

    # DashboardMetrics observes TaskModel
    ax.plot([7.1, 8.0], [2.4, 3.2], color=TEAL_ACCENT, linestyle='--', linewidth=1.3)
    ax.text(7.6, 2.7, "<<aggregates>>", fontsize=7, color=TEAL_ACCENT, rotation=45)

    plt.tight_layout()
    out_path = 'diagram_images/class_diagram.png'
    plt.savefig(out_path, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"Generated {out_path}")

# 6. ACTIVITY DIAGRAM
def generate_activity_diagram():
    fig, ax = plt.subplots(figsize=(10, 6.2), dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 6.2)
    ax.axis('off')

    bg = patches.FancyBboxPatch((0.1, 0.1), 9.8, 6.0, boxstyle="round,pad=0.1,rounding_size=0.15",
                                facecolor='#F8FAFC', edgecolor=BORDER_GRAY, linewidth=1.5)
    ax.add_patch(bg)

    ax.text(5.0, 5.85, "T.ask End-to-End Operational Activity Diagram", ha='center', va='center',
            fontsize=12, fontweight='bold', color=DARK_SLATE, family='sans-serif')

    # Initial node (black circle)
    start = patches.Circle((1.0, 4.8), 0.18, facecolor=DARK_SLATE, edgecolor=DARK_SLATE)
    ax.add_patch(start)
    ax.text(1.0, 5.15, "Start", ha='center', va='center', fontsize=7.5, fontweight='bold')

    arrow_kw = dict(arrowstyle="-|>", mutation_scale=12, linewidth=1.5, color='#475569')

    # Action 1: Upload meeting audio / notes
    a1 = patches.FancyBboxPatch((1.7, 4.45), 1.9, 0.7, boxstyle="round,pad=0.06,rounding_size=0.12",
                                facecolor='#EFF6FF', edgecolor=BLUE_ACCENT, linewidth=1.4)
    ax.add_patch(a1)
    ax.text(2.65, 4.8, "Upload Audio / Notes\nin Mobile App", ha='center', va='center', fontsize=7.5, color=DARK_SLATE)
    ax.annotate("", xy=(1.7, 4.8), xytext=(1.2, 4.8), arrowprops=arrow_kw)

    # Decision 1: Audio format?
    d1 = patches.Polygon([[4.4, 4.8], [4.8, 5.15], [5.2, 4.8], [4.8, 4.45]], closed=True,
                         facecolor='#FEF3C7', edgecolor=OCHRE, linewidth=1.4)
    ax.add_patch(d1)
    ax.text(4.8, 4.8, "Audio?", ha='center', va='center', fontsize=7, fontweight='bold', color=DARK_SLATE)
    ax.annotate("", xy=(4.4, 4.8), xytext=(3.6, 4.8), arrowprops=arrow_kw)

    # Branch Audio: AssemblyAI
    a_stt = patches.FancyBboxPatch((5.8, 4.95), 1.8, 0.65, boxstyle="round,pad=0.06,rounding_size=0.12",
                                   facecolor='#FEF3C7', edgecolor=OCHRE, linewidth=1.4)
    ax.add_patch(a_stt)
    ax.text(6.7, 5.27, "AssemblyAI\nSpeech-to-Text", ha='center', va='center', fontsize=7.2, color=DARK_SLATE)
    ax.annotate("", xy=(5.8, 5.27), xytext=(5.0, 5.0), arrowprops=arrow_kw)
    ax.text(5.3, 5.2, "[Yes]", fontsize=6.8, color=OCHRE, fontweight='bold')

    # Branch Text: Direct ingestion
    a_txt = patches.FancyBboxPatch((5.8, 3.95), 1.8, 0.65, boxstyle="round,pad=0.06,rounding_size=0.12",
                                   facecolor='#F1F5F9', edgecolor='#94A3B8', linewidth=1.4)
    ax.add_patch(a_txt)
    ax.text(6.7, 4.27, "Direct Transcript\nIngestion", ha='center', va='center', fontsize=7.2, color=DARK_SLATE)
    ax.annotate("", xy=(5.8, 4.27), xytext=(5.0, 4.6), arrowprops=arrow_kw)
    ax.text(5.3, 4.4, "[No]", fontsize=6.8, color='#64748B', fontweight='bold')

    # Merge node -> Gemini AI
    a_gem = patches.FancyBboxPatch((8.1, 4.3), 1.6, 1.0, boxstyle="round,pad=0.06,rounding_size=0.12",
                                   facecolor='#F3E8FF', edgecolor=PURPLE_ACCENT, linewidth=1.4)
    ax.add_patch(a_gem)
    ax.text(8.9, 4.8, "Gemini 1.5 Pro\nTask Extraction\n& Prioritization", ha='center', va='center',
            fontsize=7.2, color=DARK_SLATE)
    ax.annotate("", xy=(8.1, 5.0), xytext=(7.6, 5.27), arrowprops=arrow_kw)
    ax.annotate("", xy=(8.1, 4.6), xytext=(7.6, 4.27), arrowprops=arrow_kw)

    # Down to Fork Bar (Parallel Dispatch)
    fork_bar = patches.Rectangle((8.7, 3.3), 0.4, 0.08, facecolor=DARK_SLATE)
    ax.add_patch(fork_bar)
    ax.annotate("", xy=(8.9, 3.4), xytext=(8.9, 4.3), arrowprops=arrow_kw)

    # Branch 1: Update Mobile App
    a_mob = patches.FancyBboxPatch((6.0, 2.3), 2.2, 0.7, boxstyle="round,pad=0.06,rounding_size=0.12",
                                   facecolor='#EFF6FF', edgecolor=BLUE_ACCENT, linewidth=1.4)
    ax.add_patch(a_mob)
    ax.text(7.1, 2.65, "Sync Real-Time\nFlutter Dashboard", ha='center', va='center', fontsize=7.2, color=DARK_SLATE)
    ax.annotate("", xy=(8.2, 2.65), xytext=(8.7, 3.3), arrowprops=arrow_kw)

    # Branch 2: WhatsApp Dispatch
    a_wa = patches.FancyBboxPatch((2.7, 2.3), 2.4, 0.7, boxstyle="round,pad=0.06,rounding_size=0.12",
                                  facecolor='#ECFDF5', edgecolor=GREEN_ACCENT, linewidth=1.4)
    ax.add_patch(a_wa)
    ax.text(3.9, 2.65, "Send WhatsApp Alerts\nto Assignees", ha='center', va='center', fontsize=7.2, color=DARK_SLATE)
    ax.annotate("", xy=(5.1, 2.65), xytext=(6.0, 2.65), arrowprops=arrow_kw)

    # Action: Assignee Completes Task
    a_reply = patches.FancyBboxPatch((2.7, 1.1), 2.4, 0.7, boxstyle="round,pad=0.06,rounding_size=0.12",
                                     facecolor='#FEF2F2', edgecolor=RED_ACCENT, linewidth=1.4)
    ax.add_patch(a_reply)
    ax.text(3.9, 1.45, "Assignee Texts Back\n'DONE <TASK_ID>'", ha='center', va='center', fontsize=7.2, color=DARK_SLATE)
    ax.annotate("", xy=(3.9, 1.8), xytext=(3.9, 2.3), arrowprops=arrow_kw)

    # Join & Auto-resolve
    a_res = patches.FancyBboxPatch((6.0, 1.1), 2.2, 0.7, boxstyle="round,pad=0.06,rounding_size=0.12",
                                   facecolor='#ECFEFF', edgecolor=TEAL_ACCENT, linewidth=1.4)
    ax.add_patch(a_res)
    ax.text(7.1, 1.45, "Webhook Auto-Resolves\n& Updates Metrics", ha='center', va='center', fontsize=7.2, color=DARK_SLATE)
    ax.annotate("", xy=(6.0, 1.45), xytext=(5.1, 1.45), arrowprops=arrow_kw)

    # Final Node (Bullseye)
    final_outer = patches.Circle((9.0, 1.45), 0.22, facecolor='white', edgecolor=DARK_SLATE, linewidth=1.5)
    final_inner = patches.Circle((9.0, 1.45), 0.12, facecolor=DARK_SLATE)
    ax.add_patch(final_outer)
    ax.add_patch(final_inner)
    ax.annotate("", xy=(8.75, 1.45), xytext=(8.2, 1.45), arrowprops=arrow_kw)
    ax.text(9.0, 1.05, "End", ha='center', va='center', fontsize=7.5, fontweight='bold')

    plt.tight_layout()
    out_path = 'diagram_images/activity_diagram.png'
    plt.savefig(out_path, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"Generated {out_path}")

if __name__ == '__main__':
    generate_methodology_diagram()
    generate_architecture_diagram()
    generate_use_case_diagram()
    generate_sequence_diagram()
    generate_class_diagram()
    generate_activity_diagram()
    print("All 6 diagrams generated successfully!")
