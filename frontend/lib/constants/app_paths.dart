class AppPaths {

  // Routes
  static const baseLocation = "/";
  static const homePage = "/home";
  static const userPage = "/user";
  static const historyPage = "/history";
  static const settingsPage = "/settings";
  static const recommendedSongsPage = "/recommendedSongs";
  static const emotionDialog = "/emotionDialog";
  static const cameraPage = "/camera";
  static const registerPage = "/register";
  static const loginPage = "/login";

  // API
  static const baseURL = "http://10.0.2.2:5000/api";
  static const register = "/auth/register";
  static const login = "/auth/login";
  static const emotionAnalyze = "/emotion/analyze";

  // Icons
  static const emotionHappy = 'lib/assets/icons/sentiment_very_satisfied.svg';
  static const emotionSad = 'lib/assets/icons/sentiment_dissatisfied.svg';
  static const emotionAngry = 'lib/assets/icons/sentiment_extremely_dissatisfied.svg';
  static const emotionSurprised = 'lib/assets/icons/sentiment_surprised.svg';
  static const emotionFear = 'lib/assets/icons/sentiment_fear.svg';
  static const emotionDisgust = 'lib/assets/icons/sentiment_disgust.svg';
  static const emotionNeutral = 'lib/assets/icons/sentiment_calm.svg';
}