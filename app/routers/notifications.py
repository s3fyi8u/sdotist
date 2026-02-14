from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.orm import Session
from .. import models, schemas
from ..database import get_db
from ..auth import get_current_user

router = APIRouter(
    prefix="/notifications",
    tags=["Notifications"]
)

@router.get("/", response_model=list[schemas.NotificationOut])
def get_notifications(
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user),
    skip: int = 0,
    limit: int = 100
):
    """
    Get all notifications.
    Accessible to all authenticated users.
    """
    notifications = db.query(models.Notification).order_by(models.Notification.created_at.desc()).offset(skip).limit(limit).all()
    return notifications

@router.post("/", status_code=status.HTTP_201_CREATED, response_model=schemas.NotificationOut)
def create_notification(
    notification: schemas.NotificationCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Create a broadcast notification.
    Only Admins can create notifications.
    """
    if current_user["role"] != "admin":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to create notifications")

    user = db.query(models.User).filter(models.User.email == current_user["email"]).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    new_notification = models.Notification(**notification.model_dump(), author_id=user.id)
    db.add(new_notification)
    db.commit()
    db.refresh(new_notification)
    return new_notification
