from models.database import db

class EmotionTrack(db.Model):
    __tablename__ = 'emotion_tracks'

    id = db.Column(db.Integer, primary_key=True)
    emotion_record_id = db.Column(db.Integer, db.ForeignKey('emotions.id', ondelete='CASCADE'), nullable=False, index=True)
    track_name = db.Column(db.String(255), nullable=False)
    artist = db.Column(db.String(255), nullable=False)
    spotify_track_id = db.Column(db.String(100), nullable=False)
    preview_url = db.Column(db.String(500), nullable=True)
    external_url = db.Column(db.String(500), nullable=False)
    album_image = db.Column(db.String(500), nullable=True)

    def to_dict(self):
        """Convert track to dictionary"""
        return {
            'name': self.track_name,
            'artist': self.artist,
            'spotify_id': self.spotify_track_id,
            'preview_url': self.preview_url,
            'external_url': self.external_url,
            'album_image': self.album_image
        }
