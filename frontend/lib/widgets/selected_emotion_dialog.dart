import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tuner/constants/app_paths.dart';
import 'package:vibe_tuner/constants/app_strings.dart';
import '../constants/mapping/emotion_mapping.dart';
import '../constants/app_sizes.dart';

class SelectedEmotionDialog extends StatelessWidget {
  final int emotionCode;

  const SelectedEmotionDialog({super.key, required this.emotionCode});

  @override
  Widget build(BuildContext context) {
    final iconPath = emotionEmojiIcons[emotionCode];
    final name = emotionNames[emotionCode] ?? '';
    final theme = Theme.of(context);
    final bg = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Center(
        child: Container(
          width: AppSizes.dialogWidth,
          padding: const EdgeInsets.all(AppSizes.dialogPadding),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSizes.dialogBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: AppSizes.dialogShadowOpacity),
                blurRadius: AppSizes.dialogShadowBlurRadius,
                offset: AppSizes.dialogShadowOffset,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Main column
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSizes.dialogTitleTopSpacing),
                  Text(
                    AppStrings.dialogTitle,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSizes.dialogBetweenTitleAndIcon),

                  // large icon (centered)
                  SizedBox(
                    width: AppSizes.bigIconSize,
                    height: AppSizes.bigIconSize,
                    child: Center(
                      child: iconPath != null
                          ? SvgPicture.asset(
                        iconPath,
                        width: AppSizes.bigIconSize,
                        height: AppSizes.bigIconSize,
                        colorFilter: ColorFilter.mode(onSurface, BlendMode.srcIn),
                      )
                          : Icon(Icons.sentiment_neutral,
                          size: AppSizes.bigIconSize, color: onSurface),
                    ),
                  ),

                  const SizedBox(height: AppSizes.dialogBetweenIconAndName),
                  Text(
                    name,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSizes.dialogBetweenNameAndButtons),

                  // Buttons row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: AppSizes.dialogButtonVerticalPadding),
                            side: BorderSide(color: onSurface),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            AppStrings.dialogCancel,
                            style: TextStyle(color: theme.colorScheme.onSurface),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.dialogButtonGap),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Close dialog and navigate to recommended songs page
                            Navigator.of(context).pop();
                            Future.microtask(() => context.go('${AppPaths.recommendedSongsPage}?emotion=$emotionCode'));
                          },
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: AppSizes.dialogButtonVerticalPadding)),
                          child: const Text(AppStrings.dialogNext),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // top-right close (X)
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  splashRadius: AppSizes.dialogCloseButtonSplashRadius,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
