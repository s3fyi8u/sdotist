from app.database import engine
from sqlalchemy import text

def add_is_ended_column():
    with engine.begin() as conn:
        try:
            conn.execute(text("ALTER TABLE events ADD COLUMN is_ended BOOLEAN DEFAULT FALSE;"))
            print("Column 'is_ended' added successfully.")
        except Exception as e:
            print(f"Error adding column: {e}")

if __name__ == "__main__":
    add_is_ended_column()
