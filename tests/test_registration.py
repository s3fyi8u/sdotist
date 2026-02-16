import pytest
import io
from fastapi.testclient import TestClient
from app.main import app
from app.database import SessionLocal
from app.models import User
from app.auth import hash_password


client = TestClient(app)


class TestRegistrationWithDocument:
    """اختبارات التسجيل مع رفع المستندات"""

    @pytest.fixture(autouse=True)
    def setup(self):
        """Clean up test users before each test"""
        db = SessionLocal()
        # Disable rate limiter for tests
        from app.middleware import limiter
        limiter.enabled = False
        # Clean up test users
        db.query(User).filter(User.email.like("testdoc%@example.com")).delete(synchronize_session=False)
        db.commit()
        db.close()
        yield
        # Cleanup after test
        db = SessionLocal()
        db.query(User).filter(User.email.like("testdoc%@example.com")).delete(synchronize_session=False)
        db.commit()
        db.close()

    def _create_test_image(self):
        """Create a small test image"""
        return io.BytesIO(b"\x89PNG\r\n\x1a\n" + b"\x00" * 100)

    def _create_admin_token(self):
        """Create an admin user and get token"""
        db = SessionLocal()
        admin = db.query(User).filter(User.email == "admin_test_reg@example.com").first()
        if not admin:
            admin = User(
                name="Admin Test",
                email="admin_test_reg@example.com",
                password=hash_password("adminpassword123"),
                role="admin",
                status="active",
            )
            db.add(admin)
            db.commit()
        db.close()

        response = client.post(
            "/auth/login",
            data={"username": "admin_test_reg@example.com", "password": "adminpassword123"},
        )
        return response.json()["access_token"]

    def test_register_with_valid_document(self):
        """Test registration with a valid image document"""
        test_file = self._create_test_image()
        response = client.post(
            "/register",
            data={
                "name": "Test Student",
                "email": "testdoc1@example.com",
                "password": "testpassword123",
                "university": "Istanbul University",
            },
            files={"document": ("student_id.png", test_file, "image/png")},
        )
        assert response.status_code == 201
        data = response.json()
        assert data["status"] == "pending"
        assert "under review" in data["message"].lower()

    def test_register_with_invalid_file_type(self):
        """Test registration with unsupported file type"""
        test_file = io.BytesIO(b"fake executable content")
        response = client.post(
            "/register",
            data={
                "name": "Test Student",
                "email": "testdoc2@example.com",
                "password": "testpassword123",
            },
            files={"document": ("malware.exe", test_file, "application/octet-stream")},
        )
        assert response.status_code == 400
        assert "Invalid file type" in response.json()["detail"]

    def test_login_with_pending_account(self):
        """Test that pending accounts cannot login"""
        # First register
        test_file = self._create_test_image()
        client.post(
            "/register",
            data={
                "name": "Test Student",
                "email": "testdoc3@example.com",
                "password": "testpassword123",
            },
            files={"document": ("id.png", test_file, "image/png")},
        )

        # Try to login
        response = client.post(
            "/auth/login",
            data={"username": "testdoc3@example.com", "password": "testpassword123"},
        )
        assert response.status_code == 403
        assert "review" in response.json()["detail"].lower() or "مراجعة" in response.json()["detail"]

    def test_admin_get_pending_registrations(self):
        """Test admin can list pending registrations"""
        # Register a user first
        test_file = self._create_test_image()
        client.post(
            "/register",
            data={
                "name": "Test Pending",
                "email": "testdoc4@example.com",
                "password": "testpassword123",
            },
            files={"document": ("id.png", test_file, "image/png")},
        )

        token = self._create_admin_token()
        response = client.get(
            "/admin/pending-registrations",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        # Should contain our pending user
        emails = [u["email"] for u in data]
        assert "testdoc4@example.com" in emails

    def test_admin_approve_registration(self):
        """Test admin can approve a pending user"""
        # Register
        test_file = self._create_test_image()
        reg_response = client.post(
            "/register",
            data={
                "name": "Test Approve",
                "email": "testdoc5@example.com",
                "password": "testpassword123",
            },
            files={"document": ("id.png", test_file, "image/png")},
        )
        user_id = reg_response.json()["user_id"]

        # Approve
        token = self._create_admin_token()
        response = client.post(
            f"/admin/registrations/{user_id}/approve",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert response.status_code == 200

        # Now login should work
        login_response = client.post(
            "/auth/login",
            data={"username": "testdoc5@example.com", "password": "testpassword123"},
        )
        assert login_response.status_code == 200
        assert "access_token" in login_response.json()

    def test_admin_reject_registration(self):
        """Test admin can reject a pending user (deletes user)"""
        # Register
        test_file = self._create_test_image()
        reg_response = client.post(
            "/register",
            data={
                "name": "Test Reject",
                "email": "testdoc6@example.com",
                "password": "testpassword123",
            },
            files={"document": ("id.png", test_file, "image/png")},
        )
        user_id = reg_response.json()["user_id"]

        # Reject
        token = self._create_admin_token()
        response = client.post(
            f"/admin/registrations/{user_id}/reject",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert response.status_code == 200

        # Login should fail (user deleted)
        login_response = client.post(
            "/auth/login",
            data={"username": "testdoc6@example.com", "password": "testpassword123"},
        )
        assert login_response.status_code == 401

    def test_duplicate_email_registration(self):
        """Test that duplicate emails are rejected"""
        test_file1 = self._create_test_image()
        client.post(
            "/register",
            data={
                "name": "Test First",
                "email": "testdoc7@example.com",
                "password": "testpassword123",
            },
            files={"document": ("id.png", test_file1, "image/png")},
        )

        test_file2 = self._create_test_image()
        response = client.post(
            "/register",
            data={
                "name": "Test Duplicate",
                "email": "testdoc7@example.com",
                "password": "testpassword123",
            },
            files={"document": ("id2.png", test_file2, "image/png")},
        )
        assert response.status_code == 400
        assert "already registered" in response.json()["detail"].lower()
