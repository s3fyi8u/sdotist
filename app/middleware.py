from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from fastapi import Request

import os

# Rate Limiter instance
limiter = Limiter(key_func=get_remote_address, enabled=os.getenv("TESTING") != "1")


def setup_rate_limiting(app):
    """إعداد Rate Limiting للتطبيق"""
    app.state.limiter = limiter
    app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
