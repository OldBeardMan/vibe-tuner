from flask import Blueprint, request, jsonify
from middleware.auth import token_required
from services.analytics_service import AnalyticsService

analytics_bp = Blueprint('analytics', __name__)
analytics_service = AnalyticsService()


@analytics_bp.route('/analytics/by-hour', methods=['GET'])
@token_required
def get_emotions_by_hour():
    """
    Get emotion counts grouped by hour of day (0-23)
    Returns: { "0": {"happy": 3, "sad": 1}, "1": {...}, ... }
    """
    try:
        analysis = analytics_service.get_emotions_by_hour(request.current_user.id)

        return jsonify({
            'by_hour': analysis
        }), 200

    except Exception as e:
        return jsonify({'error': f'Failed to fetch hourly analysis: {str(e)}'}), 500


@analytics_bp.route('/analytics/by-day', methods=['GET'])
@token_required
def get_emotions_by_day():
    """
    Get emotion counts grouped by day of week (0=Monday, 6=Sunday)
    Returns: { "0": {"happy": 5, "sad": 2}, "1": {...}, ... }
    """
    try:
        analysis = analytics_service.get_emotions_by_day(request.current_user.id)

        return jsonify({
            'by_day': analysis
        }), 200

    except Exception as e:
        return jsonify({'error': f'Failed to fetch daily analysis: {str(e)}'}), 500


@analytics_bp.route('/analytics/distribution', methods=['GET'])
@token_required
def get_emotion_distribution():
    """
    Get percentage distribution of all emotions
    Returns: { "happy": 35.5, "sad": 20.0, "angry": 15.5, ... }
    """
    try:
        distribution = analytics_service.get_emotion_distribution(request.current_user.id)

        return jsonify({
            'distribution': distribution
        }), 200

    except Exception as e:
        return jsonify({'error': f'Failed to fetch emotion distribution: {str(e)}'}), 500
