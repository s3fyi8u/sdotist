from fastapi_mail import FastMail, MessageSchema, ConnectionConfig, MessageType
from pydantic import EmailStr
from .config import settings
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

async def send_verification_email(email: EmailStr, token: str):
    verification_link = f"https://api.sdotist.org/auth/verify-email?token={token}"
    
    html = f"""
    <p>Welcome to sdotist!</p>
    <p>Please click the link below to verify your account:</p>
    <p><a href="{verification_link}">Verify Account</a></p>
    """

    message = MessageSchema(
        subject="Verify your sdotist account",
        recipients=[email],
        body=html,
        subtype=MessageType.html
    )

    fm = FastMail(conf)
    await fm.send_message(message)
