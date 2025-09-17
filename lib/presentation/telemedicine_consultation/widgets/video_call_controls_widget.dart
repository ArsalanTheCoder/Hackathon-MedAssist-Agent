import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VideoCallControlsWidget extends StatelessWidget {
  final bool isMuted;
  final bool isCameraOn;
  final bool isSpeakerOn;
  final VoidCallback onMuteToggle;
  final VoidCallback onCameraToggle;
  final VoidCallback onSpeakerToggle;
  final VoidCallback onEndCall;

  const VideoCallControlsWidget({
    super.key,
    required this.isMuted,
    required this.isCameraOn,
    required this.isSpeakerOn,
    required this.onMuteToggle,
    required this.onCameraToggle,
    required this.onSpeakerToggle,
    required this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            iconName: isMuted ? 'mic_off' : 'mic',
            isActive: !isMuted,
            onTap: onMuteToggle,
            backgroundColor: isMuted
                ? AppTheme.lightTheme.colorScheme.error
                : AppTheme.lightTheme.colorScheme.surface,
          ),
          _buildControlButton(
            iconName: isCameraOn ? 'videocam' : 'videocam_off',
            isActive: isCameraOn,
            onTap: onCameraToggle,
            backgroundColor: !isCameraOn
                ? AppTheme.lightTheme.colorScheme.error
                : AppTheme.lightTheme.colorScheme.surface,
          ),
          _buildControlButton(
            iconName: isSpeakerOn ? 'volume_up' : 'volume_down',
            isActive: isSpeakerOn,
            onTap: onSpeakerToggle,
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          ),
          _buildControlButton(
            iconName: 'call_end',
            isActive: false,
            onTap: onEndCall,
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            isEndCall: true,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String iconName,
    required bool isActive,
    required VoidCallback onTap,
    required Color backgroundColor,
    bool isEndCall = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 14.w,
        height: 14.w,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: iconName,
            color: isEndCall
                ? Colors.white
                : isActive
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
      ),
    );
  }
}
