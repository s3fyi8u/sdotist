import pytest
from fastapi.testclient import TestClient
from app.main import app

class TestNewsEndpoints:
    
    @pytest.fixture(autouse=True)
    def setup(self, client):
        self.client = client
        # We need an admin user for write operations
        # and a normal user for permission testing.
        self.admin_token = self._get_token("admin@example.com", "adminpassword", "admin")
        self.user_token = self._get_token("user@example.com", "userpassword", "user")

    def _get_token(self, email, password, role="user"):
        # Helper to get token, creating user if not exists
        # Try login first
        response = self.client.post(
            "/auth/login",
            data={"username": email, "password": password}
        )
        if response.status_code == 200:
            return response.json()["access_token"]
        
        # Create user if login fails (first run)
        self.client.post(
            "/users/",
            json={
                "name": "Test User",
                "email": email,
                "password": password,
                "role": role
            }
        )
        # Login again
        response = self.client.post(
            "/auth/login",
            data={"username": email, "password": password}
        )
        return response.json()["access_token"]

    def test_create_news_admin(self):
        """Test Admin can create news"""
        response = self.client.post(
            "/news/",
            json={
                "title": "Breaking News",
                "description": "Short desc",
                "body": "Long story here",
                "image": "image.jpg"
            },
            headers={"Authorization": f"Bearer {self.admin_token}"}
        )
        assert response.status_code == 201
        data = response.json()
        assert data["title"] == "Breaking News"

    def test_create_news_user_forbidden(self):
        """Test Normal User cannot create news"""
        response = self.client.post(
            "/news/",
            json={
                "title": "Fake News",
                "description": "Short desc",
                "body": "Long story here",
                "image": "image.jpg"
            },
            headers={"Authorization": f"Bearer {self.user_token}"}
        )
        assert response.status_code == 403

    def test_get_news_public(self):
        """Test Public can read news"""
        # First ensure there's news (using admin)
        create_res = self.client.post(
            "/news/",
            json={
                "title": "Public News",
                "description": "For everyone",
                "body": "Public body",
                "image": "pub.jpg"
            },
            headers={"Authorization": f"Bearer {self.admin_token}"}
        )
        news_id = create_res.json()["id"]

        # Public access (no token)
        response = self.client.get(f"/news/{news_id}")
        assert response.status_code == 200
        assert response.json()["title"] == "Public News"
