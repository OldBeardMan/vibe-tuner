from models.database import db
from config.settings import get_polish_time

class EmotionRecord(db.Model):
    __tablename__ = 'emotions'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)
    emotion_type_id = db.Column(db.Integer, db.ForeignKey('emotion_types.id'), nullable=False, index=True)
    confidence = db.Column(db.Float, nullable=False)
    timestamp = db.Column(db.DateTime, default=get_polish_time, nullable=False, index=True)
    spotify_playlist_id = db.Column(db.String(100), nullable=True)
    user_feedback = db.Column(db.Boolean, nullable=True, default=None)

    def to_dict(self):
        return {
            'id': self.id,
            'emotion': self.emotion_type.name if self.emotion_type else None,
            'emotion_display_name': self.emotion_type.display_name if self.emotion_type else None,
            'confidence': self.confidence,
            'timestamp': self.timestamp.isoformat(),
            'spotify_playlist_id': self.spotify_playlist_id,
            'user_feedback': self.user_feedback
        }