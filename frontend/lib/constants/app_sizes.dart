import 'dart:ui';

import 'package:flutter/cupertino.dart';

class AppSizes {
  // Shared
  static const double titleFontSize = 28.0;
  static const double buttonBorderRadius = 8.0;
  static const double bigIconSize = 110.0;
  static const double pageFieldCornerRadius = 12.0;
  static const double pageFieldCornerRadiusSmall = 8.0;
  static const double pageSmallGap = 8.0;
  static const double pageNormalGap = 12.0;
  static const double pageLargeGap = 32.0;

  static const double expandableCardRadius = 14.0;
  static const double expandableCardPadding = 14.0;
  static const double expandableCardPaddingInside = 10.0;
  static const double expandableCardPaddingTextTop = 12.0;
  static const double expandableCardPaddingBetween = 8.0;
  static const double expandableCardBasicTitleSize = 16.0;
  static const double expandableCardBlurRadius = 3;
  static const Offset expandableCardBlurOffset = Offset(0, 1);

  static const double historyCardPadding = 14.0;
  static const double historyCardRadius = 14.0;
  static const double historyCardAvatarSize = 50.0;
  static const double historyCardVerticalGap = 8.0;
  static const double historyCardIconSize = 50.0;
  static const double historyCardSongSpacing = 12.0;
  static const Duration historyCardAnimDuration = Duration(milliseconds: 220);
  static const double historyCardBlurRadius = 6;
  static const Offset historyCardBlurOffset = Offset(0, 2);

  static const double dialogWidth = 320.0;
  static const double dialogPadding = 18.0;
  static const double dialogBorderRadius = 12.0;
  static const double dialogShadowBlurRadius = 5.0;
  static const Offset dialogShadowOffset = Offset(1, 6);
  static const double dialogShadowOpacity = 0.20;
  static const double dialogIconBorderWidth = 0.0;
  static const double dialogTitleTopSpacing = 6.0;
  static const double dialogBetweenTitleAndIcon = 12.0;
  static const double dialogBetweenIconAndName = 12.0;
  static const double dialogBetweenNameAndButtons = 18.0;
  static const double dialogButtonVerticalPadding = 12.0;
  static const double dialogButtonGap = 12.0;
  static const double dialogCloseButtonSplashRadius = 20.0;
  static const double dialogSpinningIconSize = 40.0;
  static const dialogLoadingMessagesDuration = 2000;
  static const dialogLoadingMessagesAnimation = 500;

  static const double recommendedSongsPageListAreaHorizontalPadding = 12.0;
  static const double recommendedSongsPageSongsSpace = 8.0;
  static const double recommendedSongsPageDefaultSpace = 8.0;
  static const double recommendedSongsPageButtonHorizontalPadding = 16.0;
  static const double recommendedSongsPageButtonVerticalPadding = 18.0;
  static const double recommendedSongsPageButtonHeight = 14.0;
  static const double recommendedSongsPageSongAreaHeight = 64.0;
  static const double recommendedSongsPageSongAreaHorizontalPadding = 10.0;
  static const double recommendedSongsPageNumbersSize = 34.0;

  static const double cameraButtonsPadding = 24;
  static const double cameraSideButtonSize = 28.0;
  static const double cameraPhotoButtonBorderSize = 76.0;
  static const double cameraPhotoButtonSize = 36.0;
  static const double cameraPhotoSizeConversion = 0.9;
  static const double cameraPhotoBorderRadius = 18.0;
  static const double cameraButtonSpaceHeight = 110.0;

  static const double loginPagePaddingHorizontal = 24.0;//
  static const double loginPagePaddingVertical = 48.0;//
  static const double loginPageAvatarIconSize = 64.0;//
  static const double loginPageTitleFontSize = 18.0;//
  static const double loginPageFormSpacing = 10.0;
  static const double loginPageBetweenTitleAndForm = 12.0;
  static const double loginPageFieldVerticalPadding = 14.0;
  static const double loginPageFieldHorizontalPadding = 12.0;
  static const double loginPageFieldBorderRadius = 12.0;
  static const double loginPageButtonVerticalPadding = 14.0;
  static const double loginPageButtonBorderRadius = 10.0;
  static const double loginPageLoadingIndicatorSize = 18.0;
  static const double loginPageTopSpacer = 12.0;
  static const double loginPageLargeSpacer = 32.0;

  static const double logoutPageDialogWidth = 340.0;
  static const double logoutPageDialogPadding = 18.0;
  static const double logoutPageDialogCornerRadius = 12.0;
  static const double logoutPageDialogIconCircleSize = 76.0;
  static const double logoutPageDialogIconSize = 36.0;
  static const double logoutPageDialogSpacing = 14.0;
  static const double logoutPageDialogButtonVerticalPadding = 12.0;
  static const double logoutPageDialogShadowBlur = 12.0;
  static const Offset logoutPageDialogShadowOffset = Offset(0, 6);
  static const double logoutPageDialogShadowOpacity = 0.18;

  static const Duration animatedBannerDuration = Duration(seconds: 3);
  static const Duration animatedBannerSwitchDuration = Duration(milliseconds: 280);
  static const double animatedBannerMarginHorizontal = 24.0;
  static const double animatedBannerMarginVertical = 8.0;
  static const double animatedBannerPaddingHorizontal = 12.0;
  static const double animatedBannerPaddingVertical = 10.0;
  static const double animatedBannerBorderRadius = 12.0;
  static const double animatedBannerIconSize = 18.0;
  static const double animatedBannerCloseIconSize = 18.0;
  static const double animatedBannerBorderOpacity = 0.18;


  static const analyticsPageInitialSelectedEmotionsInCharts = 3;
  static const analyticsPageInitialSelectedEmotionsInList = 5;
  static const analyticsPageInitialMostCommonEmotions = 3;
  static const double analyticsPageTabBarUnselectLabelOpacity = 0.5;
  static const double analyticsPageComponentsPadding = 14.0;
  static const analyticsPageComponentsPadding2 = EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0);
  static const analyticsPageComponentsTitlePadding = EdgeInsets.symmetric(horizontal: 8.0, vertical: 6);
  static const double analyticsCardIconSize = 18.0;
  static const double analyticsCardElevation = 2.0;

  static const double analyticsCardEmotionPercentHeight = 200.0;
  static const double analyticsCardEmotionChartSectionSpace = 6;
  static const double analyticsCardEmotionChartCenterSpaceRadius = 36;
  static const double analyticsCardEmotionLegendSpacing = 8;
  static const double analyticsCardEmotionChartRadius = 50;
  static const double analyticsCardEmotionChartRadiusTouched = 60;
  static const double analyticsCardEmotionChartFontRadius = 12;
  static const double analyticsCardEmotionChartFontRadiusTouched = 14;
  static const double analyticsCardMostEmotionsContainerSize = 44.0;
  static const double analyticsCardMostEmotionsSmallPadding = 4.0;
  static const double analyticsCardMostEmotionsFontSize = 10.0;
  static const double analyticsCardChartAspectRadio = 1.8;
  static const double analyticsCardChartBarWidth = 2.8;
  static const double analyticsCardHourlyMaxYMultiplier = 1.05;
  static const double analyticsCardHourlyTooltipFontSize = 12.0;
  static const double analyticsCardHourlyLeftReservedSize = 36.0;
  static const double analyticsCardMostActiveEmotionCont = 32.0;
  static const double analyticsCardMostActiveEmotionHourCont = 52.0;
  static const double analyticsCardMostActiveEmotionImage = 24.0;
  static const double analyticsCardMostActiveEmotionLine = 10.0;
  static const double analyticsCardWeeklyTotalHeight = 220.0;
}