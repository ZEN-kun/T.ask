from abc import ABC, abstractmethod
import os
import re
from typing import List, Optional
import xml.etree.ElementTree as ET
import zipfile
import httpx
from app.core.config import settings

DOCUMENT_EXTENSIONS = {".txt", ".doc", ".docx", ".md", ".csv", ".rtf"}
MEDIA_EXTENSIONS = {".mp4", ".mp3", ".wav", ".m4a", ".webm", ".ogg", ".mpeg", ".mpga", ".aac"}


def is_document_file(filename: str) -> bool:
    ext = os.path.splitext(filename or "")[1].lower()
    return ext in DOCUMENT_EXTENSIONS


def extract_text_from_document(file_path: str) -> str:
    """
    Extracts plain text transcript from .txt, .docx, .doc, .md, or .rtf files
    using Python's standard library (zero external dependencies required).
    """
    ext = os.path.splitext(file_path)[1].lower()

    # 1. Handle .docx (or .doc that is actually a zip/docx archive)
    if ext in (".docx", ".doc") and zipfile.is_zipfile(file_path):
        paragraphs: List[str] = []
        with zipfile.ZipFile(file_path, "r") as zf:
            if "word/document.xml" in zf.namelist():
                xml_bytes = zf.read("word/document.xml")
                root = ET.fromstring(xml_bytes)
                for p in root.iter():
                    if p.tag.endswith("}p") or p.tag == "p":
                        texts = [
                            node.text
                            for node in p.iter()
                            if (node.tag.endswith("}t") or node.tag == "t") and node.text
                        ]
                        line = "".join(texts).strip()
                        if line:
                            paragraphs.append(line)
        return "\n".join(paragraphs).strip()

    # 2. Handle plain text (.txt, .md, .csv) or text-based .doc
    with open(file_path, "rb") as f:
        raw_bytes = f.read()

    for encoding in ("utf-8-sig", "utf-8", "utf-16", "cp1252", "latin-1"):
        try:
            decoded = raw_bytes.decode(encoding)
            # If it's a binary .doc file, filter printable segments
            if ext == ".doc" and "\x00" in decoded:
                chunks = re.findall(r"[A-Za-z0-9 ,.!?:;'\"()\-\n\r]{15,}", decoded)
                return "\n".join(c.strip() for c in chunks if c.strip())
            return decoded.strip()
        except UnicodeDecodeError:
            continue

    return raw_bytes.decode("utf-8", errors="ignore").strip()


class SpeechToTextService(ABC):
    @abstractmethod
    async def transcribe_audio(
        self,
        file_path: str,
        participant_names: Optional[List[str]] = None
    ) -> str:
        pass


class GroqWhisperService(SpeechToTextService):
    """
    Model 1 (Cloud Fast-Path): Groq Whisper ASR (`whisper-large-v3-turbo` / `whisper-large-v3`).
    Natively transcribes .mp4, .mp3, .wav, .m4a, .webm, .ogg files in seconds
    with prompt biasing for Indian participant names.
    """

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or settings.GROQ_API_KEY
        self.url = "https://api.groq.com/openai/v1/audio/transcriptions"

    async def transcribe_audio(
        self,
        file_path: str,
        participant_names: Optional[List[str]] = None
    ) -> str:
        if not self.api_key:
            raise ValueError("Groq API key is not configured.")

        prompt_str = "Meeting transcript with action items, deadlines, and Indian names."
        if participant_names:
            names_joined = ", ".join(participant_names)
            prompt_str = f"Meeting participants and proper names: {names_joined}."

        filename = os.path.basename(file_path)
        ext = os.path.splitext(filename)[1].lower()
        mime_map = {
            ".mp4": "video/mp4",
            ".mp3": "audio/mpeg",
            ".wav": "audio/wav",
            ".m4a": "audio/mp4",
            ".webm": "video/webm",
            ".ogg": "audio/ogg",
            ".mpeg": "audio/mpeg",
        }
        mime_type = mime_map.get(ext, "application/octet-stream")

        headers = {"Authorization": f"Bearer {self.api_key}"}

        async with httpx.AsyncClient(timeout=180.0) as client:
            with open(file_path, "rb") as media_file:
                files = {"file": (filename, media_file, mime_type)}
                data = {
                    "model": "whisper-large-v3-turbo",
                    "prompt": prompt_str,
                    "response_format": "text",
                    "language": "en",
                }
                response = await client.post(self.url, headers=headers, data=data, files=files)
                if response.status_code != 200:
                    # Fallback to whisper-large-v3 if turbo unavailable
                    media_file.seek(0)
                    data["model"] = "whisper-large-v3"
                    response = await client.post(self.url, headers=headers, data=data, files=files)
                response.raise_for_status()
                return response.text.strip()


class LocalWhisperService(SpeechToTextService):
    """
    Model 1 (Local Docker): Faster-Whisper ASR Service on port 9000.
    """

    def __init__(self, base_url: str = "http://localhost:9000"):
        self.base_url = base_url.rstrip("/")

    async def transcribe_audio(
        self,
        file_path: str,
        participant_names: Optional[List[str]] = None
    ) -> str:
        url = f"{self.base_url}/asr"

        prompt_str = ""
        if participant_names:
            names_joined = ", ".join(participant_names)
            prompt_str = f"Meeting participants and proper names: {names_joined}."

        params = {
            "task": "transcribe",
            "language": "en",
            "output": "txt",
        }
        if prompt_str:
            params["initial_prompt"] = prompt_str

        async with httpx.AsyncClient(timeout=180.0) as client:
            with open(file_path, "rb") as audio_file:
                files = {"audio_file": (os.path.basename(file_path), audio_file, "application/octet-stream")}
                response = await client.post(url, params=params, files=files)
                response.raise_for_status()
                return response.text.strip()


class AssemblyAIService(SpeechToTextService):
    """
    Cloud Fallback: AssemblyAI Speech-to-Text.
    """

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or settings.ASSEMBLYAI_API_KEY
        self.base_url = "https://api.assemblyai.com/v2"

    async def transcribe_audio(
        self,
        file_path: str,
        participant_names: Optional[List[str]] = None
    ) -> str:
        if not self.api_key:
            raise ValueError("AssemblyAI API key is not configured.")

        headers = {"authorization": self.api_key}

        async with httpx.AsyncClient(timeout=120.0) as client:
            with open(file_path, "rb") as f:
                upload_res = await client.post(
                    f"{self.base_url}/upload",
                    headers=headers,
                    content=f.read()
                )
            upload_res.raise_for_status()
            upload_url = upload_res.json().get("upload_url")

            payload = {
                "audio_url": upload_url,
                "speaker_labels": True,
            }
            if participant_names:
                payload["word_boost"] = participant_names
                payload["boost_param"] = "high"

            transcript_res = await client.post(
                f"{self.base_url}/transcript",
                headers=headers,
                json=payload
            )
            transcript_res.raise_for_status()
            transcript_id = transcript_res.json().get("id")

            import asyncio
            while True:
                polling_res = await client.get(
                    f"{self.base_url}/transcript/{transcript_id}",
                    headers=headers
                )
                polling_res.raise_for_status()
                data = polling_res.json()
                status = data.get("status")

                if status == "completed":
                    return data.get("text", "")
                elif status == "error":
                    error_msg = data.get("error", "Transcription failed")
                    raise RuntimeError(f"AssemblyAI error: {error_msg}")

                await asyncio.sleep(3)


class SmartTranscriptionService(SpeechToTextService):
    """
    Unified transcription pipeline:
    1. If file is a document (.txt, .docx, .doc), extracts text directly.
    2. For audio/video (.mp4, .mp3, .wav, .m4a), uses Groq Whisper first,
       then falls back to Local Docker Whisper or AssemblyAI.
    """

    async def transcribe_audio(
        self,
        file_path: str,
        participant_names: Optional[List[str]] = None
    ) -> str:
        if is_document_file(file_path):
            return extract_text_from_document(file_path)

        errors = []
        if settings.GROQ_API_KEY:
            try:
                return await GroqWhisperService().transcribe_audio(file_path, participant_names)
            except Exception as e:
                errors.append(f"Groq Whisper: {e}")

        try:
            return await LocalWhisperService(settings.LOCAL_WHISPER_URL).transcribe_audio(file_path, participant_names)
        except Exception as e:
            errors.append(f"Local Whisper: {e}")

        if settings.ASSEMBLYAI_API_KEY:
            try:
                return await AssemblyAIService().transcribe_audio(file_path, participant_names)
            except Exception as e:
                errors.append(f"AssemblyAI: {e}")

        raise RuntimeError(" | ".join(errors))


def get_transcription_service() -> SpeechToTextService:
    return SmartTranscriptionService()
