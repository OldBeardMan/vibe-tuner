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
    "id": "5rVURM4D0xpqfvqW1pHk6Q",
    "name": "Happy Vibes",
    "description": "Uplifting songs to boost your mood",
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

**Możliwe emocje:** `happy`, `sad`, `angry`, `surprise`, `calm`, `stressed`

**Uwaga:** Emocje są przechowywane w bazie danych w tabeli `emotion_types`. DeepFace wykrywa emocje (`happy`, `sad`, `angry`, `fear`, `surprise`, `disgust`, `neutral`), które są mapowane na dostępne emocje:
- `fear` → `stressed`
- `disgust` → `angry`
- `neutral` → `calm`

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
      "emotion_display_name": "Happy",
      "confidence": 0.95,
      "timestamp": "2025-01-15T10:30:00",
      "spotify_playlist_id": "5rVURM4D0xpqfvqW1pHk6Q"
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
  "emotion_display_name": "Happy",
  "confidence": 0.95,
  "timestamp": "2025-01-15T10:30:00",
  "spotify_playlist_id": "5rVURM4D0xpqfvqW1pHk6Q"
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

### Pobranie dostępnych typów emocji
```
GET /api/emotions/types
```

**Response (200):**
```json
{
  "emotion_types": [
    {
      "id": 1,
      "name": "happy",
      "display_name": "Happy",
      "description": "Feeling joyful, cheerful, and content",
      "created_at": "2025-01-15T10:00:00"
    },
    {
      "id": 2,
      "name": "sad",
      "display_name": "Sad",
      "description": "Feeling down, melancholic, or blue",
      "created_at": "2025-01-15T10:00:00"
    }
  ],
  "total": 6
}
```

**Uwaga:** Ten endpoint jest publiczny (nie wymaga autoryzacji) i zwraca wszystkie dostępne typy emocji zdefiniowane w bazie danych.

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
    "1": { "happy": 2, "calm": 2 },
    "8": { "happy": 10, "sad": 3, "angry": 1 },
    "14": { "happy": 8, "calm": 5 },
    "23": { "sad": 4, "calm": 2 }
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
    "0": { "happy": 15, "sad": 5, "calm": 8 },
    "1": { "happy": 12, "sad": 7, "calm": 10 },
    "6": { "happy": 20, "sad": 3, "calm": 5 }
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
    "calm": 15.00,
    "angry": 10.20,
    "surprise": 5.00,
    "stressed": 4.00
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

Backend używa 6 playlist Spotify przechowywanych w bazie danych (tabela `emotion_playlists`):

| Emocja | Playlist ID | Nazwa |
|--------|------------|-------|
| **happy** | `5rVURM4D0xpqfvqW1pHk6Q` | Happy Vibes |
| **sad** | `0Xy2AujP799aB7ugPdjYkl` | Sad Vibes |
| **angry** | `2jkVRCPWLXyyVUoH5TESDN` | Angry Vibes |
| **surprise** | `1EbTcG3TOFCneb6oBq9CMd` | Surprise Vibes |
| **calm** | `6oruukJQNs89eHY5gGCAXl` | Calm Vibes |
| **stressed** | `4OI3t5sg9143MkUlPK2iZY` | Stressed Vibes |

Playlisty są automatycznie ładowane z bazy danych przez `SpotifyService`.

---

## Struktura bazy danych

### Tabele

**emotion_types** - słownik dostępnych emocji
- `id` - klucz główny
- `name` - nazwa emocji (np. 'happy', 'sad')
- `display_name` - nazwa do wyświetlenia
- `description` - opis emocji

**emotion_playlists** - mapowanie emocji na playlisty Spotify
- `id` - klucz główny
- `emotion_type_id` - FK do emotion_types
- `spotify_playlist_id` - ID playlisty w Spotify
- `playlist_name` - nazwa playlisty
- `description` - opis playlisty

**emotions** - historia wykrytych emocji
- `id` - klucz główny
- `user_id` - FK do users
- `emotion_type_id` - FK do emotion_types
- `confidence` - poziom pewności detekcji
- `timestamp` - czas detekcji
- `spotify_playlist_id` - ID playlisty przypisanej do emocji

**users** - użytkownicy
- `id` - klucz główny
- `email` - email użytkownika
- `password_hash` - zahashowane hasło
- `created_at` - data rejestracji
