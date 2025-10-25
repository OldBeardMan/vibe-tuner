import 'package:vibe_tuner/models/emotion.dart';

final Map<int, String> emotionEmojiIcons = {
  for (final e in Emotion.all) e.id: e.icon
};
final Map<int, String> emotionNames = {
  for (final e in Emotion.all) e.id: e.localName
};

int emotionCodeFromName(String name) => Emotion.fromLocalNameOrDefault(name).id;
