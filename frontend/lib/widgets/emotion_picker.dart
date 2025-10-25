import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:vibe_tuner/constants/app_sizes.dart';
import 'package:vibe_tuner/constants/app_strings.dart';
import 'package:vibe_tuner/widgets/selected_emotion_dialog.dart';
import '../constants/app_paths.dart';
import '../providers/auth_provider.dart';
import 'package:vibe_tuner/models/analyze_result.dart';
import '../services/api_client.dart';
import 'package:vibe_tuner/models/emotion.dart';

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

  Future<AnalyzeResult> _sendManualEmotionByServerKey(String serverKey) async {
    final uri = Uri.parse('${ApiClient.instance.baseUrl}${AppPaths.emotionAnalyze}');

    final String? token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) {
      return AnalyzeResult(
        id: -1,
        emotion: AppStrings.unknown,
        confidence: null,
        playlist: null,
        timestamp: DateTime.now(),
        raw: {'error': 'unauthorized'},
      );
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({'emotion': serverKey});

    try {
      final resp = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 30));

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        if (resp.body.isEmpty) {
          return AnalyzeResult(
            id: null,
            emotion: AppStrings.unknown,
            confidence: null,
            playlist: null,
            timestamp: DateTime.now(),
            raw: {'note': 'empty_body'},
          );
        }
        try {
          final Map<String, dynamic> j =
          jsonDecode(resp.body) as Map<String, dynamic>;
          return AnalyzeResult.fromJson(j);
        } catch (_) {
          return AnalyzeResult(
            id: -1,
            emotion: AppStrings.unknown,
            confidence: null,
            playlist: null,
            timestamp: DateTime.now(),
            raw: {'error': 'invalid_json', 'body': resp.body},
          );
        }
      }

      if (resp.statusCode == 401) {
        return AnalyzeResult(
          id: -1,
          emotion: AppStrings.unknown,
          confidence: null,
          playlist: null,
          timestamp: DateTime.now(),
          raw: {
            'error': 'unauthorized',
            'status': resp.statusCode,
            'body': resp.body
          },
        );
      }

      try {
        final Map<String, dynamic> j =
        jsonDecode(resp.body) as Map<String, dynamic>;
        if (j.containsKey('emotion') ||
            j.containsKey('playlist') ||
            j.containsKey('songs') ||
            j.containsKey('emotionCode')) {
          return AnalyzeResult.fromJson(j);
        }
      } catch (_) {}

      return AnalyzeResult(
        id: -1,
        emotion: AppStrings.unknown,
        confidence: null,
        playlist: null,
        timestamp: DateTime.now(),
        raw: {
          'error': 'manual_rejected',
          'status': resp.statusCode,
          'body': resp.body
        },
      );
    } on TimeoutException {
      return AnalyzeResult(
        id: -1,
        emotion: AppStrings.unknown,
        confidence: null,
        playlist: null,
        timestamp: DateTime.now(),
        raw: {'error': 'timeout'},
      );
    } on http.ClientException {
      return AnalyzeResult(
        id: -1,
        emotion: AppStrings.unknown,
        confidence: null,
        playlist: null,
        timestamp: DateTime.now(),
        raw: {'error': 'network'},
      );
    } catch (e) {
      return AnalyzeResult(
        id: -1,
        emotion: AppStrings.unknown,
        confidence: null,
        playlist: null,
        timestamp: DateTime.now(),
        raw: {'error': 'unknown', 'message': e.toString()},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const emotions = Emotion.all;

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
                children: emotions.map((emotion) {
                  return Padding(
                    padding: const EdgeInsets.all(6),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                        foregroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                        elevation: 2,
                        shadowColor: Colors.black.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {
                        final serverKey = emotion.serverKey; // canonical key
                        final future = _sendManualEmotionByServerKey(serverKey);

                        showGeneralDialog(
                          context: context,
                          barrierLabel: 'SelectedEmotionDialog',
                          barrierDismissible: true,
                          barrierColor: Colors.black.withValues(alpha: 0.4),
                          pageBuilder: (context, anim1, anim2) {
                            return Center(
                              child: SelectedEmotionDialog(responseFuture: future),
                            );
                          },
                        );
                        _toggleExpanded();
                      },
                      child: Text(
                        emotion.localName,
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
