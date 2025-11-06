import 'package:flutter/material.dart';
import 'package:vibe_tuner/constants/app_colors.dart';
import '../../services/api_client.dart';
import '../app_strings.dart';

class BannerInfo {
  final String text;
  final Color color;
  BannerInfo(this.text, this.color);
}

BannerInfo mapApiExceptionToBannerInfo(ApiException e) {
  final code = e.statusCode;
  if (code == 401) {
    return BannerInfo(AppStrings.invalidLoginOrSignIn, AppColors.apiError);
  }
  if (code == 409) {
    return BannerInfo(AppStrings.accountExistsWarning, AppColors.apiWarning);
  }
  if (code != null && code >= 500) {
    return BannerInfo(AppStrings.errorDefault, AppColors.apiError);
  }
  final msg = (e.message.isNotEmpty) ? e.message : '${AppStrings.error}: HTTP ${e.statusCode ?? ''}';
  return BannerInfo(msg, AppColors.apiError);
}

BannerInfo mapGenericExceptionToBannerInfo(Object e) {
  return BannerInfo('${AppStrings.errorOccurred}: ${e.toString()}', AppColors.apiError);
}