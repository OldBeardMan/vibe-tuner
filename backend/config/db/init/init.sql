-- Users table (matching backend User model)
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(120) NOT NULL UNIQUE,
  password_hash VARCHAR(512) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Emotion types - dictionary of available emotions
CREATE TABLE IF NOT EXISTS emotion_types (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  display_name VARCHAR(100) NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Emotion playlists - mapping of emotions to Spotify playlist IDs
CREATE TABLE IF NOT EXISTS emotion_playlists (
  id SERIAL PRIMARY KEY,
  emotion_type_id INT NOT NULL,
  spotify_playlist_id VARCHAR(100) NOT NULL,
  playlist_name VARCHAR(255) NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  CONSTRAINT fk_playlists_emotion_type
    FOREIGN KEY (emotion_type_id) REFERENCES emotion_types(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT uq_emotion_playlist UNIQUE (emotion_type_id)
);

-- Emotion records (matching backend EmotionRecord model)
CREATE TABLE IF NOT EXISTS emotions (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  emotion_type_id INT NOT NULL,
  confidence FLOAT NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  spotify_playlist_id VARCHAR(100),
  user_feedback BOOLEAN DEFAULT NULL,
  CONSTRAINT fk_emotions_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_emotions_type
    FOREIGN KEY (emotion_type_id) REFERENCES emotion_types(id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);
CREATE INDEX IF NOT EXISTS idx_emotion_types_name ON emotion_types (name);
CREATE INDEX IF NOT EXISTS idx_emotions_user_id ON emotions (user_id);
CREATE INDEX IF NOT EXISTS idx_emotions_timestamp ON emotions (timestamp);
CREATE INDEX IF NOT EXISTS idx_emotions_type_id ON emotions (emotion_type_id);
CREATE INDEX IF NOT EXISTS idx_emotion_playlists_type_id ON emotion_playlists (emotion_type_id);


--------------------------------------------
-- ADD DATA (idempotent)
--------------------------------------------

-- Insert emotion types (DeepFace emotions only)
INSERT INTO emotion_types (name, display_name, description) VALUES
  ('happy', 'Happy', 'Feeling joyful, cheerful, and content'),
  ('sad', 'Sad', 'Feeling down, melancholic, or blue'),
  ('angry', 'Angry', 'Feeling frustrated, irritated, or mad'),
  ('fear', 'Fear', 'Feeling scared, anxious, or afraid'),
  ('surprise', 'Surprise', 'Feeling amazed, astonished, or shocked'),
  ('disgust', 'Disgust', 'Feeling repulsed, disgusted, or averse'),
  ('neutral', 'Neutral', 'Feeling calm, peaceful, and balanced')
ON CONFLICT (name) DO NOTHING;

-- Insert emotion playlists (linked to emotion types)
INSERT INTO emotion_playlists (emotion_type_id, spotify_playlist_id, playlist_name, description)
SELECT
  et.id,
  playlists.spotify_id,
  playlists.name,
  playlists.description
FROM emotion_types et
CROSS JOIN LATERAL (
  VALUES
    ('happy', '5rVURM4D0xpqfvqW1pHk6Q', 'Happy Vibes', 'Uplifting songs to boost your mood'),
    ('sad', '0Xy2AujP799aB7ugPdjYkl', 'Sad Vibes', 'Melancholic tunes for reflective moments'),
    ('angry', '2jkVRCPWLXyyVUoH5TESDN', 'Angry Vibes', 'Intense music to channel your energy'),
    ('surprise', '1EbTcG3TOFCneb6oBq9CMd', 'Surprise Vibes', 'Unexpected and exciting tracks'),
    ('fear', '6oruukJQNs89eHY5gGCAXl', 'Calm Vibes', 'Music to calm your fears and anxieties'),
    ('disgust', '3waPZEYKqcy8AjnX1sZxd3', 'Disgust Vibes', 'Music to shift your mood'),
    ('neutral', '6oruukJQNs89eHY5gGCAXl', 'Calm Vibes', 'Peaceful music for balanced moments')
) AS playlists(emotion_name, spotify_id, name, description)
WHERE et.name = playlists.emotion_name
ON CONFLICT (emotion_type_id) DO NOTHING;

-- Insert sample users
INSERT INTO users (email, password_hash) VALUES
  ('alice@example.com', 'pbkdf2:sha256:260000$fakehash1$abc123'),
  ('bob@example.com', 'pbkdf2:sha256:260000$fakehash2$def456'),
  ('carol@example.com', 'pbkdf2:sha256:260000$fakehash3$ghi789')
ON CONFLICT (email) DO NOTHING;

-- Insert sample emotion records for testing
INSERT INTO emotions (user_id, emotion_type_id, confidence, timestamp, spotify_playlist_id)
SELECT
  u.id,
  et.id,
  0.95,
  now() - interval '25 minutes',
  ep.spotify_playlist_id
FROM users u
CROSS JOIN emotion_types et
CROSS JOIN emotion_playlists ep
WHERE u.email = 'alice@example.com' AND et.name = 'happy' AND ep.emotion_type_id = et.id
ON CONFLICT DO NOTHING;

INSERT INTO emotions (user_id, emotion_type_id, confidence, timestamp, spotify_playlist_id)
SELECT
  u.id,
  et.id,
  0.88,
  now() - interval '15 minutes',
  ep.spotify_playlist_id
FROM users u
CROSS JOIN emotion_types et
CROSS JOIN emotion_playlists ep
WHERE u.email = 'alice@example.com' AND et.name = 'calm' AND ep.emotion_type_id = et.id
ON CONFLICT DO NOTHING;

INSERT INTO emotions (user_id, emotion_type_id, confidence, timestamp, spotify_playlist_id)
SELECT
  u.id,
  et.id,
  0.82,
  now() - interval '30 minutes',
  ep.spotify_playlist_id
FROM users u
CROSS JOIN emotion_types et
CROSS JOIN emotion_playlists ep
WHERE u.email = 'bob@example.com' AND et.name = 'sad' AND ep.emotion_type_id = et.id
ON CONFLICT DO NOTHING;
