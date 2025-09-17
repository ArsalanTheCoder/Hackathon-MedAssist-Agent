import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CameraCaptureWidget extends StatefulWidget {
  final Function(XFile) onImageCaptured;
  final bool isEnabled;

  const CameraCaptureWidget({
    Key? key,
    required this.onImageCaptured,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<CameraCaptureWidget> createState() => _CameraCaptureWidgetState();
}

class _CameraCaptureWidgetState extends State<CameraCaptureWidget> {
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isInitializing = false;
  XFile? _capturedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.isEnabled) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _initializeCamera() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
    });

    try {
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        _showPermissionDialog();
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _showErrorDialog('No cameras available on this device.');
        return;
      }

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
      );

      await _cameraController!.initialize();

      // Apply platform-specific settings
      await _applySettings();

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      _showErrorDialog('Failed to initialize camera. Please try again.');
    } finally {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);

      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          // Flash not supported, continue without it
        }
      }
    } catch (e) {
      // Settings not supported, continue without them
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = photo;
      });
      widget.onImageCaptured(photo);
    } catch (e) {
      _showErrorDialog('Failed to capture photo. Please try again.');
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImage = image;
        });
        widget.onImageCaptured(image);
      }
    } catch (e) {
      _showErrorDialog('Failed to select image from gallery.');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Camera Permission Required',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimaryLight,
          ),
        ),
        content: Text(
          'To capture photos of your symptoms, please allow camera access in your device settings.',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondaryLight),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Camera Error',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.errorLight,
          ),
        ),
        content: Text(
          message,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimaryLight,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'security',
              color: AppTheme.warningLight,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                'Privacy Notice',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.warningLight,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your privacy is important to us:',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              '• Photos are stored securely on your device\n'
              '• Images are encrypted during transmission\n'
              '• Only you and your healthcare provider can access them\n'
              '• You can delete photos at any time',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimaryLight,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondaryLight),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeCamera();
            },
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderSubtleLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Privacy warning header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.warningLight.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'security',
                  color: AppTheme.warningLight,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Photos are encrypted and stored securely',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.warningLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _showPrivacyWarning,
                  child: CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.warningLight,
                    size: 4.w,
                  ),
                ),
              ],
            ),
          ),

          // Camera preview or captured image
          Container(
            width: double.infinity,
            height: 40.h,
            child: _capturedImage != null
                ? Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: kIsWeb
                            ? Image.network(
                                _capturedImage!.path,
                                fit: BoxFit.cover,
                              )
                            : CustomImageWidget(
                                imageUrl: _capturedImage!.path,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        top: 2.h,
                        right: 2.w,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _capturedImage = null;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                            child: CustomIconWidget(
                              iconName: 'close',
                              color: Colors.white,
                              size: 5.w,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : _isCameraInitialized && _cameraController != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CameraPreview(_cameraController!),
                      )
                    : Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme
                              .lightTheme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isInitializing) ...[
                              const CircularProgressIndicator(),
                              SizedBox(height: 2.h),
                              Text(
                                'Initializing camera...',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme.textSecondaryLight,
                                ),
                              ),
                            ] else ...[
                              CustomIconWidget(
                                iconName: 'camera_alt',
                                color: AppTheme.textSecondaryLight,
                                size: 15.w,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Camera not initialized',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme.textSecondaryLight,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
          ),

          // Action buttons
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.isEnabled ? _selectFromGallery : null,
                    icon: CustomIconWidget(
                      iconName: 'photo_library',
                      color: Colors.white,
                      size: 4.w,
                    ),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppTheme.lightTheme.colorScheme.secondary,
                      foregroundColor: AppTheme.textPrimaryLight,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.isEnabled && _isCameraInitialized
                        ? _capturePhoto
                        : widget.isEnabled
                            ? _initializeCamera
                            : null,
                    icon: CustomIconWidget(
                      iconName: _isCameraInitialized ? 'camera_alt' : 'refresh',
                      color: Colors.white,
                      size: 4.w,
                    ),
                    label:
                        Text(_isCameraInitialized ? 'Capture' : 'Initialize'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
