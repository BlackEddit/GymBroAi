import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  CameraController? get controller => _controller;

  Future<CameraController?> initializeCamera() async {
    try {
      // Get available cameras
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No cameras available');
      }

      // Use back camera for object detection
      final backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      // Initialize camera controller
      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();
      _isInitialized = true;

      return _controller;
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> dispose() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
      _isInitialized = false;
    }
  }

  Future<void> startImageStream(Function(CameraImage) onImageAvailable) async {
    if (_controller != null && _controller!.value.isInitialized) {
      await _controller!.startImageStream(onImageAvailable);
    }
  }

  Future<void> stopImageStream() async {
    if (_controller != null && _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
    }
  }

  Future<XFile?> takePicture() async {
    if (_controller != null && _controller!.value.isInitialized) {
      return await _controller!.takePicture();
    }
    return null;
  }

  Size? getCameraSize() {
    if (_controller != null && _controller!.value.isInitialized) {
      return _controller!.value.previewSize;
    }
    return null;
  }
}