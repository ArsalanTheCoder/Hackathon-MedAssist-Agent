import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ConsultationStatusBarWidget extends StatelessWidget {
  final String connectionQuality;
  final Duration consultationDuration;
  final bool isRecording;
  final double costPerMinute;

  const ConsultationStatusBarWidget({
    super.key,
    required this.connectionQuality,
    required this.consultationDuration,
    required this.isRecording,
    required this.costPerMinute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildConnectionIndicator(),
            _buildTimerAndCost(),
            if (isRecording) _buildRecordingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionIndicator() {
    Color indicatorColor;
    String qualityText;

    switch (connectionQuality.toLowerCase()) {
      case 'excellent':
        indicatorColor = AppTheme.lightTheme.colorScheme.tertiary;
        qualityText = 'Excellent';
        break;
      case 'good':
        indicatorColor = Colors.green;
        qualityText = 'Good';
        break;
      case 'fair':
        indicatorColor = Colors.orange;
        qualityText = 'Fair';
        break;
      case 'poor':
        indicatorColor = AppTheme.lightTheme.colorScheme.error;
        qualityText = 'Poor';
        break;
      default:
        indicatorColor = Colors.grey;
        qualityText = 'Unknown';
    }

    return Row(
      children: [
        Container(
          width: 2.w,
          height: 2.w,
          decoration: BoxDecoration(
            color: indicatorColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          qualityText,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerAndCost() {
    final minutes = consultationDuration.inMinutes;
    final seconds = consultationDuration.inSeconds % 60;
    final totalCost = (consultationDuration.inMinutes + 1) * costPerMinute;

    return Column(
      children: [
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '\$${totalCost.toStringAsFixed(3)} SOL',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingIndicator() {
    return Row(
      children: [
        Container(
          width: 2.w,
          height: 2.w,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          'REC',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
