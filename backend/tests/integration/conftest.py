"""
Moduł konfiguracyjny testów integracyjnych.

Konfiguruje aplikację testową z bazą danych in-memory (SQLite),
fixture'y dla klienta testowego oraz autoryzację użytkownika testowego.
"""
import pytest
import jwt
import sys
import os
from datetime import datetime, timedelta, timezone
from unittest.mock import patch
from flask import Flask
from flask_cors import CORS

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))


class TestConfig:
    """Konfiguracja testowa z bazą danych in-memory."""
    SECRET_KEY = 'test-secret-key-for-integration-tests'
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    TESTING = True
    SPOTIFY_CLIENT_ID = 'test-spotify-client-id'
    SPOTIFY_CLIENT_SECRET = 'test-spotify-client-secret'
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024


def create_test_app():
    """Tworzy aplikację Flask z konfiguracją testową."""
    from models.database import db

    app = Flask(__name__)
    app.config.from_object(TestConfig)

    db.init_app(app)
    CORS(app)

    from routes.auth_routes import auth_bp
    from routes.emotion_routes import emotion_bp
    from routes.analytics_routes import analytics_bp

    app.register_blueprint(auth_bp, url_prefix='/api')
    app.register_blueprint(emotion_bp, url_prefix='/api')
    app.register_blueprint(analytics_bp, url_prefix='/api')

    return app


@pytest.fixture(autouse=True)
def mock_config_secret_key():
    """Mockuje SECRET_KEY dla autoryzacji JWT."""
    with patch('config.settings.Config.SECRET_KEY', TestConfig.SECRET_KEY):
        with patch('middleware.auth.Config.SECRET_KEY', TestConfig.SECRET_KEY):
            with patch('routes.auth_routes.Config.SECRET_KEY', TestConfig.SECRET_KEY):
                yield


@pytest.fixture(scope='function')
def app():
    """Tworzy aplikację testową z czystą bazą danych."""
    from models.database import db

    test_app = create_test_app()

    with test_app.app_context():
        db.create_all()
        _seed_emotion_types(db)
        _seed_emotion_playlists(db)
        db.session.commit()

    yield test_app

    with test_app.app_context():
        db.session.remove()
        db.drop_all()


@pytest.fixture(scope='function')
def client(app):
    """Tworzy klienta testowego HTTP."""
    return app.test_client()


@pytest.fixture(scope='function')
def test_user(app):
    """Tworzy użytkownika testowego w bazie danych."""
    from models.user import User
    from models.database import db

    with app.app_context():
        user = User(email='test@example.com')
        user.set_password('testpassword123')
        db.session.add(user)
        db.session.commit()

        user_data = {
            'id': user.id,
            'email': user.email,
            'password': 'testpassword123'
        }

    return user_data


@pytest.fixture(scope='function')
def auth_headers(app, test_user):
    """Generuje nagłówki autoryzacyjne z tokenem JWT."""
    token = jwt.encode(
        {
            'user_id': test_user['id'],
            'exp': datetime.now(timezone.utc) + timedelta(days=7)
        },
        TestConfig.SECRET_KEY,
        algorithm='HS256'
    )
    return {'Authorization': f'Bearer {token}'}


@pytest.fixture(scope='function')
def mock_spotify_service():
    """Mockuje serwis Spotify dla testów."""
    mock_tracks = [
        {
            'name': 'Test Track 1',
            'artist': 'Test Artist 1',
            'spotify_id': 'spotify:track:test1',
            'preview_url': 'https://example.com/preview1.mp3',
            'external_url': 'https://open.spotify.com/track/test1',
            'album_image': 'https://example.com/album1.jpg'
        }
    ]

    with patch('routes.emotion_routes.spotify_service') as mock:
        mock.get_random_tracks_for_emotion.return_value = mock_tracks
        yield mock


def _seed_emotion_types(db):
    """Zasila bazę danymi typami emocji."""
    from models.emotion_type import EmotionType

    emotion_types = [
        {'name': 'happy', 'display_name': 'Szczęśliwy', 'description': 'Radość'},
        {'name': 'sad', 'display_name': 'Smutny', 'description': 'Smutek'},
        {'name': 'angry', 'display_name': 'Zły', 'description': 'Złość'},
        {'name': 'neutral', 'display_name': 'Neutralny', 'description': 'Neutralny'},
    ]

    for et in emotion_types:
        emotion_type = EmotionType(
            name=et['name'],
            display_name=et['display_name'],
            description=et['description']
        )
        db.session.add(emotion_type)


def _seed_emotion_playlists(db):
    """Zasila bazę danymi playlistami emocji."""
    from models.emotion_type import EmotionType
    from models.playlist import EmotionPlaylist

    playlists = {'happy': 'test_happy', 'sad': 'test_sad', 'angry': 'test_angry', 'neutral': 'test_neutral'}

    for emotion_name, playlist_id in playlists.items():
        emotion_type = EmotionType.query.filter_by(name=emotion_name).first()
        if emotion_type:
            playlist = EmotionPlaylist(
                emotion_type_id=emotion_type.id,
                spotify_playlist_id=playlist_id,
                playlist_name=f'Test Playlist for {emotion_name}'
            )
            db.session.add(playlist)
