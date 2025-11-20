from functools import wraps
from flask import request, jsonify
import jwt
from config.settings import Config

def token_required(f):

    @wraps(f)
    def decorated(*args, **kwargs):
        token = None

        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            try:
                token = auth_header.split(" ")[1]
            except IndexError:
                return jsonify({'error': 'Invalid token format. Use: Bearer <token>'}), 401

        if not token:
            return jsonify({'error': 'Authentication token is missing'}), 401

        try:
            data = jwt.decode(token, Config.SECRET_KEY, algorithms=["HS256"])
            from models.user import User
            current_user = User.query.filter_by(id=data['user_id']).first()
            if not current_user:
                return jsonify({'error': 'User not found'}), 401
            request.current_user = current_user

        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token has expired'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Invalid token'}), 401
        except Exception as e:
            return jsonify({'error': f'Token validation failed: {str(e)}'}), 401
        return f(*args, **kwargs)

    return decorated
