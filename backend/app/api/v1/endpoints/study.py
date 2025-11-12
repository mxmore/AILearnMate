"""
Study Management Endpoints - Study Plans, Sessions, Check-ins
"""

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import List, Optional
from datetime import date, datetime

from app.core.security import get_current_active_user

router = APIRouter()


class StudyPlan(BaseModel):
    id: str
    name: str
    description: Optional[str]
    subject: str
    start_date: date
    end_date: Optional[date]
    daily_target: int
    status: str
    progress: float


class StudyPlanCreate(BaseModel):
    name: str
    description: Optional[str] = None
    subject: str
    start_date: date
    end_date: Optional[date] = None
    daily_target: int = 20
    knowledge_point_ids: List[str]


class StudySession(BaseModel):
    id: str
    session_type: str
    subject: Optional[str]
    started_at: datetime
    ended_at: Optional[datetime]
    total_questions: int
    correct_count: int
    accuracy: float
    time_spent: int


class CheckIn(BaseModel):
    date: date
    questions_completed: int
    study_minutes: int
    streak_days: int


@router.get("/plans", response_model=List[StudyPlan])
async def list_study_plans(
    status: Optional[str] = None,
    current_user: dict = Depends(get_current_active_user)
):
    """List user's study plans"""
    # TODO: Fetch from PostgreSQL
    return [
        {
            "id": "plan-1",
            "name": "初中数学强化",
            "description": "针对薄弱知识点的强化训练",
            "subject": "数学",
            "start_date": date.today(),
            "end_date": None,
            "daily_target": 30,
            "status": "active",
            "progress": 0.45
        }
    ]


@router.post("/plans", response_model=StudyPlan, status_code=201)
async def create_study_plan(
    plan_data: StudyPlanCreate,
    current_user: dict = Depends(get_current_active_user)
):
    """Create a new study plan"""
    # TODO: Create in PostgreSQL
    return {
        "id": "new-plan-id",
        "name": plan_data.name,
        "description": plan_data.description,
        "subject": plan_data.subject,
        "start_date": plan_data.start_date,
        "end_date": plan_data.end_date,
        "daily_target": plan_data.daily_target,
        "status": "active",
        "progress": 0.0
    }


@router.get("/sessions", response_model=List[StudySession])
async def list_study_sessions(
    skip: int = 0,
    limit: int = 20,
    current_user: dict = Depends(get_current_active_user)
):
    """List user's study sessions"""
    # TODO: Fetch from MongoDB
    return []


@router.post("/sessions/start")
async def start_study_session(
    session_type: str = "practice",
    subject: Optional[str] = None,
    current_user: dict = Depends(get_current_active_user)
):
    """Start a new study session"""
    # TODO: Create session in MongoDB
    return {
        "session_id": "new-session-id",
        "started_at": datetime.now(),
        "session_type": session_type
    }


@router.post("/sessions/{session_id}/end")
async def end_study_session(
    session_id: str,
    current_user: dict = Depends(get_current_active_user)
):
    """End a study session"""
    # TODO: Update session in MongoDB with end time and stats
    return {
        "session_id": session_id,
        "ended_at": datetime.now(),
        "summary": {
            "total_questions": 20,
            "correct_count": 16,
            "accuracy": 0.80,
            "time_spent": 1200
        }
    }


@router.get("/check-ins", response_model=List[CheckIn])
async def list_check_ins(
    days: int = 30,
    current_user: dict = Depends(get_current_active_user)
):
    """List user's recent check-ins"""
    # TODO: Fetch from PostgreSQL
    return []


@router.post("/check-ins/today", response_model=CheckIn)
async def check_in_today(
    current_user: dict = Depends(get_current_active_user)
):
    """Check in for today"""
    # TODO: Create or update check-in record
    return {
        "date": date.today(),
        "questions_completed": 25,
        "study_minutes": 45,
        "streak_days": 8
    }


@router.get("/wrong-questions")
async def list_wrong_questions(
    is_mastered: Optional[bool] = None,
    skip: int = 0,
    limit: int = 20,
    current_user: dict = Depends(get_current_active_user)
):
    """List user's wrong questions (错题本)"""
    # TODO: Fetch from MongoDB
    return {
        "questions": [],
        "total": 0,
        "unmastered_count": 0
    }
