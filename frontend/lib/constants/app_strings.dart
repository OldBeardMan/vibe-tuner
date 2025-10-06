class AppStrings {
  static const emotionHappy = "szczęśliwy";
  static const emotionSad = "smutny";
  static const emotionAngry = "zły";
  static const emotionShocked = "zaskoczony";
  static const emotionCalm = "spokojny";
  static const emotionStressed = "zestresowany";

  static const settings = "ustawienia";
  static const homePage = "Strona główna";
  static const history = "Historia";
  static const profile = "Profil";

  // Home page
  static const homePagePhotoButton = "Zrób zdjęcie";
  static const homePageOr = "lub";
  static const homePageManuallySelectingEmotionsButton = "Wybierz emocję ręcznie";

  // Settings page
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

}