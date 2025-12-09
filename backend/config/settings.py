import os
from dotenv import load_dotenv
from datetime import datetime, timezone
from zoneinfo import ZoneInfo

load_dotenv()

# Polish timezone
POLISH_TZ = ZoneInfo('Europe/Warsaw')

def get_polish_time():
    """Get current time in Polish timezone (naive datetime for SQLAlchemy)"""
    return datetime.now(POLISH_TZ).replace(tzinfo=None)

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY')
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SPOTIFY_CLIENT_ID = os.environ.get('SPOTIFY_CLIENT_ID')
    SPOTIFY_CLIENT_SECRET = os.environ.get('SPOTIFY_CLIENT_SECRET')
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB
    TIMEZONE = POLISH_TZ