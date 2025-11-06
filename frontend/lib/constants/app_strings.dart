class AppStrings {
  static const appTitle = 'Vibe Tuner';

  static const emotionHappy = 'szczęśliwy';
  static const emotionSad = 'smutny';
  static const emotionAngry = 'zły';
  static const emotionSurprised = 'zaskoczony';
  static const emotionFear = 'przestraszony';
  static const emotionDisgust = 'wstręt';
  static const emotionNeutral= 'neutralny';

  static const analytics = 'Analityka';
  static const homePage = 'Strona główna';
  static const history = 'Historia';
  static const profile = 'Profil';
  static const recommendedSongs = 'Twoje utwory';

  static const unknown = 'unknown';

  // Home page
  static const homePagePhotoButton = 'Zrób zdjęcie';
  static const homePageOr = 'lub';
  static const homePageManuallySelectingEmotionsButton = 'Wybierz emocję ręcznie';

  // User page
  static const userPageAboutApplication = 'O aplikacji';
  static const userPageStatue = 'Regulamin';
  static const userPageSpotifyIntegration = 'Integracja ze Spotify';
  static const userPageFaq = 'FAQ';
  static const userPagePrivacy = 'Prywatność';
  static const userPageDarkTheme = 'Tryb ciemny';
  static const userPageConsents = 'Zgody';
  static const userPageLinkError = 'Nie udało się otworzyć linku';
  static const userPageAboutHeader = 'Vibe Tuner — aplikacja do rekomendacji muzyki na podstawie emocji';
  static const userPageAboutDescription = 'Celem aplikacji jest dostarczanie rekomendacji muzycznych dopasowanych do aktualnego nastroju użytkownika. Aplikacja analizuje zdjęcie twarzy użytkownika (moduł analizy wykorzystuje DeepFace/OpenCV po stronie backendu), wykrywa emocję, a następnie proponuje playlisty zintegrowane z serwisem Spotify.';
  static const userPageMainFeaturesTitle = 'Główne funkcjonalności:';
  static const userPageFeature1 = 'Analiza emocji ze zdjęcia (backend z DeepFace).';
  static const userPageFeature2 = 'Ręczny wybór emocji jeśli użytkownik nie chce przesyłać zdjęcia.';
  static const userPageFeature3 = 'Historia wykrytych emocji i możliwość jej przeglądania.';
  static const userPageFeature4 = 'Rekomendacje playlist powiązane z wykrytą emocją (integracja Spotify).';
  static const userPageFeature5 = 'Prosty system autoryzacji (JWT) oraz możliwość wylogowania i zarządzania kontem.';
  static const userPageTechnologiesTitle = 'Technologie użyte w projekcie:';
  static const userPageTech1 = 'Frontend: Flutter (Android & iOS).';
  static const userPageTech2 = 'Backend: Flask + SQLAlchemy (DeepFace, Spotipy, PyJWT).';
  static const userPageTech3 = 'Baza: PostgreSQL (lub SQLite dla developmentu).';
  static const userPageAuthorsTitle = 'Autorzy / podział pracy:';
  static const userPageAuthorsDescription = 'Projekt został zrealizowany przez zespół: Mateusz Krupa (backend) oraz Mateusz Kozieł (część wizualna).';
  static const userPageGithubButton = 'Otwórz repozytorium na GitHub';
  static const spotifyIntegrationHeader = 'Jak działa integracja ze Spotify';
  static const spotifyIntegrationBody = 'Aplikacja integruje rekomendacje muzyczne z serwisem Spotify poprzez dedykowany serwis backendowy. Playlisty powiązane z konkretnymi emocjami są przechowywane w bazie danych. Backend wykorzystuje bibliotekę Spotipy do komunikacji z API Spotify i pobierania informacji o playlistach/utworach.';
  static const spotifyRequirementsTitle = 'Wymagania i konfiguracja:';
  static const spotifyReq1 = 'Konto deweloperskie Spotify (Client ID i Client Secret).';
  static const spotifyReq2 = 'Uzupełnienie danych w pliku .env po stronie backendu: SPOTIFY_CLIENT_ID i SPOTIFY_CLIENT_SECRET.';
  static const spotifyReq3 = 'Playlisty są powiązane z emocjami i mogą być edytowane przez backend (dbAdmin).';
  static const spotifyMobileTitle = 'Z punktu widzenia aplikacji mobilnej:';
  static const spotifyMobile1 = 'Użytkownik otrzymuje listę playlist dopasowanych do wykrytej emocji.';
  static const spotifyMobile2 = 'Kliknięcie playlisty otwiera link Spotify (zewnętrznie).';
  static const spotifyMobile3 = 'Opcjonalnie w przyszłości można dodać integrację SDK do bezpośredniego odtwarzania.';
  static const privacyHeader = 'Zasady przetwarzania danych';
  static const privacyIntro = 'Dane użytkownika są traktowane z najwyższą ostrożnością. Poniżej najważniejsze zasady prywatności:';
  static const privacyItem1 = 'Zdjęcia przesyłane do analizy są usuwane po przetworzeniu i zwróceniu wyniku (nie są przechowywane długoterminowo).';
  static const privacyItem2 = 'Hasła przechowywane są w postaci zaszyfrowanej (hash).';
  static const privacyItem3 = 'Dostęp do funkcji autoryzacji opiera się na tokenach JWT — tokeny przechowywane są bezpiecznie po stronie klienta.';
  static const privacySecurityTitle = 'Bezpieczeństwo';
  static const privacySecurityDesc = 'Backend używa bezpiecznych praktyk: uwierzytelnianie JWT, bezpieczne przechowywanie credentiali w .env, a zdjęcia nie są zachowywane po analizie.';
  static const privacyContactTitle = 'Kontakt';
  static const privacyContactDesc = 'W razie pytań dotyczących prywatności prosimy o kontakt z administratorem projektu (dane w repozytorium GitHub. Link w zakładce "O aplikacji").';
  static const consentsHeader = 'Zgody wymagane przez aplikację';
  static const consentsIntro = 'Przed korzystaniem z funkcji analizy zdjęć użytkownik musi wyrazić zgodę na przetwarzanie obrazu. Zgody mają na celu zapewnienie zgodności z zasadami prywatności i bezpieczeństwa.';
  static const consentCameraTitle = 'Zgoda na uzycie aparatu';
  static const consentCameraDesc = 'Użytkownik wyraża zgodę na użycie aparatu urządzenia w celu zrobienia zdjęcia do analizy.';
  static const faqQ1 = 'Jak działa analiza emocji?';
  static const faqA1 = 'Zdjęcie twarzy jest wysyłane do backendu, gdzie model (DeepFace/OpenCV) identyfikuje emocję i zwraca wynik.';
  static const faqQ2 = 'Czy moje zdjęcia są przechowywane?';
  static const faqA2 = 'Zdjęcia są usuwane po dokonaniu analizy. Tylko (opcjonalnie) wynik analizy może zostać zapisany w historii.';
  static const faqQ3 = 'Co zrobić, gdy model nie wykrywa twarzy?';
  static const faqA3 = 'Upewnij się że zdjęcie ma dobrą jakość, twarz jest dobrze oświetlona i skierowana w stronę kamery. Możesz też wybrać emocję ręcznie.';
  static const faqQ4 = 'Jak działa integracja ze Spotify?';
  static const faqA4 = 'Backend używa API Spotify (Spotipy) do pobierania playlist powiązanych z emocjami; aplikacja otwiera playlisty w Spotify.';
  static const faqQ5 = 'Co jeśli wystąpi błąd z JWT?';
  static const faqA5 = 'Sprawdź czy backend używa PyJWT (a nie starej biblioteki jwt). W dokumentacji backendu są instrukcje naprawy tego problemu.';
  static const termsHeading = 'Regulamin korzystania z aplikacji Vibe Tuner';
  static const termsGeneral = '1. Postanowienia ogólne\nAplikacja Vibe Tuner służy do analizy emocji na podstawie zdjęć oraz proponowania rekomendacji muzycznych. Korzystając z aplikacji, użytkownik akceptuje zasady prywatności i warunki użytkowania.';
  static const termsResponsibility = '2. Odpowiedzialność\nDeweloperzy nie gwarantują stuprocentowej trafności analizy emocji. Aplikacja dostarcza sugestii muzycznych w oparciu o model i dane z Spotify. Użytkownik korzysta z aplikacji na własne ryzyko.';
  static const termsLicenses = '3. Licencje i zewnętrzne serwisy\nBackend projektu korzysta z bibliotek open-source (np. DeepFace, Spotipy). Repozytorium backendu jest objęte licencją MIT (szczegóły w pliku LICENSE w repozytorium).';
  static const termsContactTitle = '4. Kontakt';
  static const termsContactText = 'Wszelkie pytania techniczne kieruj do opisu projektu w repozytorium GitHub.';

  // Emotion Dialog
  static const dialogAttention = 'Uwaga';
  static const dialogTitle = 'Twoja emocja';
  static const dialogCancel = 'Anuluj';
  static const dialogNext = 'Dalej';
  static const dialogLoadingMessages = [
    'Już chwila...',
    'Jeszcze moment...',
    'Prawie gotowe...',
    'Zaraz pokażę propozycje...'
  ];

  // Recomended Songs
  static const recommendedSongsPageNoSongsFound = 'Nie znaleziono utworów';
  static const recommendedSongsBackButtonLabel = 'Powrót';
  static const recommendedSongsNoData = 'Brak danych rekomendacji';

  // Exceptions
  static const noTokenReturn = 'No token returned from server';
  static const serverConnectionError = 'Brak połączenia z serwerem. Sprawdź połączenie sieciowe.';
  static const serverNotRespondingError = 'Serwer nie odpowiada. Spróbuj ponownie później.';

  // Login Register page
  static const invalidEmail = 'Niepoprawny email';
  static const invalidPasswordHint = 'Hasło musi mieć co najmniej 6 znaków';
  static const passwordNoMatch = 'Hasła nie są zgodne';
  static const enterEmail = 'Wprowadź email';
  static const enterPassword = 'Wprowadź hasło';
  static const logIn = 'Zaloguj się';
  static const signIn = 'Zarejestruj się';
  static const email = 'Email';
  static const password = 'Hasło';
  static const confirmPassword = 'Powtórz hasło';
  static const noAccountQuestion = 'Nie masz konta? ';
  static const existAccountQuestion = 'Masz już konto? ';
  static const logOutDialogTitle = 'Wylogować się?';
  static const logOutDialogBody = 'Czy na pewno chcesz się wylogować z aplikacji na tym urządzeniu?';
  static const signedIn = 'Zarejestrowano. Możesz się zalogować.';
  static const logOut = 'Wyloguj';
  static const logOut2 = 'Wyloguj się';
  static const invalidLoginOrSignIn = 'Nieprawidłowy login lub hasło.';
  static const accountExistsWarning = 'Konto o tym emailu już istnieje.';

  // Errors
  static const error = "Błąd";
  static const errorOccurred = 'Wystąpił błąd';
  static const errorDefault = 'Wystąpił błąd. Spróbuj ponownie.';
  static const errorManualRejected = 'Ręczny wybór emocji nie został przyjęty przez serwer. Spróbuj ponownie.';
  static const errorDetectionFailed = 'Nie wykryto twarzy ani emocji na zdjęciu. Zrób zdjęcie w lepszym świetle i upewnij się, że twarz jest widoczna.';
  static const errorNoNetwork = 'Brak połączenia. Sprawdź sieć i spróbuj ponownie.';
  static const errorTimeout = 'Serwer nie odpowiada. Spróbuj ponownie później.';
  static const errorInvalidJson = 'Serwer zwrócił nieprawidłową odpowiedź.';
  static const errorUnauthorized = 'Brak autoryzacji.';
  static const errorLoginAgain = 'Zaloguj się ponownie.';
  static const errorUnknown = 'Wystąpił nieznany błąd. Spróbuj ponownie.';

  // Analytics
  static const analyticsPageOverview = 'Przegląd';
  static const analyticsPageHourly = 'Godzinowo';
  static const analyticsPageWeekly = 'Tygodniowo';
  static const analyticsPageNoData = 'Brak danych';

  static const analyticsCardEmotionPercentTitle = 'Rozkład procentowy emocji';
  static const analyticsCardEmotionTotalTitle = 'Liczba wszystkich wpisów';
  static const analyticsCardEmotionHourlyTitle = 'Rozkład emocji po godzinach';
  static const analyticsCardEmotionMostActiveHoursTitle = 'Najbardziej aktywne godziny';
  static const analyticsCardEmotionWeeklyTitle = 'Rozkład emocji po dniach tygodnia';
  static const analyticsCardEmotionWeeklyTotalTitle = 'Suma emocji na dzień tygodnia';
  static const analyticsCardEmotionTotalEntries = 'wpisów';
  static const analyticsCardEmotionMostCommonEmotions = 'Najczęstsze emocje';
  static const analyticsCardEmotionTopTwo = '2';
  static const analyticsCardEmotionTopThree = '3';
  static final analyticsCardWeeklyLabels = ['Pn','Wt','Śr','Cz','Pt','So','Nd'];

  // History Page
  static const historyPageEmotionLabel = 'Emocja';
  static const historyPageSourceLabel = 'Źródło';
  static const historyPageManualFilterLabel = 'Ręczne';
  static const historyPageFromFaceFilterLabel = 'Z twarzy';
  static const historyPageEndOfResults = 'Koniec wyników';
  static const historyCardManualEmotion = 'Emocja wybrana ręcznie';
  static const historyCardClassificationConfidence = 'Pewność klasyfikacji';
}