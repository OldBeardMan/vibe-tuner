from datetime import datetime, timedelta
from sqlalchemy import func, and_, extract
from models.emotion import EmotionRecord
from models.emotion_type import EmotionType
from models.database import db
from collections import defaultdict


class AnalyticsService:

    def get_emotions_by_hour(self, user_id):
        try:
            results = db.session.query(
                extract('hour', EmotionRecord.timestamp).label('hour'),
                EmotionType.name,
                func.count(EmotionRecord.id).label('count')
            ).join(
                EmotionType, EmotionRecord.emotion_type_id == EmotionType.id
            ).filter(
                EmotionRecord.user_id == user_id
            ).group_by(
                extract('hour', EmotionRecord.timestamp),
                EmotionType.name
            ).all()

            analysis = defaultdict(lambda: defaultdict(int))
            for hour, emotion, count in results:
                analysis[str(int(hour))][emotion] = count

            return {hour: dict(emotions) for hour, emotions in analysis.items()}

        except Exception as e:
            print(f"Error in get_emotions_by_hour: {str(e)}")
            return {}

    def get_emotions_by_day(self, user_id):
        try:
            results = db.session.query(
                extract('dow', EmotionRecord.timestamp).label('day_of_week'),
                EmotionType.name,
                func.count(EmotionRecord.id).label('count')
            ).join(
                EmotionType, EmotionRecord.emotion_type_id == EmotionType.id
            ).filter(
                EmotionRecord.user_id == user_id
            ).group_by(
                extract('dow', EmotionRecord.timestamp),
                EmotionType.name
            ).all()

            analysis = defaultdict(lambda: defaultdict(int))
            for day, emotion, count in results:
                day_normalized = str(int((day + 6) % 7))
                analysis[day_normalized][emotion] = count

            return {day: dict(emotions) for day, emotions in analysis.items()}

        except Exception as e:
            print(f"Error in get_emotions_by_day: {str(e)}")
            return {}

    def get_emotion_distribution(self, user_id):
        try:
            results = db.session.query(
                EmotionType.name,
                func.count(EmotionRecord.id).label('count')
            ).join(
                EmotionType, EmotionRecord.emotion_type_id == EmotionType.id
            ).filter(
                EmotionRecord.user_id == user_id
            ).group_by(
                EmotionType.name
            ).all()

            total_emotions = sum(count for _, count in results)

            if total_emotions == 0:
                return {}

            distribution = {}
            for emotion, count in results:
                percentage = round((count / total_emotions) * 100, 2)
                distribution[emotion] = percentage

            return distribution

        except Exception as e:
            print(f"Error in get_emotion_distribution: {str(e)}")
            return {}
