import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../constants/app_paths.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../widgets/charts/emotion_percent_chart.dart';
import '../widgets/charts/hourly_stacked_line_chart.dart';
import '../widgets/charts/top_hours_card.dart';
import '../widgets/charts/top_three_emotions_card.dart';
import '../widgets/charts/total_emotions_count_card.dart';
import '../widgets/charts/weekly_stacked_line_chart.dart';
import '../widgets/charts/weekly_totals_bar_chart.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> with SingleTickerProviderStateMixin {
  bool _loading = true;
  String? _error;

  Map<int, Map<String, int>> _byHour = {};
  Map<int, Map<String, int>> _byDay = {};
  Map<String, double> _distribution = {};

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<Uri> _buildUri(String path) async {
    final base = ApiClient.instance.baseUrl;
    return Uri.parse('$base$path');
  }

  Future<void> _fetchAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final String? token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) {
      setState(() {
        _error = AppStrings.errorUnauthorized;
        _loading = false;
      });
      return;
    }

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final byHourUri = await _buildUri(AppPaths.analyticsByHour);
      final byDayUri = await _buildUri(AppPaths.analyticsByDay);
      final distUri = await _buildUri(AppPaths.analyticsDistribution);

      final futures = await Future.wait([
        http.get(byHourUri, headers: headers).timeout(const Duration(seconds: 20)),
        http.get(byDayUri, headers: headers).timeout(const Duration(seconds: 20)),
        http.get(distUri, headers: headers).timeout(const Duration(seconds: 20)),
      ]);

      final byHourResp = futures[0];
      final byDayResp = futures[1];
      final distResp = futures[2];

      if (byHourResp.statusCode >= 200 && byHourResp.statusCode < 300) {
        final json = jsonDecode(byHourResp.body) as Map<String, dynamic>? ?? {};
        final raw = json['by_hour'] as Map<String, dynamic>? ?? {};
        _byHour = raw.map((k, v) =>
            MapEntry(int.parse(k.toString()), Map<String, int>.from(v as Map)));
      } else if (byHourResp.statusCode == 401) {
        throw Exception('Unauthorized (by-hour)');
      } else {
        throw Exception('by-hour: ${byHourResp.statusCode}');
      }

      if (byDayResp.statusCode >= 200 && byDayResp.statusCode < 300) {
        final json = jsonDecode(byDayResp.body) as Map<String, dynamic>? ?? {};
        final raw = json['by_day'] as Map<String, dynamic>? ?? {};
        _byDay = raw.map((k, v) =>
            MapEntry(int.parse(k.toString()), Map<String, int>.from(v as Map)));
      } else if (byDayResp.statusCode == 401) {
        throw Exception('Unauthorized (by-day)');
      } else {
        throw Exception('by-day: ${byDayResp.statusCode}');
      }

      if (distResp.statusCode >= 200 && distResp.statusCode < 300) {
        final json = jsonDecode(distResp.body) as Map<String, dynamic>? ?? {};
        final raw = json['distribution'] as Map<String, dynamic>? ?? {};
        _distribution = raw.map((k, v) => MapEntry(k, (v as num).toDouble()));
      } else if (distResp.statusCode == 401) {
        throw Exception('Unauthorized (distribution)');
      } else {
        throw Exception('distribution: ${distResp.statusCode}');
      }

      setState(() {
        _loading = false;
        _error = null;
      });
    } on TimeoutException {
      setState(() {
        _error = AppStrings.errorTimeout;
        _loading = false;
      });
    } on http.ClientException {
      setState(() {
        _error = AppStrings.errorDefault;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppStrings.analytics,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: AppSizes.titleFontSize,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => context.push(AppPaths.userPage),
              icon: const Icon(Icons.person_outline),
            ),
          ],
          bottom: TabBar(
            indicatorColor: theme.colorScheme.onSurface,
            labelColor: theme.colorScheme.onSurface,
            unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: AppSizes.analyticsPageTabBarUnselectLabelOpacity),
            tabs: const [
              Tab(text: AppStrings.analyticsPageOverview),
              Tab(text: AppStrings.analyticsPageHourly),
              Tab(text: AppStrings.analyticsPageWeekly),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$_error'),
            ],
          ),
        )
            : TabBarView(
          children: [

            // TAB 1 - Overview
            RefreshIndicator(
              onRefresh: _fetchAll,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.analyticsPageComponentsPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EmotionPercentChart(
                      distribution: _distribution,
                    ),
                    const SizedBox(height: AppSizes.pageNormalGap),
                    TotalEmotionsCountCard(byDay: _byDay),
                    const SizedBox(height: AppSizes.pageNormalGap),
                    TopThreeEmotionsCard(distribution: _distribution),
                  ],
                ),
              ),
            ),

            // TAB 2 - Hourly
            RefreshIndicator(
              onRefresh: _fetchAll,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.analyticsPageComponentsPadding),
                child: Column(
                  children: [
                    HourlyStackedLineChart(
                      byHour: _byHour,
                      initialTopN: AppSizes.analyticsPageInitialSelectedEmotionsInCharts,
                    ),
                    const SizedBox(height: AppSizes.pageNormalGap),
                    TopHoursCard(
                      byHour: _byHour,
                      topN: AppSizes.analyticsPageInitialSelectedEmotionsInList,
                    ),
                  ],
                ),
              ),
            ),

            // TAB 3 - Weekly
            RefreshIndicator(
              onRefresh: _fetchAll,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.analyticsPageComponentsPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WeeklyStackedLineChart(
                      byDay: _byDay,
                      initialTopN: AppSizes.analyticsPageInitialSelectedEmotionsInCharts,
                    ),

                    const SizedBox(height: AppSizes.pageNormalGap),

                    WeeklyTotalsBarChart(
                      byDay: _byDay,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
