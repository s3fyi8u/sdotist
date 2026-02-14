import requests
import sys

BASE_URL = "http://127.0.0.1:8000"

def print_step(step):
    print(f"\n🔹 {step}...")

def run_demo():
    email = "demo_user@example.com"
    password = "password123"

    # 1. Register
    print_step("Registering new user")
    reg_data = {
        "name": "Demo User",
        "email": email,
        "password": password,
        "role": "user"
    }
    res = requests.post(f"{BASE_URL}/users/", json=reg_data)
    if res.status_code == 400:
        print("User might already exist, trying to login...")
    elif res.status_code != 201:
        print(f"Registration failed: {res.text}")
        sys.exit(1)
    else:
        print("✅ User registered successfully.")

    # 2. Login
    print_step("Logging in")
    res = requests.post(f"{BASE_URL}/auth/login", data={"username": email, "password": password})
    if res.status_code != 200:
        print(f"Login failed: {res.text}")
        sys.exit(1)
    
    token = res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    print("✅ Login successful, token received.")

    # 3. Get Barcode
    print_step("Fetching Barcode")
    res = requests.get(f"{BASE_URL}/users/me/barcode", headers=headers)
    if res.status_code == 200 and res.headers["content-type"] == "image/png":
        print(f"✅ Barcode received successfully ({len(res.content)} bytes).")
    else:
        print(f"❌ Failed to get barcode: {res.status_code} {res.text}")

    # 4. Update Profile
    print_step("Updating Profile (Self-Service)")
    update_data = {"specialization": "Software Engineering", "university": "Khartoum University"}
    res = requests.put(f"{BASE_URL}/users/me", json=update_data, headers=headers)
    if res.status_code == 200 and res.json()["specialization"] == "Software Engineering":
        print("✅ Profile updated successfully.")
    else:
        print(f"❌ Update failed: {res.text}")

    # 5. Delete Account
    print_step("Deleting Account (Self-Service)")
    res = requests.delete(f"{BASE_URL}/users/me", headers=headers)
    if res.status_code == 204:
        print("✅ Account deleted successfully.")
    else:
        print(f"❌ Deletion failed: {res.text}")

    # 6. Verify Deletion
    print_step("Verifying Deletion (Login attempt)")
    res = requests.post(f"{BASE_URL}/auth/login", data={"username": email, "password": password})
    if res.status_code == 401:
        print("✅ Login failed as expected (Account deleted).")
    else:
        print(f"❌ Login succeeded but shouldn't have: {res.status_code}")

if __name__ == "__main__":
    try:
        run_demo()
    except requests.exceptions.ConnectionError:
        print("❌ Could not connect to server. Is it running?")
