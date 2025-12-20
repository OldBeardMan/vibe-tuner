"""
Testy jednostkowe dla serwisu EmotionDetector.

Sprawdza działanie metod walidacji emocji i przetwarzania obrazu.
"""
import pytest
import numpy as np
from unittest.mock import patch
from io import BytesIO
from PIL import Image


class TestValidateEmotion:
    """Testy dla metody _validate_emotion."""

    def test_valid_emotion_returns_same(self):
        """Sprawdza czy prawidłowa emocja jest zwracana bez zmian."""
        from services.emotion_detector import EmotionDetector
        detector = EmotionDetector()
        detector._valid_emotions = {'happy', 'sad', 'angry', 'neutral'}

        assert detector._validate_emotion('happy') == 'happy'

    def test_invalid_emotion_returns_neutral(self):
        """Sprawdza czy nieprawidłowa emocja zwraca 'neutral'."""
        from services.emotion_detector import EmotionDetector
        detector = EmotionDetector()
        detector._valid_emotions = {'happy', 'sad', 'angry', 'neutral'}

        assert detector._validate_emotion('unknown') == 'neutral'


class TestPreprocessImage:
    """Testy dla metody preprocess_image."""

    def test_large_image_is_resized(self):
        """Sprawdza czy duży obraz jest zmniejszany do 800px szerokości."""
        from services.emotion_detector import EmotionDetector
        detector = EmotionDetector()
        large_image = np.zeros((600, 1200, 3), dtype=np.uint8)

        result = detector.preprocess_image(large_image)

        assert result.shape[1] == 800

    def test_small_image_unchanged(self):
        """Sprawdza czy mały obraz nie jest modyfikowany."""
        from services.emotion_detector import EmotionDetector
        detector = EmotionDetector()
        small_image = np.zeros((400, 600, 3), dtype=np.uint8)

        result = detector.preprocess_image(small_image)

        assert result.shape[1] == 600


class TestDetectEmotion:
    """Testy dla metody detect_emotion."""

    def _create_test_image(self):
        """Helper tworzący testowy plik obrazu."""
        img = Image.new('RGB', (100, 100), color='red')
        img_bytes = BytesIO()
        img.save(img_bytes, format='JPEG')
        img_bytes.seek(0)
        return img_bytes

    @patch('services.emotion_detector.DeepFace')
    @patch('services.emotion_detector.cv2')
    def test_detect_emotion_success(self, mock_cv2, mock_deepface):
        """Sprawdza poprawne wykrywanie emocji z obrazu."""
        from services.emotion_detector import EmotionDetector

        # Mock dla cv2
        mock_cv2.CascadeClassifier.return_value.detectMultiScale.return_value = [(10, 10, 50, 50)]
        mock_cv2.cvtColor.return_value = np.zeros((100, 100, 3), dtype=np.uint8)
        mock_cv2.data.haarcascades = ''

        # Mock dla DeepFace
        mock_deepface.analyze.return_value = [{'dominant_emotion': 'happy', 'emotion': {'happy': 85.5}}]

        detector = EmotionDetector()
        detector._valid_emotions = {'happy', 'sad', 'angry', 'neutral'}

        result = detector.detect_emotion(self._create_test_image())

        assert result['emotion'] == 'happy'
        assert result['confidence'] == 0.855

    @patch('services.emotion_detector.DeepFace')
    @patch('services.emotion_detector.cv2')
    def test_no_face_returns_none(self, mock_cv2, mock_deepface):
        """Sprawdza czy brak twarzy zwraca None."""
        from services.emotion_detector import EmotionDetector

        mock_cv2.CascadeClassifier.return_value.detectMultiScale.return_value = []
        mock_cv2.cvtColor.return_value = np.zeros((100, 100, 3), dtype=np.uint8)
        mock_cv2.data.haarcascades = ''

        detector = EmotionDetector()

        result = detector.detect_emotion(self._create_test_image())

        assert result is None
