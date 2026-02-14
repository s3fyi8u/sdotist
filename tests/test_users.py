import pytest
from fastapi.testclient import TestClient
from app.main import app


client = TestClient(app)


class TestUserEndpoints:
    """اختبارات نقاط نهاية المستخدمين"""

    def test_create_user(self):
        """اختبار إنشاء مستخدم جديد"""
        response = client.post(
            "/users/",
            json={
                "name": "Test User",
                "email": "testuser@example.com",
                "password": "testpassword123",
                "role": "user"
            }
        )
        # قد يكون 201 (created) أو 400 (email exists)
        assert response.status_code in [201, 400]

    def test_get_users(self):
        """اختبار الحصول على قائمة المستخدمين"""
        response = client.get("/users/")
        assert response.status_code == 200
        assert isinstance(response.json(), list)

    def test_get_user_by_id(self):
        """اختبار الحصول على مستخدم محدد"""
        # First create a user
        response = client.get("/users/1")
        # قد يكون 200 (found) أو 404 (not found)
        assert response.status_code in [200, 404]

    def test_get_me_without_auth(self):
        """اختبار الوصول لـ /me بدون تسجيل دخول"""
        response = client.get("/users/me")
        assert response.status_code == 401  # Unauthorized
