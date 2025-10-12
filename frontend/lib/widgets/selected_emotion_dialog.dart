import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tuner/constants/app_paths.dart';
import 'package:vibe_tuner/constants/app_strings.dart';
import '../constants/mapping/emotion_mapping.dart';
import '../constants/app_sizes.dart';

class SelectedEmotionDialog extends StatefulWidget {
  final int? emotionCode;
  final Future<int>? responseFuture;

  const SelectedEmotionDialog({super.key, this.emotionCode, this.responseFuture});

  @override
  State<SelectedEmotionDialog> createState() => _SelectedEmotionDialogState();
}

class _SelectedEmotionDialogState extends State<SelectedEmotionDialog> {
  late Future<_SelectedEmotionResponse> _future;
  Timer? _messageTimer;
  int _messageIndex = 0;
  final List<String> _loadingMessages = AppStrings.dialogLoadingMessages;

  @override
  void initState() {
    super.initState();

    if (widget.responseFuture != null) {
      _future = widget.responseFuture!.then((code) {
        final name = emotionNames[code] ?? AppStrings.unknown;
        return _SelectedEmotionResponse(emotionCode: code, emotionName: name);
      }).catchError((e) {
        return _SelectedEmotionResponse(
          emotionCode: 4,
          emotionName: emotionNames[4] ?? AppStrings.unknown,
          error: e.toString(),
        );
      });
    } else {
      _future = _loadEmotionDialog(widget.emotionCode);
    }

    _messageTimer = Timer.periodic(const Duration(milliseconds: AppSizes.dialogLoadingMessagesDuration), (_) {
      if (!mounted) return;
      setState(() {
        _messageIndex = (_messageIndex + 1) % _loadingMessages.length;
      });
    });
  }


  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  Future<_SelectedEmotionResponse> _loadEmotionDialog(int? providedCode) async {
    final code = providedCode ?? 2;
    final name = emotionNames[code] ?? AppStrings.unknown;
    return _SelectedEmotionResponse(emotionCode: code, emotionName: name);
  }

  void _closeDialog() {
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
            clipBehavior: Clip.none,
            children: [
              FutureBuilder<_SelectedEmotionResponse>(
                future: _future,
                builder: (context, snapshot) {
                  // Loading state: show compact loader + animated messages + cancel X visible
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingBody(onSurface);
                  }

                  // Error
                  if (snapshot.hasError || snapshot.data?.error != null) {
                    final err = snapshot.data?.error ?? snapshot.error.toString();
                    return _buildErrorBody(err.toString());
                  }

                  // Data ready
                  final resp = snapshot.data!;
                  return _buildContentBody(resp, onSurface);
                },
              ),

              // Top-right X always present (overlapping)
              Positioned(
                right: -8,
                top: -8,
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: Icon(Icons.close, color: onSurface),
                    onPressed: _closeDialog,
                    splashRadius: AppSizes.dialogCloseButtonSplashRadius,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBody(Color onSurface) {
    final message = _loadingMessages[_messageIndex];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSizes.dialogTitleTopSpacing),

        Text(
          AppStrings.dialogTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: AppSizes.dialogBetweenTitleAndIcon),

        SizedBox(
          width: AppSizes.dialogSpinningIconSize,
          height: AppSizes.dialogSpinningIconSize,
          child: Center(
            child: SizedBox(
              width: AppSizes.dialogSpinningIconSize,
              height: AppSizes.dialogSpinningIconSize,
              child: CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation<Color>(onSurface),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSizes.dialogBetweenIconAndName),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: AppSizes.dialogLoadingMessagesAnimation),
          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
          child: Text(
            message,
            key: ValueKey<String>(message),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),

        const SizedBox(height: AppSizes.dialogBetweenNameAndButtons),

        // single cancel button (cancel only)
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _closeDialog,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.dialogButtonVerticalPadding),
                  side: BorderSide(color: onSurface),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius)),
                ),
                child: Text(AppStrings.dialogCancel, style: TextStyle(color: onSurface)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorBody(String error) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSizes.dialogTitleTopSpacing),
        Text(AppStrings.dialogTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSizes.dialogBetweenTitleAndIcon),
        Icon(Icons.error_outline, size: AppSizes.dialogSpinningIconSize, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: AppSizes.dialogBetweenIconAndName),
        Text('Błąd: $error', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSizes.dialogBetweenNameAndButtons),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _closeDialog,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.dialogButtonVerticalPadding),
                  side: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius)),
                ),
                child: Text(AppStrings.dialogCancel, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentBody(_SelectedEmotionResponse resp, Color onSurface) {
    final iconPath = emotionEmojiIcons[resp.emotionCode];
    final name = resp.emotionName;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSizes.dialogTitleTopSpacing),
        Text(AppStrings.dialogTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSizes.dialogBetweenTitleAndIcon),

        Container(
          width: AppSizes.bigIconSize,
          height: AppSizes.bigIconSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: AppSizes.dialogIconBorderWidth > 0
                ? Border.all(color: onSurface, width: AppSizes.dialogIconBorderWidth)
                : null,
            color: Colors.transparent,
          ),
          child: Center(
            child: iconPath != null
                ? SvgPicture.asset(
              iconPath,
              width: AppSizes.bigIconSize,
              height: AppSizes.bigIconSize,
              colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
            )
                : Icon(Icons.sentiment_very_satisfied_outlined, size: AppSizes.bigIconSize, color: Theme.of(context).colorScheme.onSurface),
          ),
        ),

        const SizedBox(height: AppSizes.dialogBetweenIconAndName),
        Text(name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSizes.dialogBetweenNameAndButtons),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _closeDialog,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.dialogButtonVerticalPadding),
                  side: BorderSide(color: onSurface),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius)),
                ),
                child: Text(AppStrings.dialogCancel, style: TextStyle(color: onSurface)),
              ),
            ),
            const SizedBox(width: AppSizes.dialogButtonGap),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Future.microtask(() => context.go('${AppPaths.recommendedSongsPage}?emotion=${resp.emotionCode}'));
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: AppSizes.dialogButtonVerticalPadding)),
                child: const Text(AppStrings.dialogNext),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SelectedEmotionResponse {
  final int emotionCode;
  final String emotionName;
  final String? error;

  _SelectedEmotionResponse({
    required this.emotionCode,
    required this.emotionName,
    this.error,
  });
}
