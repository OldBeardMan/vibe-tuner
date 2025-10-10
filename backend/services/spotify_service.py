import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
from config.settings import Config
from models.playlist import EmotionPlaylist
import random

class SpotifyService:
    def __init__(self):
        self.client_credentials_manager = SpotifyClientCredentials(
            client_id=Config.SPOTIFY_CLIENT_ID,
            client_secret=Config.SPOTIFY_CLIENT_SECRET
        )
        self.spotify = spotipy.Spotify(client_credentials_manager=self.client_credentials_manager)

    def _get_playlist_id_for_emotion(self, emotion):
        """Get playlist ID from database for given emotion"""
        playlist = EmotionPlaylist.get_by_emotion(emotion)
        return playlist.spotify_playlist_id if playlist else None
    
    def get_playlist_for_emotion(self, emotion):
        """
        Get pre-created Spotify playlist for given emotion
        Fetches playlist details from Spotify API
        """
        try:
            if not self.spotify:
                return None

            # Get playlist ID from database
            playlist_id = self._get_playlist_id_for_emotion(emotion)

            if not playlist_id:
                return None

            # Fetch playlist details from Spotify
            playlist = self.spotify.playlist(playlist_id)

            # Get tracks from playlist
            tracks = []
            for item in playlist['tracks']['items'][:20]:  # Limit to 20 tracks
                if item['track']:
                    track = item['track']
                    tracks.append({
                        'name': track['name'],
                        'artist': track['artists'][0]['name'] if track['artists'] else 'Unknown',
                        'spotify_id': track['id'],
                        'preview_url': track.get('preview_url'),
                        'external_url': track['external_urls']['spotify'],
                        'album_image': track['album']['images'][0]['url'] if track['album']['images'] else None
                    })

            return {
                'id': playlist_id,
                'name': playlist['name'],
                'description': playlist.get('description', ''),
                'emotion': emotion,
                'tracks': tracks,
                'total_tracks': len(tracks),
                'external_url': playlist['external_urls']['spotify'],
                'image': playlist['images'][0]['url'] if playlist['images'] else None
            }

        except Exception as e:
            print(f"Error getting Spotify playlist: {str(e)}")
            return self._get_fallback_playlist(emotion)
    
    def _get_fallback_playlist(self, emotion):
        """Fallback playlist when Spotify API fails"""
        playlist_id = self._get_playlist_id_for_emotion(emotion) or ''

        return {
            'id': playlist_id,
            'name': f'{emotion.title()} Vibes',
            'description': f'A playlist for {emotion} mood',
            'emotion': emotion,
            'tracks': [],
            'total_tracks': 0,
            'external_url': f'https://open.spotify.com/playlist/{playlist_id}',
            'image': None,
            'error': 'Could not fetch playlist from Spotify'
        }