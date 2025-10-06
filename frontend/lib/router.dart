import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'constants/app_strings.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'pages/history_page.dart';
import 'pages/user_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginPage()),
    ShellRoute(
      builder: (context, state, child) {
        final location = state.uri.toString();
        int currentIndex = 1;
        if (location.startsWith('/settings')) {
          currentIndex = 0;
        } else if (location.startsWith('/home')) {
          currentIndex = 1;
        } else if (location.startsWith('/history')) {
          currentIndex = 2;
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              if (index == 0) context.go('/settings');
              if (index == 1) context.go('/home');
              if (index == 2) context.go('/history');
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: AppStrings.settings),
              BottomNavigationBarItem(icon: Icon(Icons.home), label: AppStrings.homePage),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: AppStrings.history),
            ],
          ),
        );
      },
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
        GoRoute(path: '/history', builder: (context, state) => const HistoryPage()),
      ],
    ),
    GoRoute(path: '/user', builder: (context, state) => const UserPage()),
  ],
);
