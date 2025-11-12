"""
Authentication Endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from pydantic import BaseModel, EmailStr
from datetime import timedelta

from app.core.config import settings
from app.core.security import (
    verify_password,
    get_password_hash,
    create_access_token,
    create_refresh_token,
    decode_token
)

router = APIRouter()


class UserRegister(BaseModel):
    email: EmailStr
    username: str
    password: str


class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class TokenRefresh(BaseModel):
    refresh_token: str


@router.post("/register", response_model=dict, status_code=status.HTTP_201_CREATED)
async def register(user_data: UserRegister):
    """
    Register a new user
    
    - **email**: Valid email address
    - **username**: Username (3-50 characters)
    - **password**: Password (min 8 characters)
    """
    # TODO: Check if user exists in database
    # TODO: Create user in database
    
    # For demo purposes, return success
    return {
        "message": "User registered successfully",
        "user": {
            "email": user_data.email,
            "username": user_data.username
        }
    }


@router.post("/login", response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    """
    Login with email/username and password
    
    Returns access token and refresh token
    """
    # TODO: Verify user credentials from database
    # For demo, using hardcoded validation
    
    # Create tokens
    access_token = create_access_token(
        data={"sub": "user_id_here", "email": form_data.username, "role": "user"}
    )
    refresh_token = create_refresh_token(
        data={"sub": "user_id_here"}
    )
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }


@router.post("/refresh", response_model=Token)
async def refresh_token(token_data: TokenRefresh):
    """
    Refresh access token using refresh token
    """
    try:
        payload = decode_token(token_data.refresh_token)
        
        if payload.get("type") != "refresh":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token type"
            )
        
        user_id = payload.get("sub")
        
        # Create new tokens
        access_token = create_access_token(
            data={"sub": user_id}
        )
        refresh_token = create_refresh_token(
            data={"sub": user_id}
        )
        
        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer"
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate refresh token"
        )


@router.post("/logout")
async def logout():
    """
    Logout user (client should discard tokens)
    """
    # In a real implementation, you might want to blacklist the token
    return {"message": "Successfully logged out"}
