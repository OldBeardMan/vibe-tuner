import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vibe_tuner/constants/app_colors.dart';

import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../models/emotion.dart';

class TopThreeEmotionsCard extends StatelessWidget {
  final Map<String, double> distribution;

  const TopThreeEmotionsCard({
    super.key,
    required this.distribution,
  });

  List<MapEntry<Emotion, double>> _sortedEntries() {
    final list = distribution.entries.map((e) {
      final em = Emotion.fromServerKeyOrDefault(e.key);
      return MapEntry(em, e.value);
    }).toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = _sortedEntries();
    while (entries.length < 3) {
      entries.add(MapEntry(Emotion.defaultEmotion, 0.0));
    }
    final top3 = entries.take(AppSizes.analyticsPageInitialMostCommonEmotions).toList();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.pageFieldCornerRadius),
      ),
      elevation: AppSizes.analyticsCardElevation,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.analyticsPageComponentsPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  AppStrings.analyticsCardEmotionMostCommonEmotions,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: AppSizes.pageSmallGap),
                Expanded(child: Container()),
                Icon(Icons.leaderboard, size: AppSizes.analyticsCardIconSize, color: theme.colorScheme.primary),
              ],
            ),
            const SizedBox(height: AppSizes.pageNormalGap),

            Column(
              children: top3.asMap().entries.map((entry) {
                final idx = entry.key;
                final em = entry.value.key;
                final value = entry.value.value;
                final color = AppColors.chartColors[em.serverKey]!;
                final progress = (value.clamp(0.0, 100.0) / 100.0);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: AppSizes.analyticsCardMostEmotionsContainerSize,
                            height: AppSizes.analyticsCardMostEmotionsContainerSize,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _buildIcon(em, context),
                            ),
                          ),
                          if (idx == 0)
                            Positioned(
                              right: -6,
                              top: -6,
                              child: Container(
                                padding: const EdgeInsets.all(AppSizes.analyticsCardMostEmotionsSmallPadding),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade700,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4)],
                                ),
                                child: const Icon(Icons.emoji_events, size: 12, color: Colors.white),
                              ),
                            )
                          else if (idx == 1)
                            Positioned(
                              right: -6,
                              top: -6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(AppStrings.analyticsCardEmotionTopTwo,
                                    style: TextStyle(fontSize: AppSizes.analyticsCardMostEmotionsFontSize, color: Colors.white)
                                ),
                              ),
                            )
                          else if (idx == 2)
                              Positioned(
                                right: -6,
                                top: -6,
                                child: Container(
                                  padding: const EdgeInsets.all(AppSizes.analyticsCardMostEmotionsSmallPadding),
                                  decoration: BoxDecoration(
                                    color: Colors.brown.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text(AppStrings.analyticsCardEmotionTopThree,
                                      style: TextStyle(fontSize: AppSizes.analyticsCardMostEmotionsFontSize, color: Colors.white)
                                  ),
                                ),
                              ),
                        ],
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              em.localName,
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: AppSizes.pageSmallGap),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: color.withValues(alpha: 0.18),
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      SizedBox(
                        width: 64,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${value.toStringAsFixed(1)} %',
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: AppSizes.pageSmallGap),
                            Icon(
                              idx == 0 ? Icons.trending_up : Icons.show_chart,
                              size: 16,
                              color: color,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(Emotion em, BuildContext context) {
    return SvgPicture.asset(
      em.iconPath,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode( Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
      errorBuilder: (_, __, ___) {
        return Center(child: Icon(Icons.emoji_emotions, color: AppColors.chartColors[em.serverKey]));
      },
    );
  }
}
