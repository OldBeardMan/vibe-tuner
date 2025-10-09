from functools import wraps
from flask import request, jsonify
import jwt
from config.settings import Config

def token_required(f):
    """
    Decorator to protect routes that require authentication.
    Validates JWT token and adds current_user to request context.
    """
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None

        # Check if token is in headers
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            try:
                # Expected format: "Bearer <token>"
                token = auth_header.split(" ")[1]
            except IndexError:
                return jsonify({'error': 'Invalid token format. Use: Bearer <token>'}), 401

        if not token:
            return jsonify({'error': 'Authentication token is missing'}), 401

        try:
            # Decode JWT token
            data = jwt.decode(token, Config.SECRET_KEY, algorithms=["HS256"])

            # Import here to avoid circular imports
            from models.user import User

            # Get user from database
            current_user = User.query.filter_by(id=data['user_id']).first()

            if not current_user:
                return jsonify({'error': 'User not found'}), 401

            # Add user to request context
            request.current_user = current_user

        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token has expired'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Invalid token'}), 401
        except Exception as e:
            return jsonify({'error': f'Token validation failed: {str(e)}'}), 401

        return f(*args, **kwargs)

    return decorated
