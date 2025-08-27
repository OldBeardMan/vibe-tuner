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
        
        # Emotion to genre/mood mapping
        self.emotion_genres = {
            'happy': ['pop', 'dance', 'funk', 'disco', 'electronic'],
            'sad': ['blues', 'indie', 'alternative', 'acoustic', 'folk'],
            'angry': ['rock', 'metal', 'punk', 'hard rock', 'grunge'],
            'surprised': ['electronic', 'experimental', 'techno', 'ambient'],
            'neutral': ['ambient', 'chill', 'lo-fi', 'indie', 'alternative'],
            'fear': ['dark ambient', 'industrial', 'gothic', 'doom'],
            'disgust': ['experimental', 'noise', 'industrial']
        }
        
        # Emotion to audio features
        self.emotion_features = {
            'happy': {'valence': (0.6, 1.0), 'energy': (0.5, 1.0), 'danceability': (0.5, 1.0)},
            'sad': {'valence': (0.0, 0.4), 'energy': (0.0, 0.5), 'acousticness': (0.3, 1.0)},
            'angry': {'valence': (0.0, 0.5), 'energy': (0.7, 1.0), 'loudness': (-10, 0)},
            'surprised': {'valence': (0.4, 0.8), 'energy': (0.6, 1.0)},
            'neutral': {'valence': (0.3, 0.7), 'energy': (0.3, 0.7)},
            'fear': {'valence': (0.0, 0.3), 'energy': (0.2, 0.6)},
            'disgust': {'valence': (0.0, 0.3), 'energy': (0.3, 0.7)}
        }
    
    def get_playlist_for_emotion(self, emotion):
        try:
            if not self.spotify:
                return None
            
            # Get genres for this emotion
            genres = self.emotion_genres.get(emotion, ['pop'])
            selected_genre = random.choice(genres)
            
            # Search for tracks
            query = f'genre:{selected_genre}'
            results = self.spotify.search(
                q=query, 
                type='track', 
                limit=20,
                market='US'
            )
            
            if not results['tracks']['items']:
                # Fallback search without genre
                results = self.spotify.search(
                    q=f'mood {emotion}',
                    type='track',
                    limit=20,
                    market='US'
                )
            
            tracks = []
            for track in results['tracks']['items'][:10]:
                tracks.append({
                    'name': track['name'],
                    'artist': track['artists'][0]['name'],
                    'spotify_id': track['id'],
                    'preview_url': track.get('preview_url'),
                    'external_url': track['external_urls']['spotify']
                })
            
            playlist = {
                'name': f'{emotion.title()} Vibes',
                'emotion': emotion,
                'genre': selected_genre,
                'tracks': tracks,
                'total_tracks': len(tracks)
            }
            
            return playlist
            
        except Exception as e:
            print(f"Error getting Spotify playlist: {str(e)}")
            return self._get_fallback_playlist(emotion)
    
    def _get_fallback_playlist(self, emotion):
        # Fallback playlist when Spotify API fails
        fallback_tracks = {
            'happy': [
                {'name': 'Happy', 'artist': 'Pharrell Williams', 'spotify_id': 'fallback'},
                {'name': 'Good as Hell', 'artist': 'Lizzo', 'spotify_id': 'fallback'}
            ],
            'sad': [
                {'name': 'Someone Like You', 'artist': 'Adele', 'spotify_id': 'fallback'},
                {'name': 'Mad World', 'artist': 'Gary Jules', 'spotify_id': 'fallback'}
            ],
            'angry': [
                {'name': 'Break Stuff', 'artist': 'Limp Bizkit', 'spotify_id': 'fallback'},
                {'name': 'Bodies', 'artist': 'Drowning Pool', 'spotify_id': 'fallback'}
            ]
        }
        
        return {
            'name': f'{emotion.title()} Vibes (Fallback)',
            'emotion': emotion,
            'tracks': fallback_tracks.get(emotion, []),
            'total_tracks': len(fallback_tracks.get(emotion, []))
        }