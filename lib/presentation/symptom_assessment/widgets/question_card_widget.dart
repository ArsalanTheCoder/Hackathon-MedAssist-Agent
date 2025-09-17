import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuestionCardWidget extends StatelessWidget {
  final String question;
  final String? description;
  final Widget child;
  final bool showMedicalIllustration;
  final String? illustrationUrl;

  const QuestionCardWidget({
    Key? key,
    required this.question,
    this.description,
    required this.child,
    this.showMedicalIllustration = false,
    this.illustrationUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showMedicalIllustration && illustrationUrl != null) ...[
            Container(
              width: double.infinity,
              height: 20.h,
              margin: EdgeInsets.only(bottom: 3.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.lightTheme.colorScheme.secondaryContainer,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  imageUrl: illustrationUrl!,
                  width: double.infinity,
                  height: 20.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
          Text(
            question,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          if (description != null) ...[
            SizedBox(height: 1.h),
            Text(
              description!,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ],
          SizedBox(height: 3.h),
          child,
        ],
      ),
    );
  }
}
