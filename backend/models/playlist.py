from models.database import db
from config.settings import get_polish_time

class EmotionPlaylist(db.Model):
    __tablename__ = 'emotion_playlists'

    id = db.Column(db.Integer, primary_key=True)
    emotion_type_id = db.Column(db.Integer, db.ForeignKey('emotion_types.id'), unique=True, nullable=False, index=True)
    spotify_playlist_id = db.Column(db.String(100), nullable=False)
    playlist_name = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, default=get_polish_time, nullable=False)
    updated_at = db.Column(db.DateTime, default=get_polish_time, onupdate=get_polish_time, nullable=False)

    def to_dict(self):
        """Convert playlist to dictionary"""
        return {
            'id': self.id,
            'emotion': self.emotion_type.name if self.emotion_type else None,
            'emotion_display_name': self.emotion_type.display_name if self.emotion_type else None,
            'spotify_playlist_id': self.spotify_playlist_id,
            'playlist_name': self.playlist_name,
            'description': self.description,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }

    @staticmethod
    def get_by_emotion(emotion_name):
        """Get playlist by emotion name"""
        from models.emotion_type import EmotionType
        emotion_type = EmotionType.get_by_name(emotion_name)
        if not emotion_type:
            return None
        return EmotionPlaylist.query.filter_by(emotion_type_id=emotion_type.id).first()

    @staticmethod
    def get_all():
        """Get all emotion playlists"""
        return EmotionPlaylist.query.all()
