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
    MAIL_USERNAME: str = "info@sdotist.org"
    MAIL_PASSWORD: str = "Pablo@390"
    MAIL_FROM: str = "info@sdotist.org"
    MAIL_PORT: int = 587
    MAIL_SERVER: str = "smtp.zoho.sa"
    MAIL_STARTTLS: bool = True
    MAIL_SSL_TLS: bool = False

    model_config = SettingsConfigDict(env_file=".env")


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
