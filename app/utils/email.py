from fastapi_mail import FastMail, MessageSchema, ConnectionConfig, MessageType
from pydantic import EmailStr
from ..config import settings
from pathlib import Path

conf = ConnectionConfig(
    MAIL_USERNAME=settings.MAIL_USERNAME,
    MAIL_PASSWORD=settings.MAIL_PASSWORD,
    MAIL_FROM=settings.MAIL_FROM,
    MAIL_PORT=settings.MAIL_PORT,
    MAIL_SERVER="smtp.zoho.sa",
    MAIL_STARTTLS=False,
    MAIL_SSL_TLS=True,
    USE_CREDENTIALS=True,
    VALIDATE_CERTS=True,
    TEMPLATE_FOLDER=Path(__file__).parent.parent / 'templates'
)

async def send_verification_email(email: EmailStr, name: str, token: str, language: str = "ar"):
    verification_link = f"https://api.sdotist.org/auth/verify-email?token={token}"
    
    # Common variables
    variables = {
        "user_name": name,
        "verification_link": verification_link,
        "expiry_minutes": "30",
        "logo_url": "https://sdotist.org/assets/images/app_icon.png",
        "facebook_url": "https://facebook.com/sdotist",
        "twitter_url": "https://twitter.com/sdotist",
        "instagram_url": "https://instagram.com/sdotist"
    }
    
    # Select template based on language
    template_name = "verification_email_en.html" if language == "en" else "verification_email_ar.html"
    template_path = conf.TEMPLATE_FOLDER / template_name
    
    with open(template_path, "r", encoding="utf-8") as f:
        html = f.read()
        
    # Inject variables
    for key, value in variables.items():
        html = html.replace(f"{{{{ {key} }}}}", value)

    message = MessageSchema(
        subject="Verify your sdotist account" if language == "en" else "تأكيد حسابك في رابطة الطلاب السودانيين باسطنبول",
        recipients=[email],
        body=html,
        subtype=MessageType.html
    )

    fm = FastMail(conf)
    await fm.send_message(message)

async def send_welcome_email(email: EmailStr, name: str, language: str = "ar"):
    # Common variables
    variables = {
        "user_name": name,
        "app_url": "https://sdotist.org",
        "logo_url": "https://sdotist.org/assets/images/app_icon.png",
        "facebook_url": "https://facebook.com/sdotist",
        "twitter_url": "https://twitter.com/sdotist",
        "instagram_url": "https://instagram.com/sdotist"
    }
    
    # Select template based on language
    template_name = "welcome_email_en.html" if language == "en" else "welcome_email_ar.html"
    template_path = conf.TEMPLATE_FOLDER / template_name
    
    with open(template_path, "r", encoding="utf-8") as f:
        html = f.read()
        
    # Inject variables
    for key, value in variables.items():
        html = html.replace(f"{{{{ {key} }}}}", value)

    message = MessageSchema(
        subject="Welcome to sdotist!" if language == "en" else "مرحباً بك في رابطة الطلاب السودانيين باسطنبول",
        recipients=[email],
        body=html,
        subtype=MessageType.html
    )

    fm = FastMail(conf)
    await fm.send_message(message)
