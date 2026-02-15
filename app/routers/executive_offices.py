from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import SessionLocal
from ..models import ExecutiveOffice, OfficeMember
from ..schemas import ExecutiveOfficeCreate, ExecutiveOfficeUpdate, ExecutiveOfficeOut, OfficeMemberCreate, OfficeMemberUpdate, OfficeMemberOut
from ..auth import require_admin, get_current_user

router = APIRouter(prefix="/offices", tags=["Executive Offices"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/", response_model=list[ExecutiveOfficeOut])
def get_offices(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """List all executive offices"""
    return db.query(ExecutiveOffice).offset(skip).limit(limit).all()

@router.get("/{office_id}", response_model=ExecutiveOfficeOut)
def get_office(office_id: int, db: Session = Depends(get_db)):
    """Get specific office details with members"""
    office = db.query(ExecutiveOffice).filter(ExecutiveOffice.id == office_id).first()
    if not office:
        raise HTTPException(status_code=404, detail="Office not found")
    return office

@router.post("/", response_model=ExecutiveOfficeOut, status_code=status.HTTP_201_CREATED)
def create_office(
    office_data: ExecutiveOfficeCreate, 
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_admin)
):
    """Create a new executive office (Admin only)"""
    new_office = ExecutiveOffice(**office_data.model_dump())
    db.add(new_office)
    db.commit()
    db.refresh(new_office)
    return new_office

@router.post("/{office_id}/members", response_model=OfficeMemberOut, status_code=status.HTTP_201_CREATED)
def add_member(
    office_id: int,
    member_data: OfficeMemberCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_admin)
):
    """Add a member to an office (Admin only)"""
    office = db.query(ExecutiveOffice).filter(ExecutiveOffice.id == office_id).first()
    if not office:
        raise HTTPException(status_code=404, detail="Office not found")
    
    new_member = OfficeMember(**member_data.model_dump(), office_id=office_id)
    db.add(new_member)
    db.commit()
    db.refresh(new_member)
    return new_member


@router.put("/{office_id}", response_model=ExecutiveOfficeOut)
def update_office(
    office_id: int,
    office_data: ExecutiveOfficeUpdate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_admin)
):
    """Update an executive office (Admin only)"""
    office = db.query(ExecutiveOffice).filter(ExecutiveOffice.id == office_id).first()
    if not office:
        raise HTTPException(status_code=404, detail="Office not found")
    
    update_data = office_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(office, field, value)
    
    db.commit()
    db.refresh(office)
    return office

@router.delete("/{office_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_office(
    office_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_admin)
):
    """Delete an office (Admin only)"""
    office = db.query(ExecutiveOffice).filter(ExecutiveOffice.id == office_id).first()
    if not office:
        raise HTTPException(status_code=404, detail="Office not found")
    
    db.delete(office)
    db.commit()
    return None

@router.put("/{office_id}/members/{member_id}", response_model=OfficeMemberOut)
def update_member(
    office_id: int,
    member_id: int,
    member_data: OfficeMemberUpdate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_admin)
):
    """Update an office member (Admin only)"""
    member = db.query(OfficeMember).filter(
        OfficeMember.id == member_id,
        OfficeMember.office_id == office_id
    ).first()
    if not member:
        raise HTTPException(status_code=404, detail="Member not found")
    
    update_data = member_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(member, field, value)
    
    db.commit()
    db.refresh(member)
    return member

@router.delete("/{office_id}/members/{member_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_member(
    office_id: int,
    member_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_admin)
):
    """Delete an office member (Admin only)"""
    member = db.query(OfficeMember).filter(
        OfficeMember.id == member_id,
        OfficeMember.office_id == office_id
    ).first()
    if not member:
        raise HTTPException(status_code=404, detail="Member not found")
    
    db.delete(member)
    db.commit()
    return None
