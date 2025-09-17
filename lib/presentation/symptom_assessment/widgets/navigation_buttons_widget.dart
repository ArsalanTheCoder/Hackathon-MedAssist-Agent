import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NavigationButtonsWidget extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final bool canGoBack;
  final bool canGoNext;
  final bool canSkip;
  final bool isLoading;
  final String nextButtonText;

  const NavigationButtonsWidget({
    Key? key,
    this.onPrevious,
    this.onNext,
    this.onSkip,
    this.canGoBack = true,
    this.canGoNext = true,
    this.canSkip = false,
    this.isLoading = false,
    this.nextButtonText = 'Next',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canSkip) ...[
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 2.h),
                child: TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                  child: Text(
                    'Skip Question',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryLight,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
            Row(
              children: [
                if (canGoBack) ...[
                  Expanded(
                    flex: 1,
                    child: OutlinedButton.icon(
                      onPressed: onPrevious,
                      icon: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: AppTheme.primaryLight,
                        size: 4.w,
                      ),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                ],
                Expanded(
                  flex: canGoBack ? 2 : 1,
                  child: ElevatedButton(
                    onPressed: canGoNext && !isLoading ? onNext : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                    child: isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 4.w,
                                height: 4.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              const Text('Processing...'),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(nextButtonText),
                              SizedBox(width: 2.w),
                              CustomIconWidget(
                                iconName:
                                    nextButtonText == 'Complete Assessment'
                                        ? 'check_circle'
                                        : 'arrow_forward',
                                color: Colors.white,
                                size: 4.w,
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
