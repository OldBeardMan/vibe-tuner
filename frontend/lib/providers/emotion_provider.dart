import 'package:flutter/cupertino.dart';
import 'package:vibe_tuner/models/emotion.dart';

class EmotionProvider extends ChangeNotifier {
  Emotion? _selectedEmotion;

  List<String> get emotions => Emotion.all.map((e) => e.localName).toList();

  Emotion? get selectedEmotion => _selectedEmotion;

  void selectEmotionByName(String name) {
    _selectedEmotion = Emotion.fromLocalNameOrDefault(name);
    notifyListeners();
  }

  void selectEmotion(Emotion e) {
    _selectedEmotion = e;
    notifyListeners();
  }

  void clear() {
    _selectedEmotion = null;
    notifyListeners();
  }
}
