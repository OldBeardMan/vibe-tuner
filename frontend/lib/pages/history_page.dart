import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_tuner/constants/app_paths.dart';
import 'package:vibe_tuner/constants/app_strings.dart';
import 'package:vibe_tuner/services/api_client.dart';
import 'package:vibe_tuner/models/emotion.dart';
import 'package:vibe_tuner/widgets/history_card.dart';

import '../constants/app_sizes.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final int _limit = 50;
  int _offset = 0;

  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  int? _total;

  final List<_HistoryRecord> _fetchedRecords = [];
  final List<_HistoryRecord> _displayedRecords = [];

  final Set<int> _selectedEmotionIds = {};
  final Set<String> _selectedSources = {};

  Timer? _filterTimer;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _fetchHistory(refresh: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _filterTimer?.cancel();
    super.dispose();
  }

  String _buildPath({required int limit, required int offset}) {
    final parts = <String>[];
    parts.add('limit=$limit');
    parts.add('offset=$offset');
    if (_selectedEmotionIds.isNotEmpty) {
      final keys = Emotion.all
          .where((e) => _selectedEmotionIds.contains(e.id))
          .map((e) => e.serverKey)
          .join(',');
      if (keys.isNotEmpty) parts.add('emotion=${Uri.encodeQueryComponent(keys)}');
    }
    return '${AppPaths.history}?${parts.join('&')}';
  }

  Future<void> _fetchHistory({bool refresh = false}) async {
    if (_loading || _loadingMore) return;
    if (refresh) {
      _offset = 0;
      _hasMore = true;
      _total = null;
    }
    setState(() {
      _error = null;
      if (refresh) {
        _loading = true;
      } else {
        _loadingMore = true;
      }
    });

    const int maxRetries = 3;
    int attempt = 0;
    while (attempt < maxRetries) {
      attempt++;
      try {
        final path = _buildPath(limit: _limit, offset: _offset);
        final res = await ApiClient.instance.get(path);

        final rawRecords = (res['records'] as List<dynamic>?) ?? [];
        final parsed = <_HistoryRecord>[];

        for (final r in rawRecords) {
          final m = r as Map<String, dynamic>;

          final confidence = (m['confidence'] is num)
              ? (m['confidence'] as num).toDouble()
              : double.tryParse('${m['confidence']}') ?? 0.0;

          final emotionKey = (m['emotion'] ?? m['emotion_display_name'])?.toString();
          final timestampStr = m['timestamp']?.toString();
          DateTime ts;
          try {
            ts = timestampStr != null ? DateTime.parse(timestampStr) : DateTime.now();
          } catch (_) {
            ts = DateTime.now();
          }

          bool? userFeedback;
          if (m.containsKey('user_feedback')) {
            final rawUf = m['user_feedback'];
            if (rawUf == null) {
              userFeedback = null;
            } else {
              userFeedback = rawUf == true;
            }
          } else {
            userFeedback = null;
          }

          String source;
          final detectionSource = m['detection_source']?.toString();
          if (detectionSource != null) {
            source = detectionSource.toLowerCase() == 'manual' ? 'manual' : 'face';
          } else {
            final isManual = userFeedback == true;
            source = isManual ? 'manual' : 'face';
          }

          List<Song> songs = [];
          if (m.containsKey('tracks') && m['tracks'] is List) {
            try {
              final list = (m['tracks'] as List).cast<Map<String, dynamic>>();
              songs = list.map((t) {
                return Song(
                  title: (t['name'] ?? '').toString(),
                  artist: (t['artist'] ?? '').toString(),
                  spotifyId: (t['spotify_id'] ?? t['spotifyId'] ?? '').toString(),
                  previewUrl: (t['preview_url'] ?? '').toString(),
                  externalUrl: (t['external_url'] ?? '').toString(),
                  albumImage: (t['album_image'] ?? '').toString(),
                );
              }).toList();
            } catch (_) {
              songs = [];
            }
          }

          final record = _HistoryRecord(
            id: m['id'] is int ? m['id'] as int : int.tryParse('${m['id']}') ?? 0,
            emotionKey: emotionKey,
            confidence: confidence.clamp(0.0, 1.0),
            timestamp: ts,
            source: source,
            raw: m,
            userFeedback: userFeedback,
            songs: songs,
          );

          parsed.add(record);
        }

        final totalFromResp =
        (res['total'] is int) ? res['total'] as int : int.tryParse('${res['total'] ?? ''}');

        setState(() {
          _total = totalFromResp;
          if (refresh) {
            _fetchedRecords.clear();
            _fetchedRecords.addAll(parsed);
          } else {
            _fetchedRecords.addAll(parsed);
          }

          _offset = _fetchedRecords.length;
          if (_total != null) {
            _hasMore = _fetchedRecords.length < _total!;
          } else {
            _hasMore = parsed.length >= _limit;
          }

          _applyClientFilters();

          _loading = false;
          _loadingMore = false;
        });

        debugPrint('Fetched ${parsed.length} history records (total: $_total).');

        break;
      } on ApiException catch (e) {
        setState(() {
          _loading = false;
          _loadingMore = false;
          _error = e.message;
        });
        break;
      } on Exception catch (e) {
        debugPrint('Fetch history attempt $attempt failed: $e');
        if (attempt >= maxRetries) {
          setState(() {
            _loading = false;
            _loadingMore = false;
            _error = e.toString();
          });
          break;
        } else {
          await Future.delayed(Duration(milliseconds: 300 * attempt));
          continue;
        }
      }
    }
  }

  void _applyClientFilters() {
    _displayedRecords.clear();
    final filtered = _fetchedRecords.where((r) {
      if (_selectedEmotionIds.isNotEmpty) {
        final em = Emotion.tryFromServerKey(r.emotionKey) ?? Emotion.fromServerKeyOrDefault(r.emotionKey);
        if (!_selectedEmotionIds.contains(em.id)) return false;
      }
      if (_selectedSources.isNotEmpty) {
        if (!_selectedSources.contains(r.source)) return false;
      }
      return true;
    }).toList();

    _displayedRecords.addAll(filtered);
  }

  void _onFilterChanged() {
    setState(() {
      _applyClientFilters();
    });

    _filterTimer?.cancel();
    _filterTimer = Timer(const Duration(milliseconds: 350), () {
      _fetchHistory(refresh: true);
    });
  }

  void _onScroll() {
    if (!_hasMore || _loading || _loadingMore) return;
    if (!_scrollController.hasClients) return;

    const threshold = 200.0;
    final position = _scrollController.position;
    if (position.maxScrollExtent - position.pixels <= threshold) {
      _fetchHistory(refresh: false);
    }
  }

  Future<void> _onRefresh() async {
    await _fetchHistory(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.history,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: AppSizes.titleFontSize,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push(AppPaths.userPage),
            icon: const Icon(Icons.person_outline, size: AppSizes.titleFontSize),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.historyCardPadding, vertical: AppSizes.pageSmallGap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.historyPageEmotionLabel, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSizes.pageSmallGap),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...Emotion.all.map((e) {
                        final selected = _selectedEmotionIds.contains(e.id);
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSizes.historyPageEmotionsSpace),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppSizes.pageFieldCornerRadius),
                            onTap: () {
                              setState(() {
                                if (selected) {
                                  _selectedEmotionIds.remove(e.id);
                                } else {
                                  _selectedEmotionIds.add(e.id);
                                }
                              });
                              _onFilterChanged();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageNormalGap),
                              decoration: BoxDecoration(
                                color: selected
                                    ? theme.colorScheme.onSurface.withValues(alpha: AppSizes.defaultOpacity)
                                    : theme.scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(AppSizes.pageFieldCornerRadius),
                                border: Border.all(
                                  color: selected
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurface.withValues(alpha: AppSizes.defaultOpacity),
                                  width: selected ? 1.6 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (selected) ...[
                                    Icon(Icons.check, size: AppSizes.historyPageCheckIconSize, color: theme.colorScheme.onSurface),
                                    const SizedBox(width: AppSizes.pageSmallGap),
                                  ],
                                  Text(
                                    e.localName,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),


                const SizedBox(height: AppSizes.pageNormalGap),

                Text(AppStrings.historyPageSourceLabel, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSizes.pageSmallGap),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_selectedSources.contains('manual')) {
                              _selectedSources.remove('manual');
                            } else {
                              _selectedSources.add('manual');
                            }
                          });
                          _onFilterChanged();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          margin: const EdgeInsets.only(right: AppSizes.historyPageEmotionsSpace),
                          decoration: BoxDecoration(
                            color: _selectedSources.contains('manual') ? theme.colorScheme.onSurface.withValues(alpha: AppSizes.defaultOpacity) : Colors.transparent,
                            border: Border.all(
                              color: _selectedSources.contains('manual') ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: AppSizes.defaultOpacity),
                              width: _selectedSources.contains('manual') ? 1.6 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(AppSizes.pageFieldCornerRadius),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_selectedSources.contains('manual')) ...[
                                Icon(Icons.check, size: AppSizes.historyPageCheckIconSize, color: theme.colorScheme.onSurface,),
                                const SizedBox(width: AppSizes.pageSmallGap),
                              ],
                              Text(
                                AppStrings.historyPageManualFilterLabel,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: _selectedSources.contains('manual') ? FontWeight.w700 : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_selectedSources.contains('face')) {
                              _selectedSources.remove('face');
                            } else {
                              _selectedSources.add('face');
                            }
                          });
                          _onFilterChanged();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          margin: const EdgeInsets.only(left: AppSizes.pageSmallGap),
                          decoration: BoxDecoration(
                            color: _selectedSources.contains('face') ? theme.colorScheme.onSurface.withValues(alpha: AppSizes.defaultOpacity) : Colors.transparent,
                            border: Border.all(
                              color: _selectedSources.contains('face') ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: AppSizes.defaultOpacity),
                              width: _selectedSources.contains('face') ? 1.6 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(AppSizes.pageFieldCornerRadius),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_selectedSources.contains('face')) ...[
                                Icon(Icons.check, size: AppSizes.historyPageCheckIconSize, color: theme.colorScheme.onSurface,),
                                const SizedBox(width: AppSizes.pageSmallGap),
                              ],
                              Text(
                                AppStrings.historyPageFromFaceFilterLabel,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: _selectedSources.contains('face') ? FontWeight.w700 : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading && _displayedRecords.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _displayedRecords.isEmpty
                ? Center(child: _errorWidget())
                : RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.pageSmallGap),
                itemCount: _displayedRecords.length + 1,
                itemBuilder: (context, index) {
                  if (index >= _displayedRecords.length) {
                    if (_loadingMore) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSizes.pageNormalGap),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (!_hasMore) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSizes.pageNormalGap),
                        child: Center(child: Text(AppStrings.historyPageEndOfResults)),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }

                  final r = _displayedRecords[index];
                  final emotion = Emotion.fromServerKeyOrDefault(r.emotionKey);
                  return HistoryCard(
                    emotion: emotion,
                    dateTime: r.timestamp,
                    confidence: r.confidence,
                    songs: r.songs,
                    userFeedback: r.userFeedback,
                    source: r.source,
                    onToggle: (expanded) {},
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${AppStrings.errorOccurred}:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSizes.pageSmallGap),
          Text(_error ?? AppStrings.errorDefault, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _HistoryRecord {
  final int id;
  final String? emotionKey;
  final double confidence;
  final DateTime timestamp;
  final String source;
  final Map<String, dynamic> raw;
  final bool? userFeedback;
  List<Song> songs;

  _HistoryRecord({
    required this.id,
    required this.emotionKey,
    required this.confidence,
    required this.timestamp,
    required this.source,
    required this.raw,
    required this.userFeedback,
    this.songs = const [],
  });
}
