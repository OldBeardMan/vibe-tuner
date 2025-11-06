import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../models/emotion.dart';

typedef ByDay = Map<int, Map<String, int>>;

class WeeklyStackedLineChart extends StatefulWidget {
  final ByDay byDay;
  final List<String>? emotionOrder;
  final int initialTopN;
  final String title;

  const WeeklyStackedLineChart({
    super.key,
    required this.byDay,
    this.emotionOrder,
    this.initialTopN = 4,
    this.title = AppStrings.analyticsCardEmotionWeeklyTitle,
  });

  @override
  State<WeeklyStackedLineChart> createState() => _WeeklyStackedLineChartState();
}

class _WeeklyStackedLineChartState extends State<WeeklyStackedLineChart> {
  late List<String> _allEmotions;
  late List<String> _visibleEmotions;
  late Map<String, List<int>> _counts;
  late int _maxTotal;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void didUpdateWidget(covariant WeeklyStackedLineChart old) {
    super.didUpdateWidget(old);
    if (old.byDay != widget.byDay || old.emotionOrder != widget.emotionOrder) {
      _prepare();
      setState(() {});
    }
  }

  void _prepare() {
    final set = <String>{};
    for (final row in widget.byDay.values) {
      set.addAll(row.keys);
    }
    _allEmotions = set.toList();

    final totals = <String, int>{};
    for (final e in _allEmotions) {
      var sum = 0;
      for (var d = 0; d < 7; d++) {
        sum += widget.byDay[d]?[e] ?? 0;
      }
      totals[e] = sum;
    }

    if (widget.emotionOrder != null && widget.emotionOrder!.isNotEmpty) {
      final ordered = widget.emotionOrder!.where((e) => _allEmotions.contains(e)).toList();
      ordered.addAll(_allEmotions.where((e) => !ordered.contains(e)));
      _allEmotions = ordered;
    } else {
      _allEmotions.sort((a, b) => (totals[b] ?? 0).compareTo(totals[a] ?? 0));
    }

    final topN = min(widget.initialTopN, _allEmotions.length);
    _visibleEmotions = _allEmotions.take(topN).toList();

    _counts = {};
    for (final e in _allEmotions) {
      _counts[e] = List<int>.generate(7, (d) => widget.byDay[d]?[e] ?? 0);
    }

    _recomputeMax();
  }

  void _recomputeMax() {
    var m = 0;
    for (final e in _visibleEmotions) {
      final arr = _counts[e] ?? List.filled(7, 0);
      for (var d = 0; d < 7; d++) {
        m = max(m, arr[d]);
      }
    }
    _maxTotal = max(1, m);
  }

  void _toggle(String e) {
    setState(() {
      if (_visibleEmotions.contains(e)) {
        _visibleEmotions.remove(e);
      } else {
        _visibleEmotions.add(e);
      }
      _recomputeMax();
    });
  }

  List<List<double>> _buildCumulative() {
    final n = _visibleEmotions.length;
    final vals = List.generate(n, (_) => List<double>.filled(7, 0.0));
    for (var i = 0; i < n; i++) {
      final e = _visibleEmotions[i];
      final arr = _counts[e] ?? List.filled(7, 0);
      for (var d = 0; d < 7; d++) {
        vals[i][d] = arr[d].toDouble();
      }
    }
    return vals;
  }

  List<FlSpot> _toSpots(List<double> vals) {
    return List.generate(7, (i) => FlSpot(i.toDouble(), vals[i]));
  }

  @override
  Widget build(BuildContext context) {
    if (_allEmotions.isEmpty) {
      return const Center(child: Text(AppStrings.analyticsPageNoData));
    }
    final cum = _buildCumulative();
    final theme = Theme.of(context);
    final List<LineChartBarData> series = [];
    for (var i = 0; i < _visibleEmotions.length; i++) {
      final emotion = _visibleEmotions[i];
      final spots = _toSpots(cum[i]);
      final color = AppColors.chartColors[emotion];
      series.add(
        LineChartBarData(
          spots: spots,
          isCurved: false,
          barWidth: AppSizes.analyticsCardChartBarWidth,
          dotData: const FlDotData(show: true),
          color: color,
          belowBarData: BarAreaData(show: false),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.pageFieldCornerRadius),
      ),
      elevation: AppSizes.analyticsCardElevation,
      child: Padding(
        padding: AppSizes.analyticsPageComponentsPadding2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            Padding(
              padding: AppSizes.analyticsPageComponentsTitlePadding,
              child: Row(
                children: [
                  Text(widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Icon(Icons.line_axis, size: AppSizes.analyticsCardIconSize, color: theme.colorScheme.primary),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.pageNormalGap),

            AspectRatio(
              aspectRatio: AppSizes.analyticsCardChartAspectRadio,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: (_maxTotal / 4).ceilToDouble()),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 36, interval: (_maxTotal / 4).ceilToDouble()),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (v, meta) {
                          final idx = v.toInt().clamp(0, 6);
                          final labels = AppStrings.analyticsCardWeeklyLabels;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(labels[idx], style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touches) {
                        final items = <LineTooltipItem>[];
                        final day = touches.isNotEmpty ? touches.first.x.toInt().clamp(0, 6) : 0;
                        for (var i = _visibleEmotions.length - 1; i >= 0; i--) {
                          final serverKey = _visibleEmotions[i];
                          final value = _counts[serverKey]?[day] ?? 0;
                          final color = AppColors.chartColors[serverKey];
                          final em = Emotion.fromServerKeyOrDefault(serverKey);
                          items.add(LineTooltipItem('${em.localName}: $value\n', TextStyle(color: color, fontSize: 12)));
                        }
                        return items;
                      },
                    ),
                  ),
                  minY: 0,
                  maxY: (_maxTotal.toDouble() * 1.05),
                  lineBarsData: series,
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.pageSmallGap),

            // legend
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageSmallGap),
              child: Row(
                children: _allEmotions.asMap().entries.map((entry) {
                  final serverKey = entry.value;
                  final sel = _visibleEmotions.contains(serverKey);
                  final color = AppColors.chartColors[serverKey]!;
                  final em = Emotion.fromServerKeyOrDefault(serverKey);
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSizes.pageSmallGap),
                    child: FilterChip(
                      label: Text(em.localName, style: TextStyle(color: sel ? Colors.white : null)),
                      selected: sel,
                      onSelected: (_) => _toggle(serverKey),
                      selectedColor: color,
                      backgroundColor: color.withValues(alpha: 0.12),
                      checkmarkColor: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: AppSizes.pageSmallGap),
          ],
        ),
      ),
    );
  }
}
