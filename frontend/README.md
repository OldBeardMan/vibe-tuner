# **Vibe Tuner - frontend**

`Vibe Tuner` to aplikacja mobilna, która łączy analizę emocji z rekomendacjami muzycznymi. Aplikacja:

- Analizuje emocje na podstawie zdjęcia twarzy (kamera/galeria)
- możliwia ręczny wybór emocji
- yświetla historię analiz i statystyki
- ntegruje rekomendacje playlist ze Spotify
- bsługuje motywy jasny i ciemny
- Zawiera strony informacyjne (O aplikacji, Prywatność, FAQ, Regulamin)

> **Uwaga:** Backend (Flask + DeepFace + Spotipy) musi być uruchomiony oddzielnie. Frontend komunikuje się z backendem przez REST API.

---

## Spis treści

- [Funkcje](#Funkcje)
- [Wymagania](#Wymagania)
- [Instalacja](#Instalacja)
- [Konfiguracja](#Konfiguracja)
- [Uruchamianie aplikacji](#Uruchamianie-aplikacji)
- [Struktura projektu](#Struktura-projektu)
- [Licencja](#Licencja)

---

## Funkcje

- Analiza emocji z wykorzystaniem AI
- Ręczny wybór emocji
- Historia emocji z możliwością usuwania
- Rekomendacje playlist powiązane z emocją
- Ustawienia: tryb jasny/ciemny, wylogowanie
- Strony informacyjne z linkiem do GitHub
- Obsługa tokenów JWT

---

## Wymagania

- **Flutter SDK** (stable) — minimalna wersja: **3.x**
- **Android SDK** (dla budowania aplikacji Android)
- **Xcode** (dla budowania aplikacji iOS)
- **Backend API** działający i dostępny
- Dostęp do kamery/storage na urządzeniu (dla testów)

---

## Instalacja

1. Zainstaluj Fluttera, dart i skonfiguruj środowisko wraz z emulatorem za pomocą poniższych linków
- instalacja fluttera dla VSC https://docs.flutter.dev/install/with-vs-code
- instalacja fluttera manualnie (min. dla Android Studio) https://docs.flutter.dev/install/manual
- emulator w andoid studio https://docs.flutter.dev/platform-integration/android/setup#set-up-devices
- ogólna instrukcja https://docs.flutter.dev/tools/android-studio

2. **Sklonuj repozytorium:**
```bash
git clone https://github.com/OldBeardMan/vibe-tuner
cd frontend
```

3. **Zainstaluj zależności:**
```bash
flutter pub get
```

---

## Konfiguracja

### Adres backendu (API)

W pliku `lib/constants/app_paths.dart` ustaw adres backendu:
```dart
class AppPaths {
  static const baseURL = "http://10.0.2.2:5000/api"; // <-- ustaw tutaj adres backendu
}
```
domyślnie ustawione jest aby aplikacja działała przez emulator w android studio z backendem uruchomionym lokalnie

---

## Uruchamianie aplikacji

najlepiej wykorzystać środowisko programistyczne (na przykładzie Android Studio):
- po uruchomieniu emulatrora wybrać na jakim urządzeniu chcemy włączyć aplikacje
- nacisnąć zieloną strzałeczkę obok klasy main.dart

### Android
```bash
flutter devices
flutter run
```

### iOS
```bash
flutter run
```

> **Uwaga:** Dla urządzeń iOS wymagane są odpowiednie ustawienia w Xcode (provisioning profile i certyfikaty).

---

## Struktura projektu
```
lib/
├── constants/       # app_strings.dart, app_sizes.dart, app_paths.dart
├── pages/           # widoki (info_pages, user_page, analyze_page, history_page...)
├── providers/       # ThemeProvider i inne
├── services/        # ApiService (HTTP)
└── widgets/         # wspólne widgety
android/
ios/
pubspec.yaml
```

---

## Licencja

Projekt opublikowany na licencji **MIT**.

---


<p align="center">Made with ❤️ by Vibe Tuner Team</p>