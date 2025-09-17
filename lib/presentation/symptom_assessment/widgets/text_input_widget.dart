import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TextInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final Function(String)? onChanged;

  const TextInputWidget({
    Key? key,
    required this.controller,
    required this.hintText,
    this.maxLines = 4,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.borderSubtleLight,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: onChanged,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          color: AppTheme.textPrimaryLight,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textDisabledLight,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(4.w),
          counterStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryLight,
          ),
        ),
        maxLength: 500,
        buildCounter: (context,
            {required currentLength, required isFocused, maxLength}) {
          return Container(
            padding: EdgeInsets.only(right: 2.w, bottom: 1.h),
            alignment: Alignment.centerRight,
            child: Text(
              '$currentLength/${maxLength ?? 500}',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: currentLength > (maxLength ?? 500) * 0.8
                    ? AppTheme.warningLight
                    : AppTheme.textSecondaryLight,
              ),
            ),
          );
        },
      ),
    );
  }
}
