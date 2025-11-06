import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vibe_tuner/constants/app_strings.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../models/emotion.dart';

class Song {
  final String title;
  final String artist;

  Song({required this.title, required this.artist});
}

class HistoryCard extends StatefulWidget {
  final Emotion emotion;
  final DateTime dateTime;
  final double confidence;
  final List<Song>? songs;
  final ValueChanged<bool>? onToggle;

  const HistoryCard({
    super.key,
    required this.emotion,
    required this.dateTime,
    required this.confidence,
    this.songs,
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

  bool get _isManual => widget.confidence >= 0.999;

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
              color: Colors.black.withValues(alpha: AppSizes.defaultOpacity),
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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _toggleExpanded,
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
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(widget.dateTime),
                            style: theme.textTheme.bodySmall
                          ),
                        ],
                      ),
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
                textAlign: TextAlign.center,
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
