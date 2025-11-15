import 'package:flutter/material.dart';
import 'package:vibe_tuner/models/track.dart';

class SongRowView extends StatelessWidget {
  final int number;
  final Track song;

  const SongRowView({super.key, required this.number, required this.song});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double imageSize = 64.0;
    const double containerHeight = 88.0;

    return Container(
      height: containerHeight,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Container(
            width: imageSize,
            height: imageSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: (song.albumImage != null && song.albumImage!.isNotEmpty)
                  ? Image.network(
                song.albumImage!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Center(child: Icon(Icons.music_note, color: theme.colorScheme.onSurfaceVariant)),
                  );
                },
              )
                  : Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(child: Icon(Icons.music_note, color: theme.colorScheme.onSurfaceVariant)),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.name,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  song.artist,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),
          SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Icon(
                Icons.music_note,
                size: 28,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          )
        ],
      ),
    );
  }
}
