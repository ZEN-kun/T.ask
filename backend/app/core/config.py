from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional


class Settings(BaseSettings):
    PROJECT_NAME: str = "T.ask API"
    PROJECT_MOTTO: str = "What are your task?"
    API_V1_STR: str = "/api"

    DATABASE_URL: str = "sqlite:///./task.db"

    # AI & LLM Keys
    GROQ_API_KEY: Optional[str] = None
    GEMINI_API_KEY: Optional[str] = None
    ASSEMBLYAI_API_KEY: Optional[str] = None

    # Local Docker Services
    LOCAL_WHISPER_URL: str = "http://localhost:9000"

    # WhatsApp Cloud API
    WHATSAPP_ACCESS_TOKEN: Optional[str] = None
    WHATSAPP_PHONE_NUMBER_ID: Optional[str] = None
    WHATSAPP_VERIFY_TOKEN: Optional[str] = None

    # JWT Security
    JWT_SECRET: str = "dev_secret_key_t_ask_2026_super_secure_random_key_value"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440  # 24 hours

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


settings = Settings()
