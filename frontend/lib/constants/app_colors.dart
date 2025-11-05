import 'package:flutter/material.dart';

class AppColors {
  static const Color signInError = Colors.redAccent;
  static Color signUpSuccess = Colors.green.shade600;

  static Color apiError = Colors.red.shade400;
  static Color apiWarning = Colors.orange.shade400;

  static final Map<String, Color> chartColors = {
    'happy': Colors.amber,
    'sad': Colors.blue,
    'angry': Colors.red,
    'surprise': Colors.purple,
    'fear': Colors.indigo,
    'disgust': Colors.teal,
    'neutral': Colors.green,
    '_other': Colors.grey.shade400,
  };

  static const Color confidenceHigh = Colors.green;
  static const Color confidenceMedium = Colors.amber;
  static const Color confidenceLow = Colors.red;
}