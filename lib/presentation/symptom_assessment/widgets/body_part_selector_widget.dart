import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BodyPartSelectorWidget extends StatelessWidget {
  final List<String> selectedParts;
  final Function(String) onPartToggled;

  const BodyPartSelectorWidget({
    Key? key,
    required this.selectedParts,
    required this.onPartToggled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bodyParts = [
      {
        'name': 'Head',
        'position': {'top': 5.0, 'left': 42.0}
      },
      {
        'name': 'Neck',
        'position': {'top': 15.0, 'left': 42.0}
      },
      {
        'name': 'Chest',
        'position': {'top': 25.0, 'left': 42.0}
      },
      {
        'name': 'Left Arm',
        'position': {'top': 25.0, 'left': 25.0}
      },
      {
        'name': 'Right Arm',
        'position': {'top': 25.0, 'left': 59.0}
      },
      {
        'name': 'Abdomen',
        'position': {'top': 40.0, 'left': 42.0}
      },
      {
        'name': 'Back',
        'position': {'top': 55.0, 'left': 42.0}
      },
      {
        'name': 'Left Leg',
        'position': {'top': 65.0, 'left': 35.0}
      },
      {
        'name': 'Right Leg',
        'position': {'top': 65.0, 'left': 49.0}
      },
    ];

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 50.h,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderSubtleLight,
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Human body silhouette background
              Center(
                child: CustomImageWidget(
                  imageUrl:
                      "https://images.unsplash.com/photo-1559757148-5c350d0d3c56?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
                  width: 60.w,
                  height: 45.h,
                  fit: BoxFit.contain,
                ),
              ),
              // Body part selection points
              ...bodyParts.map((part) {
                final isSelected =
                    selectedParts.contains(part['name'] as String);
                final position = part['position'] as Map<String, double>;

                return Positioned(
                  top: (position['top']! / 100) * 50.h,
                  left: (position['left']! / 100) * 100.w,
                  child: GestureDetector(
                    onTap: () => onPartToggled(part['name'] as String),
                    child: Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppTheme.errorLight
                            : AppTheme.primaryLight.withValues(alpha: 0.7),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: isSelected ? 'close' : 'add',
                          color: Colors.white,
                          size: 4.w,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        SizedBox(height: 3.h),
        if (selectedParts.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primaryLight,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Areas:',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: selectedParts.map((part) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            part,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          GestureDetector(
                            onTap: () => onPartToggled(part),
                            child: CustomIconWidget(
                              iconName: 'close',
                              color: Colors.white,
                              size: 3.w,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
