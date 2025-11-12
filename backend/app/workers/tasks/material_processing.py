"""
Material Processing Tasks
"""

from celery import Task
from app.workers.celery_app import celery_app
import time


@celery_app.task(bind=True, name="process_uploaded_material")
def process_uploaded_material(self: Task, material_id: str, file_path: str):
    """Process uploaded learning material"""
    try:
        self.update_state(state="PROGRESS", meta={"step": "OCR", "progress": 10})
        time.sleep(1)
        
        self.update_state(state="PROGRESS", meta={"step": "Extracting text", "progress": 30})
        time.sleep(1)
        
        self.update_state(state="PROGRESS", meta={"step": "Extracting knowledge points", "progress": 50})
        time.sleep(1)
        
        self.update_state(state="PROGRESS", meta={"step": "Generating questions", "progress": 70})
        time.sleep(1)
        
        self.update_state(state="PROGRESS", meta={"step": "Vectorization", "progress": 90})
        time.sleep(1)
        
        return {
            "status": "completed",
            "material_id": material_id,
            "knowledge_points_count": 5,
            "questions_generated": 12
        }
    except Exception as e:
        self.update_state(state="FAILURE", meta={"error": str(e)})
        raise
