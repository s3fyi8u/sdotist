import pytest
from fastapi.testclient import TestClient
from app.main import app


client = TestClient(app)


class TestAuthEndpoints:
    """اختبارات نقاط نهاية المصادقة"""

    def test_login_invalid_credentials(self):
        """اختبار تسجيل دخول ببيانات خاطئة"""
        response = client.post(
            "/auth/login",
            data={
                "username": "invalid@example.com",
                "password": "wrongpassword"
            }
        )
        assert response.status_code == 401

    def test_refresh_invalid_token(self):
        """اختبار تجديد Token بـ token خاطئ"""
        response = client.post(
            "/auth/refresh",
            json={"refresh_token": "invalid-token"}
        )
        assert response.status_code == 401


class TestHealthEndpoint:
    """اختبارات نقطة نهاية الصحة"""

    def test_health_check(self):
        """اختبار فحص حالة الخادم"""
        response = client.get("/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert "api" in data
