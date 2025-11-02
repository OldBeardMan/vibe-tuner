class AppStrings {
  static const emotionHappy = "szczęśliwy";
  static const emotionSad = "smutny";
  static const emotionAngry = "zły";
  static const emotionSurprised = "zaskoczony";
  static const emotionFear = "przestraszony";
  static const emotionDisgust = "wstręt";
  static const emotionNeutral= "neutralny";

  static const analytics = "Analityka";
  static const homePage = "Strona główna";
  static const history = "Historia";
  static const profile = "Profil";
  static const recommendedSongs = "Twoje utwory";

  static const unknown = "unknown";

  // Home page
  static const homePagePhotoButton = "Zrób zdjęcie";
  static const homePageOr = "lub";
  static const homePageManuallySelectingEmotionsButton = "Wybierz emocję ręcznie";

  // Settings widgets
  static const settingsPageFaqQuestions = [
    "Czy moje zdjęcia są gdzieś zapisywane?",
    "Jak aplikacja rozpoznaje emocje?",
    "What's 9 + 10?",
  ];
  static const settingsPageFaqAnswers = [
    "Nie – zdjęcia są używane tylko chwilowo do rozpoznania emocji i "
        "nie są nigdzie przechowywane. Twoje dane są prywatne i bezpieczne.",
    "Aplikacja wykorzystuje aparat do zrobienia selfie, "
        "a następnie analizuje mimikę twarzy przy pomocy modelu sztucznej inteligencji. "
        "Możesz też ręcznie wybrać swoją emocję, jeśli wolisz.",
    "21"
  ];
  static const settingsPageSpotifyIntegration = "Integracja ze Spotify";
  static const settingsPageFaq = "FAQ";
  static const settingsPagePrivacy = "Prywatność";
  static const settingsPageDarkTheme = "Tryb ciemny";
  static const settingsPageConsents = "Zgody";

  static int getNumOfQuestions() {
    if (settingsPageFaqQuestions.length == settingsPageFaqAnswers.length) {
      return settingsPageFaqQuestions.length;
    }
    return 0;
  }

  // User page
  static const userPageChangeLogin = "Zmień login";
  static const userPageChangePassword = "Zmień hasło";
  static const userPageShowPersonalData = "Pokaż swoje dane";
  static const userPageDeleteAccount = "Usuń konto";


  // Emotion Dialog
  static const dialogTitle = "Twoja emocja";
  static const dialogCancel = "Anuluj";
  static const dialogNext = "Dalej";
  static const dialogLoadingMessages = [
    'Już chwila...',
    'Jeszcze moment...',
    'Prawie gotowe...',
    'Zaraz pokażę propozycje...'
  ];

  // Recomended Songs
  static const recommendedSongsPageNoSongsFound = "Nie znaleziono utworów";
  static const recommendedSongsBackButtonLabel = "Powrót";

  // Exceptions
  static const noTokenReturn = "No token returned from server";
  static const serverConnectionError = "Brak połączenia z serwerem. Sprawdź połączenie sieciowe.";
  static const serverNotRespondingError = "Serwer nie odpowiada. Spróbuj ponownie później.";

  // Login Register page
  static const invalidEmail = "Niepoprawny email";
  static const invalidPasswordHint = "Hasło musi mieć co najmniej 6 znaków";
  static const passwordNoMatch = "Hasła nie są zgodne";
  static const enterEmail = "Wprowadź email";
  static const enterPassword = "Wprowadź hasło";
  static const logIn = "Zaloguj się";
  static const signIn = "Zarejestruj się";
  static const email = "Email";
  static const password = "Hasło";
  static const confirmPassword = "Powtórz hasło";
  static const noAccountQuestion = "Nie masz konta? ";
  static const existAccountQuestion = "Masz już konto? ";
  static const logOutDialogTitle = "Wylogować się?";
  static const logOutDialogBody = "Czy na pewno chcesz się wylogować z aplikacji na tym urządzeniu?";
  static const signedIn = "Zarejestrowano. Możesz się zalogować.";
  static const logOut = "Wyloguj";
  static const logOut2 = "Wyloguj się";

  // Errors
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
}