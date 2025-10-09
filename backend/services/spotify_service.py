import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
from config.settings import Config
import random

class SpotifyService:
    def __init__(self):
        self.client_credentials_manager = SpotifyClientCredentials(
            client_id=Config.SPOTIFY_CLIENT_ID,
            client_secret=Config.SPOTIFY_CLIENT_SECRET
        )
        self.spotify = spotipy.Spotify(client_credentials_manager=self.client_credentials_manager)

        # Pre-created playlists mapping (7 playlists for 7 emotions)
        # TODO: Replace these IDs with actual Spotify playlist IDs
        self.emotion_playlists = {
            'happy': '37i9dQZF1DXdPec7aLTmlC',      # Happy Hits
            'sad': '37i9dQZF1DX7qK8ma5wgG1',        # Sad Indie
            'angry': '37i9dQZF1DX4pUKG1kS0Ac',      # Rock Classics
            'surprise': '37i9dQZF1DWZd79rJ6a7lp',   # Electronic Hits
            'neutral': '37i9dQZF1DX4sWSpwq3LiO',    # Peaceful Piano
            'fear': '37i9dQZF1DX4pUKG1kS0Ac',       # Dark & Stormy
            'disgust': '37i9dQZF1DX0XUsuxWHRQd'     # RapCaviar
        }
    
    def get_playlist_for_emotion(self, emotion):
        """
        Get pre-created Spotify playlist for given emotion
        Fetches playlist details from Spotify API
        """
        try:
            if not self.spotify:
                return None

            # Get playlist ID for emotion
            playlist_id = self.emotion_playlists.get(emotion)

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
        playlist_id = self.emotion_playlists.get(emotion, '')

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