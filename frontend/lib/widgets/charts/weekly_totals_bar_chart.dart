import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vibe_tuner/constants/app_strings.dart';

import '../../constants/app_sizes.dart';

typedef ByDay = Map<int, Map<String, int>>;

class WeeklyTotalsBarChart extends StatelessWidget {
  final ByDay byDay;
  final String title;

  const WeeklyTotalsBarChart({
    super.key,
    required this.byDay,
    this.title = AppStrings.analyticsCardEmotionWeeklyTotalTitle,
  });

  static final List<String> _shortLabels = AppStrings.analyticsCardWeeklyLabels;

  int _dayTotal(int d) {
    final row = byDay[d] ?? {};
    var s = 0;
    for (var v in row.values) {
      s += v;
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totals = List<int>.generate(7, (d) => _dayTotal(d));
    final maxVal = totals.fold<int>(0, (p, e) => e > p ? e : p);
    final displayMax = max(1, maxVal);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.pageFieldCornerRadius)),
      elevation: AppSizes.analyticsCardElevation,
      child: Padding(
        padding: AppSizes.analyticsPageComponentsPadding2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: AppSizes.analyticsPageComponentsTitlePadding,
              child: Row(
                children: [
                  Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Icon(Icons.bar_chart, size: AppSizes.analyticsCardIconSize, color: theme.colorScheme.primary),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.pageNormalGap),

            SizedBox(
              height: AppSizes.analyticsCardWeeklyTotalHeight,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: displayMax * 1.1,
                  barTouchData: const BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 36),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, meta) {
                          final idx = v.toInt().clamp(0, 6);
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(_shortLabels[idx], style: const TextStyle(fontSize: 12)),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  barGroups: List.generate(7, (i) {
                    final value = totals[i].toDouble();
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: value,
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                          color: theme.colorScheme.primary,
                        ),
                      ],
                      showingTooltipIndicators: const [],
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 4),

            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: List.generate(7, (i) {
                final t = totals[i];
                return Text('${_shortLabels[i]}: $t', style: theme.textTheme.bodySmall);
              }),
            ),
          ],
        ),
      ),
    );
  }
}
