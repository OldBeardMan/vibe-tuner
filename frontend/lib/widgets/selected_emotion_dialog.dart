import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tuner/constants/app_paths.dart';
import 'package:vibe_tuner/constants/app_strings.dart';
import 'package:vibe_tuner/constants/app_sizes.dart';
import '../models/emotion.dart';
import '../models/analyze_result.dart';
import '../models/navigation_args.dart';
import '../models/track.dart';

class SelectedEmotionDialog extends StatefulWidget {
  final int? emotionCode;
  final Future<dynamic>? responseFuture;

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
      _future = widget.responseFuture!.then((res) {
        return _robustParseResponse(res);
      }).catchError((e, st) {
        final errText = 'Request error: ${e.runtimeType}${e != null ? ": ${e.toString()}" : ""}';
        return _SelectedEmotionResponse(
          emotionCode: Emotion.defaultEmotion.id,
          emotionName: Emotion.defaultEmotion.localName,
          error: errText,
        );
      });
    } else {
      final e = Emotion.fromId(widget.emotionCode);
      _future = Future.value(_SelectedEmotionResponse(
        emotionCode: e.id,
        emotionName: e.localName,
      ));
    }

    _messageTimer = Timer.periodic(
      const Duration(milliseconds: AppSizes.dialogLoadingMessagesDuration),
          (_) {
        if (!mounted) return;
        setState(() {
          _messageIndex = (_messageIndex + 1) % _loadingMessages.length;
        });
      },
    );
  }

  String _errorMessagePolish(String? codeOrMessage) {
    if (codeOrMessage == null) return AppStrings.errorDefault;
    final s = codeOrMessage.toLowerCase();

    if (s.contains('manual_rejected')) {
      return AppStrings.errorManualRejected;
    }
    if (s.contains('detection_failed') || s.contains('could not detect') || s.contains('no face')) {
      return AppStrings.errorDetectionFailed;
    }
    if (s.contains('network')) return AppStrings.errorNoNetwork;
    if (s.contains('timeout')) return AppStrings.errorTimeout;
    if (s.contains('invalid_json')) return AppStrings.errorInvalidJson;
    if (s.contains('unauthorized') || s.contains('401')) return '${AppStrings.errorUnauthorized} ${AppStrings.errorLoginAgain}';
    if (s.contains('unknown')) return AppStrings.errorUnknown;
    if (s.length < 200) return codeOrMessage;
    return AppStrings.errorDefault;
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  _SelectedEmotionResponse _robustParseResponse(dynamic res) {
    try {
      if (res is AnalyzeResult) {
        final emoRaw = (res.emotion).trim();
        final generated = res.timestamp ?? DateTime.now();
        final tracks = res.playlist?.tracks ?? <Track>[];

        final byServer = Emotion.tryFromServerKey(emoRaw);
        if (byServer != null) {
          return _SelectedEmotionResponse(
            emotionCode: byServer.id,
            emotionName: byServer.localName,
            tracks: tracks,
            generatedAt: generated,
          );
        }
        final byLocal = Emotion.tryFromLocalName(emoRaw);
        if (byLocal != null) {
          return _SelectedEmotionResponse(
            emotionCode: byLocal.id,
            emotionName: byLocal.localName,
            tracks: tracks,
            generatedAt: generated,
          );
        }

        return _SelectedEmotionResponse(
          emotionCode: Emotion.defaultEmotion.id,
          emotionName: Emotion.defaultEmotion.localName,
          tracks: tracks,
          generatedAt: generated,
          error: _errorMessagePolish('detection_failed'),
        );
      }

      // 1) int -> treat as code
      if (res is int) {
        final e = Emotion.fromId(res);
        return _SelectedEmotionResponse(emotionCode: e.id, emotionName: e.localName);
      }

      // 2) String -> try JSON or direct emotion key/name
      if (res is String) {
        try {
          final decoded = jsonDecode(res);
          return _robustParseResponse(decoded);
        } catch (_) {
          final s = res.trim();
          final byServer = Emotion.tryFromServerKey(s);
          if (byServer != null) {
            return _SelectedEmotionResponse(emotionCode: byServer.id, emotionName: byServer.localName);
          }
          final byLocal = Emotion.tryFromLocalName(s);
          if (byLocal != null) {
            return _SelectedEmotionResponse(emotionCode: byLocal.id, emotionName: byLocal.localName);
          }
          return _SelectedEmotionResponse(
            emotionCode: Emotion.defaultEmotion.id,
            emotionName: Emotion.defaultEmotion.localName,
            error: _errorMessagePolish(s),
          );
        }
      }

      // 3) Map -> many shapes supported
      if (res is Map) {
        final map = Map<String, dynamic>.from(res);

        // explicit error returned by backend
        if (map.containsKey('error')) {
          final errVal = map['error']?.toString();
          return _SelectedEmotionResponse(
            emotionCode: Emotion.defaultEmotion.id,
            emotionName: Emotion.defaultEmotion.localName,
            error: _errorMessagePolish(errVal),
          );
        }

        // numeric code fields
        final ecandidate = map['emotionCode'] ?? map['emotion_code'] ?? map['code'] ?? map['id'];
        final codeFromNumber = _coerceToInt(ecandidate, fallback: null);
        if (codeFromNumber != null) {
          final e = Emotion.fromId(codeFromNumber);
          // attempt to also extract tracks & timestamp if present
          final tracks = _extractTracksFromMap(map);
          final gen = _extractTimestampFromMap(map);
          return _SelectedEmotionResponse(emotionCode: e.id, emotionName: e.localName, tracks: tracks, generatedAt: gen);
        }

        // top-level emotion string fields
        final emotStrRaw = map['emotion'] ?? map['emotionName'] ?? map['emotion_name'];
        final emotStr = (emotStrRaw is String) ? emotStrRaw.trim() : (emotStrRaw?.toString().trim());
        if (emotStr != null && emotStr.isNotEmpty) {
          final byServer = Emotion.tryFromServerKey(emotStr);
          if (byServer != null) {
            final tracks = _extractTracksFromMap(map);
            final gen = _extractTimestampFromMap(map);
            return _SelectedEmotionResponse(emotionCode: byServer.id, emotionName: byServer.localName, tracks: tracks, generatedAt: gen);
          }
          final byLocal = Emotion.tryFromLocalName(emotStr);
          if (byLocal != null) {
            final tracks = _extractTracksFromMap(map);
            final gen = _extractTimestampFromMap(map);
            return _SelectedEmotionResponse(emotionCode: byLocal.id, emotionName: byLocal.localName, tracks: tracks, generatedAt: gen);
          }
        }

        // playlist.emotion
        if (map['playlist'] is Map) {
          final p = Map<String, dynamic>.from(map['playlist'] as Map);
          final peRaw = p['emotion'] ?? p['emotionName'] ?? p['emotion_name'];
          final pe = (peRaw is String) ? peRaw.trim() : (peRaw?.toString().trim());
          if (pe != null && pe.isNotEmpty) {
            final byServer = Emotion.tryFromServerKey(pe);
            if (byServer != null) {
              final tracks = _extractTracksFromMap({'playlist': p});
              final gen = _extractTimestampFromMap(map);
              return _SelectedEmotionResponse(emotionCode: byServer.id, emotionName: byServer.localName, tracks: tracks, generatedAt: gen);
            }
            final byLocal = Emotion.tryFromLocalName(pe);
            if (byLocal != null) {
              final tracks = _extractTracksFromMap({'playlist': p});
              final gen = _extractTimestampFromMap(map);
              return _SelectedEmotionResponse(emotionCode: byLocal.id, emotionName: byLocal.localName, tracks: tracks, generatedAt: gen);
            }
          }
        }

        // If we have playlist/songs/tracks but no emotion -> return default with tracks
        if (map.containsKey('songs') || map.containsKey('tracks') || map.containsKey('playlist')) {
          final tracks = _extractTracksFromMap(map);
          final gen = _extractTimestampFromMap(map);
          return _SelectedEmotionResponse(
            emotionCode: Emotion.defaultEmotion.id,
            emotionName: Emotion.defaultEmotion.localName,
            tracks: tracks,
            generatedAt: gen,
          );
        }

        // unknown shape -> generic error
        return _SelectedEmotionResponse(
          emotionCode: Emotion.defaultEmotion.id,
          emotionName: Emotion.defaultEmotion.localName,
          error: _errorMessagePolish(null),
        );
      }

      // 4) List -> try first element
      if (res is List && res.isNotEmpty) return _robustParseResponse(res.first);

      // last resort
      return _SelectedEmotionResponse(
        emotionCode: Emotion.defaultEmotion.id,
        emotionName: Emotion.defaultEmotion.localName,
        error: _errorMessagePolish('unknown'),
      );
    } catch (e) {
      return _SelectedEmotionResponse(
        emotionCode: Emotion.defaultEmotion.id,
        emotionName: Emotion.defaultEmotion.localName,
        error: _errorMessagePolish('unknown'),
      );
    }
  }

  int? _coerceToInt(dynamic v, {int? fallback}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    if (v is double) return v.toInt();
    return fallback;
  }

  List<Track> _extractTracksFromMap(Map<String, dynamic> map) {
    try {
      final playlist = map['playlist'] ?? map;
      if (playlist is Map && playlist['tracks'] is List) {
        final list = (playlist['tracks'] as List<dynamic>);
        return list.map((t) {
          if (t is Track) return t;
          if (t is Map<String, dynamic>) {
            return Track.fromJson(Map<String, dynamic>.from(t));
          }
          return Track(name: t.toString(), artist: '');
        }).toList();
      }
      // legacy 'songs' shape
      if (map['songs'] is List) {
        final list = (map['songs'] as List<dynamic>);
        return list.map((t) {
          if (t is Track) return t;
          if (t is Map<String, dynamic>) return Track.fromJson(Map<String, dynamic>.from(t));
          return Track(name: t.toString(), artist: '');
        }).toList();
      }
    } catch (_) {}
    return <Track>[];
  }

  DateTime? _extractTimestampFromMap(Map<String, dynamic> map) {
    try {
      final ts = map['timestamp'] ?? map['generatedAt'] ?? map['generated_at'];
      if (ts == null) return null;
      if (ts is String) return DateTime.tryParse(ts)?.toLocal();
      if (ts is int) return DateTime.fromMillisecondsSinceEpoch(ts).toLocal();
    } catch (_) {}
    return null;
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
                  // Loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingBody(onSurface);
                  }

                  // Error
                  if (snapshot.hasError || snapshot.data?.error != null) {
                    final err = snapshot.data?.error ?? snapshot.error.toString();
                    return _buildErrorBody(err.toString());
                  }

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

  Widget _buildErrorBody(String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSizes.dialogTitleTopSpacing),
        Text(AppStrings.dialogAttention, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSizes.dialogBetweenTitleAndIcon),
        Icon(Icons.warning_amber_rounded, size: AppSizes.dialogSpinningIconSize, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: AppSizes.dialogBetweenIconAndName),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
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
    final em = Emotion.fromId(resp.emotionCode);
    final iconPath = em.icon;
    final name = resp.emotionName.isNotEmpty ? resp.emotionName : em.localName;

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
            child: iconPath.isNotEmpty
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
                  final payload = RecommendedSongsArgs(
                    emotionCode: resp.emotionCode,
                    emotionName: name,
                    tracks: resp.tracks,
                    generatedAt: (resp.generatedAt ?? DateTime.now()),
                  );

                  Navigator.of(context).pop();
                  context.go(AppPaths.recommendedSongsPage, extra: payload);
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
  final List<Track> tracks;
  final DateTime? generatedAt;
  final String? error;

  _SelectedEmotionResponse({
    required this.emotionCode,
    required this.emotionName,
    this.tracks = const [],
    this.generatedAt,
    this.error,
  });
}
