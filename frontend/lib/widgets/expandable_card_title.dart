import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

class ExpandableCardTitle extends StatelessWidget {
  final String title;

  const ExpandableCardTitle({
    super.key,
    required this.title
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(title,
      style: theme.textTheme.bodySmall?.copyWith(
          fontSize: AppSizes.expandableCardBasicTitleSize,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface
      ),
    );
  }
}