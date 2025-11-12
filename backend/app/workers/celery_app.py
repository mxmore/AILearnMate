"""
Celery Application Configuration
"""

from celery import Celery
from app.core.config import settings

celery_app = Celery(
    "ailearnmate",
    broker=settings.celery_broker,
    backend=settings.celery_backend,
    include=[
        "app.workers.tasks.material_processing",
        "app.workers.tasks.question_generation",
        "app.workers.tasks.ai_tasks"
    ]
)

# Celery configuration
celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    task_track_started=True,
    task_time_limit=30 * 60,  # 30 minutes
    task_soft_time_limit=25 * 60,  # 25 minutes
    worker_prefetch_multiplier=1,
    worker_max_tasks_per_child=1000,
)

# Task routes
celery_app.conf.task_routes = {
    "app.workers.tasks.material_processing.*": {"queue": "material_processing"},
    "app.workers.tasks.question_generation.*": {"queue": "question_generation"},
    "app.workers.tasks.ai_tasks.*": {"queue": "ai_tasks"},
}

if __name__ == "__main__":
    celery_app.start()
