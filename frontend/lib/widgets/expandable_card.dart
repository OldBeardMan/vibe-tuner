import 'package:flutter/material.dart';
import 'package:vibe_tuner/constants/app_sizes.dart';

class ExpandableCard extends StatefulWidget {
  final Widget title;
  final Widget? body;
  final bool? toggleButton;
  final bool toggleInitialValue;
  final ValueChanged<bool>? onToggle;
  final bool errorCard;

  const ExpandableCard({
    super.key,
    required this.title,
    this.body,
    this.toggleButton = false,
    this.toggleInitialValue = false,
    this.onToggle,
    this.errorCard = false
  });

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late bool _toggleValue;

  @override
  void initState() {
    super.initState();
    _expanded = false;
    _toggleValue = widget.toggleInitialValue;
  }

  void _toggleExpand() => setState(() => _expanded = !_expanded);

  void   _onSwitchChanged(bool v) {
    setState(() => _toggleValue = v);
    if (widget.onToggle != null) widget.onToggle!(v);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: AppSizes.expandableCardPadding,
          right: AppSizes.expandableCardPadding,
          top: AppSizes.expandableCardPaddingBetween
      ),
      child: Container(
        decoration: BoxDecoration(
          color: getColor(widget.errorCard, context),
          borderRadius: BorderRadius.circular(AppSizes.expandableCardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: AppSizes.expandableCardBlurRadius,
              offset: AppSizes.expandableCardBlurOffset,
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSizes.expandableCardPaddingInside),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _toggleExpand,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: widget.title
                    ),
                  ),
                ),

                if (widget.toggleButton == true) ...[
                  Switch(
                    value: _toggleValue,
                    activeThumbColor: const Color(0xFFDDD0B8),
                    onChanged: _onSwitchChanged,
                  ),
                ] else ...[
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 220),
                    child: IconButton(
                      icon: const Icon(Icons.expand_more),
                      onPressed: _toggleExpand,
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ],
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: _expanded && widget.body != null
                  ? Padding(
                padding: const EdgeInsets.only(top: AppSizes.expandableCardPaddingTextTop),
                child: widget.body!,
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Color getColor(bool color, BuildContext context) {
    if (color == false) {
      return Theme.of(context).colorScheme.surface;
    } else {
      return Theme.of(context).colorScheme.error;
    }
  }
}
