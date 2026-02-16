from fastapi import APIRouter, Depends, HTTPException, status, Response
from sqlalchemy.orm import Session
import io
import qrcode
from ..database import SessionLocal
from ..models import User
from ..schemas import UserCreate, UserOut, UserUpdate, PasswordChange
from ..auth import hash_password, verify_password, require_admin, get_current_user

router = APIRouter(prefix="/users", tags=["Users"])


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.post("/", response_model=UserOut, status_code=status.HTTP_201_CREATED)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    """إنشاء مستخدم جديد"""
    # Check if email already exists
    existing = db.query(User).filter(User.email == user.email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"

        )

    # Create user
    new_user = User(
        name=user.name,
        email=user.email,
        password=hash_password(user.password),
        role=user.role or "user",
        university=user.university,
        specialization=user.specialization,
        academic_year=user.academic_year,
        degree=user.degree,
        date_of_birth=user.date_of_birth,
        profile_image=user.profile_image,
        is_verified=False # Explicitly set false
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    # Send verification email
    from ..auth import create_access_token
    from ..utils.email import send_verification_email
    token = create_access_token({"sub": new_user.email, "role": new_user.role})
    import asyncio
    asyncio.create_task(send_verification_email(new_user.email, token))
    
    return new_user


@router.get("/", response_model=list[UserOut])
def get_users(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """الحصول على قائمة المستخدمين"""
    return db.query(User).offset(skip).limit(limit).all()


@router.get("/me", response_model=UserOut)
def get_me(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    """الحصول على بيانات المستخدم الحالي"""
    user = db.query(User).filter(User.email == current_user["email"]).first()
    return user


@router.put("/me", response_model=UserOut)
def update_me(
    user_data: UserUpdate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """تحديث الملف الشخصي للمستخدم الحالي"""
    user = db.query(User).filter(User.email == current_user["email"]).first()
    
    update_data = user_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(user, field, value)

    db.commit()
    db.refresh(user)
    return user


@router.delete("/me", status_code=status.HTTP_204_NO_CONTENT)
def delete_me(
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """حذف الحساب للمستخدم الحالي"""
    user = db.query(User).filter(User.email == current_user["email"]).first()
    db.delete(user)
    db.commit()
    return None


@router.get("/me/barcode")
def get_my_barcode(
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """الحصول على الباركود الخاص بالمستخدم"""
    user = db.query(User).filter(User.email == current_user["email"]).first()
    
    if not user.barcode_id:
        import uuid
        user.barcode_id = str(uuid.uuid4())
        db.commit()

    # Generate QR Code
    img = qrcode.make(user.barcode_id)
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    buf.seek(0)
    
    return Response(content=buf.getvalue(), media_type="image/png")


@router.get("/{user_id}", response_model=UserOut)
def get_user(user_id: int, db: Session = Depends(get_db)):
    """الحصول على مستخدم محدد"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="المستخدم غير موجود"
        )
    return user


@router.put("/{user_id}", response_model=UserOut)
def update_user(
    user_id: int,
    user_data: UserUpdate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_admin)
):
    """تحديث بيانات مستخدم (للمشرفين فقط)"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="المستخدم غير موجود"
        )

    update_data = user_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(user, field, value)

    db.commit()
    db.refresh(user)
    return user


@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_admin)
):
    """حذف مستخدم (للمشرفين فقط)"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="المستخدم غير موجود"
        )

    db.delete(user)
    db.commit()
    return None


@router.patch("/me/password")
def change_password(
    password_data: PasswordChange,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """تغيير كلمة المرور"""
    user = db.query(User).filter(User.email == current_user["email"]).first()

    if not verify_password(password_data.current_password, user.password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="كلمة المرور الحالية غير صحيحة"
        )

    user.password = hash_password(password_data.new_password)
    db.commit()

    return {"message": "تم تغيير كلمة المرور بنجاح ✅"}


@router.get("/admin/dashboard")
def admin_panel(user: dict = Depends(require_admin)):
    """لوحة الإدارة (للمشرفين فقط)"""
    return {
        "message": "Welcome Admin 👑",
        "email": user["email"],
        "role": user["role"]
    }