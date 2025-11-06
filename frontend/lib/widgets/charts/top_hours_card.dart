import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../models/emotion.dart';

class TopHoursCard extends StatelessWidget {
  final Map<int, Map<String, int>> byHour;
  final int topN;
  final String title;

  const TopHoursCard({
    super.key,
    required this.byHour,
    this.topN = 5,
    this.title = AppStrings.analyticsCardEmotionMostActiveHoursTitle,
  });

  int _totalAll() {
    var total = 0;
    for (var h = 0; h < 24; h++) {
      final row = byHour[h];
      if (row == null) continue;
      for (var v in row.values) {
        total += v;
      }
    }
    return total;
  }

  List<MapEntry<int, int>> _topHours() {
    final totals = <int, int>{};
    for (var h = 0; h < 24; h++) {
      final row = byHour[h];
      if (row == null) {
        totals[h] = 0;
        continue;
      }
      var s = 0;
      for (var v in row.values) {
        s += v;
      }
      totals[h] = s;
    }
    final list = totals.entries.toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list.take(topN).toList();
  }

  MapEntry<Emotion, int> _dominantEmotionForHour(int hour) {
    final row = byHour[hour] ?? {};
    if (row.isEmpty) {
      return MapEntry(Emotion.defaultEmotion, 0);
    }
    final sorted = row.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first;
    final em = Emotion.fromServerKeyOrDefault(top.key);
    return MapEntry(em, top.value);
  }

  Widget _buildIconOrFallback(Emotion em, Color color, ThemeData theme) {
    return Container(
      width: AppSizes.analyticsCardMostActiveEmotionCont,
      height: AppSizes.analyticsCardMostActiveEmotionCont,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.pageFieldCornerRadiusSmall),
      ),
      child: SvgPicture.asset(
        em.iconPath,
        width: AppSizes.analyticsCardMostActiveEmotionImage,
        height: AppSizes.analyticsCardMostActiveEmotionImage,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(theme.colorScheme.onSurface, BlendMode.srcIn),
        errorBuilder: (_, __, ___) {
          return Center(child: Icon(Icons.emoji_emotions, color: AppColors.chartColors[em.serverKey]));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = _totalAll();
    final topHours = _topHours();

    if (total == 0) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.pageFieldCornerRadius)),
        elevation: AppSizes.analyticsCardElevation,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.analyticsPageComponentsPadding),
          child: SizedBox(
            height: 120,
            child: Center(child: Text(AppStrings.analyticsPageNoData, style: theme.textTheme.bodyMedium)),
          ),
        ),
      );
    }

    const int maxIconsToShow = 6;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.pageFieldCornerRadius)),
      elevation: AppSizes.analyticsCardElevation,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.analyticsPageComponentsPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(width: AppSizes.pageSmallGap),
                const Spacer(),
                Icon(Icons.schedule, size: AppSizes.analyticsCardIconSize, color: theme.colorScheme.primary),
              ],
            ),
            const SizedBox(height: AppSizes.pageNormalGap),

            Column(
              children: topHours.map((entry) {
                final hour = entry.key.clamp(0, 23);
                final hourTotal = entry.value;
                final percent = total > 0 ? (hourTotal / total) * 100.0 : 0.0;
                final dom = _dominantEmotionForHour(hour);
                final domEmotion = dom.key;
                final domColor = AppColors.chartColors[domEmotion.serverKey] ?? theme.colorScheme.primary;
                final row = Map<String, int>.from(byHour[hour] ?? {});
                final emList = row.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
                final icons = <Widget>[];
                final toShow = emList.length <= maxIconsToShow ? emList.length : (maxIconsToShow - 1);
                for (var i = 0; i < toShow; i++) {
                  final kv = emList[i];
                  final em = Emotion.fromServerKeyOrDefault(kv.key);
                  final color = AppColors.chartColors[kv.key] ?? theme.colorScheme.primary;
                  icons.add(
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _buildIconOrFallback(em, color, theme),
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Text(
                              '${kv.value}',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w700, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (emList.length > maxIconsToShow) {
                  final remaining = emList.length - (maxIconsToShow - 1);
                  icons.add(
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        width: AppSizes.analyticsCardMostActiveEmotionCont,
                        height: AppSizes.analyticsCardMostActiveEmotionCont,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(AppSizes.pageFieldCornerRadiusSmall),
                        ),
                        child: Text(
                          '+$remaining',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  );
                }

                if (icons.isEmpty) {
                  final em = Emotion.defaultEmotion;
                  final color = AppColors.chartColors[em.serverKey] ?? theme.colorScheme.primary;
                  icons.add(_buildIconOrFallback(em, color, theme));
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.pageSmallGap),
                  child: Row(
                    children: [
                      Container(
                        width: AppSizes.analyticsCardMostActiveEmotionHourCont,
                        height: AppSizes.analyticsCardMostActiveEmotionHourCont,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppSizes.pageFieldCornerRadiusSmall),
                        ),
                        child: Center(
                          child: Text(
                            '${hour.toString().padLeft(2, '0')}:00',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(children: icons),
                            ),

                            const SizedBox(height: AppSizes.pageSmallGap),

                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppSizes.pageFieldCornerRadiusSmall),
                              child: LinearProgressIndicator(
                                value: (percent / 100).clamp(0.0, 1.0),
                                minHeight: AppSizes.analyticsCardMostActiveEmotionLine,
                                backgroundColor: domColor.withValues(alpha: 0.12),
                                valueColor: AlwaysStoppedAnimation<Color>(domColor),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: AppSizes.pageSmallGap),

                      Text('$hourTotal', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
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
}
