from flask import Blueprint, request, jsonify
from models.user import User
from models.database import db
from datetime import datetime, timedelta
import jwt
from config.settings import Config
import re

auth_bp = Blueprint('auth', __name__)

def validate_email(email):
    """Validate email format"""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

def validate_password(password):
    """Validate password strength (min 6 characters)"""
    return len(password) >= 6

@auth_bp.route('/auth/register', methods=['POST'])
def register():
    """
    Register a new user
    Expected JSON: { "email": "user@example.com", "password": "password123" }
    """
    try:
        data = request.get_json()

        if not data:
            return jsonify({'error': 'No data provided'}), 400

        email = data.get('email')
        password = data.get('password')

        # Validation
        if not email or not password:
            return jsonify({'error': 'Email and password are required'}), 400

        if not validate_email(email):
            return jsonify({'error': 'Invalid email format'}), 400

        if not validate_password(password):
            return jsonify({'error': 'Password must be at least 6 characters long'}), 400

        # Check if user already exists
        existing_user = User.query.filter_by(email=email.lower()).first()
        if existing_user:
            return jsonify({'error': 'User with this email already exists'}), 409

        # Create new user
        new_user = User(email=email.lower())
        new_user.set_password(password)

        db.session.add(new_user)
        db.session.commit()

        return jsonify({
            'message': 'User registered successfully',
            'user': new_user.to_dict()
        }), 201

    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Registration failed: {str(e)}'}), 500

@auth_bp.route('/auth/login', methods=['POST'])
def login():
    """
    Login user and return JWT token
    Expected JSON: { "email": "user@example.com", "password": "password123" }
    Returns: { "token": "jwt_token", "user": {...} }
    """
    try:
        data = request.get_json()

        if not data:
            return jsonify({'error': 'No data provided'}), 400

        email = data.get('email')
        password = data.get('password')

        if not email or not password:
            return jsonify({'error': 'Email and password are required'}), 400

        # Find user
        user = User.query.filter_by(email=email.lower()).first()

        if not user or not user.check_password(password):
            return jsonify({'error': 'Invalid email or password'}), 401

        # Generate JWT token (expires in 7 days)
        token = jwt.encode({
            'user_id': user.id,
            'exp': datetime.utcnow() + timedelta(days=7)
        }, Config.SECRET_KEY, algorithm='HS256')

        return jsonify({
            'token': token,
            'user': user.to_dict()
        }), 200

    except Exception as e:
        return jsonify({'error': f'Login failed: {str(e)}'}), 500
