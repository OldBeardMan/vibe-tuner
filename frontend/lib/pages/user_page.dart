import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_tuner/constants/app_strings.dart';

import '../constants/app_sizes.dart';
import '../widgets/expandable_card.dart';
import '../widgets/expandable_card_title.dart';
import '../widgets/loggout_card.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          AppStrings.profile,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: AppSizes.titleFontSize,
          ),
        ),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: const Column(
        children: [

          // === Zmień login ===
          ExpandableCard(
            title:  ExpandableCardTitle(
              title: AppStrings.userPageChangeLogin,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TODO dodać zawartość
                Text('Zmień login'),
              ],
            ),
          ),

          // === Zmień hasło ===
          ExpandableCard(
            title: ExpandableCardTitle(
              title: AppStrings.userPageChangePassword,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TODO dodać zawartość
                Text('Zmień hasło'),
              ],
            ),
          ),

          // === Pokaż swoje dane ===
          ExpandableCard(
            title: ExpandableCardTitle(
              title: AppStrings.userPageShowPersonalData,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TODO dodać zawartość
                Text('Jakieś dane'),
              ],
            ),
          ),

          LogoutCard(),

          // === Usuń konto ===
          ExpandableCard(
            title: ExpandableCardTitle(
              title: AppStrings.userPageDeleteAccount,
            ),
            errorCard: true,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TODO dodać zawartość
                Text('usuń konto'),
              ],
            ),
          ),

        ],
      )
    );
  }
}
