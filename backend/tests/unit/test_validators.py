"""
Testy jednostkowe dla funkcji walidacyjnych.

Sprawdza działanie funkcji validate_email i validate_password.
"""
import pytest
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from routes.auth_routes import validate_email, validate_password


class TestValidateEmail:
    """Testy dla funkcji validate_email."""

    def test_valid_email_returns_true(self):
        """Sprawdza czy prawidłowy adres email zwraca True."""
        assert validate_email('user@example.com') is True

    def test_invalid_email_returns_false(self):
        """Sprawdza czy nieprawidłowy adres email zwraca False."""
        assert validate_email('invalid-email') is False


class TestValidatePassword:
    """Testy dla funkcji validate_password."""

    def test_valid_password_returns_true(self):
        """Sprawdza czy hasło >= 6 znaków zwraca True."""
        assert validate_password('password123') is True

    def test_short_password_returns_false(self):
        """Sprawdza czy hasło < 6 znaków zwraca False."""
        assert validate_password('12345') is False

    def test_exactly_6_chars_returns_true(self):
        """Sprawdza wartość graniczną - dokładnie 6 znaków."""
        assert validate_password('abc123') is True
