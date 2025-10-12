import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tuner/constants/app_paths.dart';
import 'package:vibe_tuner/pages/camera_page.dart';
import 'package:vibe_tuner/pages/recommended_songs_page.dart';
import 'package:vibe_tuner/widgets/selected_emotion_dialog.dart';
import 'constants/app_strings.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'pages/history_page.dart';
import 'pages/user_page.dart';

final GoRouter router = GoRouter(
  initialLocation: AppPaths.baseLocation,
  routes: [
    GoRoute(path: AppPaths.baseLocation, builder: (context, state) => const LoginPage()),
    ShellRoute(
      builder: (context, state, child) {
        final location = state.uri.toString();
        int currentIndex = 1;
        if (location.startsWith(AppPaths.settingsPage)) {
          currentIndex = 0;
        } else if (location.startsWith(AppPaths.homePage)) {
          currentIndex = 1;
        } else if (location.startsWith(AppPaths.historyPage)) {
          currentIndex = 2;
        }

        final hideOn = [
          AppPaths.cameraPage,
        ];
        final bool showBottomBar = !hideOn.any((p) => location.startsWith(p));

        return Scaffold(
          body: child,
          bottomNavigationBar: showBottomBar ? BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              if (index == 0) context.go(AppPaths.settingsPage);
              if (index == 1) context.go(AppPaths.homePage);
              if (index == 2) context.go(AppPaths.historyPage);
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: AppStrings.settings),
              BottomNavigationBarItem(icon: Icon(Icons.home), label: AppStrings.homePage),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: AppStrings.history),
            ],
          ) : null,
        );
      },
      routes: [
        GoRoute(path: AppPaths.homePage, builder: (context, state) => const HomePage()),
        GoRoute(path: AppPaths.settingsPage, builder: (context, state) => const SettingsPage()),
        GoRoute(path: AppPaths.historyPage, builder: (context, state) => const HistoryPage()),
        GoRoute(
          path: AppPaths.recommendedSongsPage,
          builder: (context, state) {
            final q = state.uri.queryParameters['emotion'];
            final code = q != null ? int.tryParse(q) ?? 4 : 4;
            return RecommendedSongsPage(emotionCode: code);
          },
        ),
        GoRoute(path: AppPaths.emotionDialog, builder: (context, state) => const SelectedEmotionDialog()),
        GoRoute(path: AppPaths.cameraPage, builder: (context, state) => const CameraPage()),
      ],
    ),
    GoRoute(path: AppPaths.userPage, builder: (context, state) => const UserPage()),
  ],
);
