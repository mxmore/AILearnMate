"""
API Router
"""

from fastapi import APIRouter

from app.api.v1.endpoints import auth, users, questions, study, materials, knowledge

api_router = APIRouter()

# Include all endpoint routers
api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(users.router, prefix="/users", tags=["Users"])
api_router.include_router(questions.router, prefix="/questions", tags=["Questions"])
api_router.include_router(study.router, prefix="/study", tags=["Study"])
api_router.include_router(materials.router, prefix="/materials", tags=["Materials"])
api_router.include_router(knowledge.router, prefix="/knowledge", tags=["Knowledge Points"])
