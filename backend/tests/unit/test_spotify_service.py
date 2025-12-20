"""
Testy jednostkowe dla serwisu SpotifyService.

Sprawdza działanie metod pobierania utworów z API Spotify.
"""
import pytest
from unittest.mock import Mock, patch


class TestGetRandomTracksForEmotion:
    """Testy dla metody get_random_tracks_for_emotion."""

    @patch('services.spotify_service.EmotionPlaylist')
    @patch('services.spotify_service.SpotifyClientCredentials')
    @patch('services.spotify_service.spotipy.Spotify')
    def test_get_tracks_success(self, mock_spotify_class, mock_credentials, mock_playlist_model):
        """Sprawdza poprawne pobieranie utworów dla emocji."""
        from services.spotify_service import SpotifyService

        # Mock playlisty
        mock_playlist = Mock()
        mock_playlist.spotify_playlist_id = 'test_playlist_id'
        mock_playlist_model.get_by_emotion.return_value = mock_playlist

        # Mock Spotify API
        mock_spotify_instance = Mock()
        mock_spotify_instance.playlist.return_value = {
            'tracks': {'items': [{'track': {
                'name': 'Test Track',
                'artists': [{'name': 'Artist'}],
                'id': 'track_id',
                'preview_url': 'https://preview.mp3',
                'external_urls': {'spotify': 'https://open.spotify.com/track/1'},
                'album': {'images': [{'url': 'https://album.jpg'}]}
            }}]}
        }
        mock_spotify_class.return_value = mock_spotify_instance

        service = SpotifyService()
        result = service.get_random_tracks_for_emotion('happy', count=1)

        assert len(result) == 1
        assert result[0]['name'] == 'Test Track'

    @patch('services.spotify_service.EmotionPlaylist')
    @patch('services.spotify_service.SpotifyClientCredentials')
    @patch('services.spotify_service.spotipy.Spotify')
    def test_no_playlist_returns_empty(self, mock_spotify_class, mock_credentials, mock_playlist_model):
        """Sprawdza czy brak playlisty zwraca pustą listę."""
        from services.spotify_service import SpotifyService

        mock_playlist_model.get_by_emotion.return_value = None
        mock_spotify_class.return_value = Mock()

        service = SpotifyService()
        result = service.get_random_tracks_for_emotion('nonexistent')

        assert result == []

    @patch('services.spotify_service.EmotionPlaylist')
    @patch('services.spotify_service.SpotifyClientCredentials')
    @patch('services.spotify_service.spotipy.Spotify')
    def test_api_error_returns_empty(self, mock_spotify_class, mock_credentials, mock_playlist_model):
        """Sprawdza czy błąd API zwraca pustą listę."""
        from services.spotify_service import SpotifyService

        mock_playlist = Mock()
        mock_playlist.spotify_playlist_id = 'test_id'
        mock_playlist_model.get_by_emotion.return_value = mock_playlist

        mock_spotify_instance = Mock()
        mock_spotify_instance.playlist.side_effect = Exception("API Error")
        mock_spotify_class.return_value = mock_spotify_instance

        service = SpotifyService()
        result = service.get_random_tracks_for_emotion('happy')

        assert result == []
