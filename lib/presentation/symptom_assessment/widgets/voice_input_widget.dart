import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VoiceInputWidget extends StatefulWidget {
  final Function(String) onTranscriptionComplete;
  final bool isEnabled;

  const VoiceInputWidget({
    Key? key,
    required this.onTranscriptionComplete,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget>
    with TickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _recordingPath;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<bool> _requestMicrophonePermission() async {
    if (kIsWeb) return true;

    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _startRecording() async {
    if (!widget.isEnabled || _isRecording) return;

    final hasPermission = await _requestMicrophonePermission();
    if (!hasPermission) {
      _showPermissionDialog();
      return;
    }

    try {
      if (await _audioRecorder.hasPermission()) {
        setState(() {
          _isRecording = true;
        });

        _pulseController.repeat(reverse: true);

        if (kIsWeb) {
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.wav),
            path: 'recording.wav',
          );
        } else {
          final dir = await getTemporaryDirectory();
          _recordingPath =
              '${dir.path}/symptom_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: _recordingPath!,
          );
        }
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      _pulseController.stop();
      _showErrorDialog('Failed to start recording. Please try again.');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      _pulseController.stop();
      _pulseController.reset();

      if (path != null) {
        // Simulate transcription processing
        await Future.delayed(const Duration(seconds: 2));

        // Mock transcription result
        const mockTranscription =
            "I have been experiencing headaches and nausea for the past two days. The pain is moderate and gets worse in the evening.";

        widget.onTranscriptionComplete(mockTranscription);
      }
    } catch (e) {
      _showErrorDialog('Failed to process recording. Please try again.');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Microphone Permission Required',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimaryLight,
          ),
        ),
        content: Text(
          'To use voice input for symptom description, please allow microphone access in your device settings.',
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
          'Recording Error',
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _isRecording ? AppTheme.primaryLight : AppTheme.borderSubtleLight,
          width: _isRecording ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'mic',
                color: AppTheme.primaryLight,
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  _isRecording
                      ? 'Recording... Tap to stop'
                      : _isProcessing
                          ? 'Processing your recording...'
                          : 'Tap to describe your symptoms with voice',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimaryLight,
                    fontWeight:
                        _isRecording ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          GestureDetector(
            onTap: widget.isEnabled
                ? (_isRecording ? _stopRecording : _startRecording)
                : null,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isRecording ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording
                          ? AppTheme.errorLight
                          : _isProcessing
                              ? AppTheme.warningLight
                              : AppTheme.primaryLight,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording
                                  ? AppTheme.errorLight
                                  : AppTheme.primaryLight)
                              .withValues(alpha: 0.3),
                          blurRadius: _isRecording ? 20 : 8,
                          spreadRadius: _isRecording ? 4 : 0,
                        ),
                      ],
                    ),
                    child: _isProcessing
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Center(
                            child: CustomIconWidget(
                              iconName: _isRecording ? 'stop' : 'mic',
                              color: Colors.white,
                              size: 8.w,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            _isRecording
                ? 'Recording in progress...'
                : _isProcessing
                    ? 'Converting speech to text...'
                    : 'Tap the microphone to start',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
