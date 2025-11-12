"""
Learning Materials Management Endpoints
"""

from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

from app.core.security import get_current_active_user
from app.core.config import settings

router = APIRouter()


class Material(BaseModel):
    id: str
    title: str
    description: Optional[str]
    type: str
    file_url: str
    file_size: int
    page_count: Optional[int]
    processing_status: str
    created_at: datetime


class MaterialDetail(Material):
    knowledge_points: List[str]
    tags: List[str]
    extracted_content: Optional[List[dict]] = None


@router.get("/", response_model=List[Material])
async def list_materials(
    type: Optional[str] = None,
    skip: int = 0,
    limit: int = 20,
    current_user: dict = Depends(get_current_active_user)
):
    """List user's learning materials"""
    # TODO: Fetch from MongoDB
    return []


@router.post("/upload", status_code=202)
async def upload_material(
    file: UploadFile = File(...),
    title: Optional[str] = None,
    description: Optional[str] = None,
    current_user: dict = Depends(get_current_active_user)
):
    """
    Upload a learning material file
    
    Supported formats: PDF, images (PNG, JPG), Word, PowerPoint, text files
    
    The file will be processed asynchronously:
    1. OCR recognition
    2. Knowledge point extraction
    3. Question generation
    """
    # Validate file type
    file_ext = file.filename.split(".")[-1].lower()
    if file_ext not in settings.allowed_file_types_list:
        raise HTTPException(
            status_code=400,
            detail=f"File type not allowed. Supported types: {settings.ALLOWED_FILE_TYPES}"
        )
    
    # Validate file size
    file.file.seek(0, 2)
    file_size = file.file.tell()
    file.file.seek(0)
    
    if file_size > settings.max_file_size_bytes:
        raise HTTPException(
            status_code=400,
            detail=f"File too large. Max size: {settings.MAX_FILE_SIZE_MB}MB"
        )
    
    # TODO: 
    # 1. Upload file to object storage
    # 2. Create material record in MongoDB
    # 3. Queue processing task in Celery
    
    return {
        "message": "File uploaded successfully",
        "material_id": "new-material-id",
        "status": "pending",
        "task_id": "task-123"
    }


@router.get("/{material_id}", response_model=MaterialDetail)
async def get_material(
    material_id: str,
    current_user: dict = Depends(get_current_active_user)
):
    """Get material details"""
    # TODO: Fetch from MongoDB
    return {
        "id": material_id,
        "title": "初中数学总复习",
        "description": "包含代数、几何各章节",
        "type": "pdf",
        "file_url": "/files/math_review.pdf",
        "file_size": 2048576,
        "page_count": 45,
        "processing_status": "completed",
        "knowledge_points": ["math-algebra", "math-geometry"],
        "tags": ["数学", "复习"],
        "created_at": datetime.now()
    }


@router.delete("/{material_id}")
async def delete_material(
    material_id: str,
    current_user: dict = Depends(get_current_active_user)
):
    """Delete a material"""
    # TODO: Delete from MongoDB and object storage
    return {"message": "Material deleted successfully"}


@router.get("/{material_id}/processing-status")
async def get_processing_status(
    material_id: str,
    current_user: dict = Depends(get_current_active_user)
):
    """Get material processing status"""
    # TODO: Check processing task status
    return {
        "material_id": material_id,
        "status": "processing",
        "progress": 65,
        "current_step": "Extracting knowledge points",
        "tasks": {
            "ocr": "completed",
            "knowledge_extraction": "processing",
            "question_generation": "pending"
        }
    }
