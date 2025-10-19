import 'package:flutter/material.dart';
import 'package:vibe_tuner/constants/app_colors.dart';
import '../../services/api_client.dart';

class BannerInfo {
  final String text;
  final Color color;
  BannerInfo(this.text, this.color);
}

BannerInfo mapApiExceptionToBannerInfo(ApiException e) {
  final code = e.statusCode;
  if (code == 401) {
    return BannerInfo('Nieprawidłowy login lub hasło.', AppColors.apiError);
  }
  if (code == 409) {
    return BannerInfo('Konto o tym emailu już istnieje.', AppColors.apiWarning);
  }
  if (code != null && code >= 500) {
    return BannerInfo('Błąd serwera. Spróbuj później.', AppColors.apiError);
  }
  final msg = (e.message.isNotEmpty) ? e.message : 'Błąd: HTTP ${e.statusCode ?? ''}';
  return BannerInfo(msg, AppColors.apiError);
}

BannerInfo mapGenericExceptionToBannerInfo(Object e) {
  return BannerInfo('Błąd sieciowy: ${e.toString()}', AppColors.apiError);
}