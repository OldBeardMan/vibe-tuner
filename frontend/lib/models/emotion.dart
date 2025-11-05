import 'package:vibe_tuner/constants/app_strings.dart';

import '../constants/app_paths.dart';

class Emotion {
  final int id;
  final String localName;
  final String serverKey;
  final String iconPath;

  const Emotion({
    required this.id,
    required this.localName,
    required this.serverKey,
    required this.iconPath,
  });

  static const List<Emotion> all = [
    Emotion(id: 1, localName: AppStrings.emotionHappy,    serverKey: 'happy',   iconPath: AppPaths.emotionHappy),
    Emotion(id: 2, localName: AppStrings.emotionSad,      serverKey: 'sad',     iconPath: AppPaths.emotionSad),
    Emotion(id: 3, localName: AppStrings.emotionAngry,    serverKey: 'angry',   iconPath: AppPaths.emotionAngry),
    Emotion(id: 4, localName: AppStrings.emotionSurprised,serverKey: 'surprise',iconPath: AppPaths.emotionSurprised),
    Emotion(id: 5, localName: AppStrings.emotionFear,     serverKey: 'fear',    iconPath: AppPaths.emotionFear),
    Emotion(id: 6, localName: AppStrings.emotionDisgust,  serverKey: 'disgust', iconPath: AppPaths.emotionDisgust),
    Emotion(id: 7, localName: AppStrings.emotionNeutral,  serverKey: 'neutral', iconPath: AppPaths.emotionNeutral),
  ];

  static Emotion get defaultEmotion => all.firstWhere((e) => e.id == 5, orElse: () => all.first);

  static Emotion fromId(int? id) {
    if (id == null) return defaultEmotion;
    return all.firstWhere((e) => e.id == id, orElse: () => defaultEmotion);
  }

  static String _normalize(String s) {
    final lower = s.trim().toLowerCase();
    return lower
        .replaceAll('ą', 'a')
        .replaceAll('ć', 'c')
        .replaceAll('ę', 'e')
        .replaceAll('ł', 'l')
        .replaceAll('ń', 'n')
        .replaceAll('ó', 'o')
        .replaceAll('ś', 's')
        .replaceAll('ż', 'z')
        .replaceAll('ź', 'z');
  }

  static Emotion? tryFromLocalName(String? local) {
    if (local == null) return null;
    final key = _normalize(local);
    try {
      return all.firstWhere((e) => _normalize(e.localName) == key);
    } catch (_) {
      return null;
    }
  }

  static Emotion fromLocalNameOrDefault(String? local) {
    return tryFromLocalName(local) ?? defaultEmotion;
  }

  static Emotion? tryFromServerKey(String? key) {
    if (key == null) return null;
    final k = _normalize(key);
    try {
      return all.firstWhere((e) => _normalize(e.serverKey) == k);
    } catch (_) {
      return null;
    }
  }

  static Emotion fromServerKeyOrDefault(String? key) {
    return tryFromServerKey(key) ?? defaultEmotion;
  }

  String get name => localName;
  String get key => serverKey;
  String get icon => iconPath;
  int get code => id;

  Map<String, dynamic> toMap() => {
    'id': id,
    'localName': localName,
    'serverKey': serverKey,
    'iconPath': iconPath,
  };

  @override
  String toString() => 'Emotion($id, $localName, $serverKey)';
}
