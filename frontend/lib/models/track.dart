class Track {
  final String name;
  final String artist;
  final String? spotifyId;
  final String? previewUrl;
  final String? externalUrl;
  final String? albumImage;

  Track({
    required this.name,
    required this.artist,
    this.spotifyId,
    this.previewUrl,
    this.externalUrl,
    this.albumImage,
  });

  factory Track.fromJson(Map<String, dynamic> raw) {
    final Map<String, dynamic> json = {};
    raw.forEach((k, v) {
      json[k.toString()] = v;
    });

    String? pick(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) {
          return json[k].toString();
        }
      }
      return null;
    }

    final name = pick(['name', 'title']) ?? '';
    final artist = pick(['artist', 'artists', 'artist_name']) ?? '';
    final spotifyId = pick(['spotify_id', 'spotifyId', 'id']);
    final previewUrl = pick(['preview_url', 'previewUrl', 'preview']);
    final externalUrl = pick(['external_url', 'externalUrl', 'url', 'external']);
    final albumImage = pick(['album_image', 'albumImage', 'image', 'album_image_url']);

    return Track(
      name: name,
      artist: artist,
      spotifyId: spotifyId,
      previewUrl: previewUrl,
      externalUrl: externalUrl,
      albumImage: albumImage,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'artist': artist,
    'spotify_id': spotifyId,
    'preview_url': previewUrl,
    'external_url': externalUrl,
    'album_image': albumImage,
  };
}
