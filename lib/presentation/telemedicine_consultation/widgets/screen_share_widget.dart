import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ScreenShareWidget extends StatelessWidget {
  final bool isSharing;
  final VoidCallback onToggleShare;
  final VoidCallback onSelectDocument;

  const ScreenShareWidget({
    super.key,
    required this.isSharing,
    required this.onToggleShare,
    required this.onSelectDocument,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
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
              Text(
                'Screen Share',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: isSharing,
                onChanged: (_) => onToggleShare(),
                activeColor: AppTheme.lightTheme.colorScheme.primary,
              ),
            ],
          ),
          if (isSharing) ...[
            SizedBox(height: 2.h),
            _buildShareOptions(),
          ],
        ],
      ),
    );
  }

  Widget _buildShareOptions() {
    return Column(
      children: [
        _buildShareOption(
          iconName: 'description',
          title: 'Share Document',
          subtitle: 'Share medical reports or prescriptions',
          onTap: onSelectDocument,
        ),
        SizedBox(height: 1.h),
        _buildShareOption(
          iconName: 'camera_alt',
          title: 'Share Photo',
          subtitle: 'Share symptom photos or medical images',
          onTap: () {}, // Placeholder for photo sharing
        ),
      ],
    );
  }

  Widget _buildShareOption({
    required String iconName,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primaryContainer
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(2.w),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: iconName,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 5.w,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
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
}
