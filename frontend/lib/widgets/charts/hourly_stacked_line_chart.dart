import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../models/emotion.dart';

typedef ByHour = Map<int, Map<String, int>>;

class HourlyStackedLineChart extends StatefulWidget {
  final ByHour byHour;
  final List<String>? emotionOrder;
  final int initialTopN;
  final String title;

  const HourlyStackedLineChart({
    super.key,
    required this.byHour,
    this.emotionOrder,
    this.initialTopN = 4,
    this.title = AppStrings.analyticsCardEmotionHourlyTitle,
  });

  @override
  State<HourlyStackedLineChart> createState() => _HourlyStackedLineChartState();
}

class _HourlyStackedLineChartState extends State<HourlyStackedLineChart> {
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
  void didUpdateWidget(covariant HourlyStackedLineChart old) {
    super.didUpdateWidget(old);
    if (old.byHour != widget.byHour || old.emotionOrder != widget.emotionOrder) {
      _prepare();
      setState(() {});
    }
  }

  void _prepare() {
    final set = <String>{};
    for (final row in widget.byHour.values) {
      set.addAll(row.keys);
    }
    _allEmotions = set.toList();

    final totals = <String, int>{};
    for (final e in _allEmotions) {
      var sum = 0;
      for (var h = 0; h < 24; h++) {
        sum += widget.byHour[h]?[e] ?? 0;
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
      _counts[e] = List<int>.generate(24, (h) => widget.byHour[h]?[e] ?? 0);
    }

    _recomputeMax();
  }

  void _recomputeMax() {
    var m = 0;
    for (final e in _visibleEmotions) {
      final arr = _counts[e] ?? List.filled(24, 0);
      for (var h = 0; h < 24; h++) {
        m = max(m, arr[h]);
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
    final vals = List.generate(n, (_) => List<double>.filled(24, 0.0));
    for (var i = 0; i < n; i++) {
      final e = _visibleEmotions[i];
      final arr = _counts[e] ?? List.filled(24, 0);
      for (var h = 0; h < 24; h++) {
        vals[i][h] = arr[h].toDouble();
      }
    }
    return vals;
  }

  List<FlSpot> _toSpots(List<double> vals) {
    return List.generate(24, (i) => FlSpot(i.toDouble(), vals[i]));
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
      final emotionKey = _visibleEmotions[i];
      final spots = _toSpots(cum[i]);
      final color = AppColors.chartColors[emotionKey];
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
            Padding(
              padding: AppSizes.analyticsPageComponentsTitlePadding,
              child: Row(
                children: [
                  Text(widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(width: AppSizes.pageSmallGap),
                  const Spacer(),
                  Icon(Icons.line_axis, size: AppSizes.analyticsCardIconSize, color: theme.colorScheme.primary),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.pageNormalGap),

            // chart area
            AspectRatio(
              aspectRatio: AppSizes.analyticsCardChartAspectRadio,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: (_maxTotal / 4).ceilToDouble(),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: (_maxTotal / 4).ceilToDouble(),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, meta) {
                          final h = v.toInt();
                          final labels = {0: '00', 6: '06', 12: '12', 18: '18', 23: '23'};
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(labels[h] ?? '', style: const TextStyle(fontSize: AppSizes.analyticsCardMostEmotionsFontSize)),
                          );
                        },
                        interval: 1,
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touches) {
                        final items = <LineTooltipItem>[];
                        final hour = touches.isNotEmpty ? touches.first.x.toInt().clamp(0, 23) : 0;
                        for (var i = _visibleEmotions.length - 1; i >= 0; i--) {
                          final serverKey = _visibleEmotions[i];
                          final value = _counts[serverKey]?[hour] ?? 0;
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
