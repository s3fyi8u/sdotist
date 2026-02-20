from pydantic import BaseModel, EmailStr, Field, ConfigDict
from datetime import datetime


class UserCreate(BaseModel):
    name: str = Field(..., min_length=2, max_length=50, description="اسم المستخدم")
    email: EmailStr = Field(..., description="البريد الإلكتروني")
    password: str = Field(..., min_length=8, description="كلمة المرور (8 أحرف على الأقل)")
    role: str | None = Field(default="user", description="دور المستخدم")
    
    # Profile Fields
    university: str | None = Field(None, description="الجامعة")
    specialization: str | None = Field(None, description="التخصص")
    academic_year: str | None = Field(None, description="السنة الدراسية")
    degree: str | None = Field(None, description="الدرجة العلمية")
    date_of_birth: str | None = Field(None, description="تاريخ الميلاد (YYYY-MM-DD)")
    profile_image: str | None = Field(None, description="رابط صورة الملف الشخصي")

class UserUpdate(BaseModel):
    name: str | None = Field(None, min_length=2, max_length=50)
    email: EmailStr | None = None
    role: str | None = None
    university: str | None = None
    specialization: str | None = None
    academic_year: str | None = None
    degree: str | None = None
    date_of_birth: str | None = None
    profile_image: str | None = None

class PasswordChange(BaseModel):
    current_password: str
    new_password: str = Field(..., min_length=8)


class UserOut(BaseModel):
    id: int
    barcode_id: str | None = None
    name: str
    email: str
    role: str
    university: str | None = None
    specialization: str | None = None
    academic_year: str | None = None
    degree: str | None = None
    date_of_birth: str | None = None
    profile_image: str | None = None
    status: str = "active"
    created_at: datetime | None = None
    updated_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)


class PendingUserOut(BaseModel):
    id: int
    name: str
    email: str
    university: str | None = None
    specialization: str | None = None
    degree: str | None = None
    academic_year: str | None = None
    document_url: str | None = None
    created_at: datetime | None = None

    model_config = ConfigDict(from_attributes=True)


class Token(BaseModel):
    access_token: str
    refresh_token: str | None = None
    token_type: str = "bearer"


class TokenData(BaseModel):
    email: str | None = None
    role: str | None = None


class NewsBase(BaseModel):
    title: str = Field(..., min_length=5, description="عنوان الخبر")
    description: str | None = Field(None, description="وصف مختصر")
    body: str = Field(..., description="نص الخبر")
    image: str | None = Field(None, description="رابط الصورة الرئيسية")
    images: list[str] | None = Field(None, description="قائمة روابط الصور")


class NewsCreate(NewsBase):
    pass


class NewsUpdate(BaseModel):
    title: str | None = None
    description: str | None = None
    body: str | None = None
    image: str | None = None
    images: list[str] | None = None


class NewsImageOut(BaseModel):
    id: int
    image_url: str
    order: int

    model_config = ConfigDict(from_attributes=True)


class NewsOut(BaseModel):
    id: int
    title: str
    description: str | None = None
    body: str
    image: str | None = None
    images: list[NewsImageOut] = []
    created_at: datetime
    updated_at: datetime | None = None
    author_id: int | None = None

    model_config = ConfigDict(from_attributes=True)


class NotificationBase(BaseModel):
    title: str
    body: str

class NotificationCreate(NotificationBase):
    pass

class NotificationOut(NotificationBase):
    id: int
    created_at: datetime
    author_id: int | None = None
    recipient_id: int | None = None

    model_config = ConfigDict(from_attributes=True)


class OfficeMemberBase(BaseModel):
    name: str
    position: str | None = None
    image_url: str | None = None
    email: str | None = None
    phone: str | None = None
    role: str = "member"

class OfficeMemberCreate(OfficeMemberBase):
    pass

class OfficeMemberUpdate(BaseModel):
    name: str | None = None
    position: str | None = None
    image_url: str | None = None
    email: str | None = None
    phone: str | None = None
    role: str | None = None

class OfficeMemberOut(OfficeMemberBase):
    id: int
    office_id: int

    model_config = ConfigDict(from_attributes=True)


class ExecutiveOfficeBase(BaseModel):
    name: str
    description: str | None = None
    image_url: str | None = None

class ExecutiveOfficeCreate(ExecutiveOfficeBase):
    pass

class ExecutiveOfficeOut(ExecutiveOfficeBase):
    id: int
    members: list[OfficeMemberOut] = []

    model_config = ConfigDict(from_attributes=True)


class UniversityRepresentativeBase(BaseModel):
    name: str
    university: str
    image_url: str | None = None

class UniversityRepresentativeCreate(UniversityRepresentativeBase):
    pass

class UniversityRepresentativeOut(UniversityRepresentativeBase):
    id: int

    model_config = ConfigDict(from_attributes=True)


class ExecutiveOfficeUpdate(BaseModel):
    name: str | None = None
    description: str | None = None
    image_url: str | None = None


class UniversityRepresentativeUpdate(BaseModel):
    name: str | None = None
    university: str | None = None
    image_url: str | None = None


class EventBase(BaseModel):
    title: str = Field(..., min_length=3, description="عنوان الفعالية")
    description: str | None = Field(None, description="وصف الفعالية")
    date: datetime = Field(..., description="تاريخ ووقت الفعالية")
    location: str = Field(..., description="مكان الفعالية")
    image_url: str | None = Field(None, description="رابط صورة الفعالية")
    is_ended: bool = Field(False, description="حالة الفعالية (انتهت/مستمرة)")

class EventCreate(EventBase):
    pass

class EventUpdate(BaseModel):
    title: str | None = None
    description: str | None = None
    date: datetime | None = None
    location: str | None = None
    image_url: str | None = None
    is_ended: bool | None = None

class EventRegistrationOut(BaseModel):
    id: int
    user_id: int
    event_id: int
    registered_at: datetime
    attended: bool
    user: UserOut # Include user details

    model_config = ConfigDict(from_attributes=True)

class EventOut(EventBase):
    id: int
    created_at: datetime
    updated_at: datetime | None = None
    registrations: list[EventRegistrationOut] = []

    model_config = ConfigDict(from_attributes=True)