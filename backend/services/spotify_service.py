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
        playlist = EmotionPlaylist.get_by_emotion(emotion)
        return playlist.spotify_playlist_id if playlist else None

    def get_random_tracks_for_emotion(self, emotion, count=5):
        try:
            if not self.spotify:
                return []

            playlist_id = self._get_playlist_id_for_emotion(emotion)

            if not playlist_id:
                return []

            playlist = self.spotify.playlist(playlist_id)

            all_tracks = []
            for item in playlist['tracks']['items']:
                if item['track']:
                    track = item['track']
                    all_tracks.append({
                        'name': track['name'],
                        'artist': track['artists'][0]['name'] if track['artists'] else 'Unknown',
                        'spotify_id': track['id'],
                        'preview_url': track.get('preview_url'),
                        'external_url': track['external_urls']['spotify'],
                        'album_image': track['album']['images'][0]['url'] if track['album']['images'] else None
                    })

            if len(all_tracks) <= count:
                return all_tracks

            return random.sample(all_tracks, count)

        except Exception as e:
            print(f"Error getting Spotify tracks: {str(e)}")
            return []