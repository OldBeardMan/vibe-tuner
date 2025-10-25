class Track {
  final String name;
  final String artist;
  final String? spotifyId;
  final String? previewUrl;
  final String? externalUrl;
  final String? albumImage;
  final int? durationMs; // optional, may be missing

  Track({
    required this.name,
    required this.artist,
    this.spotifyId,
    this.previewUrl,
    this.externalUrl,
    this.albumImage,
    this.durationMs,
  });

  factory Track.fromJson(Map<String, dynamic> j) {
    return Track(
      name: j['name'] as String? ?? j['title'] as String? ?? '',
      artist: j['artist'] as String? ?? '',
      spotifyId: j['spotify_id'] as String? ?? j['spotifyId'] as String?,
      previewUrl: j['preview_url'] as String?,
      externalUrl: j['external_url'] as String?,
      albumImage: j['album_image'] as String? ?? j['image'] as String?,
      durationMs: (j['durationMs'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'artist': artist,
    'spotify_id': spotifyId,
    'preview_url': previewUrl,
    'external_url': externalUrl,
    'album_image': albumImage,
    'durationMs': durationMs,
  };
}