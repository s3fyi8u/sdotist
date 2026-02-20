from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from .. import models, database

router = APIRouter(
    prefix="/statistics",
    tags=["Statistics"]
)

@router.get("/")
def get_statistics(db: Session = Depends(database.get_db)):
    """
    Get aggregated statistics for the application
    """
    total_users = db.query(models.User).count()
    total_events = db.query(models.Event).count()
    
    return {
        "total_users": total_users,
        "total_events": total_events
    }
