import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class YesNoToggleWidget extends StatelessWidget {
  final bool? value;
  final Function(bool) onChanged;

  const YesNoToggleWidget({
    Key? key,
    this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onChanged(true),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: value == true
                      ? AppTheme.successLight
                      : AppTheme.lightTheme.colorScheme.secondaryContainer,
                  border: Border.all(
                    color: value == true
                        ? AppTheme.successLight
                        : AppTheme.borderSubtleLight,
                    width: value == true ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'check_circle',
                      color: value == true
                          ? Colors.white
                          : AppTheme.textSecondaryLight,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Yes',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: value == true
                            ? Colors.white
                            : AppTheme.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onChanged(false),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: value == false
                      ? AppTheme.errorLight
                      : AppTheme.lightTheme.colorScheme.secondaryContainer,
                  border: Border.all(
                    color: value == false
                        ? AppTheme.errorLight
                        : AppTheme.borderSubtleLight,
                    width: value == false ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'cancel',
                      color: value == false
                          ? Colors.white
                          : AppTheme.textSecondaryLight,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'No',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: value == false
                            ? Colors.white
                            : AppTheme.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
