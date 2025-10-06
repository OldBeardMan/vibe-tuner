import 'package:vibe_tuner/constants/app_sizes.dart';
import 'package:vibe_tuner/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emotion_provider.dart';

class EmotionPicker extends StatefulWidget {
  const EmotionPicker({super.key});

  @override
  State<EmotionPicker> createState() => _EmotionPickerState();
}

class _EmotionPickerState extends State<EmotionPicker>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _arrowAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
      _expanded ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final emoProv = Provider.of<EmotionProvider>(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(8),
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.homePageManuallySelectingEmotionsButton,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                RotationTransition(
                  turns: _arrowAnimation,
                  child: const Icon(Icons.expand_more, size: 26),
                ),
              ],
            ),
          ),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 2.6,
                children: emoProv.emotions.map((e) {
                  return Padding(
                    padding: const EdgeInsets.all(6),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                        elevation: 2,
                        shadowColor: Colors.black.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {
                        emoProv.selectEmotion(e);
                        _toggleExpanded();
                      },
                      child: Text(
                        e,
                        style: const TextStyle(fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
