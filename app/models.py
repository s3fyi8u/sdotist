from sqlalchemy import Column, Integer, String, DateTime, Text, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from .database import Base


import uuid

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    barcode_id = Column(String, unique=True, default=lambda: str(uuid.uuid4()))
    name = Column(String)
    email = Column(String, unique=True, index=True)
    password = Column(String)
    role = Column(String, default="user", nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Profile Fields
    university = Column(String, nullable=True)
    specialization = Column(String, nullable=True)
    academic_year = Column(String, nullable=True)
    degree = Column(String, nullable=True)
    date_of_birth = Column(String, nullable=True)
    profile_image = Column(String, nullable=True)
    status = Column(String, default="active", nullable=False)  # pending, active, rejected
    document_path = Column(String, nullable=True)  # Path to uploaded student ID document
    
    news = relationship("News", back_populates="author")
    notifications = relationship("Notification", back_populates="author")


class News(Base):
    __tablename__ = "news"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(String, nullable=True)
    body = Column(Text, nullable=False)
    image = Column(String, nullable=True)  # Legacy single image field
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    author_id = Column(Integer, ForeignKey("users.id"))
    author = relationship("User", back_populates="news")
    images = relationship("NewsImage", back_populates="news", cascade="all, delete-orphan", order_by="NewsImage.order")


class NewsImage(Base):
    __tablename__ = "news_images"

    id = Column(Integer, primary_key=True, index=True)
    image_url = Column(String, nullable=False)
    order = Column(Integer, default=0)
    
    news_id = Column(Integer, ForeignKey("news.id"))
    news = relationship("News", back_populates="images")


class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    body = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    author_id = Column(Integer, ForeignKey("users.id"))
    author = relationship("User", back_populates="notifications")


class ExecutiveOffice(Base):
    __tablename__ = "executive_offices"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True, nullable=False)
    description = Column(Text, nullable=True)
    image_url = Column(String, nullable=True)
    
    members = relationship("OfficeMember", back_populates="office", cascade="all, delete-orphan")


class OfficeMember(Base):
    __tablename__ = "office_members"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    position = Column(String, nullable=True)
    image_url = Column(String, nullable=True)
    email = Column(String, nullable=True)
    phone = Column(String, nullable=True)
    role = Column(String, default="member")  # member or manager
    
    office_id = Column(Integer, ForeignKey("executive_offices.id"))
    office = relationship("ExecutiveOffice", back_populates="members")

class UniversityRepresentative(Base):
    __tablename__ = "university_representatives"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    university = Column(String, nullable=False)
    image_url = Column(String, nullable=True)