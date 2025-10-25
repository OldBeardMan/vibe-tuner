import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tuner/constants/app_paths.dart';
import 'package:vibe_tuner/constants/app_sizes.dart';
import 'package:vibe_tuner/constants/mapping/emotion_mapping.dart';
import 'package:vibe_tuner/constants/app_strings.dart';
import 'package:vibe_tuner/models/track.dart';
import 'package:vibe_tuner/models/navigation_args.dart';

class RecommendedSongsPage extends StatelessWidget {
  final RecommendedSongsArgs args;

  const RecommendedSongsPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconPath = emotionEmojiIcons[args.emotionCode];
    final name = args.emotionName;
    final generatedAt = args.generatedAt;
    final songs = args.tracks;

    final dateStr = '${generatedAt.day.toString().padLeft(2, '0')}.${generatedAt.month.toString().padLeft(2, '0')}.${generatedAt.year}';
    final timeStr = '${generatedAt.hour.toString().padLeft(2, '0')}:${generatedAt.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.recommendedSongs,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: AppSizes.titleFontSize),
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(AppPaths.homePage)),
        actions: [IconButton(onPressed: () => context.push(AppPaths.userPage), icon: const Icon(Icons.person_outline))],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSizes.recommendedSongsPageDefaultSpace),
            if (iconPath != null)
              SvgPicture.asset(
                iconPath,
                width: AppSizes.bigIconSize,
                height: AppSizes.bigIconSize,
                colorFilter: ColorFilter.mode(theme.colorScheme.onSurface, BlendMode.srcIn),
              )
            else
              Icon(Icons.sentiment_very_satisfied_outlined, size: AppSizes.bigIconSize, color: theme.colorScheme.onSurface),
            const SizedBox(height: AppSizes.recommendedSongsPageDefaultSpace),
            Text(name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSizes.recommendedSongsPageDefaultSpace),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.recommendedSongsPageListAreaHorizontalPadding),
                child: songs.isEmpty
                    ? const Center(child: Text(AppStrings.recommendedSongsPageNoSongsFound))
                    : ListView.separated(
                  itemCount: songs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSizes.recommendedSongsPageSongsSpace),
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return _buildSongRow(index + 1, song, context);
                  },
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.recommendedSongsPageButtonVerticalPadding,
                horizontal: AppSizes.recommendedSongsPageButtonHorizontalPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.calendar_today_outlined),
                    const SizedBox(width: AppSizes.recommendedSongsPageDefaultSpace),
                    Text(dateStr),
                    const SizedBox(width: 24),
                    const Icon(Icons.access_time_outlined),
                    const SizedBox(width: AppSizes.recommendedSongsPageDefaultSpace),
                    Text(timeStr),
                  ]),
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

  Widget _buildSongRow(int number, Track song, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: AppSizes.recommendedSongsPageSongAreaHeight,
      decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(22)),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.recommendedSongsPageSongAreaHorizontalPadding),
      child: Row(
        children: [
          Container(
            width: AppSizes.recommendedSongsPageNumbersSize,
            height: AppSizes.recommendedSongsPageNumbersSize,
            decoration: BoxDecoration(color: theme.colorScheme.surface, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(number.toString(), style: theme.textTheme.bodyMedium),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(song.name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(song.artist, style: theme.textTheme.bodySmall),
            ]),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.music_note_outlined),
        ],
      ),
    );
  }
}
