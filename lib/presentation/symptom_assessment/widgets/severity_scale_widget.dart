import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SeverityScaleWidget extends StatelessWidget {
  final double value;
  final Function(double) onChanged;
  final String minLabel;
  final String maxLabel;

  const SeverityScaleWidget({
    Key? key,
    required this.value,
    required this.onChanged,
    this.minLabel = "Mild",
    this.maxLabel = "Severe",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                minLabel,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getSeverityColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getSeverityColor(),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${(value * 10).round()}/10',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: _getSeverityColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                maxLabel,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _getSeverityColor(),
            thumbColor: _getSeverityColor(),
            overlayColor: _getSeverityColor().withValues(alpha: 0.2),
            inactiveTrackColor:
                AppTheme.lightTheme.colorScheme.secondaryContainer,
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: value,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            onChanged: onChanged,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(10, (index) {
              return Text(
                '${index + 1}',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textDisabledLight,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor() {
    if (value <= 0.3) return AppTheme.successLight;
    if (value <= 0.7) return AppTheme.warningLight;
    return AppTheme.errorLight;
  }
}
