import 'dart:async';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/chat_overlay_widget.dart';
import './widgets/consultation_status_bar_widget.dart';
import './widgets/consultation_summary_widget.dart';
import './widgets/prescription_notification_widget.dart';
import './widgets/screen_share_widget.dart';
import './widgets/video_call_controls_widget.dart';

class TelemedicineConsultation extends StatefulWidget {
  const TelemedicineConsultation({super.key});

  @override
  State<TelemedicineConsultation> createState() =>
      _TelemedicineConsultationState();
}

class _TelemedicineConsultationState extends State<TelemedicineConsultation>
    with TickerProviderStateMixin {
  // WebRTC components
  RTCPeerConnection? _peerConnection;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;

  // Camera components
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;

  // Call state
  bool _isMuted = false;
  bool _isCameraOn = true;
  bool _isSpeakerOn = true;
  bool _isConnected = false;
  String _connectionQuality = 'excellent';
  Timer? _callTimer;
  Duration _consultationDuration = Duration.zero;

  // UI state
  bool _isChatVisible = false;
  bool _isPrescriptionVisible = false;
  bool _isScreenSharing = false;
  bool _isConsultationComplete = false;
  bool _showSummary = false;

  // Draggable PiP position
  Offset _pipPosition = const Offset(20, 100);

  // Cost calculation
  final double _costPerMinute = 0.025; // SOL per minute

  // Mock doctor data
  final Map<String, dynamic> _doctorInfo = {
    "name": "Dr. Sarah Johnson",
    "specialty": "Internal Medicine",
    "avatar":
        "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&h=400&fit=crop&crop=face",
    "rating": 4.9,
    "experience": "15 years",
  };

  @override
  void initState() {
    super.initState();
    _initializeCall();
    _startCallTimer();
    _setSystemUIOverlay();
  }

  @override
  void dispose() {
    _cleanupCall();
    _restoreSystemUIOverlay();
    super.dispose();
  }

  void _setSystemUIOverlay() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void _restoreSystemUIOverlay() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  Future<void> _initializeCall() async {
    try {
      await _initializeRenderers();
      await _requestPermissions();
      await _initializeCamera();
      await _setupWebRTC();
      setState(() => _isConnected = true);
    } catch (e) {
      _showErrorDialog('Failed to initialize call: ${e.toString()}');
    }
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) return;

    await [
      Permission.camera,
      Permission.microphone,
    ].request();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        final camera = kIsWeb
            ? _cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.front,
                orElse: () => _cameras.first,
              )
            : _cameras.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.front,
                orElse: () => _cameras.first,
              );

        _cameraController = CameraController(
          camera,
          kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        );

        await _cameraController!.initialize();

        // Apply settings (skip unsupported features on web)
        try {
          await _cameraController!.setFocusMode(FocusMode.auto);
          if (!kIsWeb) {
            await _cameraController!.setFlashMode(FlashMode.auto);
          }
        } catch (e) {
          // Silently handle unsupported features
        }
      }
    } catch (e) {
      // Handle camera initialization failure gracefully
    }
  }

  Future<void> _setupWebRTC() async {
    try {
      final configuration = <String, dynamic>{
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ],
      };

      _peerConnection = await createPeerConnection(configuration);

      // Get user media
      final mediaConstraints = <String, dynamic>{
        'audio': true,
        'video': {
          'mandatory': {
            'minWidth': '640',
            'minHeight': '480',
            'minFrameRate': '30',
          },
          'facingMode': 'user',
          'optional': [],
        },
      };

      _localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;

      // Add local stream to peer connection
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      // Handle remote stream
      _peerConnection!.onAddStream = (MediaStream stream) {
        _remoteRenderer.srcObject = stream;
        setState(() {});
      };

      // Simulate doctor joining after 2 seconds
      Timer(const Duration(seconds: 2), () {
        _simulateDoctorJoining();
      });
    } catch (e) {
      // Handle WebRTC setup failure
    }
  }

  void _simulateDoctorJoining() {
    // In a real implementation, this would handle actual peer connection
    setState(() {
      _connectionQuality = 'excellent';
    });

    // Simulate prescription notification after 30 seconds
    Timer(const Duration(seconds: 30), () {
      setState(() => _isPrescriptionVisible = true);
    });
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _consultationDuration = Duration(seconds: timer.tick);
      });
    });
  }

  void _cleanupCall() {
    _callTimer?.cancel();
    _localStream?.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.dispose();
    _cameraController?.dispose();
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = !_isMuted;
    });
  }

  void _toggleCamera() {
    setState(() => _isCameraOn = !_isCameraOn);
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = _isCameraOn;
    });
  }

  void _toggleSpeaker() {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    // In a real implementation, this would switch audio output
  }

  void _endCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Consultation'),
        content: const Text('Are you sure you want to end this consultation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _finalizeConsultation();
            },
            child: const Text('End Call'),
          ),
        ],
      ),
    );
  }

  void _finalizeConsultation() {
    setState(() {
      _isConsultationComplete = true;
      _showSummary = true;
    });
    _callTimer?.cancel();
  }

  void _toggleChat() {
    setState(() => _isChatVisible = !_isChatVisible);
  }

  void _sendMessage(String message) {
    // In a real implementation, this would send the message via WebRTC data channel
  }

  void _toggleScreenShare() {
    setState(() => _isScreenSharing = !_isScreenSharing);
  }

  Future<void> _selectDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
      );

      if (result != null) {
        // In a real implementation, this would share the document via WebRTC
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document shared with doctor')),
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to select document');
    }
  }

  void _viewPrescriptionDetails() {
    setState(() => _isPrescriptionVisible = false);
    Navigator.pushNamed(context, '/health-profile-setup');
  }

  void _dismissPrescription() {
    setState(() => _isPrescriptionVisible = false);
  }

  void _viewRecording() {
    // In a real implementation, this would open the recording
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening session recording...')),
    );
  }

  void _viewPrescription() {
    Navigator.pushNamed(context, '/health-profile-setup');
  }

  void _viewReceipt() {
    Navigator.pushNamed(context, '/solana-wallet');
  }

  void _closeSummary() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main video view (doctor's feed)
          _buildMainVideoView(),

          // User's camera (draggable PiP)
          if (_isCameraOn) _buildPictureInPicture(),

          // Top status bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ConsultationStatusBarWidget(
              connectionQuality: _connectionQuality,
              consultationDuration: _consultationDuration,
              isRecording: false,
              costPerMinute: _costPerMinute,
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Screen share controls
                if (_isScreenSharing)
                  Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    child: ScreenShareWidget(
                      isSharing: _isScreenSharing,
                      onToggleShare: _toggleScreenShare,
                      onSelectDocument: _selectDocument,
                    ),
                  ),

                // Chat and additional controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSecondaryControl('chat', _toggleChat),
                    _buildSecondaryControl('screen_share', _toggleScreenShare),
                    _buildSecondaryControl('more_vert', () {}),
                  ],
                ),

                SizedBox(height: 1.h),

                // Main call controls
                VideoCallControlsWidget(
                  isMuted: _isMuted,
                  isCameraOn: _isCameraOn,
                  isSpeakerOn: _isSpeakerOn,
                  onMuteToggle: _toggleMute,
                  onCameraToggle: _toggleCamera,
                  onSpeakerToggle: _toggleSpeaker,
                  onEndCall: _endCall,
                ),
              ],
            ),
          ),

          // Chat overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ChatOverlayWidget(
              isVisible: _isChatVisible,
              onClose: () => setState(() => _isChatVisible = false),
              onSendMessage: _sendMessage,
            ),
          ),

          // Prescription notification
          PrescriptionNotificationWidget(
            isVisible: _isPrescriptionVisible,
            onViewDetails: _viewPrescriptionDetails,
            onDismiss: _dismissPrescription,
          ),

          // Consultation summary
          if (_showSummary)
            ConsultationSummaryWidget(
              isVisible: _showSummary,
              consultationDuration: _consultationDuration,
              totalCost: (_consultationDuration.inMinutes + 1) * _costPerMinute,
              onViewRecording: _viewRecording,
              onViewPrescription: _viewPrescription,
              onViewReceipt: _viewReceipt,
              onClose: _closeSummary,
            ),
        ],
      ),
    );
  }

  Widget _buildMainVideoView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: _isConnected && _remoteRenderer.srcObject != null
          ? RTCVideoView(_remoteRenderer, mirror: false)
          : Container(
              color: Colors.grey[900],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 15.w,
                      backgroundImage: NetworkImage(_doctorInfo["avatar"]),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _doctorInfo["name"],
                      style:
                          AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _doctorInfo["specialty"],
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    if (!_isConnected)
                      const CircularProgressIndicator(color: Colors.white)
                    else
                      Text(
                        'Connecting...',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPictureInPicture() {
    return Positioned(
      left: _pipPosition.dx,
      top: _pipPosition.dy,
      child: Draggable(
        feedback: _buildPiPContent(),
        childWhenDragging: Container(),
        onDragEnd: (details) {
          setState(() {
            _pipPosition = Offset(
              details.offset.dx
                  .clamp(0, MediaQuery.of(context).size.width - 30.w),
              details.offset.dy
                  .clamp(0, MediaQuery.of(context).size.height - 40.w),
            );
          });
        },
        child: _buildPiPContent(),
      ),
    );
  }

  Widget _buildPiPContent() {
    return Container(
      width: 30.w,
      height: 40.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.w),
        child: _localRenderer.srcObject != null
            ? RTCVideoView(_localRenderer, mirror: true)
            : _cameraController?.value.isInitialized == true
                ? CameraPreview(_cameraController!)
                : Container(
                    color: Colors.grey[800],
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'person',
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 8.w,
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildSecondaryControl(String iconName, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: iconName,
            color: Colors.white,
            size: 5.w,
          ),
        ),
      ),
    );
  }
}
