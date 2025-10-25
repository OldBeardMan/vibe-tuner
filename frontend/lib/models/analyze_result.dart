import 'package:vibe_tuner/models/playlist.dart';
import 'package:vibe_tuner/models/track.dart';

import '../constants/app_strings.dart';

class AnalyzeResult {
  final int? id;
  final String emotion; // e.g. "happy"
  final double? confidence;
  final Playlist? playlist;
  final DateTime? timestamp;
  final Map<String, dynamic> raw;

  AnalyzeResult({
    this.id,
    required this.emotion,
    this.confidence,
    this.playlist,
    this.timestamp,
    required this.raw,
  });

  factory AnalyzeResult.fromJson(Map<String, dynamic> j) {
    final id = (j['id'] is int) ? j['id'] as int : int.tryParse(j['id']?.toString() ?? '');
    final emotion = (j['emotion'] as String?) ?? (j['emotionName'] as String?) ?? AppStrings.unknown;
    final confidence = (j['confidence'] is num) ? (j['confidence'] as num).toDouble() : (j['confidence'] != null ? double.tryParse(j['confidence'].toString()) : null);

    DateTime? ts;
    final timestampStr = (j['timestamp'] as String?) ?? (j['generatedAt'] as String?);
    if (timestampStr != null) {
      ts = DateTime.tryParse(timestampStr)?.toLocal();
    }

    Playlist? playlist;
    if (j['playlist'] is Map<String, dynamic>) {
      playlist = Playlist.fromJson(j['playlist'] as Map<String, dynamic>);
    } else if (j['playlist'] is Map) {
      playlist = Playlist.fromJson(Map<String, dynamic>.from(j['playlist'] as Map));
    } else if (j['songs'] is List) {
      // backward compatibility: convert old songs -> playlist.tracks
      final tracks = (j['songs'] as List<dynamic>).map((s) {
        if (s is Map<String, dynamic>) return Track.fromJson(s);
        return Track.fromJson(Map<String, dynamic>.from(s as Map));
      }).toList();
      playlist = Playlist(id: null, name: null, description: null, emotion: emotion, tracks: tracks, totalTracks: tracks.length, externalUrl: null, image: null);
    }

    return AnalyzeResult(
      id: id,
      emotion: emotion,
      confidence: confidence,
      playlist: playlist,
      timestamp: ts,
      raw: Map<String, dynamic>.from(j),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'emotion': emotion,
    'confidence': confidence,
    'playlist': playlist?.toJson(),
    'timestamp': timestamp?.toUtc().toIso8601String(),
    'raw': raw,
  };
}