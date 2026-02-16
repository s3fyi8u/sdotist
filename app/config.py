from pydantic_settings import BaseSettings, SettingsConfigDict
from functools import lru_cache


class Settings(BaseSettings):
    # JWT Settings
    SECRET_KEY: str = "super-secret-key-change-me"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # Database
    DATABASE_URL: str = "sqlite:///./test.db"

    # App Settings
    APP_NAME: str = "User Management API"
    DEBUG: bool = False

    # Email Settings
    MAIL_USERNAME: str = "support@sdotist.org"
    MAIL_PASSWORD: str = "Sdotist360*"
    MAIL_FROM: str = "support@sdotist.org"
    MAIL_PORT: int = 465
    MAIL_SERVER: str = "smtp.zoho.sa"
    MAIL_STARTTLS: bool = False
    MAIL_SSL_TLS: bool = True

    model_config = SettingsConfigDict(env_file=".env")


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
