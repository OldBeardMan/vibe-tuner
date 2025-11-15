import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_tuner/constants/app_paths.dart';
import 'package:vibe_tuner/providers/auth_provider.dart';
import 'package:vibe_tuner/providers/camera_provider.dart';
import 'package:vibe_tuner/widgets/selected_emotion_dialog.dart';

import '../constants/app_sizes.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  late CameraProvider camProv;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    camProv = Provider.of<CameraProvider>(context, listen: false);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      camProv.tryInitIfNeeded(delay: const Duration(milliseconds: 300));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    camProv.reset();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.resumed) {
      camProv.tryInitIfNeeded(delay: const Duration(milliseconds: 150));
    } else if (state == AppLifecycleState.paused) {
      camProv.disposeController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            camProv.reset();
            context.go(AppPaths.homePage);
          },
        ),
      ),
      body: Consumer<CameraProvider>(
        builder: (context, p, _) {
          if (p.isPreviewMode) return _buildPreview(context, p);
          return _buildCamera(context, p);
        },
      ),
    );
  }

  Widget _buildCamera(BuildContext context, CameraProvider p) {
    final w = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Column(
        children: [
          Flexible(
            flex: 7,
            child: Center(
              child: Container(
                width: w * AppSizes.cameraPhotoSizeConversion,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.cameraPhotoBorderRadius),
                ),
                clipBehavior: Clip.hardEdge,
                child: p.isInitializing || p.controller == null || !p.controller!.value.isInitialized
                    ? const Center(child: CircularProgressIndicator())
                    : CameraPreview(p.controller!),
              ),
            ),
          ),

          SizedBox(
            height: AppSizes.cameraButtonSpaceHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.cameraButtonsPadding, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: (p.isBusy || p.isInitializing) ? null : p.pickFromGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    iconSize: AppSizes.cameraSideButtonSize,
                  ),

                  GestureDetector(
                    onTap: (p.isBusy || p.isInitializing) ? null : p.takePicture,
                    child: Container(
                      width: AppSizes.cameraPhotoButtonBorderSize,
                      height:  AppSizes.cameraPhotoButtonBorderSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: (p.isBusy || p.isInitializing) ? Colors.grey : Theme.of(context).colorScheme.onSurface, width: 3),
                      ),
                      child: Icon(Icons.camera_alt, size: AppSizes.cameraPhotoButtonSize, color: (p.isBusy || p.isInitializing) ? Colors.grey : Theme.of(context).colorScheme.onSurface),
                    ),
                  ),

                  IconButton(
                    onPressed: (p.isBusy || p.isInitializing) ? null : p.switchCamera,
                    icon: const Icon(Icons.cameraswitch),
                    iconSize: AppSizes.cameraSideButtonSize,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context, CameraProvider p) {
    final w = MediaQuery.of(context).size.width;

    Widget imageWidget;
    if (p.capturedFile == null) {
      imageWidget = const SizedBox.shrink();
    } else if (kIsWeb) {
      imageWidget = Image.network(p.capturedFile!.path, fit: BoxFit.cover);
    } else {
      imageWidget = Image.file(File(p.capturedFile!.path), fit: BoxFit.cover);
    }

    if (p.capturedIsFront) {
      imageWidget = Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(-1.0, 1.0, 1.0),
        child: imageWidget,
      );
    }

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              Flexible(
                flex: 7,
                child: Center(
                  child: Container(
                    width: w * AppSizes.cameraPhotoSizeConversion,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.cameraPhotoBorderRadius),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: imageWidget,
                  ),
                ),
              ),
              SizedBox(
                height: AppSizes.cameraButtonSpaceHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.cameraButtonsPadding, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: p.isBusy ? null : () {
                          p.retake();
                          p.init();
                        },
                        icon: const Icon(Icons.undo_outlined),
                        iconSize: AppSizes.cameraSideButtonSize,
                      ),
                      GestureDetector(
                        onTap: (p.isBusy || p.isSending) ? null : () {
                          try {
                            final String? token = context.read<AuthProvider>().token;
                            final Future<dynamic> sendFuture = p.sendCapturedImage(token: token);

                            p.reset();
                            context.go(AppPaths.homePage);

                            SchedulerBinding.instance.addPostFrameCallback((_) {
                              showGeneralDialog(
                                context: context,
                                barrierDismissible: true,
                                barrierLabel: 'SelectedEmotionDialog',
                                barrierColor: Colors.black.withValues(alpha: 0.4),
                                transitionDuration: const Duration(milliseconds: 220),
                                pageBuilder: (ctx, a1, a2) => Center(
                                  child: SelectedEmotionDialog(
                                    responseFuture: sendFuture,
                                    allowCorrection: true,
                                    authToken: token,
                                  ),
                                ),
                              );
                            });
                          } catch (e) {
                            debugPrint('send error: $e');
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Błąd wysyłania zdjęcia.')));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (p.isBusy || p.isSending) ? Colors.grey : Theme.of(context).colorScheme.onSurface,
                          ),
                          child: Icon(Icons.send, color: Theme.of(context).colorScheme.surface, size: AppSizes.cameraSideButtonSize),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
