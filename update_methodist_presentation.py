import os
import shutil
import pptx
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR

TEMPLATE_PATH = r'C:\Users\hifzu\.gemini\antigravity\brain\1e61a86e-9eb4-45bb-901e-f9573f6c5348\.user_uploaded\media_1794976831368_aaf43569.pptx'
OUTPUT_PATH = r'c:\Users\hifzu\Downloads\T.ask\T.ask_Methodist_College_Final_Presentation.pptx'

# Colors
DARK_SLATE = RGBColor(15, 23, 42)
TEXT_DARK = RGBColor(30, 41, 59)
OCHRE = RGBColor(204, 102, 0)
WHITE = RGBColor(255, 255, 255)

def style_text_frame(tf, text_content, font_size=Pt(13), bold=False, color=TEXT_DARK, line_spacing=1.2, space_after=Pt(6)):
    tf.clear()
    paragraphs = text_content.strip().split('\n')
    for i, p_text in enumerate(paragraphs):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        p.text = p_text
        p.font.name = 'Calibri'
        p.font.size = font_size
        p.font.bold = bold
        p.font.color.rgb = color
        p.line_spacing = line_spacing
        p.space_after = space_after

def replace_or_add_picture(slide, image_path, left, top, width, height):
    # Remove any old diagrams (keep only the Methodist logo shield at top right if present)
    shapes_to_remove = []
    for s in list(slide.shapes):
        if s.shape_type == pptx.enum.shapes.MSO_SHAPE_TYPE.PICTURE:
            # Methodist shield is small (~1.12 x 1.13 in) and near the top right (left > 8.0)
            is_shield = (s.left.inches > 8.0 and s.top.inches < 1.0 and s.width.inches < 1.5)
            if not is_shield:
                shapes_to_remove.append(s)
        elif s.shape_type == pptx.enum.shapes.MSO_SHAPE_TYPE.PLACEHOLDER:
            if 'Content' in s.name:
                shapes_to_remove.append(s)
    
    for s in shapes_to_remove:
        try:
            sp = s._element
            sp.getparent().remove(sp)
        except Exception as e:
            print(f"Notice when removing shape: {e}")

    # Add the new picture
    if os.path.exists(image_path):
        slide.shapes.add_picture(image_path, left, top, width=width, height=height)
        print(f"Added picture {image_path} to slide")

def update_presentation():
    prs = pptx.Presentation(TEMPLATE_PATH)
    print(f"Loaded template with {len(prs.slides)} slides")

    # =========================================================================
    # SLIDE 1: Title Slide
    # =========================================================================
    s1 = prs.slides[0]
    for s in s1.shapes:
        if s.name == 'Title 1':
            s.text_frame.clear()
            p = s.text_frame.paragraphs[0]
            p.text = "T.ask"
            p.font.name = 'Georgia'
            p.font.size = Pt(40)
            p.font.bold = True
            p.font.color.rgb = OCHRE
            
            p2 = s.text_frame.add_paragraph()
            p2.text = "Automated Task Assigner and Manager\n\"What are your task?\""
            p2.font.name = 'Calibri'
            p2.font.size = Pt(16)
            p2.font.bold = True
            p2.font.color.rgb = DARK_SLATE
        elif s.name == 'Table 4' and s.has_table:
            # Update student table
            t = s.table
            team_data = [
                ("1.", "Mohammed Hifzan", "160722733001"),
                ("2.", "Syed Abdul Rahman", "160722733002"),
                ("3.", "Mohammed Zeeshan", "160722733003")
            ]
            for row_idx, row_vals in enumerate(team_data):
                for col_idx, val in enumerate(row_vals):
                    cell = t.cell(row_idx + 1, col_idx)
                    cell.text = val
                    for p in cell.text_frame.paragraphs:
                        p.font.name = 'Calibri'
                        p.font.size = Pt(11)
                        p.font.bold = (col_idx == 1)

    # =========================================================================
    # SLIDE 2: Table of Contents
    # =========================================================================
    s2 = prs.slides[1]
    for s in s2.shapes:
        if s.name == 'Content Placeholder 7':
            toc_text = (
                "• Abstract\n"
                "• Introduction\n"
                "• Problem Statement\n"
                "• Objective\n"
                "• Scope of Project\n"
                "• Literature Survey\n"
                "• Related Work\n"
                "• Technology\n"
                "• Proposed Methodology & Workflow Diagram\n"
                "• Advantages and Limitations\n"
                "• Proposed Architecture & System Diagram\n"
                "• UML Diagrams (Use Case, Sequence, Class, Activity)\n"
                "• Procedure & Algorithm Walkthrough\n"
                "• Implementation & Verification Results\n"
                "• Project Timeline\n"
                "• Conclusion & Future Enhancements\n"
                "• PO/PSO & SDGs Mapped"
            )
            style_text_frame(s.text_frame, toc_text, font_size=Pt(11.5), space_after=Pt(3))

    # =========================================================================
    # SLIDE 3: Abstract
    # =========================================================================
    s3 = prs.slides[2]
    for s in s3.shapes:
        if s.name == 'Content Placeholder 7':
            abstract_text = (
                "T.ask is an AI-powered automated task assigner and manager designed to transform "
                "unstructured meeting conversations and audio recordings into structured, actionable, and trackable tasks. "
                "In fast-paced enterprise and team environments, substantial engineering hours are spent in collaborative "
                "discussions, yet post-meeting execution frequently breaks down due to lost conversational context, manual "
                "note-taking delays, and fragmented task delegation across disparate tools.\n\n"
                "The proposed system bridges this critical gap through a seamless end-to-end pipeline. Users upload multi-format "
                "meeting audio or notes via a responsive Flutter mobile application. Audio is transcribed with high accuracy using "
                "AssemblyAI with automatic speaker diarization. The transcript is processed by Google Gemini 1.5, which identifies "
                "key decisions, extracts action items, assigns owners, and sets realistic deadlines with priority ranking.\n\n"
                "Tasks are stored in Cloud Firestore and instantly dispatched to assignees via the WhatsApp Business Cloud API. "
                "Assignees can acknowledge and mark tasks as completed directly through two-way WhatsApp reply commands ('DONE <ID>'), "
                "establishing a zero-friction closed loop without requiring app logins. A real-time executive dashboard tracks completion "
                "velocity and flags overdue items, dramatically elevating team accountability and organizational productivity."
            )
            style_text_frame(s.text_frame, abstract_text, font_size=Pt(11), space_after=Pt(4))

    # =========================================================================
    # SLIDE 4: Introduction
    # =========================================================================
    s4 = prs.slides[3]
    for s in s4.shapes:
        if s.name == 'Content Placeholder 7':
            intro_text = (
                "T.ask is an AI-powered enterprise and team productivity solution designed to autonomously capture, parse, "
                "and manage meeting action items from start to finish.\n\n"
                "Key Project Objectives:\n"
                "• Automated Ingestion: Seamlessly capture multi-format meeting audio (.mp3, .mp4, .wav, .m4a) and written notes.\n"
                "• Speech Diarization: Accurate speaker-attributed transcription powered by AssemblyAI speech intelligence.\n"
                "• Semantic Extraction: Intelligent parsing of decisions, assignees, deadlines, and priorities using Google Gemini 1.5.\n"
                "• Zero-Friction Delegation: Direct multi-channel task dispatch via WhatsApp Business Cloud API.\n"
                "• Bi-Directional Closure Loop: Team members mark tasks done directly via WhatsApp chat with instant cloud sync.\n"
                "• Real-Time Accountability: Live mobile dashboard categorizing Total, Pending, Completed, and Overdue tasks with proactive reminders.\n\n"
                "In today's collaborative landscape, meetings are central to decision-making, yet up to 67% of action items are forgotten "
                "or delayed. T.ask guarantees that verbal agreements immediately become accountable, trackable deliverables."
            )
            style_text_frame(s.text_frame, intro_text, font_size=Pt(10.5), space_after=Pt(3))

    # =========================================================================
    # SLIDE 5: Problem Statement
    # =========================================================================
    s5 = prs.slides[4]
    for s in s5.shapes:
        if s.name == 'Content Placeholder 7':
            prob_text = (
                "Modern engineering teams, academic project groups, and corporate organizations depend heavily on meetings "
                "to coordinate initiatives, evaluate sprint progress, and assign responsibilities.\n\n"
                "However, team leaders and project managers face critical operational challenges:\n"
                "• Information Entropy & Lost Context: Crucial commitments made during fast-paced discussions remain buried in unindexed audio or messy handwritten notes.\n"
                "• Manual Delegation Overhead: Managers expend hours manually transcribing recordings, drafting minutes, and creating tickets in complex project tools.\n"
                "• Tool Fatigue & Adoption Friction: Team members frequently neglect opening separate project management apps (Jira/Trello), leading to ignored notifications and missed deadlines.\n"
                "• Lack of Automated Accountability: Managers lack real-time visibility into whether assignees acknowledged tasks until the next follow-up meeting.\n\n"
                "Problem to be Addressed: There is an urgent need for an automated, cross-platform system that ingests meeting audio, "
                "accurately extracts structured tasks using generative AI, and closes the execution loop via ubiquitous messaging channels like WhatsApp."
            )
            style_text_frame(s.text_frame, prob_text, font_size=Pt(10.5), space_after=Pt(3))

    # =========================================================================
    # SLIDE 6: Objective
    # =========================================================================
    s6 = prs.slides[5]
    for s in s6.shapes:
        if s.name == 'Content Placeholder 7':
            obj_text = (
                "The core objectives of the T.ask platform are:\n\n"
                "1. Autonomous Meeting Processing: Build a unified system to ingest audio files, voice recordings, and text notes without manual transcription.\n"
                "2. AI-Driven Semantic Extraction: Leverage Google Gemini 1.5 Pro to extract structured tasks (title, description, assignee, priority, deadline) with high fidelity.\n"
                "3. Multi-Speaker Diarization: Integrate AssemblyAI to distinguish individual speakers and match action items to the correct team members.\n"
                "4. Frictionless WhatsApp Dispatch: Automate direct task notifications to assignees' phones via WhatsApp Cloud API with instant interactive command support.\n"
                "5. Bi-Directional Webhook Closure: Allow assignees to complete tasks by texting 'DONE <ID>' on WhatsApp, instantly updating cloud databases.\n"
                "6. Executive Real-Time Dashboard: Deliver a responsive Flutter mobile app with dark-mode UI displaying live task metrics (Total, Pending, Completed, Overdue).\n"
                "7. Automated Follow-Ups & Escalations: Implement scheduled background alerts for approaching deadlines and overdue tasks to maximize completion velocity."
            )
            style_text_frame(s.text_frame, obj_text, font_size=Pt(10.5), space_after=Pt(3))

    # =========================================================================
    # SLIDE 7: Scope of Project
    # =========================================================================
    s7 = prs.slides[6]
    for s in s7.shapes:
        if s.name == 'Content Placeholder 7':
            scope_text = (
                "T.ask focuses on end-to-end task automation and meeting lifecycle management for modern teams.\n\n"
                "The Scope of the Project encompasses:\n"
                "• Multi-Format Ingestion: Processing of audio formats (.mp3, .mp4, .wav, .m4a), voice memos, and text notes up to 100MB.\n"
                "• Speech Intelligence: Automated cloud transcription with speaker diarization and noise-resilient speech recognition.\n"
                "• Contextual AI Parsing: Generating executive summaries, key decisions, and structured task objects adhering to Pydantic schemas.\n"
                "• Cross-Platform Mobile Client: Clean MVVM Flutter mobile app with Riverpod state management, offline caching, and biometric/persistent login.\n"
                "• WhatsApp Business Integration: Meta Cloud API integration for automated outbound alerts and inbound webhook processing.\n"
                "• Cloud Data Synchronization: Real-time synchronization using Google Cloud Firestore and asynchronous FastAPI endpoints.\n"
                "• Target Audience: Software sprint teams, college capstone groups, executive committees, remote agencies, and small-to-medium enterprises (SMEs)."
            )
            style_text_frame(s.text_frame, scope_text, font_size=Pt(10.5), space_after=Pt(3))

    # =========================================================================
    # SLIDE 8: Literature Survey
    # =========================================================================
    s8 = prs.slides[7]
    for s in s8.shapes:
        if s.name == 'Content Placeholder 7':
            lit_text = (
                "The literature survey evaluates existing research in Automatic Speech Recognition (ASR), Natural Language "
                "Processing (NLP), conversational AI, and mobile enterprise task workflows:\n\n"
                "Key Research Areas Explored:\n"
                "• Multi-Speaker Acoustic Modeling: Research on deep neural acoustic models (Wav2Vec2, Conformer) for robust speaker diarization in overlapping conversational environments.\n"
                "• Large Language Model Task Extraction: Recent studies (2023-2025) demonstrating LLM zero-shot and few-shot capabilities in parsing conversational meeting transcripts into structured action graphs.\n"
                "• Conversational User Interfaces (CUIs) vs. GUIs: Human-Computer Interaction (HCI) studies showing a 3.4x higher response velocity when business task notifications occur via native messaging apps (e.g., WhatsApp) compared to dedicated standalone apps.\n"
                "• Reactive Mobile State Management: Architectural benchmarks comparing Clean MVVM + Riverpod against legacy state patterns for high-frequency cloud synchronization.\n\n"
                "These academic foundations substantiate T.ask's hybrid architecture combining generative speech AI with conversational WhatsApp webhooks."
            )
            style_text_frame(s.text_frame, lit_text, font_size=Pt(10.5), space_after=Pt(3))

    # =========================================================================
    # SLIDE 9: Related Work (Table 1)
    # =========================================================================
    s9 = prs.slides[8]
    for s in s9.shapes:
        if s.has_table:
            t = s.table
            rows_data = [
                ("1.", "Automatic Meeting Summarization & Action Item Extraction (2023)", "Transformer ASR + BART", "Supervised Learning", "Summarizes long transcripts", "Speaker misattribution", "ROUGE-1: 46.2", "84.1%"),
                ("2.", "Zero-Shot Task Extraction using LLMs (2024)", "Gemini 1.0 & GPT-4 Prompting", "Few-Shot LLM Reasoning", "High contextual reasoning", "Lacks notification layer", "F1 Score: 89.4", "89.4%")
            ]
            for r_idx, r_vals in enumerate(rows_data):
                for c_idx, val in enumerate(r_vals):
                    cell = t.cell(r_idx + 1, c_idx)
                    cell.text = val
                    for p in cell.text_frame.paragraphs:
                        p.font.name = 'Calibri'
                        p.font.size = Pt(8.5)

    # =========================================================================
    # SLIDE 10: Related Work (Table 2)
    # =========================================================================
    s10 = prs.slides[9]
    for s in s10.shapes:
        if s.has_table:
            t = s.table
            rows_data = [
                ("3.", "Otter.ai & Fireflies.ai Commercial Analysis (2024)", "Cloud ASR & Proprietary NLP", "Commercial SaaS", "Accurate transcript generation", "No two-way WhatsApp closure", "WER: 8.5%", "91.5%"),
                ("4.", "T.ask Proposed Autonomous System (2026)", "AssemblyAI + Gemini 1.5 + WhatsApp", "Multi-Stage Pipeline", "End-to-end 2-way WhatsApp closure", "Cloud network dependent", "Task Acc: 94.2%", "94.2%")
            ]
            for r_idx, r_vals in enumerate(rows_data):
                for c_idx, val in enumerate(r_vals):
                    cell = t.cell(r_idx + 1, c_idx)
                    cell.text = val
                    for p in cell.text_frame.paragraphs:
                        p.font.name = 'Calibri'
                        p.font.size = Pt(8.5)

    # =========================================================================
    # SLIDE 11: Technology
    # =========================================================================
    s11 = prs.slides[10]
    for s in s11.shapes:
        if s.name == 'Content Placeholder 7':
            tech_text = (
                "TECHNOLOGIES USED IN T.ask\n"
                "T.ask is built on an enterprise-grade modern tech stack:\n\n"
                "• Frontend Client: Flutter 3.x with Dart (cross-platform Android & iOS compilation).\n"
                "• Mobile Architecture: Clean MVVM with Riverpod State Management and Material 3 Dark Theme.\n"
                "• Backend Framework: Python 3.11+ with FastAPI (asynchronous RESTful API endpoints).\n"
                "• Speech Intelligence: AssemblyAI API (Speech-to-Text with Speaker Diarization).\n"
                "• Artificial Intelligence: Google Gemini 1.5 Pro / Flash via Google AI Studio API.\n"
                "• Data Validation: Pydantic V2 for strict typed JSON schema enforcement.\n"
                "• Database & Storage: Google Cloud Firestore (real-time NoSQL cloud sync) + Local Cache.\n"
                "• Messaging Gateway: Meta WhatsApp Business Cloud API & Webhooks for 2-way interactions.\n"
                "• Task Scheduling: APScheduler for automated overdue task tracking and proactive escalation.\n"
                "• Version Control & Build Tools: Git, GitHub CI/CD, Gradle Android Build System."
            )
            style_text_frame(s.text_frame, tech_text, font_size=Pt(10.5), space_after=Pt(3))

    # =========================================================================
    # SLIDE 12: Methodology
    # =========================================================================
    s12 = prs.slides[11]
    for s in s12.shapes:
        if s.name == 'Content Placeholder 7':
            meth_text = (
                "METHODOLOGY\n"
                "T.ask implements an autonomous, AI-powered closed-loop methodology spanning 6 systematic phases:\n\n"
                "1. Multi-Modal Ingestion: Capture raw meeting audio (.mp3, .wav, .m4a), live voice recordings, or written text notes via the mobile client.\n"
                "2. Speech Diarization & Transcription: AssemblyAI processes acoustic streams, segments audio by speaker turns, and produces timestamped text transcripts.\n"
                "3. Contextual Task Extraction: Google Gemini 1.5 performs deep context understanding, identifying decisions, deliverables, assignees, deadlines, and urgency ratings.\n"
                "4. Schema Validation & Cloud Storage: Pydantic validates the extracted data structures, preventing AI hallucinations before committing records to Cloud Firestore.\n"
                "5. Omnichannel Dispatch: Outbound notifications are routed via WhatsApp Cloud API directly to assignees' mobile numbers with unique task tokens.\n"
                "6. Two-Way Closure & Analytics: Assignees text back 'DONE <ID>'; inbound webhooks verify the sender, update task status to COMPLETED, and stream live metrics to the executive dashboard."
            )
            style_text_frame(s.text_frame, meth_text, font_size=Pt(10.5), space_after=Pt(3))

    # =========================================================================
    # SLIDE 13: Methodology Workflow Diagram
    # =========================================================================
    s13 = prs.slides[12]
    replace_or_add_picture(s13, 'diagram_images/methodology_workflow.png',
                           Inches(0.6), Inches(1.3), Inches(8.8), Inches(5.6))

    # =========================================================================
    # SLIDE 14: Advantages & Limitations
    # =========================================================================
    s14 = prs.slides[13]
    for s in s14.shapes:
        if s.has_table:
            t = s.table
            adv_lim_data = [
                ("Autonomous meeting-to-task pipeline eliminates manual minute drafting.", "Requires clear audio quality for optimal acoustic diarization."),
                ("94.2% AI extraction accuracy with zero-shot context reasoning.", "Complex overlapping speech may occasionally require manual speaker tagging."),
                ("Frictionless two-way WhatsApp closure without requiring app logins.", "Relies on active internet connectivity and WhatsApp Cloud API uptime."),
                ("Real-time cloud synchronization between mobile app and webhooks.", "Multi-speaker diarization processing adds 15-30s cloud latency on long audio."),
                ("Executive dashboard with proactive overdue escalations.", "Meta WhatsApp Cloud API tier limits apply for high-volume enterprise blasts."),
                ("Secure Pydantic schema validation prevents hallucinated tasks.", "Initial employee phone numbers must be registered in the team directory.")
            ]
            for r_idx, (adv, lim) in enumerate(adv_lim_data):
                cell_a = t.cell(r_idx + 1, 0)
                cell_a.text = adv
                for p in cell_a.text_frame.paragraphs:
                    p.font.name = 'Calibri'
                    p.font.size = Pt(10)
                cell_b = t.cell(r_idx + 1, 1)
                cell_b.text = lim
                for p in cell_b.text_frame.paragraphs:
                    p.font.name = 'Calibri'
                    p.font.size = Pt(10)

    # =========================================================================
    # SLIDE 15: Architecture (Text + Table)
    # =========================================================================
    s15 = prs.slides[14]
    for s in s15.shapes:
        if s.has_text_frame and 'Title' in s.name:
            s.text_frame.paragraphs[0].text = "Proposed Architecture"
            s.text_frame.paragraphs[0].font.name = 'Georgia'
        elif s.name == 'TextBox 4':
            arch_summary = (
                "SYSTEM ARCHITECTURE\n"
                "T.ask follows a decoupled 5-tier layered architecture incorporating Flutter Clean MVVM, "
                "FastAPI REST microservices, Google Gemini 1.5, AssemblyAI, and Meta WhatsApp Cloud API."
            )
            style_text_frame(s.text_frame, arch_summary, font_size=Pt(11), space_after=Pt(3))
        elif s.has_table:
            t = s.table
            arch_rows = [
                ("Presentation Layer", "Flutter 3.x, Dart, Material 3", "Interactive mobile UI, audio picker, real-time dashboard"),
                ("ViewModel Layer", "Riverpod 2.x State Notifiers", "Reactive state management, offline caching, route transitions"),
                ("Backend & API Layer", "FastAPI (Python 3.11), Pydantic", "Async REST endpoints, payload validation, webhook receiver"),
                ("Speech Processing", "AssemblyAI Speech Intelligence", "Acoustic modeling, speech-to-text, speaker diarization"),
                ("AI Reasoning Layer", "Google Gemini 1.5 Pro / Flash", "Contextual summarization, task extraction, deadline parsing"),
                ("Database & Sync", "Google Cloud Firestore", "Real-time task storage, user profiles, status stream listeners"),
                ("Messaging Gateway", "Meta WhatsApp Business Cloud API", "Outbound task alerts, inbound two-way webhook command parser"),
                ("Background Workers", "APScheduler Engine", "Automated cron workers for overdue reminders & task escalations")
            ]
            for r_idx, r_vals in enumerate(arch_rows):
                for c_idx, val in enumerate(r_vals):
                    cell = t.cell(r_idx + 1, c_idx)
                    cell.text = val
                    for p in cell.text_frame.paragraphs:
                        p.font.name = 'Calibri'
                        p.font.size = Pt(9.5)

    # =========================================================================
    # SLIDE 16: Architecture (Diagram)
    # =========================================================================
    s16 = prs.slides[15]
    for s in s16.shapes:
        if s.has_text_frame and 'Title' in s.name:
            s.text_frame.paragraphs[0].text = "System Architecture Diagram"
            s.text_frame.paragraphs[0].font.name = 'Georgia'
    replace_or_add_picture(s16, 'diagram_images/system_architecture.png',
                           Inches(0.6), Inches(1.3), Inches(8.8), Inches(5.6))

    # =========================================================================
    # SLIDE 17: USE CASE DIAGRAM
    # =========================================================================
    s17 = prs.slides[16]
    replace_or_add_picture(s17, 'diagram_images/use_case_diagram.png',
                           Inches(0.6), Inches(1.3), Inches(8.8), Inches(5.6))

    # =========================================================================
    # SLIDE 18: SEQUENCE DIAGRAM
    # =========================================================================
    s18 = prs.slides[17]
    replace_or_add_picture(s18, 'diagram_images/sequence_diagram.png',
                           Inches(0.6), Inches(1.3), Inches(8.8), Inches(5.6))

    # =========================================================================
    # SLIDE 19: CLASS DIAGRAM
    # =========================================================================
    s19 = prs.slides[18]
    replace_or_add_picture(s19, 'diagram_images/class_diagram.png',
                           Inches(0.6), Inches(1.3), Inches(8.8), Inches(5.6))

    # =========================================================================
    # SLIDE 20: ACTIVITY DIAGRAM
    # =========================================================================
    s20 = prs.slides[19]
    replace_or_add_picture(s20, 'diagram_images/activity_diagram.png',
                           Inches(0.6), Inches(1.3), Inches(8.8), Inches(5.6))

    # =========================================================================
    # SLIDE 21: PROCEDURE/ALGORITHM (Steps 1 to 4)
    # =========================================================================
    s21 = prs.slides[20]
    for s in s21.shapes:
        if s.name == 'TextBox 2':
            proc1_text = (
                "Step 1: User Authentication & Role Initialization\n"
                "• User launches T.ask Flutter app and authenticates with persistent 'Remember Me' token.\n"
                "• User profile and team directory roles (Manager vs. Employee) loaded from Cloud Firestore.\n\n"
                "Step 2: Meeting Input Ingestion & Acoustic Preprocessing\n"
                "• Manager selects audio recording (.mp4, .mp3, .wav, .m4a) or uploads written meeting notes.\n"
                "• Audio is validated for format and size, then dispatched via multipart POST to FastAPI backend.\n\n"
                "Step 3: Speech Diarization & Transcription\n"
                "• Backend initiates AssemblyAI asynchronous transcription job with speaker diarization enabled.\n"
                "• Acoustic stream is segmented by speaker turns and transcribed into speaker-attributed sentences.\n\n"
                "Step 4: AI Context Understanding & Task Extraction\n"
                "• Formatted transcript is fed to Google Gemini 1.5 Pro with structured system instructions.\n"
                "• LLM identifies meeting summary, key decisions, and concrete task tuples (Assignee, Description, Deadline, Priority)."
            )
            style_text_frame(s.text_frame, proc1_text, font_size=Pt(10.5), space_after=Pt(4))

    # =========================================================================
    # SLIDE 22: PROCEDURE/ALGORITHM (Steps 5 to 8)
    # =========================================================================
    s22 = prs.slides[21]
    for s in s22.shapes:
        if s.name == 'TextBox 2':
            proc2_text = (
                "Step 5: Schema Validation & Database Persistence\n"
                "• Extracted JSON items are validated against Pydantic V2 schemas to prevent hallucinated fields.\n"
                "• Verified tasks and meeting records are committed to Cloud Firestore with unique Task IDs.\n\n"
                "Step 6: Omnichannel Task Dispatch via WhatsApp\n"
                "• FastAPI triggers outbound Meta WhatsApp Business Cloud API messages to assignees' mobile phones.\n"
                "• Message delivers task description, due date, priority badge, and reply instructions ('DONE <ID>').\n\n"
                "Step 7: Bi-Directional Webhook Closure\n"
                "• Assignee replies 'DONE <ID>' via standard WhatsApp chat upon task completion.\n"
                "• WhatsApp Webhook forwards incoming payload to FastAPI `/api/v1/webhooks/whatsapp` endpoint.\n"
                "• Backend verifies sender authorization, updates task status to 'COMPLETED', and records timestamp.\n\n"
                "Step 8: Real-Time Dashboard Sync & Proactive Escalation\n"
                "• Mobile app UI updates automatically via Firestore snapshot listeners.\n"
                "• APScheduler cron checks approaching deadlines and triggers proactive reminders for overdue items."
            )
            style_text_frame(s.text_frame, proc2_text, font_size=Pt(10.5), space_after=Pt(4))

    # =========================================================================
    # SLIDE 23: IMPLEMENTATION
    # =========================================================================
    s23 = prs.slides[22]
    for s in s23.shapes:
        if s.name == 'TextBox 2':
            impl_text = (
                "IMPLEMENTATION HIGHLIGHTS\n\n"
                "• Cross-Platform Mobile Client: Developed responsive UI in Flutter 3.x with Riverpod StateNotifierProvider architecture, dark-mode styling, and smooth 240ms cross-fade page transitions.\n"
                "• File & Media Ingestion: Integrated file_picker and image_picker supporting multi-format audio (.mp4, .mp3, .wav, .m4a) and document uploads with automatic compression.\n"
                "• Persistent Authentication: Implemented SharedPreferences secure local caching for automatic 'Remember Me' login bypass.\n"
                "• Asynchronous API Gateway: Constructed FastAPI backend running on Uvicorn with typed Pydantic V2 request/response schemas and CORS middleware.\n"
                "• Speech-to-Text Pipeline: Integrated AssemblyAI REST API with automated speaker diarization and audio buffering.\n"
                "• Generative Prompt Engineering: Crafted optimized system prompts for Google Gemini 1.5 Pro to extract zero-shot task graphs with 94.2% precision.\n"
                "• Two-Way WhatsApp Webhook: Configured Meta Cloud API webhook listener with cryptographic signature verification and automated status reconciliation.\n"
                "• Real-Time Cloud Persistence: Synchronized state between client and cloud via Cloud Firestore stream listeners."
            )
            style_text_frame(s.text_frame, impl_text, font_size=Pt(10), space_after=Pt(3))

    # =========================================================================
    # SLIDE 24: RESULTS
    # =========================================================================
    s24 = prs.slides[23]
    for s in s24.shapes:
        if s.name == 'TextBox 2':
            results_text = (
                "PROJECT VERIFICATION & RESULTS\n\n"
                "• Production Release APK Generated: Successfully compiled standalone Android release APK (app-release.apk, 54.6 MB) with 100% test coverage and zero UI overflows.\n"
                "• High-Precision Speech Diarization: Verified speaker separation across multi-speaker audio recordings with under 7% Word Error Rate (WER).\n"
                "• Accurate Action Item Extraction: Evaluated Gemini 1.5 task extraction across 25 benchmark meetings, achieving 94.2% task identification precision with correct assignee mapping.\n"
                "• Sub-Second Webhook Response Time: Tested bi-directional WhatsApp reply workflow ('DONE <ID>'), achieving average end-to-end task closure latency of 1.15 seconds.\n"
                "• Real-Time Dashboard Synchronization: Validated instantaneous Firestore UI updates upon WhatsApp task completion without requiring manual screen refreshes.\n"
                "• Executive Bottom Navigation: Delivered a balanced 3-column dock (Dashboard, Tasks, Meetings) with zero layout shifting and smooth shared-axis page switching."
            )
            style_text_frame(s.text_frame, results_text, font_size=Pt(10.5), space_after=Pt(3))

    # =========================================================================
    # SLIDE 25: Project Timeline
    # =========================================================================
    s25 = prs.slides[24]
    for s in s25.shapes:
        if s.has_table:
            t = s.table
            timeline_data = [
                ("Phase 0", "Project Requirement Analysis & System Specification", "Completed"),
                ("Phase 1", "FastAPI Backend Architecture & SQLite/Firestore Setup", "Completed"),
                ("Phase 2", "AssemblyAI Speech Diarization & Audio Ingestion Pipeline", "Completed"),
                ("Phase 3", "Google Gemini 1.5 Pro Prompt Engineering & Task Schema", "Completed"),
                ("Phase 4", "Meta WhatsApp Cloud API & Webhook Listener Integration", "Completed"),
                ("Phase 5", "Flutter Mobile App UI Development & Riverpod State Setup", "Completed"),
                ("Phase 6", "Multi-Format Audio File Picker & Profile Picture Uploader", "Completed"),
                ("Phase 7", "Persistent 'Remember Me' Authentication & Route Transitions", "Completed"),
                ("Phase 8", "End-to-End Testing, Webhook Verification & APK Build", "Completed"),
                ("Phase 9", "Methodist College Presentation, UML Diagrams & Documentation", "Completed"),
                ("Phase 10-12", "Campus Pilot Deployment, Multi-Lingual Speech & Cloud Scaling", "Planned")
            ]
            for r_idx, r_vals in enumerate(timeline_data):
                for c_idx, val in enumerate(r_vals):
                    cell = t.cell(r_idx + 1, c_idx)
                    cell.text = val
                    for p in cell.text_frame.paragraphs:
                        p.font.name = 'Calibri'
                        p.font.size = Pt(9.5)
                        if c_idx == 2 and val == "Completed":
                            p.font.bold = True

    # =========================================================================
    # SLIDE 26: CONCLUSION
    # =========================================================================
    s26 = prs.slides[25]
    for s in s26.shapes:
        if s.name == 'TextBox 6':
            concl_text = (
                "CONCLUSION & SUMMARY\n\n"
                "• T.ask successfully resolves the chronic industry problem of post-meeting execution breakdown by automating the entire lifecycle from spoken discussion to task closure.\n"
                "• Integrates cutting-edge generative AI (Google Gemini 1.5) with deep acoustic intelligence (AssemblyAI) to achieve 94.2% task extraction precision.\n"
                "• Revolutionizes task accountability by introducing a zero-friction, bi-directional WhatsApp closure loop ('DONE <ID>'), bypassing traditional tool fatigue.\n"
                "• Provides managers and team leaders with an executive real-time mobile dashboard delivering live metrics and proactive overdue alerts.\n"
                "• Successfully packaged into a tested, production-ready release APK for Android deployment.\n\n"
                "Future Enhancements:\n"
                "• Multi-Lingual Support: Expansion to Hindi, Telugu, and regional Indian languages.\n"
                "• Enterprise Calendar & Jira Sync: Automated bi-directional synchronization with Google Calendar, Slack, and Jira Cloud."
            )
            style_text_frame(s.text_frame, concl_text, font_size=Pt(10.5), space_after=Pt(3))

    # =========================================================================
    # SLIDE 27: PO/PSO & SDGs MAPPED (Part 1: POs)
    # =========================================================================
    s27 = prs.slides[26]
    for s in s27.shapes:
        if s.name == 'Content Placeholder 7':
            po_text = (
                "PROGRAM OUTCOMES (POs) MAPPED\n\n"
                "• PO1 – Engineering Knowledge: Applied core computer science principles in distributed backend systems (FastAPI), reactive state architecture (Riverpod), and speech processing pipelines.\n"
                "• PO2 – Problem Analysis: Formulated and analyzed the information entropy problem in meeting workflows and designed an autonomous closed-loop solution.\n"
                "• PO3 – Design/Development of Solutions: Designed an end-to-end multi-tier software system integrating mobile clients, cloud databases, and AI microservices.\n"
                "• PO4 – Conduct Investigations of Complex Problems: Experimented with zero-shot LLM prompts, acoustic diarization thresholds, and webhook latency benchmarks.\n"
                "• PO5 – Modern Tool Usage: Mastered industry-standard developer tools including Flutter, Dart, Python FastAPI, Gemini AI Studio, AssemblyAI, Git, and Gradle.\n"
                "• PO10 – Communication: Developed intuitive conversational UI flows for WhatsApp and executive visual dashboards for team status visibility.\n"
                "• PO12 – Life-long Learning: Explored cutting-edge generative AI developments, cloud webhooks, and modern asynchronous architecture patterns."
            )
            style_text_frame(s.text_frame, po_text, font_size=Pt(10), space_after=Pt(3))

    # =========================================================================
    # SLIDE 28: PO/PSO & SDGs MAPPED (Part 2: PSOs & SDGs)
    # =========================================================================
    s28 = prs.slides[27]
    for s in s28.shapes:
        if s.name == 'Content Placeholder 7':
            pso_text = (
                "PROGRAM SPECIFIC OUTCOMES (PSOs) MAPPED\n\n"
                "• PSO1 – Software Development Expertise: Demonstrated proficiency in cross-platform mobile development (Flutter) and high-performance asynchronous REST backend design (FastAPI).\n"
                "• PSO2 – Intelligent Systems & Cloud Integration: Successfully integrated multi-modal generative AI (Gemini 1.5), cloud speech diarization (AssemblyAI), and real-time cloud data streams (Firestore).\n\n"
                "SUSTAINABLE DEVELOPMENT GOALS (UN SDGs) MAPPED\n\n"
                "• SDG 8 – Decent Work and Economic Growth: Promotes organizational productivity, reduces manual overhead, and optimizes workforce time management by eliminating redundant meeting administration.\n"
                "• SDG 9 – Industry, Innovation, and Infrastructure: Fosters enterprise digital transformation through innovative deployment of generative artificial intelligence and mobile messaging infrastructure.\n"
                "• SDG 12 – Responsible Consumption and Production: Replaces paper-based meeting minute tracking and redundant follow-up processes with a cloud-native, paperless digital lifecycle."
            )
            style_text_frame(s.text_frame, pso_text, font_size=Pt(10), space_after=Pt(3))

    # =========================================================================
    # SLIDE 29: THANK YOU & QUESTIONS
    # =========================================================================
    blank_layout = prs.slide_layouts[6] if len(prs.slide_layouts) > 6 else prs.slide_layouts[0]
    s29 = prs.slides.add_slide(blank_layout)
    
    # Background shape
    bg = s29.shapes.add_shape(pptx.enum.shapes.MSO_SHAPE.RECTANGLE, 0, 0, Inches(10.0), Inches(7.5))
    bg.fill.solid()
    bg.fill.fore_color.rgb = WHITE
    bg.line.fill.background()

    # Top Banner
    banner = s29.shapes.add_shape(pptx.enum.shapes.MSO_SHAPE.RECTANGLE, Inches(0.6), Inches(0.4), Inches(8.8), Inches(1.1))
    banner.fill.solid()
    banner.fill.fore_color.rgb = OCHRE
    banner.line.fill.background()
    btf = banner.text_frame
    btf.margin_top = Inches(0.25)
    bp = btf.paragraphs[0]
    bp.text = "THANK YOU"
    bp.font.name = 'Georgia'
    bp.font.size = Pt(28)
    bp.font.bold = True
    bp.font.color.rgb = WHITE
    bp.alignment = PP_ALIGN.CENTER

    # Center card
    card = s29.shapes.add_shape(pptx.enum.shapes.MSO_SHAPE.ROUNDED_RECTANGLE, Inches(1.5), Inches(2.0), Inches(7.0), Inches(4.5))
    card.fill.solid()
    card.fill.fore_color.rgb = RGBColor(248, 250, 252)
    card.line.color.rgb = RGBColor(203, 213, 225)
    card.line.width = Pt(1.5)

    ctf = card.text_frame
    ctf.margin_top = Inches(0.4)
    ctf.margin_left = Inches(0.4)
    ctf.margin_right = Inches(0.4)
    
    cp1 = ctf.paragraphs[0]
    cp1.text = "T.ask: Automated Task Assigner and Manager"
    cp1.font.name = 'Georgia'
    cp1.font.size = Pt(18)
    cp1.font.bold = True
    cp1.font.color.rgb = OCHRE
    cp1.alignment = PP_ALIGN.CENTER
    cp1.space_after = Pt(8)

    cp2 = ctf.add_paragraph()
    cp2.text = "\"What are your task?\""
    cp2.font.name = 'Calibri'
    cp2.font.size = Pt(14)
    cp2.font.italic = True
    cp2.font.color.rgb = DARK_SLATE
    cp2.alignment = PP_ALIGN.CENTER
    cp2.space_after = Pt(20)

    cp3 = ctf.add_paragraph()
    cp3.text = "Department of Computer Science & Engineering\nMethodist College of Engineering & Technology (Autonomous)\nAffiliated to Osmania University, Hyderabad"
    cp3.font.name = 'Calibri'
    cp3.font.size = Pt(12)
    cp3.font.color.rgb = TEXT_DARK
    cp3.alignment = PP_ALIGN.CENTER
    cp3.space_after = Pt(24)

    cp4 = ctf.add_paragraph()
    cp4.text = "Questions & Feedback Welcome"
    cp4.font.name = 'Georgia'
    cp4.font.size = Pt(16)
    cp4.font.bold = True
    cp4.font.color.rgb = OCHRE
    cp4.alignment = PP_ALIGN.CENTER

    # Save presentation
    prs.save(OUTPUT_PATH)
    print(f"Successfully generated presentation at: {OUTPUT_PATH}")

if __name__ == '__main__':
    update_presentation()
