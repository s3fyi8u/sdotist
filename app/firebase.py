import firebase_admin
from firebase_admin import credentials, messaging
import os
import logging

logger = logging.getLogger(__name__)

# Initialize Firebase Admin SDK
_firebase_app = None

def init_firebase():
    """Initialize Firebase Admin SDK using service account credentials."""
    global _firebase_app
    if _firebase_app:
        return _firebase_app
    
    # Look for service account file
    service_account_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "service-account.json")
    
    if os.path.exists(service_account_path):
        cred = credentials.Certificate(service_account_path)
        _firebase_app = firebase_admin.initialize_app(cred)
        logger.info("Firebase Admin SDK initialized successfully")
    else:
        logger.warning(f"Firebase service account not found at {service_account_path}. Push notifications will not work.")
    
    return _firebase_app


def send_push_notification(tokens: list[str], title: str, body: str) -> dict:
    """
    Send a push notification to multiple device tokens.
    
    Returns a dict with 'success_count' and 'failure_count'.
    """
    if not tokens:
        return {"success_count": 0, "failure_count": 0}
    
    if not _firebase_app:
        init_firebase()
    
    if not _firebase_app:
        logger.warning("Firebase not initialized. Cannot send push notifications.")
        return {"success_count": 0, "failure_count": 0}
    
    message = messaging.MulticastMessage(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        tokens=tokens,
    )
    
    try:
        response = messaging.send_each_for_multicast(message)
        logger.info(f"FCM: {response.success_count} sent, {response.failure_count} failed")
        return {
            "success_count": response.success_count,
            "failure_count": response.failure_count
        }
    except Exception as e:
        logger.error(f"FCM send error: {e}")
        return {"success_count": 0, "failure_count": 0}
