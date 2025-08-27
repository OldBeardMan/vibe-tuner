from datetime import datetime, timedelta
from sqlalchemy import func, and_
from models.emotion import EmotionRecord
from models.database import db
from collections import defaultdict

class AnalyticsService:
    def __init__(self):
        self.time_periods = {
            'morning': (6, 12),    # 6:00 - 11:59
            'afternoon': (12, 17), # 12:00 - 16:59
            'evening': (17, 22),   # 17:00 - 21:59
            'night': (22, 6)       # 22:00 - 5:59 (next day)
        }
    
    def get_emotion_analysis_by_time(self, time_period='week'):
        try:
            # Calculate date range
            end_date = datetime.utcnow()
            if time_period == 'day':
                start_date = end_date - timedelta(days=1)
            elif time_period == 'week':
                start_date = end_date - timedelta(weeks=1)
            elif time_period == 'month':
                start_date = end_date - timedelta(days=30)
            else:
                start_date = end_date - timedelta(weeks=1)
            
            # Get emotions in date range
            emotions = EmotionRecord.query.filter(
                and_(
                    EmotionRecord.timestamp >= start_date,
                    EmotionRecord.timestamp <= end_date
                )
            ).all()
            
            # Group by time periods
            time_analysis = {
                'morning': defaultdict(int),
                'afternoon': defaultdict(int),
                'evening': defaultdict(int),
                'night': defaultdict(int)
            }
            
            for emotion_record in emotions:
                hour = emotion_record.timestamp.hour
                time_slot = self._get_time_slot(hour)
                time_analysis[time_slot][emotion_record.emotion] += 1
            
            # Convert defaultdict to regular dict for JSON serialization
            analysis_result = {}
            dominant_emotions = {}
            
            for time_slot, emotions_count in time_analysis.items():
                # Convert to regular dict and calculate percentages
                total_emotions = sum(emotions_count.values())
                if total_emotions > 0:
                    emotion_percentages = {
                        emotion: round((count / total_emotions) * 100, 1)
                        for emotion, count in emotions_count.items()
                    }
                    analysis_result[time_slot] = emotion_percentages
                    
                    # Find dominant emotion
                    dominant_emotions[time_slot] = max(emotions_count.items(), key=lambda x: x[1])[0]
                else:
                    analysis_result[time_slot] = {}
                    dominant_emotions[time_slot] = 'neutral'
            
            return {
                'time_analysis': analysis_result,
                'dominant_emotions': dominant_emotions,
                'total_records': len(emotions),
                'date_range': {
                    'start': start_date.isoformat(),
                    'end': end_date.isoformat()
                }
            }
            
        except Exception as e:
            print(f"Error in analytics: {str(e)}")
            return {
                'time_analysis': {},
                'dominant_emotions': {},
                'total_records': 0,
                'error': str(e)
            }
    
    def _get_time_slot(self, hour):
        if 6 <= hour < 12:
            return 'morning'
        elif 12 <= hour < 17:
            return 'afternoon'
        elif 17 <= hour < 22:
            return 'evening'
        else:
            return 'night'
    
    def get_emotion_trends(self, days=7):
        try:
            end_date = datetime.utcnow()
            start_date = end_date - timedelta(days=days)
            
            # Group emotions by day
            emotions_by_day = db.session.query(
                func.date(EmotionRecord.timestamp).label('date'),
                EmotionRecord.emotion,
                func.count(EmotionRecord.id).label('count')
            ).filter(
                and_(
                    EmotionRecord.timestamp >= start_date,
                    EmotionRecord.timestamp <= end_date
                )
            ).group_by(
                func.date(EmotionRecord.timestamp),
                EmotionRecord.emotion
            ).all()
            
            # Format results
            trends = defaultdict(lambda: defaultdict(int))
            for date, emotion, count in emotions_by_day:
                trends[str(date)][emotion] = count
            
            return dict(trends)
            
        except Exception as e:
            print(f"Error getting trends: {str(e)}")
            return {}