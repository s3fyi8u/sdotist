from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import or_
from .. import models, schemas
from ..database import get_db
from ..auth import get_current_user
from ..firebase import send_push_notification

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
    accessible to all authenticated users.
    """
    user = db.query(models.User).filter(models.User.email == current_user["email"]).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    notifications = db.query(models.Notification).filter(
        or_(
            models.Notification.recipient_id == None,
            models.Notification.recipient_id == user.id
        )
    ).order_by(models.Notification.created_at.desc()).offset(skip).limit(limit).all()
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
    Also sends a real push notification via FCM to all registered devices.
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

    # Send FCM push notification to all users with registered tokens
    tokens = [u.fcm_token for u in db.query(models.User).filter(models.User.fcm_token != None).all()]
    if tokens:
        send_push_notification(tokens, notification.title, notification.body)

    return new_notification


@router.post("/register-token", status_code=status.HTTP_200_OK)
def register_fcm_token(
    payload: schemas.FCMTokenRegister,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Register or update the user's FCM device token.
    Called by the Flutter app after obtaining a token from Firebase.
    """
    user = db.query(models.User).filter(models.User.email == current_user["email"]).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    user.fcm_token = payload.token
    db.commit()
    return {"message": "FCM token registered successfully"}
