"""
User Management Endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr
from typing import Optional

from app.core.security import get_current_active_user

router = APIRouter()


class UserProfile(BaseModel):
    id: str
    email: EmailStr
    username: str
    avatar_url: Optional[str] = None
    role: str
    is_active: bool
    is_verified: bool


class UserUpdate(BaseModel):
    username: Optional[str] = None
    avatar_url: Optional[str] = None


@router.get("/me", response_model=UserProfile)
async def get_current_user_profile(current_user: dict = Depends(get_current_active_user)):
    """Get current user profile"""
    # TODO: Fetch user from database
    return {
        "id": current_user.get("user_id"),
        "email": current_user.get("email", "user@example.com"),
        "username": "Demo User",
        "avatar_url": None,
        "role": current_user.get("role", "user"),
        "is_active": True,
        "is_verified": True
    }


@router.put("/me", response_model=UserProfile)
async def update_user_profile(
    user_update: UserUpdate,
    current_user: dict = Depends(get_current_active_user)
):
    """Update current user profile"""
    # TODO: Update user in database
    return {
        "id": current_user.get("user_id"),
        "email": current_user.get("email", "user@example.com"),
        "username": user_update.username or "Demo User",
        "avatar_url": user_update.avatar_url,
        "role": current_user.get("role", "user"),
        "is_active": True,
        "is_verified": True
    }


@router.get("/stats")
async def get_user_stats(current_user: dict = Depends(get_current_active_user)):
    """Get user learning statistics"""
    # TODO: Fetch stats from database
    return {
        "total_questions_answered": 245,
        "correct_answers": 198,
        "accuracy_rate": 80.82,
        "total_study_hours": 45.5,
        "study_days": 28,
        "current_streak": 7,
        "max_streak": 15,
        "active_study_plans": 2
    }
