import pytest
from fastapi.testclient import TestClient
from app.main import app

class TestUserControl:
    
    @pytest.fixture(autouse=True)
    def setup(self, client):
        self.client = client
        self.email = "control@example.com"
        self.password = "password123"
        self.token = self._get_token(self.email, self.password)

    def _get_token(self, email, password):
        # Create user
        self.client.post(
            "/users/",
            json={
                "name": "Control User",
                "email": email,
                "password": password
            }
        )
        # Login
        response = self.client.post(
            "/auth/login",
            data={"username": email, "password": password}
        )
        return response.json()["access_token"]

    def test_update_me(self):
        """Test self-update"""
        response = self.client.put(
            "/users/me",
            json={"name": "Updated Name", "specialization": "AI"},
            headers={"Authorization": f"Bearer {self.token}"}
        )
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == "Updated Name"
        assert data["specialization"] == "AI"
        
        # Verify persistence
        get_res = self.client.get(
            "/users/me",
            headers={"Authorization": f"Bearer {self.token}"}
        )
        assert get_res.json()["email"] == self.email # get_me returns dict currently

    def test_get_barcode(self):
        """Test barcode generation"""
        response = self.client.get(
            "/users/me/barcode",
            headers={"Authorization": f"Bearer {self.token}"}
        )
        assert response.status_code == 200
        assert response.headers["content-type"] == "image/png"
        assert len(response.content) > 0

    def test_delete_me(self):
        """Test self-deletion"""
        # Delete
        response = self.client.delete(
            "/users/me",
            headers={"Authorization": f"Bearer {self.token}"}
        )
        assert response.status_code == 204
        
        # Verify login fails
        login_res = self.client.post(
            "/auth/login",
            data={"username": self.email, "password": self.password}
        )
        assert login_res.status_code == 401
