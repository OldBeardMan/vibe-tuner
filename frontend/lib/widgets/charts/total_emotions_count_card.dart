import 'package:flutter/material.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';

typedef ByDay = Map<int, Map<String, int>>;

class TotalEmotionsCountCard extends StatelessWidget {
  final ByDay byDay;
  final String title;

  const TotalEmotionsCountCard({
    super.key,
    required this.byDay,
    this.title = AppStrings.analyticsCardEmotionTotalTitle,
  });

  int _totalAll() {
    var total = 0;
    for (var d = 0; d < 7; d++) {
      final row = byDay[d] ?? {};
      for (var v in row.values) {
        total += v;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = _totalAll();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: AppSizes.analyticsCardElevation,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.analyticsPageComponentsPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Icon(Icons.format_list_numbered, size: AppSizes.analyticsCardIconSize, color: theme.colorScheme.primary),
              ],
            ),

            const SizedBox(height: AppSizes.pageNormalGap),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  total.toString(),
                  style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(width: AppSizes.pageNormalGap),
                Text(AppStrings.analyticsCardEmotionTotalEntries, style: theme.textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
