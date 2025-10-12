import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tuner/constants/app_paths.dart';
import 'package:vibe_tuner/constants/app_sizes.dart';
import 'package:vibe_tuner/constants/mapping/emotion_mapping.dart';
import 'package:vibe_tuner/constants/app_strings.dart';

class RecommendedSongsPage extends StatefulWidget {
  final int? emotionCode;

  const RecommendedSongsPage({super.key, this.emotionCode});

  @override
  State<RecommendedSongsPage> createState() => _RecommendedSongsPageState();
}

class _RecommendedSongsPageState extends State<RecommendedSongsPage> {
  late Future<_RecommendationResponse> _future;

  @override
  void initState() {
    super.initState();
    // if no code provided, fallback to 4
    _future = _loadRecommendations(widget.emotionCode ?? 4);
  }

  Future<_RecommendationResponse> _loadRecommendations(int emotionCode) async {
    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final path = 'lib/assets/mock/response/recommended_songs/recommendations_emotion_$emotionCode.json';

    try {
      final raw = await rootBundle.loadString(path);
      final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
      final generatedAtStr = json['generatedAt'] as String?;
      final generatedAt = generatedAtStr != null ? DateTime.tryParse(generatedAtStr)?.toLocal() : DateTime.now();
      final emotionName = emotionNames[emotionCode] ?? AppStrings.unknown;
      final songsJson = (json['songs'] as List<dynamic>?) ?? <dynamic>[];
      final songs = songsJson.map((s) {
        return _Song.fromJson(s as Map<String, dynamic>);
      }).toList();

      return _RecommendationResponse(
        emotionCode: emotionCode,
        emotionName: emotionName,
        generatedAt: generatedAt ?? DateTime.now(),
        songs: songs,
      );
    } catch (e) {
      return _RecommendationResponse(
        emotionCode: emotionCode,
        emotionName: emotionNames[emotionCode] ?? AppStrings.unknown,
        generatedAt: DateTime.now(),
        songs: [],
        error: e.toString(),
      );
    }
  }

  String _formatDuration(int ms) {
    final seconds = (ms / 1000).round();
    final minutesPart = seconds ~/ 60;
    final secondsPart = seconds % 60;
    return '${minutesPart.toString().padLeft(1, '0')}:${secondsPart.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.recommendedSongs,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: AppSizes.titleFontSize,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppPaths.homePage),
        ),
        actions: [
          IconButton(
              onPressed: () => context.push(AppPaths.userPage),
              icon: const Icon(Icons.person_outline))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // header: big icon + emotion name
            const SizedBox(height: AppSizes.recommendedSongsPageDefaultSpace),
            FutureBuilder<_RecommendationResponse>(
              future: _future,
              builder: (context, snap) {
                // Use emotionName from response (which we set from emotionNames map)
                final name = snap.hasData ? snap.data!.emotionName : (widget.emotionCode != null ? (emotionNames[widget.emotionCode!] ?? '') : '');
                // icon path comes from mapping using the passed emotionCode
                final iconPath = widget.emotionCode != null ? emotionEmojiIcons[widget.emotionCode!] : null;

                return Column(
                  children: [
                    const SizedBox(height: AppSizes.recommendedSongsPageDefaultSpace),
                    if (iconPath != null)
                      Center(
                        child: SizedBox(
                          width: AppSizes.bigIconSize,
                          height: AppSizes.bigIconSize,
                          child: Center(
                            child: SvgPicture.asset(
                                iconPath,
                                width: AppSizes.bigIconSize,
                                height: AppSizes.bigIconSize,
                                colorFilter: ColorFilter.mode(theme.colorScheme.onSurface, BlendMode.srcIn)
                            ),
                          ),
                        ),
                      )
                    else
                      Icon(Icons.sentiment_very_satisfied_outlined, size: AppSizes.bigIconSize, color: theme.colorScheme.onSurface),
                    const SizedBox(height: AppSizes.recommendedSongsPageDefaultSpace),
                    Text(
                      name,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSizes.recommendedSongsPageDefaultSpace),
                  ],
                );
              },
            ),

            // list area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.recommendedSongsPageListAreaHorizontalPadding),
                child: FutureBuilder<_RecommendationResponse>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final resp = snapshot.data!;
                    if (resp.songs.isEmpty) {
                      return const Center(child: Text(AppStrings.recommendedSongsPageNoSongsFound));
                    }

                    // ListView of songs
                    return ListView.separated(
                      itemCount: resp.songs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.recommendedSongsPageSongsSpace),
                      itemBuilder: (context, index) {
                        final song = resp.songs[index];
                        return _buildSongRow(index + 1, song, _formatDuration(song.durationMs), context);
                      },
                    );
                  },
                ),
              ),
            ),

            // bottom info + button
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.recommendedSongsPageButtonVerticalPadding,
                  horizontal: AppSizes.recommendedSongsPageButtonHorizontalPadding
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<_RecommendationResponse>(
                    future: _future,
                    builder: (context, snap) {
                      final generatedAt = snap.hasData ? snap.data!.generatedAt : DateTime.now();
                      final dateStr = '${generatedAt.day.toString().padLeft(2, '0')}.${generatedAt.month.toString().padLeft(2, '0')}.${generatedAt.year}';
                      final timeStr = '${generatedAt.hour.toString().padLeft(2, '0')}:${generatedAt.minute.toString().padLeft(2, '0')}';
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today_outlined),
                          const SizedBox(width: AppSizes.recommendedSongsPageDefaultSpace),
                          Text(dateStr),
                          const SizedBox(width: 24),
                          const Icon(Icons.access_time_outlined),
                          const SizedBox(width: AppSizes.recommendedSongsPageDefaultSpace),
                          Text(timeStr),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () => context.go(AppPaths.homePage),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.recommendedSongsPageButtonHeight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius)),
                      ),
                      child: const Text(AppStrings.recommendedSongsBackButtonLabel),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongRow(int number, _Song song, String duration, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: AppSizes.recommendedSongsPageSongAreaHeight,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.recommendedSongsPageSongAreaHorizontalPadding),
      child: Row(
        children: [
          // number in circle
          Container(
            width: AppSizes.recommendedSongsPageNumbersSize,
            height: AppSizes.recommendedSongsPageNumbersSize,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(number.toString(), style: theme.textTheme.bodyMedium),
          ),
          const SizedBox(width: 10),
          // title + artist
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(song.title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(song.artist, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(duration, style: theme.textTheme.bodySmall),
              const SizedBox(height: 6),
              const Icon(Icons.music_note_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

/// Local model for the page
class _Song {
  final String title;
  final String artist;
  final int durationMs;

  _Song({required this.title, required this.artist, required this.durationMs});

  factory _Song.fromJson(Map<String, dynamic> j) {
    return _Song(
      title: j['title'] as String? ?? '',
      artist: j['artist'] as String? ?? '',
      durationMs: (j['durationMs'] as num?)?.toInt() ?? 0,
    );
  }
}

class _RecommendationResponse {
  final int emotionCode;
  final String emotionName;
  final DateTime generatedAt;
  final List<_Song> songs;
  final String? error;

  _RecommendationResponse({
    required this.emotionCode,
    required this.emotionName,
    required this.generatedAt,
    required this.songs,
    this.error,
  });
}
