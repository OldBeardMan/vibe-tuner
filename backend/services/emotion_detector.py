import cv2
import numpy as np
from deepface import DeepFace
from PIL import Image
import io
import hashlib
from models.emotion_type import EmotionType

class EmotionDetector:
    def __init__(self):
        self._valid_emotions = None

    def _get_valid_emotions(self):
        """Get list of valid emotions from database (cached)"""
        if self._valid_emotions is None:
            try:
                self._valid_emotions = set(EmotionType.get_all_names())
            except:
                self._valid_emotions = {'happy', 'sad', 'angry', 'fear', 'surprise', 'disgust', 'neutral'}
        return self._valid_emotions

    def _validate_emotion(self, emotion):
        """Validate if emotion exists in database"""
        valid_emotions = self._get_valid_emotions()
        return emotion if emotion in valid_emotions else 'neutral'  # Default to neutral
    
    def detect_emotion(self, image_file):
        try:
            image_bytes = image_file.read()
            
            pil_image = Image.open(io.BytesIO(image_bytes))#to pil image
            
            opencv_image = cv2.cvtColor(np.array(pil_image), cv2.COLOR_RGB2BGR) #to opencv format

            image_hash = hashlib.md5(image_bytes).hexdigest() #image hash for storage
            
            face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
            gray = cv2.cvtColor(opencv_image, cv2.COLOR_BGR2GRAY)
            faces = face_cascade.detectMultiScale(gray, 1.1, 4) #detecting face first
            
            if len(faces) == 0:
                return None
            
            result = DeepFace.analyze( #deepface analyze
                opencv_image, 
                actions=['emotion'],
                enforce_detection=False
            )
            
            if isinstance(result, list): # Handle both single result and list results
                result = result[0]

            dominant_emotion = result['dominant_emotion']
            confidence = float(result['emotion'][dominant_emotion] / 100.0)

            validated_emotion = self._validate_emotion(dominant_emotion) #checking if it exist in database

            return {
                'emotion': validated_emotion,
                'confidence': float(round(confidence, 3)),
                'image_hash': image_hash,
                'raw_emotions': result['emotion']
            }
            
        except Exception as e:
            print(f"Error detecting emotion: {str(e)}")
            return None
    
    def preprocess_image(self, image):
        # Resize image if too large
        height, width = image.shape[:2]
        if width > 800:
            ratio = 800 / width
            new_width = 800
            new_height = int(height * ratio)
            image = cv2.resize(image, (new_width, new_height))
        
        return image