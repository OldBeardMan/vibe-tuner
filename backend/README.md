# Vibe Tuner Backend

Backend API dla aplikacji Vibe Tuner - system analizy emocji ze zdjęć i rekomendacji muzyki Spotify.

## Wymagania

- Python 3.8+
- PostgreSQL (lub SQLite dla developmentu)
- Spotify Developer Account (Client ID i Secret)

## Instalacja

1. **Sklonuj repozytorium i przejdź do katalogu backend:**
```bash
cd backend
```

2. **Utwórz wirtualne środowisko (opcjonalne, ale zalecane):**
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# lub
venv\Scripts\activate     # Windows
```

3. **Zainstaluj zależności:**
```bash
pip install -r requirements.txt
```

**Uwaga:** Jeśli napotkasz błąd `module 'jwt' has no attribute 'encode'`, usuń starą bibliotekę `jwt` i zainstaluj `PyJWT`:
```bash
pip uninstall jwt -y
pip install PyJWT
```

4. **Skopiuj plik konfiguracyjny:**
```bash
cp .env.example .env
```

5. **Wypełnij zmienne środowiskowe w pliku `.env`:**
```env
SECRET_KEY=twoj-bezpieczny-klucz-tutaj
DATABASE_URL=sqlite:///vibe_tuner.db  # lub PostgreSQL
SPOTIFY_CLIENT_ID=twoj-spotify-client-id
SPOTIFY_CLIENT_SECRET=twoj-spotify-client-secret
```

6. **Uruchom aplikację:**
```bash
python app.py
```

## Konfiguracja bazy danych

Baza danych posiada domyślnie dane. Aby uruchomić bazę danych należy wykonać:
```bash
docker compose up -d
```

Tabele i dane inicjalizacyjne (typy emocji, playlisty) zostaną utworzone podczas pierwszego uruchomienia aplikacji.

### Reset bazy danych

Jeżeli jest potrzeba uruchomienia bazy od nowa (np. po zmianach w schemacie):
```bash
docker compose down -v
docker compose up -d
python reset_db.py  # Inicjalizuje schemat i dane podstawowe
```

Po włączeniu bazy danych dostępna jest aplikacja pgAdmin do zarządzania bazą danych pod adresem `localhost:8080`.
Dane do logowania oraz więcej szczegółowych danych w pliku `docker-compose.yml`.

Backend będzie dostępny pod adresem: `http://localhost:5000`

## Dokumentacja API

Pełna dokumentacja API znajduje się w pliku [`API_DOCS.md`](./API_DOCS.md)

### Główne endpointy:

#### Autentykacja
- `POST /api/auth/register` - Rejestracja nowego użytkownika
- `POST /api/auth/login` - Logowanie (zwraca JWT token)

#### Detekcja emocji
- `POST /api/emotion/analyze` - Analiza emocji ze zdjęcia lub ręczne wprowadzenie (wymaga tokenu)
  - Zwraca **5 losowych piosenek** z playlisty przypisanej do emocji

#### Historia
- `GET /api/emotion/history` - Historia zapisanych emocji
- `GET /api/emotion/:id` - Pojedynczy rekord

#### Analityka
- `GET /api/analytics/by-hour` - Statystyki według godzin
- `GET /api/analytics/by-day` - Statystyki według dni tygodnia
- `GET /api/analytics/distribution` - Rozkład procentowy emocji

## Struktura projektu

```
backend/
├── models/                 # Modele bazy danych
│   ├── user.py            # Model użytkownika
│   ├── emotion.py         # Model rekordu emocji
│   ├── emotion_track.py   # Model piosenki przypisanej do emocji
│   ├── emotion_type.py    # Model typu emocji
│   ├── playlist.py        # Model playlisty Spotify
│   └── database.py        # Konfiguracja SQLAlchemy
├── routes/                # Endpointy API
│   ├── auth_routes.py     # Autentykacja
│   ├── emotion_routes.py  # Detekcja i historia emocji
│   └── analytics_routes.py # Statystyki
├── services/              # Logika biznesowa
│   ├── emotion_detector.py # DeepFace integration
│   ├── spotify_service.py  # Spotify API (losowanie piosenek)
│   └── analytics_service.py # Analityka danych
├── middleware/            # Middleware (JWT auth)
│   └── auth.py
├── config/                # Konfiguracja
│   └── settings.py
├── app.py                 # Główny plik aplikacji
├── requirements.txt       # Zależności Python
├── .env.example          # Przykładowa konfiguracja
├── docker-compose.yml    # Konfiguracja Docker dla PostgreSQL
└── API_DOCS.md           # Pełna dokumentacja API
```

## Technologie

- **Flask** - Web framework
- **SQLAlchemy** - ORM
- **DeepFace** - Detekcja emocji z twarzy
- **Spotipy** - Spotify API client
- **PyJWT** - JSON Web Tokens dla autentykacji
- **PostgreSQL/SQLite** - Baza danych

## Konfiguracja Spotify

1. Utwórz aplikację na [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Skopiuj **Client ID** i **Client Secret**
3. Dodaj je do pliku `.env`
4. Playlisty dla poszczególnych emocji są przechowywane w bazie danych w tabeli `emotion_playlists`

### Jak działa losowanie piosenek?

System **nie zwraca linków do całych playlist** - zamiast tego:
1. Pobiera wszystkie piosenki z playlisty przypisanej do wykrytej emocji
2. Losuje **5 piosenek** z tej playlisty
3. Zapisuje wylosowane piosenki do bazy danych w tabeli `emotion_tracks`
4. Zwraca te 5 piosenek w odpowiedzi API

**Dzięki temu:** Za każdym razem gdy użytkownik wykryje tę samą emocję, dostanie inny, świeży zestaw piosenek!

## Troubleshooting

### Problem z JWT
**Błąd:** `module 'jwt' has no attribute 'encode'`
```bash
pip uninstall jwt -y
pip install PyJWT
```

### Problem z PostgreSQL i numpy
**Błąd:** `can't adapt type 'numpy.float32'`
- Ten problem został rozwiązany w kodzie poprzez konwersję wartości numpy na Python float
- Upewnij się, że masz najnowszą wersję kodu z `services/emotion_detector.py`

### Problem z DeepFace
Jeśli DeepFace nie może wykryć twarzy, upewnij się że:
- Zdjęcie zawiera wyraźną twarz
- Oświetlenie jest odpowiednie
- Twarz jest skierowana w stronę kamery

## Licencja

MIT
