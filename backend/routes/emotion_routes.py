from flask import Blueprint, request, jsonify
from services.emotion_detector import EmotionDetector
from services.spotify_service import SpotifyService
from models.emotion import EmotionRecord
from models.database import db

emotion_bp = Blueprint('emotion', __name__)
emotion_detector = EmotionDetector()
spotify_service = SpotifyService()

@emotion_bp.route('/analyze-emotion', methods=['POST'])
def analyze_emotion():
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'No image provided'}), 400
        
        image_file = request.files['image']
        if image_file.filename == '':
            return jsonify({'error': 'No image selected'}), 400
        
        # Detect emotion
        emotion_result = emotion_detector.detect_emotion(image_file)
        
        if not emotion_result:
            return jsonify({'error': 'Could not detect face or emotion'}), 400
        
        # Get Spotify playlist
        playlist = spotify_service.get_playlist_for_emotion(emotion_result['emotion'])
        
        # Save to database
        emotion_record = EmotionRecord(
            emotion=emotion_result['emotion'],
            confidence=emotion_result['confidence'],
            spotify_playlist_id=playlist.get('id') if playlist else None
        )
        db.session.add(emotion_record)
        db.session.commit()
        
        return jsonify({
            'emotion': emotion_result['emotion'],
            'confidence': emotion_result['confidence'],
            'playlist': playlist,
            'timestamp': emotion_record.timestamp.isoformat()
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@emotion_bp.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy'})