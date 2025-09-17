import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PaymentSettingsWidget extends StatefulWidget {
  final double autoPayLimit;
  final bool autoPayEnabled;
  final Function(double) onAutoPayLimitChanged;
  final Function(bool) onAutoPayToggle;
  final VoidCallback onManagePaymentMethods;

  const PaymentSettingsWidget({
    Key? key,
    required this.autoPayLimit,
    required this.autoPayEnabled,
    required this.onAutoPayLimitChanged,
    required this.onAutoPayToggle,
    required this.onManagePaymentMethods,
  }) : super(key: key);

  @override
  State<PaymentSettingsWidget> createState() => _PaymentSettingsWidgetState();
}

class _PaymentSettingsWidgetState extends State<PaymentSettingsWidget> {
  late TextEditingController _limitController;

  @override
  void initState() {
    super.initState();
    _limitController = TextEditingController(
      text: widget.autoPayLimit.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'payment',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Payment Settings',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildSettingItem(
            icon: 'auto_awesome',
            title: 'Auto-Pay for Consultations',
            subtitle: 'Automatically approve payments up to your set limit',
            trailing: Switch(
              value: widget.autoPayEnabled,
              onChanged: widget.onAutoPayToggle,
              activeColor: AppTheme.lightTheme.primaryColor,
            ),
          ),
          if (widget.autoPayEnabled) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auto-Pay Limit',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _limitController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            prefixText: '\$ ',
                            suffixText: 'USD',
                            hintText: '0.00',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 2.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppTheme.lightTheme.colorScheme.outline,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppTheme.lightTheme.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            final limit = double.tryParse(value) ?? 0.0;
                            widget.onAutoPayLimitChanged(limit);
                          },
                        ),
                      ),
                      SizedBox(width: 2.w),
                      ElevatedButton(
                        onPressed: () {
                          final limit =
                              double.tryParse(_limitController.text) ?? 0.0;
                          widget.onAutoPayLimitChanged(limit);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Auto-pay limit updated to \$${limit.toStringAsFixed(2)}'),
                              backgroundColor: AppTheme.successLight,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lightTheme.primaryColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 2.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Update',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Payments above this limit will require manual approval',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 2.h),
          _buildSettingItem(
            icon: 'credit_card',
            title: 'Payment Methods',
            subtitle: 'Manage linked cards and bank accounts for SOL purchases',
            trailing: CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: AppTheme.textSecondaryLight,
              size: 16,
            ),
            onTap: widget.onManagePaymentMethods,
          ),
          SizedBox(height: 2.h),
          _buildSettingItem(
            icon: 'analytics',
            title: 'Spending Analytics',
            subtitle: 'View your healthcare spending patterns and insights',
            trailing: CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: AppTheme.textSecondaryLight,
              size: 16,
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Analytics feature coming soon'),
                  backgroundColor: AppTheme.lightTheme.primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 2.w),
            trailing,
          ],
        ),
      ),
    );
  }
}
