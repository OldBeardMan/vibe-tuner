import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibe_tuner/constants/app_paths.dart';
import 'package:vibe_tuner/constants/app_strings.dart';

import '../constants/app_sizes.dart';

class InfoAppPage extends StatelessWidget {
  const InfoAppPage({super.key});

  Future<void> _openGithub(BuildContext context) async {
    final Uri uri = Uri.parse(AppPaths.githubUrl);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw Exception(AppStrings.userPageLinkError);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.userPageLinkError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.userPageAboutApplication, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.userPagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.userPageAboutHeader,
              style: GoogleFonts.inter(fontSize: AppSizes.infoPageHeaderFontSize, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSizes.pageNormalGap),
            Text(
              AppStrings.userPageAboutDescription,
              style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize),
            ),
            const SizedBox(height: AppSizes.pageNormalGap),
            Text(
              AppStrings.userPageMainFeaturesTitle,
              style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.infoPageSmallGap),
            _bulleted([
              AppStrings.userPageFeature1,
              AppStrings.userPageFeature2,
              AppStrings.userPageFeature3,
              AppStrings.userPageFeature4,
              AppStrings.userPageFeature5,
            ]),
            const SizedBox(height: AppSizes.infoPageSectionGap),
            Text(
              AppStrings.userPageTechnologiesTitle,
              style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.infoPageSmallGap),
            _bulleted([
              AppStrings.userPageTech1,
              AppStrings.userPageTech2,
              AppStrings.userPageTech3,
            ]),
            const SizedBox(height: AppSizes.infoPageSectionGap),
            Text(
              AppStrings.userPageAuthorsTitle,
              style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.infoPageSmallGap),
            Text(
              AppStrings.userPageAuthorsDescription,
              style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize),
            ),
            const SizedBox(height: AppSizes.infoPageSectionGap),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _openGithub(context),
                icon: const Icon(Icons.code, size: AppSizes.infoPageButtonIconSize),
                label: Text(AppStrings.userPageGithubButton, style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.infoPageButtonPaddingHorizontal,
                    vertical: AppSizes.infoPageButtonPaddingVertical,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.buttonBorderRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bulleted(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((t) => Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.infoPageBulletGap),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('•  ', style: TextStyle(fontSize: AppSizes.infoPageBulletFontSize)),
            Expanded(child: Text(t, style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize))),
          ],
        ),
      ))
          .toList(),
    );
  }
}

class SpotifyIntegrationPage extends StatelessWidget {
  const SpotifyIntegrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.userPageSpotifyIntegration, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.userPagePadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            AppStrings.spotifyIntegrationHeader,
            style: GoogleFonts.inter(fontSize: AppSizes.infoPageSectionTitleFontSize, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSizes.infoPageSmallGap),
          Text(
            AppStrings.spotifyIntegrationBody,
            style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize),
          ),
          const SizedBox(height: AppSizes.infoPageSectionGap),
          Text(AppStrings.spotifyRequirementsTitle, style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.infoPageSmallGap),
          _bulleted([
            AppStrings.spotifyReq1,
            AppStrings.spotifyReq2,
            AppStrings.spotifyReq3,
          ]),
          const SizedBox(height: AppSizes.infoPageSectionGap),
          Text(AppStrings.spotifyMobileTitle, style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.infoPageSmallGap),
          _bulleted([
            AppStrings.spotifyMobile1,
            AppStrings.spotifyMobile2,
            AppStrings.spotifyMobile3,
          ]),
        ]),
      ),
    );
  }

  Widget _bulleted(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((t) => Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.infoPageBulletGap),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('•  ', style: TextStyle(fontSize: AppSizes.infoPageBulletFontSize)),
            Expanded(child: Text(t, style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize))),
          ],
        ),
      ))
          .toList(),
    );
  }
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.userPagePrivacy, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.userPagePadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppStrings.privacyHeader, style: GoogleFonts.inter(fontSize: AppSizes.infoPageSectionTitleFontSize, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.infoPageSmallGap),
          Text(AppStrings.privacyIntro, style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize)),
          const SizedBox(height: AppSizes.infoPageSmallGap),
          _bulleted([
            AppStrings.privacyItem1,
            AppStrings.privacyItem2,
            AppStrings.privacyItem3,
          ]),
          const SizedBox(height: AppSizes.infoPageSectionGap),
          Text(AppStrings.privacySecurityTitle, style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.infoPageSmallGap),
          Text(AppStrings.privacySecurityDesc, style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize)),
          const SizedBox(height: AppSizes.infoPageSectionGap),
          Text(AppStrings.privacyContactTitle, style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.infoPageSmallGap),
          Text(AppStrings.privacyContactDesc, style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize)),
        ]),
      ),
    );
  }

  Widget _bulleted(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((t) => Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.infoPageBulletGap),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('•  ', style: TextStyle(fontSize: AppSizes.infoPageBulletFontSize)),
            Expanded(child: Text(t, style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize))),
          ],
        ),
      ))
          .toList(),
    );
  }
}

class ConsentsPage extends StatelessWidget {
  const ConsentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.userPageConsents, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.userPagePadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppStrings.consentsHeader, style: GoogleFonts.inter(fontSize: AppSizes.infoPageSectionTitleFontSize, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.infoPageSmallGap),
          Text(AppStrings.consentsIntro, style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize)),
          const SizedBox(height: AppSizes.infoPageSectionGap),
          _consentItem(AppStrings.consentCameraTitle, AppStrings.consentCameraDesc),
        ]),
      ),
    );
  }

  Widget _consentItem(String title, String desc) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize, fontWeight: FontWeight.w600)),
      const SizedBox(height: AppSizes.infoPageSmallGap),
      Text(desc, style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize)),
    ]);
  }
}

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = <Map<String, String>>[
      {'q': AppStrings.faqQ1, 'a': AppStrings.faqA1},
      {'q': AppStrings.faqQ2, 'a': AppStrings.faqA2},
      {'q': AppStrings.faqQ3, 'a': AppStrings.faqA3},
      {'q': AppStrings.faqQ4, 'a': AppStrings.faqA4},
      {'q': AppStrings.faqQ5, 'a': AppStrings.faqA5},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.userPageFaq, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.userPagePadding),
        itemCount: faqs.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.infoPageSmallGap),
        itemBuilder: (context, i) {
          final item = faqs[i];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.pageFieldCornerRadius)),
            elevation: 1.0,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.infoPageCardPadding),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item['q']!, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: AppSizes.infoPageBodyFontSize)),
                const SizedBox(height: AppSizes.infoPageSmallGap),
                Text(item['a']!, style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.userPageStatue, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.userPagePadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppStrings.termsHeading, style: GoogleFonts.inter(fontSize: AppSizes.infoPageSectionTitleFontSize, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSizes.infoPageSmallGap),
          Text(AppStrings.termsGeneral, style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize)),
          const SizedBox(height: AppSizes.infoPageSmallGap),
          Text(AppStrings.termsResponsibility, style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize)),
          const SizedBox(height: AppSizes.infoPageSmallGap),
          Text(AppStrings.termsLicenses, style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize)),
          const SizedBox(height: AppSizes.infoPageSmallGap),
          Text(AppStrings.termsContactTitle, style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSizes.infoPageSmallGap),
          Text(AppStrings.termsContactText, style: GoogleFonts.inter(fontSize: AppSizes.infoPageBodyFontSize)),
        ]),
      ),
    );
  }
}
