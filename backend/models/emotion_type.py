from datetime import datetime
from models.database import db

class EmotionType(db.Model):
    __tablename__ = 'emotion_types'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), unique=True, nullable=False, index=True)
    display_name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)

    # Relationships
    emotion_records = db.relationship('EmotionRecord', backref='emotion_type', lazy=True)
    playlists = db.relationship('EmotionPlaylist', backref='emotion_type', lazy=True, uselist=False)

    def to_dict(self):
        """Convert emotion type to dictionary"""
        return {
            'id': self.id,
            'name': self.name,
            'display_name': self.display_name,
            'description': self.description,
            'created_at': self.created_at.isoformat()
        }

    @staticmethod
    def get_by_name(name):
        """Get emotion type by name"""
        return EmotionType.query.filter_by(name=name).first()

    @staticmethod
    def get_all():
        """Get all emotion types"""
        return EmotionType.query.all()

    @staticmethod
    def get_all_names():
        """Get list of all emotion names"""
        return [et.name for et in EmotionType.query.all()]

    @staticmethod
    def is_valid_emotion(name):
        """Check if emotion name is valid"""
        return EmotionType.query.filter_by(name=name).first() is not None
