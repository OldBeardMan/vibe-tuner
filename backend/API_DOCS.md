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
  "email": "matt@krupa.net",
  "password": "password123"
}
```

**Response (201):**
```json
{
  "message": "User registered successfully",
  "user": {
    "id": 1,
    "email": "matt@krupa.net",
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
  "email": "matt@krupa.net",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "email": "matt@krupa.net",
    "created_at": "2025-01-15T10:00:00"
  }
}
```

**Token wygasa po 7 dniach.**

### Usunięcie konta
```
DELETE /api/auth/account
```

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Body:**
```json
{
  "password": "password123"
}
```

**Pola:**
- `password` (wymagane): hasło do potwierdzenia usunięcia konta

**Response (200):**
```json
{
  "message": "Account matt@krupa.net has been permanently deleted"
}
```

**Uwaga:** Usunięcie konta jest permanentne i usuwa wszystkie powiązane dane (rekordy emocji) dzięki cascade delete.

**Możliwe błędy:**
- `400` - Brak hasła
- `401` - Nieprawidłowe hasło lub brak tokenu

---

## Detekcja emocji

### Analiza emocji ze zdjęcia lub ręczne wprowadzenie emocji
```
POST /api/emotion/analyze
```

Ten endpoint obsługuje dwa tryby:

#### Tryb 1: Analiza ze zdjęcia (detekcja emocji)

**Headers:**
```
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**Body:**
- `image`: plik zdjęcia (multipart/form-data)

**Przykład (curl):**
```bash
curl -X POST http://localhost:5000/api/emotion/analyze \
  -H "Authorization: Bearer <token>" \
  -F "image=@selfie.jpg"
```

#### Tryb 2: Ręczne wprowadzenie emocji (bez zdjęcia)

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Body:**
```json
{
  "emotion": "happy",
  "confidence": 0.85
}
```

**Pola:**
- `emotion` (wymagane): nazwa emocji (`happy`, `sad`, `angry`, `fear`, `surprise`, `disgust`, `neutral`)
- `confidence` (opcjonalne): poziom pewności (0.0-1.0), domyślnie 1.0

**Przykład (curl):**
```bash
curl -X POST http://localhost:5000/api/emotion/analyze \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"emotion": "happy", "confidence": 0.85}'
```

#### Response (200) - dla obu trybów:
```json
{
  "id": 123,
  "emotion": "happy",
  "confidence": 0.95,
  "detection_source": "image",
  "tracks": [
    {
      "name": "Iceland",
      "artist": "Matt Krupa",
      "spotify_id": "60nZcImufyMA1MKQY3dcCH",
      "preview_url": "https://...",
      "external_url": "https://open.spotify.com/track/...",
      "album_image": "https://..."
    },
    {
      "name": "Song Title 2",
      "artist": "Artist Name",
      "spotify_id": "track_id_2",
      "preview_url": "https://...",
      "external_url": "https://open.spotify.com/track/...",
      "album_image": "https://..."
    }
    // ... 3 more tracks (5 total)
  ],
  "timestamp": "2025-01-15T10:30:00"
}
```

**Pola odpowiedzi:**
- `detection_source`: źródło wykrycia emocji - `"image"` (wykryte ze zdjęcia) lub `"manual"` (wybrane ręcznie przez użytkownika)

**Uwaga:** Endpoint zwraca **5 losowych piosenek** z playlisty przypisanej do danej emocji. Za każdym razem, gdy użytkownik wykryje tę samą emocję, dostanie inny zestaw piosenek.

**Możliwe emocje:** `happy`, `sad`, `angry`, `fear`, `surprise`, `disgust`, `neutral`

**Uwaga:** Emocje są przechowywane w bazie danych w tabeli `emotion_types`. System używa bezpośrednio emocji wykrywanych przez DeepFace bez mapowania.

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
      "user_feedback": true,
      "detection_source": "image",
      "tracks": [
        {
          "name": "Iceland",
          "artist": "Matt Krupa",
          "spotify_id": "60nZcImufyMA1MKQY3dcCH",
          "preview_url": "https://...",
          "external_url": "https://open.spotify.com/track/...",
          "album_image": "https://..."
        }
        // ... 4 more tracks
      ]
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
  "user_feedback": null,
  "detection_source": "manual",
  "tracks": [
    {
      "name": "Iceland",
      "artist": "Matt Krupa",
      "spotify_id": "60nZcImufyMA1MKQY3dcCH",
      "preview_url": "https://...",
      "external_url": "https://open.spotify.com/track/...",
      "album_image": "https://..."
    }
    // ... 4 more tracks
  ]
}
```

### Ustawienie feedbacku użytkownika dla wykrytej emocji
```
POST /api/emotion/:id/feedback
```

Ten endpoint pozwala użytkownikowi potwierdzić lub odrzucić wykrytą emocję.

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Body:**
```json
{
  "agrees": true
}
```

**Pola:**
- `agrees` (wymagane): boolean - `true` jeśli użytkownik zgadza się z wykrytą emocją, `false` jeśli nie zgadza się

**Response (200):**
```json
{
  "message": "Feedback saved successfully",
  "emotion_record": {
    "id": 123,
    "emotion": "happy",
    "emotion_display_name": "Happy",
    "confidence": 0.95,
    "timestamp": "2025-01-15T10:30:00",
    "user_feedback": true,
    "detection_source": "image",
    "tracks": [
      {
        "name": "Iceland",
        "artist": "Matt Krupa",
        "spotify_id": "60nZcImufyMA1MKQY3dcCH",
        "preview_url": "https://...",
        "external_url": "https://open.spotify.com/track/...",
        "album_image": "https://..."
      }
      // ... 4 more tracks
    ]
  }
}
```

**Uwaga:** Po ustawieniu feedbacku, pole `user_feedback` w rekordzie emocji zostaje zaktualizowane. Możliwe wartości:
- `null` - brak feedbacku od użytkownika
- `true` - użytkownik zgadza się z wykrytą emocją
- `false` - użytkownik nie zgadza się z wykrytą emocją

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

## Spotify Playlists i losowanie piosenek

Backend używa 6 playlist Spotify (playlista calm vibes jest jednocześnie dla emocji neutral i fear) przechowywanych w bazie danych (tabela `emotion_playlists`):

| Emocja | Playlist ID | Nazwa |
|--------|------------|-------|
| **happy** | `5rVURM4D0xpqfvqW1pHk6Q` | Happy Vibes (feat. Iceland) |
| **sad** | `0Xy2AujP799aB7ugPdjYkl` | Sad Vibes (feat. Winter) |
| **angry** | `2jkVRCPWLXyyVUoH5TESDN` | Angry Vibes (feat. Blooming Cactus) |
| **fear** | `6oruukJQNs89eHY5gGCAXl` | Calm Vibes |
| **surprise** | `1EbTcG3TOFCneb6oBq9CMd` | Surprise Vibes |
| **disgust** | `3waPZEYKqcy8AjnX1sZxd3` | Disgust Vibes |
| **neutral** | `6oruukJQNs89eHY5gGCAXl` | Calm Vibes (feat. In The Autumn Forest) |

### Jak działa losowanie piosenek?

Zamiast zwracać link do całej playlisty, system:
1. Pobiera wszystkie piosenki z playlisty przypisanej do wykrytej emocji
2. Losuje **5 piosenek** z tej playlisty
3. Zapisuje wylosowane piosenki do bazy danych w tabeli `emotion_tracks`
4. Zwraca te 5 piosenek w odpowiedzi API

**Dzięki temu:** Za każdym razem gdy użytkownik wykryje tę samą emocję, dostanie inny, świeży zestaw piosenek!

**Fun fact:** Niektóre playlisty zawierają ambient/acoustic utwory [Matt Krupa](https://mattkrupa.net)

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
- `user_feedback` - feedback użytkownika (null/true/false)
- `detection_source` - źródło wykrycia ('image' / 'manual')

**emotion_tracks** - piosenki przypisane do rekordów emocji
- `id` - klucz główny
- `emotion_record_id` - FK do emotions (CASCADE DELETE)
- `track_name` - nazwa piosenki
- `artist` - artysta
- `spotify_track_id` - ID utworu w Spotify
- `preview_url` - URL do 30-sekundowego preview
- `external_url` - link do utworu w Spotify
- `album_image` - URL do okładki albumu

**users** - użytkownicy
- `id` - klucz główny
- `email` - email użytkownika
- `password_hash` - zahashowane hasło
- `created_at` - data rejestracji
