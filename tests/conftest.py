import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.database import SessionLocal, engine
from app import models


@pytest.fixture
def client():
    """Create a test client"""
    from app.middleware import limiter
    limiter.enabled = False
    return TestClient(app)


@pytest.fixture
def db():
    """Create a test database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
