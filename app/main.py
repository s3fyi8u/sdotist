from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from .database import engine
from . import models
from .routers import users, auth, news, upload
from .middleware import setup_rate_limiting, limiter
from .config import settings
from fastapi.staticfiles import StaticFiles

# Create database tables
models.Base.metadata.create_all(bind=engine)

# Initialize Firebase Admin SDK for push notifications
from .firebase import init_firebase
init_firebase()

# Create FastAPI app
app = FastAPI(
    title=settings.APP_NAME,
    description="API شاملة لإدارة المستخدمين مع JWT Authentication",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Mount Static Files
app.mount("/static", StaticFiles(directory="app/static"), name="static")

# Setup Rate Limiting
setup_rate_limiting(app)

# Setup CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "https://sdotist.org",
        "https://www.sdotist.org"
    ],
    allow_origin_regex="https?://localhost(:[0-9]+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(users.router)
app.include_router(auth.router)
app.include_router(news.router)
app.include_router(upload.router)
from .routers import notifications
app.include_router(notifications.router)

from .routers import executive_offices
app.include_router(executive_offices.router)

from .routers import pages
app.include_router(pages.router)
app.include_router(executive_offices.router)

from .routers import university_representatives
app.include_router(university_representatives.router)

from .routers import registration
app.include_router(registration.router)

from .routers import admin
app.include_router(admin.router)

from .routers import events
app.include_router(events.router)

from .routers import statistics
app.include_router(statistics.router)



# Health check endpoint
@app.get("/health", tags=["Health"])
@limiter.limit("60/minute")
def health_check(request: Request):
    """فحص حالة الخادم"""
    return {"status": "healthy", "api": settings.APP_NAME}