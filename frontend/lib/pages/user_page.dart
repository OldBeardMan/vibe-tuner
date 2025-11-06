import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/app_strings.dart';
import '../constants/app_sizes.dart';
import '../providers/theme_provider.dart';
import '../widgets/logout_card.dart';
import 'info_page.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.profile,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: AppSizes.titleFontSize,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _GroupContainer(
              children: [
                _OptionTile.toggle(
                  title: AppStrings.userPageDarkTheme,
                  value: themeProv.isDark,
                  onChanged: (v) => themeProv.toggleDarkMode(v),
                ),
                _OptionTile(
                  title: AppStrings.userPageSpotifyIntegration,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SpotifyIntegrationPage())),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.userPageGroupGap),

            _GroupContainer(
              children: [
                _OptionTile(
                  title: AppStrings.userPagePrivacy,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacyPage())),
                ),
                _OptionTile(
                  title: AppStrings.userPageConsents,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ConsentsPage())),
                ),
                _OptionTile(
                  title: AppStrings.userPageFaq,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FaqPage())),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.userPageGroupGap),

            _GroupContainer(
              children: [
                _OptionTile(
                  title: AppStrings.userPageAboutApplication,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InfoAppPage())),
                ),
                _OptionTile(
                  title: AppStrings.userPageStatue,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TermsPage())),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.userPageGroupGap),
            const LogoutCard(),
            const SizedBox(height: AppSizes.userPageGroupGap),
          ],
        ),
      ),
    );
  }
}
class _GroupContainer extends StatelessWidget {
  final List<Widget> children;
  const _GroupContainer({required this.children});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.primaryContainer;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.expandableCardPadding,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSizes.expandableCardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: AppSizes.defaultOpacity),
              blurRadius: AppSizes.expandableCardBlurRadius,
              offset: AppSizes.expandableCardBlurOffset,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _buildChildrenWithDividers(),
        ),
      ),
    );
  }

  List<Widget> _buildChildrenWithDividers() {
    final out = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      out.add(children[i]);
      if (i < children.length - 1) {
        out.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.userPageGroupGap),
            child: Divider(height: 1),
          ),
        );
      }
    }
    return out;
  }
}

class _OptionTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final bool isToggle;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;

  const _OptionTile({
    required this.title,
    this.onTap,
  })  : isToggle = false,
        toggleValue = null,
        onToggle = null;

  const _OptionTile.toggle({
    required this.title,
    required bool value,
    required ValueChanged<bool> onChanged,
  })  : isToggle = true,
        toggleValue = value,
        onToggle = onChanged,
        onTap = null;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isToggle ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.expandableCardPaddingInside,
          vertical: AppSizes.expandableCardPaddingTextTop,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(fontSize: AppSizes.userPageFontSize),
              ),
            ),
            if (isToggle)
              Switch(
                value: toggleValue ?? false,
                activeThumbColor: Theme.of(context).colorScheme.onSurface,
                onChanged: onToggle,
              )
            else
              const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
