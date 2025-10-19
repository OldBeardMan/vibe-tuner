import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibe_tuner/constants/app_sizes.dart';

class AnimatedBanner extends StatefulWidget {
  final String? message;
  final Color? color;
  final Duration duration;
  final VoidCallback? onDismissed;

  const AnimatedBanner({
    super.key,
    required this.message,
    this.color,
    this.duration = AppSizes.animatedBannerDuration,
    this.onDismissed,
  });

  @override
  State<AnimatedBanner> createState() => _AnimatedBannerState();
}

class _AnimatedBannerState extends State<AnimatedBanner> {
  Timer? _timer;
  String? _currentMessage;

  @override
  void initState() {
    super.initState();
    _currentMessage = widget.message;
    if (_currentMessage != null) _startTimer();
  }

  @override
  void didUpdateWidget(covariant AnimatedBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message != oldWidget.message) {
      _timer?.cancel();
      _currentMessage = widget.message;
      if (_currentMessage != null) _startTimer();
      setState(() {});
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.duration, () {
      widget.onDismissed?.call();
      if (mounted) {
        setState(() {
          _currentMessage = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = (widget.message != null && widget.message!.isNotEmpty) || _currentMessage != null;
    return AnimatedSwitcher(
      duration: AppSizes.animatedBannerSwitchDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: visible
          ? Container(
        key: const ValueKey('animated_banner_shown'),
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.animatedBannerMarginHorizontal, vertical: AppSizes.animatedBannerMarginVertical),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.animatedBannerPaddingHorizontal, vertical: AppSizes.animatedBannerPaddingVertical),
        decoration: BoxDecoration(
          color: (widget.color ?? Theme.of(context).colorScheme.error).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizes.animatedBannerBorderRadius),
          border: Border.all(color: (widget.color ?? Theme.of(context).colorScheme.error).withValues(alpha: AppSizes.animatedBannerBorderOpacity)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: AppSizes.animatedBannerIconSize, color: widget.color ?? Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.message ?? '',
                style: TextStyle(color: widget.color ?? Theme.of(context).colorScheme.onError),
              ),
            ),
            GestureDetector(
              onTap: () {
                _timer?.cancel();
                widget.onDismissed?.call();
                if (mounted) setState(() {});
              },
              child: Icon(Icons.close, size: AppSizes.animatedBannerCloseIconSize, color: (widget.color ?? Theme.of(context).colorScheme.error).withValues(alpha: 0.8)),
            ),
          ],
        ),
      )
          : const SizedBox.shrink(key: ValueKey('animated_banner_hidden')),
    );
  }
}
