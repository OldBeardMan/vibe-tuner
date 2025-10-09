# Vibe Tuner - Backend API Documentation

## Przegląd

Backend dla aplikacji Vibe Tuner - systemu analizy emocji ze zdjęć i rekomendacji muzyki Spotify.

**Base URL:** `http://localhost:5000/api`

## Autentykacja

### Rejestracja użytkownika
```
POST /api/auth/register
```

**Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (201):**
```json
{
  "message": "User registered successfully",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "created_at": "2025-01-15T10:00:00"
  }
}
```

### Logowanie
```
POST /api/auth/login
```

**Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "created_at": "2025-01-15T10:00:00"
  }
}
```

**Token wygasa po 7 dniach.**

---

## Detekcja emocji

### Analiza emocji ze zdjęcia
```
POST /api/emotion/analyze
```

**Headers:**
```
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**Body:**
- `image`: plik zdjęcia (multipart/form-data)

**Response (200):**
```json
{
  "id": 123,
  "emotion": "happy",
  "confidence": 0.95,
  "playlist": {
    "id": "37i9dQZF1DXdPec7aLTmlC",
    "name": "Happy Hits",
    "description": "Feel-good songs...",
    "emotion": "happy",
    "tracks": [
      {
        "name": "Happy",
        "artist": "Pharrell Williams",
        "spotify_id": "60nZcImufyMA1MKQY3dcCH",
        "preview_url": "https://...",
        "external_url": "https://open.spotify.com/track/...",
        "album_image": "https://..."
      }
    ],
    "total_tracks": 20,
    "external_url": "https://open.spotify.com/playlist/...",
    "image": "https://..."
  },
  "timestamp": "2025-01-15T10:30:00"
}
```

**Możliwe emocje:** `happy`, `sad`, `angry`, `surprise`, `neutral`, `fear`, `disgust`

---

## Historia emocji

### Pobranie historii emocji
```
GET /api/emotion/history?limit=50&offset=0
```

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
- `limit` (optional): liczba rekordów (default: 50, max: 100)
- `offset` (optional): offset dla paginacji (default: 0)

**Response (200):**
```json
{
  "records": [
    {
      "id": 123,
      "emotion": "happy",
      "confidence": 0.95,
      "timestamp": "2025-01-15T10:30:00",
      "spotify_playlist_id": "37i9dQZF1DXdPec7aLTmlC"
    }
  ],
  "total": 150,
  "limit": 50,
  "offset": 0
}
```

### Pobranie pojedynczego rekordu
```
GET /api/emotion/:id
```

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "id": 123,
  "emotion": "happy",
  "confidence": 0.95,
  "timestamp": "2025-01-15T10:30:00",
  "spotify_playlist_id": "37i9dQZF1DXdPec7aLTmlC"
}
```

### Usunięcie rekordu
```
DELETE /api/emotion/:id
```

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "message": "Emotion record deleted successfully"
}
```

---

## Analityka

### Analiza emocji według godzin
```
GET /api/analytics/by-hour
```

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "by_hour": {
    "0": { "happy": 3, "sad": 1 },
    "1": { "happy": 2, "neutral": 2 },
    "8": { "happy": 10, "sad": 3, "angry": 1 },
    "14": { "happy": 8, "neutral": 5 },
    "23": { "sad": 4, "neutral": 2 }
  }
}
```

### Analiza emocji według dni tygodnia
```
GET /api/analytics/by-day
```

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "by_day": {
    "0": { "happy": 15, "sad": 5, "neutral": 8 },
    "1": { "happy": 12, "sad": 7, "neutral": 10 },
    "6": { "happy": 20, "sad": 3, "neutral": 5 }
  }
}
```

**Dni tygodnia:** 0 = Poniedziałek, 6 = Niedziela

### Rozkład procentowy emocji
```
GET /api/analytics/distribution
```

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "distribution": {
    "happy": 45.50,
    "sad": 20.30,
    "neutral": 15.00,
    "angry": 10.20,
    "surprise": 5.00,
    "fear": 3.00,
    "disgust": 1.00
  }
}
```

---

## Kody błędów

- `400` - Bad Request (brakujące dane, nieprawidłowy format)
- `401` - Unauthorized (brak tokenu, nieprawidłowy token, token wygasł)
- `404` - Not Found (rekord nie istnieje)
- `409` - Conflict (użytkownik już istnieje)
- `500` - Internal Server Error

**Przykładowa odpowiedź błędu:**
```json
{
  "error": "Authentication token is missing"
}
```

---

## Konfiguracja

### Wymagane zmienne środowiskowe (.env)

```bash
SECRET_KEY=your-secret-key-here
DATABASE_URL=postgresql://user:password@localhost:5432/vibe_tuner
SPOTIFY_CLIENT_ID=your-spotify-client-id
SPOTIFY_CLIENT_SECRET=your-spotify-client-secret
```

### Uruchomienie backendu

```bash
cd backend
pip install -r requirements.txt
python app.py
```

Backend będzie dostępny na `http://localhost:5000`

---

## Spotify Playlists

Backend używa 7 przygotowanych playlist w Spotify dla każdej emocji:

- **happy**: Happy Hits
- **sad**: Sad Indie
- **angry**: Rock Classics
- **surprise**: Electronic Hits
- **neutral**: Peaceful Piano
- **fear**: Dark & Stormy
- **disgust**: RapCaviar

**TODO:** Zaktualizuj ID playlist w `backend/services/spotify_service.py`
