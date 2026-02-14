from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import SessionLocal
from ..models import News, User
from ..schemas import NewsCreate, NewsUpdate, NewsOut
from ..auth import get_current_user, require_admin

router = APIRouter(prefix="/news", tags=["News"])


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.get("/", response_model=list[NewsOut])
def get_all_news(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """الحصول على جميع الأخبار (عام)"""
    return db.query(News).offset(skip).limit(limit).all()


@router.get("/{news_id}", response_model=NewsOut)
def get_news(news_id: int, db: Session = Depends(get_db)):
    """الحصول على خبر محدد (عام)"""
    news = db.query(News).filter(News.id == news_id).first()
    if not news:
        raise HTTPException(status_code=404, detail="News not found")
    return news


@router.post("/", response_model=NewsOut, status_code=status.HTTP_201_CREATED)
def create_news(
    news: NewsCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_admin)
):
    """إضافة خبر جديد (للمشرفين فقط)"""
    # Get user object to associate
    user = db.query(User).filter(User.email == current_user["email"]).first()
    
    new_news = News(**news.model_dump(), author_id=user.id)
    db.add(new_news)
    db.commit()
    db.refresh(new_news)
    return new_news


@router.put("/{news_id}", response_model=NewsOut)
def update_news(
    news_id: int,
    news_data: NewsUpdate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_admin)
):
    """تحديث خبر (للمشرفين فقط)"""
    news = db.query(News).filter(News.id == news_id).first()
    if not news:
        raise HTTPException(status_code=404, detail="News not found")
    
    update_data = news_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(news, field, value)
    
    db.commit()
    db.refresh(news)
    return news


@router.delete("/{news_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_news(
    news_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_admin)
):
    """حذف خبر (للمشرفين فقط)"""
    news = db.query(News).filter(News.id == news_id).first()
    if not news:
        raise HTTPException(status_code=404, detail="News not found")
    
    db.delete(news)
    db.commit()
    return None
