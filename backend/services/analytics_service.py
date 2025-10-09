from datetime import datetime, timedelta
from sqlalchemy import func, and_, extract
from models.emotion import EmotionRecord
from models.database import db
from collections import defaultdict


class AnalyticsService:
    """Service for analyzing emotion data and generating statistics"""

    def get_emotions_by_hour(self, user_id):
        """
        Get emotion counts grouped by hour of day (0-23)
        Returns: { "0": {"happy": 3, "sad": 1}, "1": {...}, ... }
        """
        try:
            # Query emotions grouped by hour and emotion type
            results = db.session.query(
                extract('hour', EmotionRecord.timestamp).label('hour'),
                EmotionRecord.emotion,
                func.count(EmotionRecord.id).label('count')
            ).filter(
                EmotionRecord.user_id == user_id
            ).group_by(
                extract('hour', EmotionRecord.timestamp),
                EmotionRecord.emotion
            ).all()

            # Format results
            analysis = defaultdict(lambda: defaultdict(int))
            for hour, emotion, count in results:
                analysis[str(int(hour))][emotion] = count

            # Convert to regular dict
            return {hour: dict(emotions) for hour, emotions in analysis.items()}

        except Exception as e:
            print(f"Error in get_emotions_by_hour: {str(e)}")
            return {}

    def get_emotions_by_day(self, user_id):
        """
        Get emotion counts grouped by day of week (0=Monday, 6=Sunday)
        Returns: { "0": {"happy": 5, "sad": 2}, "1": {...}, ... }
        """
        try:
            # Query emotions grouped by day of week and emotion type
            # ISOWEEKDAY: 1=Monday, 7=Sunday (we'll convert to 0-6)
            results = db.session.query(
                extract('dow', EmotionRecord.timestamp).label('day_of_week'),
                EmotionRecord.emotion,
                func.count(EmotionRecord.id).label('count')
            ).filter(
                EmotionRecord.user_id == user_id
            ).group_by(
                extract('dow', EmotionRecord.timestamp),
                EmotionRecord.emotion
            ).all()

            # Format results
            analysis = defaultdict(lambda: defaultdict(int))
            for day, emotion, count in results:
                # Convert PostgreSQL dow (0=Sunday, 6=Saturday) to 0=Monday, 6=Sunday
                day_normalized = str(int((day + 6) % 7))
                analysis[day_normalized][emotion] = count

            # Convert to regular dict
            return {day: dict(emotions) for day, emotions in analysis.items()}

        except Exception as e:
            print(f"Error in get_emotions_by_day: {str(e)}")
            return {}

    def get_emotion_distribution(self, user_id):
        """
        Get percentage distribution of all emotions
        Returns: { "happy": 35.5, "sad": 20.0, "angry": 15.5, ... }
        """
        try:
            # Query emotion counts
            results = db.session.query(
                EmotionRecord.emotion,
                func.count(EmotionRecord.id).label('count')
            ).filter(
                EmotionRecord.user_id == user_id
            ).group_by(
                EmotionRecord.emotion
            ).all()

            # Calculate total
            total_emotions = sum(count for _, count in results)

            if total_emotions == 0:
                return {}

            # Calculate percentages
            distribution = {}
            for emotion, count in results:
                percentage = round((count / total_emotions) * 100, 2)
                distribution[emotion] = percentage

            return distribution

        except Exception as e:
            print(f"Error in get_emotion_distribution: {str(e)}")
            return {}
