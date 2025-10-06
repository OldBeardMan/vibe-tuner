import 'package:flutter/material.dart';
import 'package:vibe_tuner/constants/app_strings.dart';

class EmotionProvider extends ChangeNotifier {
  String? _selectedEmotion;
  List<String> emotions = [
    AppStrings.emotionHappy,
    AppStrings.emotionSad,
    AppStrings.emotionAngry,
    AppStrings.emotionShocked,
    AppStrings.emotionCalm,
    AppStrings.emotionStressed
  ];

  String? get selectedEmotion => _selectedEmotion;

  void selectEmotion(String e) {
    _selectedEmotion = e;
    notifyListeners();
  }

  void clear() {
    _selectedEmotion = null;
    notifyListeners();
  }
}
