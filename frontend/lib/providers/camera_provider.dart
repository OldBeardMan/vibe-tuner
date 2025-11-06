import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_paths.dart';
import '../constants/app_strings.dart';
import '../models/analyze_result.dart';
import '../services/api_client.dart';

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
        debugPrint("CameraProvider.takePicture error: $e");
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
        debugPrint("CameraProvider.pickFromGallery error: $e");
      }
    });
  }

  Future<AnalyzeResult> sendCapturedImage({String? token}) async {
    final XFile? file = capturedFile;
    if (file == null) throw Exception('No image to send');

    isSending = true;
    notifyListeners();

    try {
      final uri = Uri.parse('${ApiClient.instance.baseUrl}${AppPaths.emotionAnalyze}');
      final originalBytes = await file.readAsBytes();
      final filename = p.basename(file.path);
      final initialMediaType = _guessImageMediaType(file.path);

      Future<http.Response> doSend(Uint8List bytes, String name, MediaType ct) async {
        final req = http.MultipartRequest('POST', uri);
        if (token?.isNotEmpty == true) req.headers['Authorization'] = 'Bearer $token';
        req.files.add(http.MultipartFile.fromBytes('image', bytes, filename: name, contentType: ct));
        final streamed = await req.send().timeout(const Duration(seconds: 30));
        return await http.Response.fromStream(streamed);
      }

      http.Response resp = await doSend(originalBytes, filename, initialMediaType);

      if (resp.statusCode == 400) {
        final bodyLower = resp.body.toLowerCase();
        if (bodyLower.contains('could not detect') || bodyLower.contains('no face') || bodyLower.contains('could not detect face')) {
          try {
            final decoded = img.decodeImage(originalBytes);
            if (decoded != null) {
              const int maxDim = 1600;
              img.Image proc = decoded;
              if (proc.width > maxDim || proc.height > maxDim) {
                proc = img.copyResize(proc,
                    width: proc.width > proc.height ? maxDim : null,
                    height: proc.height >= proc.width ? maxDim : null);
              }
              final jpgBytes = Uint8List.fromList(img.encodeJpg(proc, quality: 90));
              final jpgName = p.setExtension(filename, '.jpg');
              resp = await doSend(jpgBytes, jpgName, MediaType('image', 'jpeg'));
            }
          } catch (_) {
            debugPrint("CameraProvider.sendCapturedImage error: could not decode image");
          }
        }
      }

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        if (resp.body.isEmpty) {
          return AnalyzeResult(
            id: null,
            emotion: AppStrings.unknown,
            confidence: null,
            playlist: null,
            timestamp: DateTime.now(),
            raw: {'note': 'empty_body'},
          );
        }
        try {
          final Map<String, dynamic> j = jsonDecode(resp.body) as Map<String, dynamic>;
          return AnalyzeResult.fromJson(j);
        } catch (_) {
          return AnalyzeResult(
            id: -1,
            emotion: AppStrings.unknown,
            confidence: null,
            playlist: null,
            timestamp: DateTime.now(),
            raw: {'error': 'invalid_json', 'body': resp.body},
          );
        }
      }

      try {
        final Map<String, dynamic> j = jsonDecode(resp.body) as Map<String, dynamic>;
        if (j.containsKey('emotion') || j.containsKey('playlist') || j.containsKey('songs') || j.containsKey('emotionCode')) {
          return AnalyzeResult.fromJson(j);
        }
      } catch (_) {}
      return AnalyzeResult(
        id: -1,
        emotion: AppStrings.unknown,
        confidence: null,
        playlist: null,
        timestamp: DateTime.now(),
        raw: {'error': 'detection_failed'},
      );
    } on SocketException catch (_) {
      return AnalyzeResult(
        id: -1,
        emotion: AppStrings.unknown,
        confidence: null,
        playlist: null,
        timestamp: DateTime.now(),
        raw: {'error': 'network'},
      );
    } on TimeoutException catch (_) {
      return AnalyzeResult(
        id: -1,
        emotion: AppStrings.unknown,
        confidence: null,
        playlist: null,
        timestamp: DateTime.now(),
        raw: {'error': 'timeout'},
      );
    } catch (e) {
      return AnalyzeResult(
        id: -1,
        emotion: AppStrings.unknown,
        confidence: null,
        playlist: null,
        timestamp: DateTime.now(),
        raw: {'error': 'unknown', 'message': e.toString()},
      );
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  MediaType _guessImageMediaType(String path) {
    final l = path.toLowerCase();
    if (l.endsWith('.png')) return MediaType('image', 'png');
    if (l.endsWith('.jpg') || l.endsWith('.jpeg')) return MediaType('image', 'jpeg');
    if (l.endsWith('.webp')) return MediaType('image', 'webp');
    if (l.endsWith('.heic')) return MediaType('image', 'heic');
    if (l.endsWith('.avif')) return MediaType('image', 'avif');
    return MediaType('image', 'jpeg');
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
