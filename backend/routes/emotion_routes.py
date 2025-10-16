from flask import Blueprint, request, jsonify
from middleware.auth import token_required
from services.emotion_detector import EmotionDetector
from services.spotify_service import SpotifyService
from models.emotion import EmotionRecord
from models.emotion_type import EmotionType
from models.database import db
import os

emotion_bp = Blueprint('emotion', __name__)
emotion_detector = EmotionDetector()
spotify_service = SpotifyService()

@emotion_bp.route('/emotion/analyze', methods=['POST'])
@token_required
def analyze_emotion():
    """
    Analyze emotion from uploaded image OR accept manually provided emotion

    Two modes:
    1. Image mode: multipart/form-data with 'image' field
    2. Manual mode: JSON with 'emotion' field and optional 'confidence' field

    Returns: emotion, confidence, playlist info
    """
    try:
        # Check if this is manual emotion input (JSON)
        if request.is_json:
            data = request.get_json()

            if 'emotion' not in data:
                return jsonify({'error': 'No emotion provided in request body'}), 400

            emotion_name = data.get('emotion')
            confidence = data.get('confidence', 1.0)  # Default confidence to 1.0 for manual input

            # Validate confidence
            if not isinstance(confidence, (int, float)) or not (0 <= confidence <= 1):
                return jsonify({'error': 'Confidence must be a number between 0 and 1'}), 400

            # Get emotion type from database
            emotion_type = EmotionType.get_by_name(emotion_name)
            if not emotion_type:
                return jsonify({'error': f"Invalid emotion type: {emotion_name}"}), 400

            emotion_result = {
                'emotion': emotion_name,
                'confidence': confidence
            }

        # Otherwise, expect image upload (original behavior)
        else:
            # Check if image is in request
            if 'image' not in request.files:
                return jsonify({'error': 'No image or emotion data provided'}), 400

            image_file = request.files['image']

            if image_file.filename == '':
                return jsonify({'error': 'No image selected'}), 400

            # Detect emotion using DeepFace
            emotion_result = emotion_detector.detect_emotion(image_file)

            if not emotion_result:
                return jsonify({'error': 'Could not detect face or emotion in the image'}), 400

            # Get emotion type from database
            emotion_type = EmotionType.get_by_name(emotion_result['emotion'])
            if not emotion_type:
                return jsonify({'error': f"Invalid emotion type: {emotion_result['emotion']}"}), 400

        # Get Spotify playlist for detected/provided emotion
        playlist = spotify_service.get_playlist_for_emotion(emotion_result['emotion'])

        # Save emotion record to database
        emotion_record = EmotionRecord(
            user_id=request.current_user.id,
            emotion_type_id=emotion_type.id,
            confidence=emotion_result['confidence'],
            spotify_playlist_id=playlist.get('id') if playlist else None
        )

        db.session.add(emotion_record)
        db.session.commit()

        return jsonify({
            'id': emotion_record.id,
            'emotion': emotion_result['emotion'],
            'confidence': emotion_result['confidence'],
            'playlist': playlist,
            'timestamp': emotion_record.timestamp.isoformat()
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Emotion analysis failed: {str(e)}'}), 500


@emotion_bp.route('/emotion/history', methods=['GET'])
@token_required
def get_emotion_history():
    """
    Get all emotion records for current user
    Optional query params:
    - limit: number of records (default: 50)
    - offset: pagination offset (default: 0)
    """
    try:
        limit = request.args.get('limit', 50, type=int)
        offset = request.args.get('offset', 0, type=int)

        # Validate limits
        if limit > 100:
            limit = 100

        # Query user's emotion records (newest first)
        records = EmotionRecord.query.filter_by(
            user_id=request.current_user.id
        ).order_by(
            EmotionRecord.timestamp.desc()
        ).limit(limit).offset(offset).all()

        total_count = EmotionRecord.query.filter_by(
            user_id=request.current_user.id
        ).count()

        return jsonify({
            'records': [record.to_dict() for record in records],
            'total': total_count,
            'limit': limit,
            'offset': offset
        }), 200

    except Exception as e:
        return jsonify({'error': f'Failed to fetch history: {str(e)}'}), 500


@emotion_bp.route('/emotion/<int:emotion_id>', methods=['GET'])
@token_required
def get_emotion(emotion_id):
    """
    Get a single emotion record by ID
    """
    try:
        emotion_record = EmotionRecord.query.filter_by(
            id=emotion_id,
            user_id=request.current_user.id
        ).first()

        if not emotion_record:
            return jsonify({'error': 'Emotion record not found'}), 404

        return jsonify(emotion_record.to_dict()), 200

    except Exception as e:
        return jsonify({'error': f'Failed to fetch record: {str(e)}'}), 500


@emotion_bp.route('/emotion/<int:emotion_id>', methods=['DELETE'])
@token_required
def delete_emotion(emotion_id):
    """
    Delete an emotion record
    """
    try:
        emotion_record = EmotionRecord.query.filter_by(
            id=emotion_id,
            user_id=request.current_user.id
        ).first()

        if not emotion_record:
            return jsonify({'error': 'Emotion record not found'}), 404

        db.session.delete(emotion_record)
        db.session.commit()

        return jsonify({'message': 'Emotion record deleted successfully'}), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Failed to delete record: {str(e)}'}), 500


@emotion_bp.route('/emotions/types', methods=['GET'])
def get_emotion_types():
    """
    Get all available emotion types from database
    Public endpoint - no authentication required
    """
    try:
        emotion_types = EmotionType.get_all()
        return jsonify({
            'emotion_types': [et.to_dict() for et in emotion_types],
            'total': len(emotion_types)
        }), 200

    except Exception as e:
        return jsonify({'error': f'Failed to fetch emotion types: {str(e)}'}), 500
