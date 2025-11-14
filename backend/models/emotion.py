from models.database import db
from config.settings import get_polish_time

class EmotionRecord(db.Model):
    __tablename__ = 'emotions'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)
    emotion_type_id = db.Column(db.Integer, db.ForeignKey('emotion_types.id'), nullable=False, index=True)
    confidence = db.Column(db.Float, nullable=False)
    timestamp = db.Column(db.DateTime, default=get_polish_time, nullable=False, index=True)
    user_feedback = db.Column(db.Boolean, nullable=True, default=None)
    detection_source = db.Column(db.String(20), nullable=False, default='image')  # 'image' or 'manual'

    # Relationship to tracks
    tracks = db.relationship('EmotionTrack', backref='emotion_record', lazy=True, cascade='all, delete-orphan')

    def to_dict(self):
        return {
            'id': self.id,
            'emotion': self.emotion_type.name if self.emotion_type else None,
            'emotion_display_name': self.emotion_type.display_name if self.emotion_type else None,
            'confidence': self.confidence,
            'timestamp': self.timestamp.isoformat(),
            'user_feedback': self.user_feedback,
            'detection_source': self.detection_source,
            'tracks': [track.to_dict() for track in self.tracks] if self.tracks else []
        }