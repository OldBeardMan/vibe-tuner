"""
Testy jednostkowe dla modelu User.

Sprawdza działanie metod hashowania hasła i konwersji do słownika.
"""
import pytest
import sys
import os
from datetime import datetime

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))


class TestUserSetPassword:
    """Testy dla metody set_password."""

    def test_password_is_hashed(self):
        """Sprawdza czy hasło jest hashowane."""
        from models.user import User
        user = User(email='test@example.com')

        user.set_password('securepassword123')

        assert user.password_hash != 'securepassword123'
        assert len(user.password_hash) > 20

    def test_different_passwords_different_hashes(self):
        """Sprawdza czy różne hasła mają różne hashe."""
        from models.user import User
        user1 = User(email='user1@example.com')
        user2 = User(email='user2@example.com')

        user1.set_password('password1')
        user2.set_password('password2')

        assert user1.password_hash != user2.password_hash


class TestUserCheckPassword:
    """Testy dla metody check_password."""

    def test_correct_password_returns_true(self):
        """Sprawdza czy poprawne hasło zwraca True."""
        from models.user import User
        user = User(email='test@example.com')
        user.set_password('correctpassword')

        assert user.check_password('correctpassword') is True

    def test_incorrect_password_returns_false(self):
        """Sprawdza czy niepoprawne hasło zwraca False."""
        from models.user import User
        user = User(email='test@example.com')
        user.set_password('correctpassword')

        assert user.check_password('wrongpassword') is False


class TestUserToDict:
    """Testy dla metody to_dict."""

    def test_contains_required_fields(self):
        """Sprawdza czy słownik zawiera wymagane pola."""
        from models.user import User
        user = User(email='test@example.com')
        user.id = 1
        user.created_at = datetime(2025, 1, 15, 10, 30, 0)

        result = user.to_dict()

        assert 'id' in result
        assert 'email' in result
        assert 'created_at' in result

    def test_excludes_password_hash(self):
        """Sprawdza czy słownik NIE zawiera hasła."""
        from models.user import User
        user = User(email='test@example.com')
        user.id = 1
        user.created_at = datetime(2025, 1, 15, 10, 30, 0)
        user.set_password('secret')

        result = user.to_dict()

        assert 'password' not in result
        assert 'password_hash' not in result
