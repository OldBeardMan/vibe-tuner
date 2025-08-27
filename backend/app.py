from flask import Flask
from flask_cors import CORS
from config.settings import Config
from models.database import db

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    
    # Initialize extensions
    db.init_app(app)
    CORS(app)
    
    # Register blueprints
    from routes.emotion_routes import emotion_bp
    from routes.analytics_routes import analytics_bp
    
    app.register_blueprint(emotion_bp, url_prefix='/api')
    app.register_blueprint(analytics_bp, url_prefix='/api')
    
    # Create tables
    with app.app_context():
        db.create_all()
    
    return app

if __name__ == '__main__':
    app = create_app()
    app.run(debug=True, host='0.0.0.0', port=5000)