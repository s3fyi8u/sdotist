from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import UniversityRepresentative
from app.schemas import UniversityRepresentativeCreate, UniversityRepresentativeOut
from app.dependencies import admin_only, get_current_user

router = APIRouter(
    prefix="/representatives",
    tags=["University Representatives"]
)

@router.get("/", response_model=list[UniversityRepresentativeOut])
def get_representatives(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    "List all university representatives"
    return db.query(UniversityRepresentative).offset(skip).limit(limit).all()

@router.post("/", response_model=UniversityRepresentativeOut, status_code=status.HTTP_201_CREATED)
def create_representative(
    representative: UniversityRepresentativeCreate, 
    db: Session = Depends(get_db),
    current_user: dict = Depends(admin_only)
):
    "Create a new university representative (Admin only)"
    new_rep = UniversityRepresentative(**representative.model_dump())
    db.add(new_rep)
    db.commit()
    db.refresh(new_rep)
    return new_rep

@router.delete("/{rep_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_representative(
    rep_id: int, 
    db: Session = Depends(get_db),
    current_user: dict = Depends(admin_only)
):
    "Delete a university representative (Admin only)"
    rep = db.query(UniversityRepresentative).filter(UniversityRepresentative.id == rep_id).first()
    if not rep:
        raise HTTPException(status_code=404, detail="Representative not found")
    
    db.delete(rep)
    db.commit()
