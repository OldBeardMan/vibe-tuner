import 'package:vibe_tuner/models/track.dart';

class RecommendedSongsArgs {
  final int emotionCode;
  final String emotionName;
  final List<Track> tracks;
  final DateTime generatedAt;

  RecommendedSongsArgs({
    required this.emotionCode,
    required this.emotionName,
    required this.tracks,
    required this.generatedAt,
  });
}
