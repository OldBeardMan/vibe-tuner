import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_tuner/constants/app_paths.dart';
import 'package:vibe_tuner/constants/app_strings.dart';
import 'package:vibe_tuner/constants/app_sizes.dart';
import 'package:vibe_tuner/themes.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark 
        ? theme.scaffoldBackgroundColor 
        : AppThemes.lightTheme.scaffoldBackgroundColor;

    final panelColor = isDark 
        ? theme.colorScheme.primaryContainer 
        : const Color(0xFFE8D5B7);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.welcomePageLogoBorderRadius),
                  child: Image.asset(
                    isDark ? AppPaths.logoDark : AppPaths.logoLight,
                    width: AppSizes.welcomePageLogoSize,
                    height: AppSizes.welcomePageLogoSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: panelColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.welcomePagePanelBorderRadius),
                  topRight: Radius.circular(AppSizes.welcomePagePanelBorderRadius),
                ),
              ),
              padding: const EdgeInsets.all(AppSizes.welcomePagePanelPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.welcomePageTitle,
                    style: GoogleFonts.montserrat(
                      fontSize: AppSizes.welcomePageTitleFontSize,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: AppSizes.pageNormalGap),
                  Text(
                    AppStrings.welcomePageDescription,
                    style: GoogleFonts.montserrat(
                      fontSize: AppSizes.welcomePageDescriptionFontSize,
                      fontWeight: FontWeight.w400,
                      color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSizes.pageLargeGap),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.go(AppPaths.loginPage),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: AppSizes.welcomePageButtonVerticalPadding),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.pageFieldCornerRadius),
                            ),
                          ),
                          child: Text(
                            AppStrings.logIn,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              fontSize: AppSizes.welcomePageButtonFontSize,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.pageNormalGap),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.go(AppPaths.registerPage),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.black54 : theme.colorScheme.primaryContainer,
                            foregroundColor: isDark ? Colors.white : Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: AppSizes.welcomePageButtonVerticalPadding),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.pageFieldCornerRadius),
                            ),
                          ),
                          child: Text(
                            AppStrings.signIn,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              fontSize: AppSizes.welcomePageButtonFontSize,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

