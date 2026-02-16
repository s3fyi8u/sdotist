from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form, Request
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import User
from ..auth import hash_password
from ..middleware import limiter
import shutil
import os
import uuid

router = APIRouter(tags=["Registration"])

DOCUMENT_DIR = "app/static/documents"
os.makedirs(DOCUMENT_DIR, exist_ok=True)

ALLOWED_TYPES = {"image/jpeg", "image/png", "image/jpg", "application/pdf"}
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB


@router.post("/register", status_code=status.HTTP_201_CREATED)
@limiter.limit("10/minute")
async def register_with_document(
    request: Request,
    name: str = Form(..., min_length=2, max_length=50),
    email: str = Form(...),
    password: str = Form(..., min_length=8),
    university: str = Form(None),
    specialization: str = Form(None),
    academic_year: str = Form(None),
    degree: str = Form(None),
    date_of_birth: str = Form(None),
    document: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    """تسجيل مستخدم جديد مع وثيقة الهوية الطلابية"""

    # Check if email already exists
    existing = db.query(User).filter(User.email == email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )

    # Validate file type
    if document.content_type not in ALLOWED_TYPES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid file type. Allowed: JPEG, PNG, PDF"
        )

    # Validate file size
    contents = await document.read()
    if len(contents) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File too large. Maximum size: 5MB"
        )
    await document.seek(0)

    # Save document with secure filename
    extension = document.filename.split(".")[-1] if document.filename else "bin"
    secure_filename = f"{uuid.uuid4()}.{extension}"
    file_path = os.path.join(DOCUMENT_DIR, secure_filename)

    with open(file_path, "wb") as buffer:
        buffer.write(contents)

    # Create user with pending status
    new_user = User(
        name=name,
        email=email,
        password=hash_password(password),
        role="user",
        university=university,
        specialization=specialization,
        academic_year=academic_year,
        degree=degree,
        date_of_birth=date_of_birth,
        status="pending",
        document_path=file_path,
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return {
        "message": "Registration submitted. Your account is under review.",
        "user_id": new_user.id,
        "status": "pending"
    }
