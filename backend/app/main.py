from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.database.database import engine, Base
import app.models  # Ensure all models are registered
from app.api import auth, meetings, tasks, webhooks

# Create database tables if they do not exist
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title=settings.PROJECT_NAME,
    description=f"T.ask Backend API — Motto: {settings.PROJECT_MOTTO}",
    version="1.0.0"
)

# CORS middleware for Flutter web/mobile communication
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# API Routers
app.include_router(auth.router, prefix=settings.API_V1_STR)
app.include_router(meetings.router, prefix=settings.API_V1_STR)
app.include_router(tasks.router, prefix=settings.API_V1_STR)
app.include_router(webhooks.router, prefix=settings.API_V1_STR)


@app.get("/")
def root():
    return {
        "app": "T.ask",
        "motto": settings.PROJECT_MOTTO,
        "status": "online",
        "docs": "/docs"
    }


@app.get("/api/health")
def health_check():
    return {
        "status": "healthy",
        "service": "T.ask API",
        "motto": settings.PROJECT_MOTTO
    }
