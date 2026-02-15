from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import SessionLocal
from ..models import News, NewsImage, User
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
    return db.query(News).order_by(News.created_at.desc()).offset(skip).limit(limit).all()


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
    user = db.query(User).filter(User.email == current_user["email"]).first()
    
    news_data = news.model_dump(exclude={"images"})
    
    # If images list provided, use the first as the main image
    images_list = news.images or []
    if images_list and not news_data.get("image"):
        news_data["image"] = images_list[0]
    
    new_news = News(**news_data, author_id=user.id)
    db.add(new_news)
    db.flush()  # Get the ID before adding images
    
    # Add images
    for i, img_url in enumerate(images_list):
        db.add(NewsImage(news_id=new_news.id, image_url=img_url, order=i))
    
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
    
    update_data = news_data.model_dump(exclude_unset=True, exclude={"images"})
    
    # Handle images list update
    if news_data.images is not None:
        # Delete old images
        db.query(NewsImage).filter(NewsImage.news_id == news_id).delete()
        # Add new images
        for i, img_url in enumerate(news_data.images):
            db.add(NewsImage(news_id=news_id, image_url=img_url, order=i))
        # Set first image as main
        if news_data.images:
            update_data["image"] = news_data.images[0]
    
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
