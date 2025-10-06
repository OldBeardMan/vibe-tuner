import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _prefsKey = 'is_dark_mode';

  bool _isDark = false;
  bool get isDark => _isDark;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDark = prefs.getBool(_prefsKey) ?? false;
    } catch (e, st) {
      debugPrint('ThemeProvider: failed to load prefs: $e\n$st');
      _isDark = false;
    }
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool dark) async {
    _isDark = dark;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, _isDark);
    } catch (e, st) {
      debugPrint('ThemeProvider: failed to save prefs: $e\n$st');
    }
  }

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;
}
