import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class CameraProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  List<CameraDescription> cameras = [];
  CameraController? controller;
  int activeCameraIndex = 0;

  int _initAttempts = 0;
  static const int _maxInitAttempts = 3;

  bool isInitializing = true;
  bool isPreviewMode = false;
  XFile? capturedFile;
  bool isSending = false;
  bool capturedIsFront = false;

  // operation lock to avoid overlapping camera ops
  bool _isBusy = false;
  bool get isBusy => _isBusy;

  Future<void> _withLock(Future<void> Function() fn) async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    try {
      await fn();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> init() async {
    return _withLock(() async {
      capturedFile = null;
      isPreviewMode = false;
      isSending = false;
      capturedIsFront = false;
      notifyListeners();

      isInitializing = true;
      notifyListeners();

      try {
        final available = await availableCameras();
        cameras = available;
        activeCameraIndex = _findFrontCameraIndex(available) ?? 0;
        await _setupController(activeCameraIndex);
      } catch (e, st) {
        debugPrint('CameraProvider.init error: $e\n$st');
        await _disposeControllerImmediate();
        rethrow;
      } finally {
        isInitializing = false;
        notifyListeners();
      }
    });
  }

  int? _findFrontCameraIndex(List<CameraDescription> cams) {
    for (var i = 0; i < cams.length; i++) {
      if (cams[i].lensDirection == CameraLensDirection.front) return i;
    }
    return null;
  }

  Future<void> _setupController(int cameraIndex) async {
    await _disposeControllerImmediate();

    if (cameraIndex >= cameras.length) return;
    final desc = cameras[cameraIndex];
    final ctrl = CameraController(
      desc,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = ctrl;
    notifyListeners();

    try {
      await ctrl.initialize();
    } catch (e) {
      await _disposeControllerImmediate();
    }
    notifyListeners();
  }

  Future<void> _disposeControllerImmediate() async {
    final old = controller;
    controller = null;
    notifyListeners();
    if (old != null) {
      try {
        await old.dispose();
      } catch (_) {}
    }
  }

  Future<void> tryInitIfNeeded({Duration delay = const Duration(milliseconds: 250)}) async {
    if (controller != null && (controller!.value.isInitialized)) return;
    if (delay > Duration.zero) await Future.delayed(delay);

    _initAttempts++;
    try {
      await init();
      _initAttempts = 0;
    } catch (e) {
      if (_initAttempts < _maxInitAttempts) {
      } else {
        _initAttempts = 0;
      }
    }
  }

  Future<void> disposeController() async {
    await _disposeControllerImmediate();
  }

  Future<void> switchCamera() async {
    return _withLock(() async {
      if (cameras.length < 2) return;

      final currentDesc = controller?.description;
      int newIndex = (activeCameraIndex + 1) % cameras.length;

      if (currentDesc != null) {
        final desiredIndex = cameras.indexWhere((c) => c.lensDirection != currentDesc.lensDirection);
        if (desiredIndex >= 0) {
          newIndex = desiredIndex;
        }
      }
      activeCameraIndex = newIndex;
      isInitializing = true;
      notifyListeners();

      await _setupController(activeCameraIndex);

      isInitializing = false;
      notifyListeners();
    });
  }


  Future<void> takePicture() async {
    return _withLock(() async {
      if (controller == null || !controller!.value.isInitialized) return;
      try {
        final XFile file = await controller!.takePicture();
        capturedFile = file;
        capturedIsFront = (controller!.description.lensDirection == CameraLensDirection.front);
        isPreviewMode = true;
        notifyListeners();
      } catch (e) {
        // ignore
      }
    });
  }

  Future<void> pickFromGallery() async {
    return _withLock(() async {
      try {
        final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
        if (picked != null) {
          capturedFile = picked;
          capturedIsFront = false;
          isPreviewMode = true;
          notifyListeners();
        }
      } catch (e) {
        // ignore
      }
    });
  }

  Future<Uint8List> _prepareImageAsPngBytes(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.length >= 8 &&
          bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        return bytes; // already PNG
      }

      final decoded = img.decodeImage(bytes);
      if (decoded == null) return bytes;
      final png = img.encodePng(decoded);
      return Uint8List.fromList(png);
    } catch (e) {
      return await file.readAsBytes();
    }
  }

  // TODO
  Future<int> sendCapturedImage() async {
    final XFile? file = capturedFile; // lokalna kopia referencji
    if (file == null) throw Exception('No image to send');

    // oznaczamy, że trwa wysyłka (UI może blokować przycisk)
    isSending = true;
    notifyListeners();

    try {
      // opcjonalna sztuczna latencja (symulacja network)
      await Future.delayed(const Duration(milliseconds: 3000));

      // TU: jeśli chcesz, możesz wysłać prawdziwe bytes:
      // final bytes = await _prepareImageAsPngBytes(file);
      // await api.upload(bytes);

      // symulowana odpowiedź: odczytujemy plik JSON z assets
      const path = 'lib/assets/mock/response/recommended_emotion/emotion.json';
      try {
        final raw = await rootBundle.loadString(path);
        final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
        final int emotionCode = (json['emotionCode'] ?? 4) as int;
        return emotionCode;
      } catch (e) {
        // jeśli coś nie pójdzie z JSONem -> fallback na wartość domyślną
        return 4;
      }
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  void retake() {
    capturedFile = null;
    isPreviewMode = false;
    capturedIsFront = false;
    notifyListeners();
    if (controller == null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        init();
      });
    }
  }

  void reset() {
    capturedFile = null;
    isPreviewMode = false;
    isSending = false;
    capturedIsFront = false;
    notifyListeners();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _disposeControllerImmediate();
    });
  }

  @override
  void dispose() {
    try {
      controller?.dispose();
    } catch (_) {}
    controller = null;
    super.dispose();
  }
}
