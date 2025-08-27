import cv2
import numpy as np
from deepface import DeepFace
from PIL import Image
import io
import hashlib

class EmotionDetector:
    def __init__(self):
        self.emotion_mapping = {
            'happy': 'happy',
            'sad': 'sad', 
            'angry': 'angry',
            'fear': 'fear',
            'surprise': 'surprised',
            'disgust': 'disgust',
            'neutral': 'neutral'
        }
    
    def detect_emotion(self, image_file):
        try:
            # Read image from uploaded file
            image_bytes = image_file.read()
            image_file.seek(0)  # Reset file pointer
            
            # Convert to PIL Image
            pil_image = Image.open(io.BytesIO(image_bytes))
            
            # Convert PIL to OpenCV format
            opencv_image = cv2.cvtColor(np.array(pil_image), cv2.COLOR_RGB2BGR)
            
            # Create image hash for storage
            image_hash = hashlib.md5(image_bytes).hexdigest()
            
            # Detect faces first
            face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
            gray = cv2.cvtColor(opencv_image, cv2.COLOR_BGR2GRAY)
            faces = face_cascade.detectMultiScale(gray, 1.1, 4)
            
            if len(faces) == 0:
                return None
            
            # Use DeepFace for emotion detection
            result = DeepFace.analyze(
                opencv_image, 
                actions=['emotion'],
                enforce_detection=False
            )
            
            # Handle both single result and list results
            if isinstance(result, list):
                result = result[0]
            
            # Get dominant emotion
            dominant_emotion = result['dominant_emotion']
            confidence = result['emotion'][dominant_emotion] / 100.0
            
            # Map to our emotion system
            mapped_emotion = self.emotion_mapping.get(dominant_emotion, 'neutral')
            
            return {
                'emotion': mapped_emotion,
                'confidence': round(confidence, 3),
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