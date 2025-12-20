"""
Testy integracyjne dla modułu autentykacji.

Testuje punkty końcowe: rejestracja, logowanie, usunięcie konta.
"""
import pytest
import json


class TestRegister:
    """Testy dla rejestracji użytkownika."""

    def test_register_success_returns_201(self, client):
        """Sprawdza poprawną rejestrację nowego użytkownika."""
        # Arrange
        register_data = {'email': 'newuser@example.com', 'password': 'securepassword123'}

        # Act
        response = client.post('/api/auth/register', data=json.dumps(register_data), content_type='application/json')

        # Assert
        assert response.status_code == 201
        assert json.loads(response.data)['user']['email'] == 'newuser@example.com'

    def test_register_invalid_email_returns_400(self, client):
        """Sprawdza walidację nieprawidłowego emaila."""
        response = client.post('/api/auth/register', data=json.dumps({'email': 'invalid-email', 'password': 'password123'}), content_type='application/json')

        assert response.status_code == 400

    def test_register_duplicate_email_returns_409(self, client, test_user):
        """Sprawdza czy rejestracja z istniejącym emailem zwraca 409."""
        response = client.post('/api/auth/register', data=json.dumps({'email': test_user['email'], 'password': 'password'}), content_type='application/json')

        assert response.status_code == 409


class TestLogin:
    """Testy dla logowania użytkownika."""

    def test_login_success_returns_token(self, client, test_user):
        """Sprawdza poprawne logowanie i zwrot tokenu JWT."""
        response = client.post('/api/auth/login', data=json.dumps({'email': test_user['email'], 'password': test_user['password']}), content_type='application/json')

        assert response.status_code == 200
        assert 'token' in json.loads(response.data)

    def test_login_invalid_credentials_returns_401(self, client, test_user):
        """Sprawdza czy nieprawidłowe dane logowania zwracają 401."""
        response = client.post('/api/auth/login', data=json.dumps({'email': test_user['email'], 'password': 'wrongpassword'}), content_type='application/json')

        assert response.status_code == 401


class TestDeleteAccount:
    """Testy dla usuwania konta."""

    def test_delete_account_success(self, client, test_user, auth_headers):
        """Sprawdza poprawne usunięcie konta użytkownika."""
        response = client.delete('/api/auth/account', data=json.dumps({'password': test_user['password']}), content_type='application/json', headers=auth_headers)

        assert response.status_code == 200

    def test_delete_account_without_auth_returns_401(self, client):
        """Sprawdza czy brak autoryzacji zwraca 401."""
        response = client.delete('/api/auth/account', data=json.dumps({'password': 'any'}), content_type='application/json')

        assert response.status_code == 401
