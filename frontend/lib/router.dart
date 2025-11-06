import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tuner/constants/app_paths.dart';
import 'package:vibe_tuner/pages/camera_page.dart';
import 'package:vibe_tuner/pages/recommended_songs_page.dart';
import 'package:vibe_tuner/pages/register_page.dart';
import 'package:vibe_tuner/widgets/selected_emotion_dialog.dart';
import 'constants/app_strings.dart';
import 'models/navigation_args.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/analytics_page.dart';
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
        if (location.startsWith(AppPaths.analyticsPage)) {
          currentIndex = 0;
        } else if (location.startsWith(AppPaths.homePage)) {
          currentIndex = 1;
        } else if (location.startsWith(AppPaths.historyPage)) {
          currentIndex = 2;
        }

        final hideOn = [
          AppPaths.cameraPage,
          AppPaths.registerPage,
          AppPaths.loginPage
        ];
        final bool showBottomBar = !hideOn.any((p) => location.startsWith(p));

        return Scaffold(
          body: child,
          bottomNavigationBar: showBottomBar ? BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              if (index == 0) context.go(AppPaths.analyticsPage);
              if (index == 1) context.go(AppPaths.homePage);
              if (index == 2) context.go(AppPaths.historyPage);
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: AppStrings.analytics),
              BottomNavigationBarItem(icon: Icon(Icons.home), label: AppStrings.homePage),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: AppStrings.history),
            ],
          ) : null,
        );
      },
      routes: [
        GoRoute(path: AppPaths.homePage, builder: (context, state) => const HomePage()),
        GoRoute(path: AppPaths.analyticsPage, builder: (context, state) => const AnalyticsPage()),
        GoRoute(path: AppPaths.historyPage, builder: (context, state) => const HistoryPage()),
        GoRoute(
          path: AppPaths.recommendedSongsPage,
          builder: (context, state) {
            final args = state.extra as RecommendedSongsArgs?;
            if (args == null) return const Scaffold(body: Center(child: Text(AppStrings.recommendedSongsNoData)));
            return RecommendedSongsPage(args: args);
          },
        ),

        GoRoute(path: AppPaths.emotionDialog, builder: (context, state) => const SelectedEmotionDialog()),
        GoRoute(path: AppPaths.cameraPage, builder: (context, state) => const CameraPage()),
        GoRoute(path: AppPaths.registerPage, builder: (context, state) => const RegisterPage()),
        GoRoute(path: AppPaths.baseLocation, builder: (context, state) => const LoginPage()),
      ],
    ),
    GoRoute(path: AppPaths.userPage, builder: (context, state) => const UserPage()),
  ],
);
