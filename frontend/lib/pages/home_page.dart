import 'package:vibe_tuner/constants/app_paths.dart';
import 'package:vibe_tuner/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_sizes.dart';
import '../providers/emotion_provider.dart';
import '../widgets/emotion_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    final emoProv = Provider.of<EmotionProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.homePage,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: AppSizes.titleFontSize,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, size: 28),
            onPressed: () => context.push(AppPaths.userPage),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ikona aparatu
              Container(
                width: 160,
                height: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt_outlined, size: 100),
              ),
              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () {
                  context.go(AppPaths.cameraPage);
                },
                style:  ElevatedButton.styleFrom(
                  minimumSize: const Size(300, 12)
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(AppStrings.homePagePhotoButton,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const Text(AppStrings.homePageOr),
              const SizedBox(height: 12),
              const EmotionPicker(),
              const SizedBox(height: 16),

              if (emoProv.selectedEmotion != null)
                Text(
                  'Wybrana emocja: ${emoProv.selectedEmotion}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }
}