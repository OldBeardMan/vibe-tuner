from datetime import datetime
from models.database import db

class EmotionRecord(db.Model):
    __tablename__ = 'emotions'
    
    id = db.Column(db.Integer, primary_key=True)
    emotion = db.Column(db.String(50), nullable=False)
    confidence = db.Column(db.Float, nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    image_hash = db.Column(db.String(64), nullable=True)
    spotify_playlist_id = db.Column(db.String(100), nullable=True)
    
    def to_dict(self):
        return {
            'id': self.id,
            'emotion': self.emotion,
            'confidence': self.confidence,
            'timestamp': self.timestamp.isoformat(),
            'spotify_playlist_id': self.spotify_playlist_id
        }