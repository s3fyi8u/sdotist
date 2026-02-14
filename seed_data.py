from app.database import SessionLocal
from app.models import ExecutiveOffice, OfficeMember

def seed_data():
    db = SessionLocal()
    try:
        # Check if data exists
        if db.query(ExecutiveOffice).count() > 0:
            print("Data already exists.")
            return

        print("Seeding data...")
        
        # Create Office
        office = ExecutiveOffice(
            name="مكتب المدير العام",
            description="المكتب المسؤول عن الإدارة العامة للشركة واتخاذ القرارات الاستراتيجية.",
            image_url="https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=800&q=80"
        )
        db.add(office)
        db.commit()
        db.refresh(office)
        
        # Create Members
        manager = OfficeMember(
            office_id=office.id,
            name="أحمد محمد",
            position="المدير العام",
            email="ahmed@example.com",
            phone="0500000000",
            role="manager",
            image_url="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=400&q=80"
        )
        
        member1 = OfficeMember(
            office_id=office.id,
            name="سارة علي",
            position="سكرتيرة تنفيذية",
            email="sara@example.com",
            phone="0555555555",
            role="member",
            image_url="https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=400&q=80"
        )
        
        member2 = OfficeMember(
            office_id=office.id,
            name="خالد عبدالله",
            position="مساعد إداري",
            email="khaled@example.com",
            role="member"
        )

        db.add(manager)
        db.add(member1)
        db.add(member2)
        db.commit()
        
        print("Data seeded successfully!")
        
    finally:
        db.close()

if __name__ == "__main__":
    seed_data()
