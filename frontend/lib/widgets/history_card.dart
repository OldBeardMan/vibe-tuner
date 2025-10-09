import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/app_sizes.dart';
import '../constants/mapping/emotion_mapping.dart';

class Song {
  final String title;
  final String artist;

  Song({required this.title, required this.artist});
}

class HistoryCard extends StatefulWidget {
  final int emotionCode;
  final DateTime dateTime;
  final List<Song> songs;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onToggle;

  const HistoryCard({
    super.key,
    required this.emotionCode,
    required this.dateTime,
    required this.songs,
    this.initiallyExpanded = false,
    this.onToggle,
  });

  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard>
    with SingleTickerProviderStateMixin {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
      widget.onToggle?.call(_expanded);
    });
  }

  String _formatDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}.${two(dt.month)}.${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.surface;
    final borderColor = theme.colorScheme.onSurface;
    final textColor = theme.colorScheme.onSurface;

    final iconLink = emotionEmojiIcons[widget.emotionCode];
    final emotion = emotionNames[widget.emotionCode];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.historyCardPadding,
        vertical: AppSizes.historyCardVerticalGap / 2,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppSizes.historyCardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: AppSizes.historyCardBlurRadius,
              offset: AppSizes.historyCardBlurOffset,
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSizes.historyCardPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: AppSizes.historyCardAvatarSize,
                  height: AppSizes.historyCardAvatarSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                  child: Center(
                    // TODO
                    child: SvgPicture.asset(
                      iconLink!,
                      width: AppSizes.historyCardIconSize,
                      height: AppSizes.historyCardIconSize,
                      colorFilter: ColorFilter.mode(borderColor, BlendMode.srcIn),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _toggleExpanded,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            emotion!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(widget.dateTime),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: textColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0.0,
                  duration: AppSizes.historyCardAnimDuration,
                  child: IconButton(
                    icon: Icon(Icons.expand_more, color: borderColor),
                    onPressed: _toggleExpanded,
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),

            AnimatedSize(
              duration: AppSizes.historyCardAnimDuration,
              curve: Curves.easeInOut,
              child: _expanded
                  ? Padding(
                padding: const EdgeInsets.only(top: AppSizes.historyCardSongSpacing),
                child: _buildSongsList(context),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongsList(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.colorScheme.onSurface.withValues(alpha: 0.25);

    final songs = widget.songs.length > 5 ? widget.songs.sublist(0, 5) : widget.songs;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < songs.length; i++) ...[
            _songRow(i + 1, songs[i], context),
            if (i != songs.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(thickness: 0.8, height: 1, color: dividerColor),
              ),
          ],
        ],
      ),
    );
  }

  Widget _songRow(int index, Song song, BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Text(
            '$index.',
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '“${song.title}”',
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '- ${song.artist}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
