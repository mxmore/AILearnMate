"""
Database Connection Management
"""

from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from motor.motor_asyncio import AsyncIOMotorClient
from redis import asyncio as aioredis
from typing import AsyncGenerator

from app.core.config import settings

# PostgreSQL
engine = create_engine(
    settings.postgres_url,
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

# MongoDB
mongodb_client: AsyncIOMotorClient | None = None
mongodb_db = None

# Redis
redis_client: aioredis.Redis | None = None


async def get_db() -> AsyncGenerator:
    """Get PostgreSQL database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


async def get_mongodb():
    """Get MongoDB database instance"""
    return mongodb_db


async def get_redis():
    """Get Redis client"""
    return redis_client


async def init_db():
    """Initialize all database connections"""
    global mongodb_client, mongodb_db, redis_client
    
    # MongoDB
    mongodb_client = AsyncIOMotorClient(settings.mongo_url)
    mongodb_db = mongodb_client[settings.MONGODB_DB]
    print(f"✅ MongoDB connected: {settings.MONGODB_DB}")
    
    # Redis
    redis_client = await aioredis.from_url(
        settings.redis_url,
        encoding="utf-8",
        decode_responses=True
    )
    print(f"✅ Redis connected: {settings.REDIS_HOST}:{settings.REDIS_PORT}")
    
    # PostgreSQL tables (if needed, create them)
    # Base.metadata.create_all(bind=engine)


async def close_db():
    """Close all database connections"""
    global mongodb_client, redis_client
    
    if mongodb_client:
        mongodb_client.close()
        print("👋 MongoDB connection closed")
    
    if redis_client:
        await redis_client.close()
        print("👋 Redis connection closed")
