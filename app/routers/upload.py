from fastapi import APIRouter, UploadFile, File, HTTPException, Request
import shutil
import os
import uuid

router = APIRouter(tags=["Upload"])

UPLOAD_DIR = "app/static/uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/upload")
async def upload_image(request: Request, file: UploadFile = File(...)):
    """Upload an image file"""
    if not file.content_type.startswith("image/"):
        raise HTTPException(400, "File must be an image")
    
    # Generate unique filename
    extension = file.filename.split(".")[-1]
    filename = f"{uuid.uuid4()}.{extension}"
    file_path = f"{UPLOAD_DIR}/{filename}"
    
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
        
    # Return URL dynamically based on request host (handles both localhost and sdotist.org)
    # Generate full URL
    # Hardcoding production domain to avoid proxy issues
    base_url = "https://api.sdotist.org/"
    url = f"{base_url}static/uploads/{filename}"
    return {"url": url}
