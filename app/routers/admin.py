from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import User, Notification
from ..auth import require_admin, get_current_user
import os

router = APIRouter(prefix="/admin", tags=["Admin"])


@router.get("/pending-registrations")
def get_pending_registrations(
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_admin),
):
    """الحصول على قائمة التسجيلات المعلقة"""
    pending_users = db.query(User).filter(User.status == "pending").all()

    result = []
    for user in pending_users:
        document_url = None
        if user.document_path:
            # Convert file path to URL
            filename = os.path.basename(user.document_path)
            document_url = f"https://api.sdotist.org/static/documents/{filename}"

        result.append({
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "university": user.university,
            "specialization": user.specialization,
            "degree": user.degree,
            "academic_year": user.academic_year,
            "profile_image": user.profile_image,
            "document_url": document_url,
            "created_at": user.created_at.isoformat() if user.created_at else None,
        })

    return result


@router.post("/registrations/{user_id}/approve")
def approve_registration(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_admin),
):
    """قبول تسجيل المستخدم"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    if user.status != "pending":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User is not in pending status"
        )

    # Delete document from disk
    if user.document_path and os.path.exists(user.document_path):
        os.remove(user.document_path)

    # Update user status
    user.status = "active"
    user.document_path = None

    # Create notification for the user
    admin_user = db.query(User).filter(User.email == current_user["email"]).first()
    notification = Notification(
        title="Account Activated / تم تفعيل حسابك",
        body="Your account has been activated. You can now login. / تم تفعيل حسابك. يمكنك الآن تسجيل الدخول.",
        author_id=admin_user.id if admin_user else None,
        recipient_id=user.id
    )
    db.add(notification)
    db.commit()

    return {"message": "User approved successfully", "user_id": user_id}


@router.post("/registrations/{user_id}/reject")
def reject_registration(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_admin),
):
    """رفض تسجيل المستخدم"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    if user.status != "pending":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User is not in pending status"
        )

    # Delete document from disk
    if user.document_path and os.path.exists(user.document_path):
        os.remove(user.document_path)

    # Delete user from database
    db.delete(user)
    db.commit()

    return {"message": "User rejected and deleted", "user_id": user_id}
