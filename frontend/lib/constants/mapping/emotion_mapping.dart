import '../app_strings.dart';

const Map<int, String> emotionEmojiIcons = {
  1 : "lib/assets/icons/sentiment_very_satisfied.svg",
  2 : "lib/assets/icons/sentiment_dissatisfied.svg",
  3 : "lib/assets/icons/sentiment_extremely_dissatisfied.svg",
  4 : "lib/assets/icons/sentiment_shocked.svg",
  5 : "lib/assets/icons/sentiment_calm.svg",
  6 : "lib/assets/icons/sentiment_stressed.svg"
};

const Map<int, String> emotionNames = {
  1 : AppStrings.emotionHappy,
  2 : AppStrings.emotionSad,
  3 : AppStrings.emotionAngry,
  4 : AppStrings.emotionShocked,
  5 : AppStrings.emotionCalm,
  6: AppStrings.emotionStressed
};

int emotionCodeFromName(String name) {
  final lower = name.toLowerCase();
  for (final entry in emotionNames.entries) {
    if (entry.value.toLowerCase() == lower) return entry.key;
  }
  return 1;
}