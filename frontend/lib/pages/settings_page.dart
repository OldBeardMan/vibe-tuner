import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../providers/theme_provider.dart';
import '../widgets/expandable_card.dart';
import '../widgets/expandable_card_title.dart';

class SettingsPage extends StatelessWidget {

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title:  Text(
        AppStrings.settings,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: AppSizes.titleFontSize,
        ),
      ),
        actions: [
          IconButton(onPressed: () => context.push('/user'), icon: const Icon(Icons.person_outline))
        ],
      ),
      body: Column(
        children: [

          // === Integracja ze spotify ===
          const ExpandableCard(
            title: ExpandableCardTitle(
              title: AppStrings.settingsPageSpotifyIntegration,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TODO dodać zawartość
                Text('Integracja ze spotify'),
              ],
            ),
          ),

          // === FAQ ===
          const ExpandableCard(
            title: ExpandableCardTitle(
              title: AppStrings.settingsPageFaq,
            ),
            body: FaqChildren(),
          ),

          // === Prywatność ==
          const ExpandableCard(
            title: ExpandableCardTitle(
              title: AppStrings.settingsPagePrivacy,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TODO dodać zawartość
                Text("Prywatność")
              ],
            ),
          ),

          // === Tryb ciemny ===
          ExpandableCard(
            title: const ExpandableCardTitle(
              title: AppStrings.settingsPageDarkTheme,
            ),
            toggleButton: true,
            toggleInitialValue: themeProv.isDark,
            onToggle: (val) {
              themeProv.toggleDarkMode(val);
            },
          ),

          // === Zgody ===
          const ExpandableCard(
            title: ExpandableCardTitle(
              title: AppStrings.settingsPageConsents,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TODO dodać zawartość
                Text("Zgody")
              ],
            ),
          ),

        ],
      ),
    );
  }
}

class FaqChildren extends StatelessWidget {
  const FaqChildren({super.key});

  @override
  Widget build(BuildContext context) {
    const questions = AppStrings.settingsPageFaqQuestions;
    const answers = AppStrings.settingsPageFaqAnswers;

    final count = min(questions.length, answers.length);
    if (count == 0) {
      return const SizedBox.shrink();
    }

    final List<Widget> children = [];
    for (var i = 0; i < count; i++) {
      children.add(
        Text(
          questions[i],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      children.add(const SizedBox(height: 6));
      children.add(
        Text(
          answers[i],
        ),
      );
      if (i < count - 1) children.add(const SizedBox(height: 12));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
