import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vibe_tuner/constants/app_strings.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../models/emotion.dart';

class Song {
  final String title;
  final String artist;
  final String spotifyId;
  final String previewUrl;
  final String externalUrl;
  final String albumImage;

  Song({
    required this.title,
    required this.artist,
    this.spotifyId = '',
    this.previewUrl = '',
    this.externalUrl = '',
    this.albumImage = '',
  });
}

class HistoryCard extends StatefulWidget {
  final Emotion emotion;
  final DateTime dateTime;
  final double confidence;
  final List<Song>? songs;
  final ValueChanged<bool>? onToggle;
  final bool? userFeedback;
  final String source;

  const HistoryCard({
    super.key,
    required this.emotion,
    required this.dateTime,
    required this.confidence,
    this.songs,
    this.onToggle,
    this.userFeedback,
    required this.source,
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
    _expanded = false;
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

  bool get _isManual => widget.source.toLowerCase() == 'manual';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.surface;
    final borderColor = theme.colorScheme.onSurface;
    final textColor = theme.colorScheme.onSurface;

    final em = widget.emotion;
    final iconLink = em.icon;
    final emotion = em.localName;
    final conf = (widget.confidence).clamp(0.0, 1.0);

    final bool userDisagrees = widget.userFeedback == false;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.historyCardPadding,
        vertical: AppSizes.historyCardVerticalGap / 2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.historyCardRadius),
          onTap: _toggleExpanded,
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(AppSizes.historyCardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: AppSizes.defaultOpacity),
                  blurRadius: AppSizes.historyCardBlurRadius,
                  offset: AppSizes.historyCardBlurOffset,
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppSizes.historyCardPadding),
            child: Stack(
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 44.0),
                        child: Row(
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
                                child: SvgPicture.asset(
                                  iconLink,
                                  width: AppSizes.historyCardIconSize,
                                  height: AppSizes.historyCardIconSize,
                                  colorFilter: ColorFilter.mode(borderColor, BlendMode.srcIn),
                                ),
                              ),
                            ),

                            const SizedBox(width: AppSizes.pageNormalGap),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      emotion,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _formatDate(widget.dateTime),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    if (userDisagrees) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.error,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          AppStrings.historyCardNotMatching,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onError,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: AppSizes.pageNormalGap),

                            SizedBox(
                              width: 110,
                              child: _isManual ? _buildManualBadge(theme, textColor) : _buildConfidenceColumn(theme, conf, textColor),
                            ),
                          ],
                        ),
                      ),

                      if (_expanded) ...[
                        const SizedBox(height: 12),
                        if (widget.songs == null || widget.songs!.isEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              AppStrings.historyCardNoSongs,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ] else ...[
                          for (var i = 0; i < widget.songs!.length && i < 5; i++)
                            _buildSongRow(context, widget.songs![i]),
                          if (widget.songs!.length > 5)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                AppStrings.historyCardMoreSongsTemplate.replaceFirst('{count}', '${widget.songs!.length - 5}'),
                                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                        ],
                      ],
                    ],
                  ),
                ),

                Positioned(
                  top: 6,
                  right: 6,
                  child: IgnorePointer(
                    ignoring: true,
                    child: AnimatedRotation(
                      turns: _expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.expand_more,
                        size: 28,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSongRow(BuildContext context, Song s) {
    final theme = Theme.of(context);
    final imageUrl = s.albumImage;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () {
        },
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (c, e, st) => Container(
                  width: 48,
                  height: 48,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
                  child: Icon(Icons.music_note, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                ),
              )
                  : Container(
                width: 48,
                height: 48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
                child: Icon(Icons.music_note, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.title,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.artist,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildManualBadge(ThemeData theme, Color textColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                  AppStrings.historyCardManualEmotion,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodySmall
              ),
            ),
            const SizedBox(width: AppSizes.pageSmallGap),
            const Icon(Icons.touch_app, size: AppSizes.historyCardTouchIconSize),
          ],
        ),
      ],
    );
  }

  Widget _buildConfidenceColumn(ThemeData theme, double conf, Color textColor) {
    final percent = (conf * 100).round();
    Color colorByConfidence;
    if (conf <= 0.40) {
      colorByConfidence = AppColors.confidenceLow;
    } else if (conf <= 0.75) {
      colorByConfidence = AppColors.confidenceMedium;
    } else {
      colorByConfidence = AppColors.confidenceHigh;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$percent%',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: textColor),
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: conf),
          duration: const Duration(milliseconds: 600),
          builder: (context, val, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: val,
                minHeight: 8,
                backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation(colorByConfidence),
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.historyCardClassificationConfidence,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
