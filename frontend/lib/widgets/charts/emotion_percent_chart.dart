import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vibe_tuner/constants/app_sizes.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/emotion.dart';

class EmotionPercentChart extends StatefulWidget {
  final Map<String, double> distribution;
  final String title;

  const EmotionPercentChart({
    super.key,
    required this.distribution,
    this.title = AppStrings.analyticsCardEmotionPercentTitle,
  });

  @override
  State<EmotionPercentChart> createState() => _EmotionPercentChartState();
}

class _EmotionPercentChartState extends State<EmotionPercentChart> {
  int? _touchedIndex;

  List<MapEntry<Emotion, double>> _sortedEmotionEntries() {
    final entries = widget.distribution.entries.map((e) {
      final em = Emotion.fromServerKeyOrDefault(e.key);
      return MapEntry(em, e.value);
    }).toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  @override
  void didUpdateWidget(covariant EmotionPercentChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.distribution != widget.distribution) {
      setState(() => _touchedIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = _sortedEmotionEntries();
    const chartHeight = AppSizes.analyticsCardEmotionPercentHeight;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.pageFieldCornerRadius),
      ),
      elevation: AppSizes.analyticsCardElevation,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.analyticsPageComponentsPadding),
        child: widget.distribution.isEmpty
            ? const SizedBox(
          height: chartHeight,
          child: Center(child: Text(AppStrings.analyticsPageNoData)),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.title,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(width: AppSizes.pageSmallGap),
                const Spacer(),
                Icon(Icons.donut_large_sharp, size: AppSizes.analyticsCardIconSize, color: theme.colorScheme.primary),
              ],
            ),
            const SizedBox(height: AppSizes.pageNormalGap),

            // chart
            SizedBox(
              height: chartHeight,
              child: Center(
                child: PieChart(
                  PieChartData(
                    sectionsSpace: AppSizes.analyticsCardEmotionChartSectionSpace,
                    centerSpaceRadius: AppSizes.analyticsCardEmotionChartCenterSpaceRadius,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (response == null || response.touchedSection == null) {
                          setState(() => _touchedIndex = null);
                          return;
                        }
                        setState(() => _touchedIndex = response.touchedSection!.touchedSectionIndex);
                      },
                    ),
                    sections: _buildSections(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.pageNormalGap),

            // legend
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: AppSizes.analyticsCardEmotionLegendSpacing,
                runSpacing: AppSizes.analyticsCardEmotionLegendSpacing,
                children: entries.asMap().entries.map((pair) {
                  final idx = pair.key;
                  final em = pair.value.key;
                  final value = pair.value.value;
                  final color = AppColors.chartColors[em.serverKey]!;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _touchedIndex = (_touchedIndex == idx) ? null : idx;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      decoration: BoxDecoration(
                        color: (_touchedIndex == idx)
                            ? color.withValues(alpha: 0.12)
                            : theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppSizes.pageFieldCornerRadius),
                        border: Border.all(
                          color: (_touchedIndex == idx) ? color.withValues(alpha: 0.4) : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSizes.pageSmallGap),

                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 140),
                            child: Text(
                              em.localName,
                              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSizes.pageSmallGap),
                          Text(
                            '${value.toStringAsFixed(1)} %',
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final entries = _sortedEmotionEntries();
    final total = entries.fold<double>(0.0, (p, e) => p + e.value);

    if (total <= 0.0001) {
      return [
        PieChartSectionData(
          value: 1,
          color: AppColors.chartColors['_other'],
          radius: _touchedIndex == 0 ? AppSizes.analyticsCardEmotionChartRadiusTouched : AppSizes.analyticsCardEmotionChartRadius,
          showTitle: true,
          title: AppStrings.analyticsPageNoData,
          titleStyle: const TextStyle(fontSize: AppSizes.analyticsCardEmotionChartFontRadius, fontWeight: FontWeight.w600),
        ),
      ];
    }

    final List<PieChartSectionData> sections = [];
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      final em = e.key;
      final val = e.value;
      final color = AppColors.chartColors[em.serverKey];
      final isTouched = _touchedIndex == i;
      sections.add(PieChartSectionData(
        color: color,
        value: val,
        title: '${val.toStringAsFixed(1)}%',
        radius: isTouched ? AppSizes.analyticsCardEmotionChartRadiusTouched : AppSizes.analyticsCardEmotionChartRadius,
        titleStyle: TextStyle(
          fontSize: isTouched ?  AppSizes.analyticsCardEmotionChartFontRadiusTouched : AppSizes.analyticsCardEmotionChartFontRadius,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        showTitle: true,
      ));
    }
    return sections;
  }
}
