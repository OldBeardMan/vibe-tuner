import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibe_tuner/constants/app_strings.dart';
import 'package:vibe_tuner/providers/camera_provider.dart';
import 'package:vibe_tuner/providers/theme_provider.dart';
import 'router.dart';
import 'providers/auth_provider.dart';
import 'themes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CameraProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appTitle,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeProv.themeMode,
      routerConfig: router,
    );
  }
}
