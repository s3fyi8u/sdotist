import requests
import os

BASE_URL = "http://127.0.0.1:8000"
TEST_IMAGE = "test_image.png"

# Create a dummy image
with open(TEST_IMAGE, "wb") as f:
    f.write(os.urandom(1024))

try:
    print("🔹 Testing Upload Endpoint...")
    with open(TEST_IMAGE, "rb") as f:
        files = {"file": ("test_image.png", f, "image/png")}
        res = requests.post(f"{BASE_URL}/upload", files=files)
    
    if res.status_code == 200:
        print(f"✅ Upload successful: {res.json()}")
        url = res.json()["url"]
        
        # Verify file access
        print("🔹 Verifying File Access...")
        res_file = requests.get(url)
        if res_file.status_code == 200:
            print("✅ File verified accessible.")
        else:
            print(f"❌ Failed to access file: {res_file.status_code}")
    else:
        print(f"❌ Upload failed: {res.status_code} {res.text}")

finally:
    if os.path.exists(TEST_IMAGE):
        os.remove(TEST_IMAGE)
