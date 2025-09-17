import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConsultationSummaryWidget extends StatelessWidget {
  final bool isVisible;
  final Duration consultationDuration;
  final double totalCost;
  final VoidCallback onViewRecording;
  final VoidCallback onViewPrescription;
  final VoidCallback onViewReceipt;
  final VoidCallback onClose;

  const ConsultationSummaryWidget({
    super.key,
    required this.isVisible,
    required this.consultationDuration,
    required this.totalCost,
    required this.onViewRecording,
    required this.onViewPrescription,
    required this.onViewReceipt,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          width: 90.w,
          constraints: BoxConstraints(maxHeight: 80.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(4.w),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    children: [
                      _buildSummaryCard(),
                      SizedBox(height: 3.h),
                      _buildActionButtons(),
                      SizedBox(height: 3.h),
                      _buildFollowUpInstructions(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4.w),
          topRight: Radius.circular(4.w),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Consultation Complete',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 6.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final minutes = consultationDuration.inMinutes;
    final seconds = consultationDuration.inSeconds % 60;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                'Duration',
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                'schedule',
              ),
              _buildSummaryItem(
                'Total Cost',
                '\$${totalCost.toStringAsFixed(3)} SOL',
                'payments',
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                'Doctor',
                'Dr. Sarah Johnson',
                'person',
              ),
              _buildSummaryItem(
                'Date',
                '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                'calendar_today',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, String iconName) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 6.w,
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildActionButton(
          'View Session Recording',
          'play_circle_filled',
          onViewRecording,
        ),
        SizedBox(height: 2.h),
        _buildActionButton(
          'View Prescription Details',
          'medical_services',
          onViewPrescription,
        ),
        SizedBox(height: 2.h),
        _buildActionButton(
          'Download Payment Receipt',
          'receipt',
          onViewReceipt,
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, String iconName, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(2.w),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                title,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.5),
              size: 4.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowUpInstructions() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.tertiaryContainer
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color:
              AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Follow-up Instructions',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            '• Take prescribed medication as directed\n• Monitor symptoms and report any changes\n• Schedule follow-up appointment in 1 week\n• Contact emergency services if symptoms worsen',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
