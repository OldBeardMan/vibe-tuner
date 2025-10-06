import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_tuner/constants/app_paths.dart';
import 'package:vibe_tuner/constants/app_strings.dart';

import '../constants/app_sizes.dart';
import '../constants/mock/history_card_mock.dart';

/*

// TODO DODAĆ STRINGI ===============

 */
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.history,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: AppSizes.titleFontSize,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push(AppPaths.userPage),
            icon: const Icon(Icons.person_outline, size: AppSizes.titleFontSize),
          )
        ],
      ),

      body: ListView.builder(
        itemCount: historyCardMockedData.length >= 7 ? 7 : historyCardMockedData.length,
        itemBuilder: (context, index) => historyCardMockedData[index],
      ),
    );
  }
}
