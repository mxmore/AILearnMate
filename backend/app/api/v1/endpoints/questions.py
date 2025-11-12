"""
Question Bank Endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel
from typing import Optional, List
from enum import Enum

from app.core.security import get_current_active_user

router = APIRouter()


class QuestionType(str, Enum):
    single_choice = "single_choice"
    multiple_choice = "multiple_choice"
    true_false = "true_false"
    fill_blank = "fill_blank"
    short_answer = "short_answer"
    essay = "essay"


class QuestionResponse(BaseModel):
    id: str
    type: QuestionType
    subject: str
    difficulty: int
    question: str
    options: Optional[List[str]] = None
    images: Optional[List[str]] = None


class QuestionDetail(QuestionResponse):
    correct_answer: str
    explanation: str
    explanation_images: Optional[List[str]] = None
    knowledge_points: List[str]
    tags: List[str]
    quality_score: float
    usage_count: int
    correct_rate: float


class AnswerSubmission(BaseModel):
    question_id: str
    answer: str
    time_spent: int  # seconds


class AnswerResult(BaseModel):
    is_correct: bool
    correct_answer: str
    explanation: str
    time_spent: int
    quality_rating: Optional[int] = None  # For SRS: 0-5


@router.get("/", response_model=List[QuestionResponse])
async def list_questions(
    subject: Optional[str] = None,
    difficulty: Optional[int] = Query(None, ge=1, le=5),
    type: Optional[QuestionType] = None,
    skip: int = 0,
    limit: int = 20,
    current_user: dict = Depends(get_current_active_user)
):
    """
    List questions with filters
    
    - **subject**: Filter by subject
    - **difficulty**: Filter by difficulty (1-5)
    - **type**: Filter by question type
    - **skip**: Pagination offset
    - **limit**: Number of results (max 100)
    """
    # TODO: Fetch from MongoDB
    return [
        {
            "id": "507f1f77bcf86cd799439011",
            "type": "single_choice",
            "subject": "数学",
            "difficulty": 3,
            "question": "方程 2x + 5 = 13 的解是？",
            "options": ["A. x = 3", "B. x = 4", "C. x = 5", "D. x = 6"],
            "images": []
        }
    ]


@router.get("/{question_id}", response_model=QuestionDetail)
async def get_question(
    question_id: str,
    current_user: dict = Depends(get_current_active_user)
):
    """Get question details by ID"""
    # TODO: Fetch from MongoDB
    return {
        "id": question_id,
        "type": "single_choice",
        "subject": "数学",
        "difficulty": 3,
        "question": "方程 2x + 5 = 13 的解是？",
        "options": ["A. x = 3", "B. x = 4", "C. x = 5", "D. x = 6"],
        "images": [],
        "correct_answer": "B",
        "explanation": "2x + 5 = 13，移项得 2x = 8，两边同时除以2，得 x = 4",
        "explanation_images": [],
        "knowledge_points": ["f5jjgh44-4h5g-9jk3-gg1i-1gg4gi835f66"],
        "tags": ["一元一次方程", "基础"],
        "quality_score": 0.92,
        "usage_count": 45,
        "correct_rate": 0.82
    }


@router.post("/answer", response_model=AnswerResult)
async def submit_answer(
    answer_data: AnswerSubmission,
    current_user: dict = Depends(get_current_active_user)
):
    """
    Submit answer for a question
    
    Returns immediate feedback with correct answer and explanation
    """
    # TODO: 
    # 1. Fetch question from MongoDB
    # 2. Check answer
    # 3. Update user study records in PostgreSQL
    # 4. Update SRS schedule
    # 5. Update knowledge mastery
    
    return {
        "is_correct": True,
        "correct_answer": "B",
        "explanation": "2x + 5 = 13，移项得 2x = 8，两边同时除以2，得 x = 4",
        "time_spent": answer_data.time_spent,
        "quality_rating": 4
    }


@router.get("/adaptive/generate")
async def generate_adaptive_questions(
    count: int = Query(10, ge=1, le=50),
    subject: Optional[str] = None,
    current_user: dict = Depends(get_current_active_user)
):
    """
    Generate adaptive question set based on user's learning progress
    
    Uses SRS algorithm and knowledge mastery data to select appropriate questions
    """
    # TODO: Implement adaptive algorithm
    # 1. Get user knowledge mastery
    # 2. Get due questions from SRS
    # 3. Identify weak knowledge points
    # 4. Generate question mix (50% weak points, 30% due reviews, 20% random)
    
    return {
        "questions": [],
        "strategy": {
            "weak_knowledge_points": ["三角形", "一元一次方程"],
            "due_reviews": 3,
            "new_questions": 5,
            "random_questions": 2
        }
    }
