from flask import Blueprint, request, jsonify
from services.analytics_service import AnalyticsService

analytics_bp = Blueprint('analytics', __name__)
analytics_service = AnalyticsService()

@analytics_bp.route('/emotion-analysis', methods=['GET'])
def get_emotion_analysis():
    try:
        time_period = request.args.get('time_period', 'week')
        
        if time_period not in ['day', 'week', 'month']:
            return jsonify({'error': 'Invalid time_period. Use: day, week, or month'}), 400
        
        analysis = analytics_service.get_emotion_analysis_by_time(time_period)
        
        return jsonify({
            'period': time_period,
            'analysis': analysis['time_analysis'],
            'dominant_emotions_by_time': analysis['dominant_emotions']
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500