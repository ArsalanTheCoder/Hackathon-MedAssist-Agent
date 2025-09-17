import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MultipleChoiceWidget extends StatelessWidget {
  final List<String> options;
  final String? selectedOption;
  final Function(String) onOptionSelected;

  const MultipleChoiceWidget({
    Key? key,
    required this.options,
    this.selectedOption,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) {
        final isSelected = selectedOption == option;
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 2.h),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onOptionSelected(option),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryLight.withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.secondaryContainer,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryLight
                        : AppTheme.borderSubtleLight,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryLight
                              : AppTheme.textSecondaryLight,
                          width: 2,
                        ),
                        color: isSelected
                            ? AppTheme.primaryLight
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : null,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        option,
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          color: isSelected
                              ? AppTheme.primaryLight
                              : AppTheme.textPrimaryLight,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
