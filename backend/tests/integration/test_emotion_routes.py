"""
Testy integracyjne dla modułu emocji.

Testuje punkty końcowe: analiza emocji, historia, feedback.
"""
import pytest
import json


class TestAnalyzeEmotion:
    """Testy dla analizy emocji."""

    def test_analyze_emotion_manual_success(self, client, auth_headers, mock_spotify_service):
        """Sprawdza poprawne wprowadzenie emocji manualnie."""
        response = client.post('/api/emotion/analyze', data=json.dumps({'emotion': 'happy', 'confidence': 0.95}), content_type='application/json', headers=auth_headers)

        assert response.status_code == 200
        data = json.loads(response.data)
        assert data['emotion'] == 'happy'
        assert data['detection_source'] == 'manual'
        assert 'tracks' in data

    def test_analyze_emotion_invalid_type_returns_400(self, client, auth_headers):
        """Sprawdza czy nieprawidłowy typ emocji zwraca 400."""
        response = client.post('/api/emotion/analyze', data=json.dumps({'emotion': 'nonexistent', 'confidence': 0.9}), content_type='application/json', headers=auth_headers)

        assert response.status_code == 400

    def test_analyze_emotion_without_auth_returns_401(self, client):
        """Sprawdza czy brak autoryzacji zwraca 401."""
        response = client.post('/api/emotion/analyze', data=json.dumps({'emotion': 'happy'}), content_type='application/json')

        assert response.status_code == 401


class TestEmotionHistory:
    """Testy dla historii emocji."""

    def test_get_history_empty_returns_200(self, client, auth_headers):
        """Sprawdza pobieranie pustej historii."""
        response = client.get('/api/emotion/history', headers=auth_headers)

        assert response.status_code == 200
        assert json.loads(response.data)['records'] == []

    def test_get_history_with_records(self, client, auth_headers, mock_spotify_service):
        """Sprawdza pobieranie historii z rekordami."""
        # Dodanie rekordu
        client.post('/api/emotion/analyze', data=json.dumps({'emotion': 'happy', 'confidence': 0.9}), content_type='application/json', headers=auth_headers)

        response = client.get('/api/emotion/history', headers=auth_headers)

        assert response.status_code == 200
        assert len(json.loads(response.data)['records']) == 1


class TestEmotionFeedback:
    """Testy dla feedbacku emocji."""

    def test_set_feedback_success(self, client, auth_headers, mock_spotify_service):
        """Sprawdza ustawianie feedbacku użytkownika."""
        # Utworzenie rekordu
        create_response = client.post('/api/emotion/analyze', data=json.dumps({'emotion': 'happy', 'confidence': 0.9}), content_type='application/json', headers=auth_headers)
        emotion_id = json.loads(create_response.data)['id']

        response = client.post(f'/api/emotion/{emotion_id}/feedback', data=json.dumps({'agrees': True}), content_type='application/json', headers=auth_headers)

        assert response.status_code == 200

    def test_set_feedback_not_found_returns_404(self, client, auth_headers):
        """Sprawdza czy nieistniejący rekord zwraca 404."""
        response = client.post('/api/emotion/99999/feedback', data=json.dumps({'agrees': True}), content_type='application/json', headers=auth_headers)

        assert response.status_code == 404
