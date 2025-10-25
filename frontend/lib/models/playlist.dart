import 'package:vibe_tuner/models/track.dart';

class Playlist {
  final String? id;
  final String? name;
  final String? description;
  final String? emotion;
  final List<Track> tracks;
  final int? totalTracks;
  final String? externalUrl;
  final String? image;

  Playlist({
    this.id,
    this.name,
    this.description,
    this.emotion,
    required this.tracks,
    this.totalTracks,
    this.externalUrl,
    this.image,
  });

  factory Playlist.fromJson(Map<String, dynamic> j) {
    final tracksJson = (j['tracks'] as List<dynamic>?) ?? <dynamic>[];
    final tracks = tracksJson.map((t) {
      if (t is Map<String, dynamic>) return Track.fromJson(t);
      return Track.fromJson(Map<String, dynamic>.from(t as Map));
    }).toList();

    return Playlist(
      id: j['id']?.toString(),
      name: j['name'] as String?,
      description: j['description'] as String?,
      emotion: j['emotion'] as String?,
      tracks: tracks,
      totalTracks: (j['total_tracks'] as num?)?.toInt(),
      externalUrl: j['external_url'] as String?,
      image: j['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'emotion': emotion,
    'tracks': tracks.map((t) => t.toJson()).toList(),
    'total_tracks': totalTracks,
    'external_url': externalUrl,
    'image': image,
  };
}