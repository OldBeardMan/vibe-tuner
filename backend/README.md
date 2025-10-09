# Vibe Tuner Backend

Backend API dla aplikacji dobierającej muzykę na podstawie emocji wykrywanych z twarzy.

## Instalacja

1. Skopiuj plik konfiguracyjny:
```bash
cp .env.example .env
```

2. Wypełnij dane Spotify API w pliku `.env`:
```
SPOTIFY_CLIENT_ID=your_client_id
SPOTIFY_CLIENT_SECRET=your_client_secret
```

3. Zainstaluj zależności:
```bash
pip install -r requirements.txt
```

4. Uruchom aplikację:
```bash
python app.py
```

## Konfiguracja bazy danych

Baza danych posiada dymyślnie dane. Aby uruchomić bazę danych należy wykonać
```bash
docker compose up -d
```

dane i tabelki zapiszą się podczas pierwszego uruchomienia bazy. Jeżeli jest potrzeba uruchomienia bazy od nowa należy wykonać
```bash
docker compose down -v
docker compose up -d
```

Po włączeniu bazy danych dostępna jest aplikacja dbAdmin do zarządzania bazą danych pod adresem localhost:8080. 
Dane do logowania oraz więcej szczegółowych danych w pliku docker-compose.yml

## API Endpoints

### POST /api/analyze-emotion
Analizuje emocje ze zdjęcia i zwraca playlistę.
- **Input**: multipart/form-data z polem 'image'
- **Output**: JSON z emocją, pewnością i playlistą Spotify

### GET /api/emotion-analysis
Zwraca analizę emocji wg pory dnia.
- **Params**: `time_period` (day/week/month)
- **Output**: JSON ze statystykami emocji

### GET /api/health
Health check endpoint.

## Struktura
- `models/` - Modele bazy danych
- `services/` - Logika biznesowa
- `routes/` - Endpointy API
- `config/` - Konfiguracja aplikacji