class AppPaths {

  // Routes
  static const baseLocation = "/";
  static const welcomePage = "/welcome";
  static const homePage = "/home";
  static const userPage = "/user";
  static const historyPage = "/history";
  static const analyticsPage = "/analytics";
  static const recommendedSongsPage = "/recommendedSongs";
  static const emotionDialog = "/emotionDialog";
  static const cameraPage = "/camera";
  static const registerPage = "/register";
  static const loginPage = "/login";

  // API
  static const baseURL = "http://10.0.2.2:5000/api";
  static const register = "/auth/register";
  static const login = "/auth/login";
  static const deleteAccount = "/auth/account";
  static const emotionAnalyze = "/emotion/analyze";
  static const analyticsDistribution = '/analytics/distribution';
  static const analyticsByDay = '/analytics/by-day';
  static const analyticsByHour = '/analytics/by-hour';
  static const history = '/emotion/history';

  // Icons
  static const emotionHappy = 'lib/assets/icons/sentiment_very_satisfied.svg';
  static const emotionSad = 'lib/assets/icons/sentiment_dissatisfied.svg';
  static const emotionAngry = 'lib/assets/icons/sentiment_extremely_dissatisfied.svg';
  static const emotionSurprised = 'lib/assets/icons/sentiment_surprised.svg';
  static const emotionFear = 'lib/assets/icons/sentiment_fear.svg';
  static const emotionDisgust = 'lib/assets/icons/sentiment_disgust.svg';
  static const emotionNeutral = 'lib/assets/icons/sentiment_calm.svg';

  // Images
  static const logoLight = 'lib/assets/images/vibe_tuner_logo_light.png';
  static const logoDark = 'lib/assets/images/vibe_tuner_logo_dark.png';

  // Links
  static const githubUrl = 'https://github.com/OldBeardMan/vibe-tuner';
}