"""
Testy integracyjne dla modułu analityki.

Testuje punkty końcowe: analiza godzinowa, dzienna, rozkład emocji.
"""
import pytest
import json


class TestAnalytics:
    """Testy dla analityki emocji."""

    def test_get_emotions_by_hour_returns_200(self, client, auth_headers):
        """Sprawdza pobieranie analizy godzinowej."""
        response = client.get('/api/analytics/by-hour', headers=auth_headers)

        assert response.status_code == 200
        assert 'by_hour' in json.loads(response.data)

    def test_get_emotions_by_day_returns_200(self, client, auth_headers):
        """Sprawdza pobieranie analizy dziennej."""
        response = client.get('/api/analytics/by-day', headers=auth_headers)

        assert response.status_code == 200
        assert 'by_day' in json.loads(response.data)

    def test_get_distribution_returns_200(self, client, auth_headers):
        """Sprawdza pobieranie rozkładu emocji."""
        response = client.get('/api/analytics/distribution', headers=auth_headers)

        assert response.status_code == 200
        assert 'distribution' in json.loads(response.data)

    def test_analytics_without_auth_returns_401(self, client):
        """Sprawdza czy brak autoryzacji zwraca 401."""
        response = client.get('/api/analytics/by-hour')

        assert response.status_code == 401
