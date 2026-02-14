from app.database import SessionLocal
from app.models import UniversityRepresentative

def seed_data():
    db = SessionLocal()
    try:
        if db.query(UniversityRepresentative).count() > 0:
            print("University Representatives data already exists.")
            return

        print("Seeding University Representatives data...")
        
        reps = [
            UniversityRepresentative(
                name="د. محمد أحمد",
                university="جامعة الملك سعود",
                image_url="https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=400&q=80"
            ),
            UniversityRepresentative(
                name="د. نورة الصالح",
                university="جامعة الأميرة نورة",
                image_url="https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80"
            ),
            UniversityRepresentative(
                name="أ. عبدالكريم الفهيد",
                university="جامعة القصيم",
                image_url="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=400&q=80"
            ),
        ]
        
        db.add_all(reps)
        db.commit()
        
        print("Data seeded successfully!")
        
    finally:
        db.close()

if __name__ == "__main__":
    seed_data()
