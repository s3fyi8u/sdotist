from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from .. import models, schemas, database, auth, dependencies
from datetime import datetime

router = APIRouter(
    prefix="/events",
    tags=["Events"]
)

@router.post("/", response_model=schemas.EventOut)
def create_event(
    event: schemas.EventCreate,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(dependencies.get_current_active_user)
):
    """
    إنشاء فعالية جديدة (للمسؤولين فقط)
    """
    if current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="ليس لديك صلاحية لإنشاء فعاليات"
        )
    
    new_event = models.Event(**event.model_dump())
    db.add(new_event)
    db.commit()
    db.refresh(new_event)
    return new_event

@router.get("/", response_model=List[schemas.EventOut])
def get_events(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(database.get_db)
):
    """
    الحصول على قائمة الفعاليات
    """
    events = db.query(models.Event).order_by(models.Event.date.desc()).offset(skip).limit(limit).all()
    return events

@router.get("/{event_id}", response_model=schemas.EventOut)
def get_event(
    event_id: int,
    db: Session = Depends(database.get_db)
):
    """
    الحصول على تفاصيل فعالية معينة
    """
    event = db.query(models.Event).filter(models.Event.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="الفعالية غير موجودة")
    return event

@router.post("/{event_id}/register", response_model=schemas.EventRegistrationOut)
def register_for_event(
    event_id: int,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(dependencies.get_current_active_user)
):
    """
    تسجيل المستخدم في فعالية
    """
    event = db.query(models.Event).filter(models.Event.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="الفعالية غير موجودة")
        
    if event.is_ended:
        raise HTTPException(status_code=400, detail="انتهت هذة الفعالية، لا يمكن التسجيل")
    
    # Check if already registered
    existing_registration = db.query(models.EventRegistration).filter(
        models.EventRegistration.event_id == event_id,
        models.EventRegistration.user_id == current_user.id
    ).first()
    
    if existing_registration:
        raise HTTPException(status_code=400, detail="أنت مسجل بالفعل في هذه الفعالية")
    
    new_registration = models.EventRegistration(
        user_id=current_user.id,
        event_id=event_id
    )
    db.add(new_registration)
    db.commit()
    db.refresh(new_registration)
    return new_registration

@router.delete("/{event_id}/register", status_code=status.HTTP_204_NO_CONTENT)
def unregister_from_event(
    event_id: int,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(dependencies.get_current_active_user)
):
    """
    إلغاء تسجيل المستخدم في فعالية
    """
    event = db.query(models.Event).filter(models.Event.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="الفعالية غير موجودة")
    
    registration = db.query(models.EventRegistration).filter(
        models.EventRegistration.event_id == event_id,
        models.EventRegistration.user_id == current_user.id
    ).first()
    
    if not registration:
        raise HTTPException(status_code=404, detail="أنت لست مسجلاً في هذه الفعالية")
        
    if registration.attended:
         raise HTTPException(status_code=400, detail="لا يمكن إلغاء التسجيل بعد تأكيد الحضور")
    
    db.delete(registration)
    db.commit()
    return None

@router.get("/{event_id}/registrations", response_model=List[schemas.EventRegistrationOut])
def get_event_registrations(
    event_id: int,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(dependencies.get_current_active_user)
):
    """
    الحصول على قائمة المسجلين في فعالية (للمسؤولين فقط)
    """
    if current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="ليس لديك صلاحية لعرض المسجلين"
        )
        
    event = db.query(models.Event).filter(models.Event.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="الفعالية غير موجودة")
        
    return event.registrations

@router.post("/{event_id}/verify", response_model=schemas.EventRegistrationOut)
def verify_attendance(
    event_id: int,
    barcode_id: str,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(dependencies.get_current_active_user)
):
    """
    تحقق من حضور المستخدم عبر الباركود (للمسؤولين فقط)
    """
    if current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="ليس لديك صلاحية للتحقق من الحضور"
        )
    
    # Create registration if user exists but not registered? No, requirements say verify registered users.
    # But let's check user first.
    user = db.query(models.User).filter(models.User.barcode_id == barcode_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="المستخدم غير موجود")
        
    registration = db.query(models.EventRegistration).filter(
        models.EventRegistration.event_id == event_id,
        models.EventRegistration.user_id == user.id
    ).first()
    
    if not registration:
        raise HTTPException(status_code=404, detail="المستخدم غير مسجل في هذه الفعالية")
    
    if registration.attended:
         raise HTTPException(status_code=400, detail="تم التحقق من الحضور مسبقاً")

    registration.attended = True
    db.commit()
    db.refresh(registration)
    return registration


@router.put("/{event_id}", response_model=schemas.EventOut)
def update_event(
    event_id: int,
    event_update: schemas.EventUpdate,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(dependencies.get_current_active_user)
):
    """
    تحديث بيانات فعالية (للمسؤولين فقط)
    """
    if current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="ليس لديك صلاحية لتعديل الفعاليات"
        )
    
    event = db.query(models.Event).filter(models.Event.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="الفعالية غير موجودة")
    
    update_data = event_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(event, key, value)
    
    db.commit()
    db.refresh(event)
    return event


@router.delete("/{event_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_event(
    event_id: int,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(dependencies.get_current_active_user)
):
    """
    حذف فعالية (للمسؤولين فقط)
    """
    if current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="ليس لديك صلاحية لحذف الفعاليات"
        )
    
    event = db.query(models.Event).filter(models.Event.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="الفعالية غير موجودة")
    
    db.delete(event)
    db.commit()
    return None
