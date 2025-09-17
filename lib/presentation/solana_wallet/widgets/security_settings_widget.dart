import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SecuritySettingsWidget extends StatefulWidget {
  final bool isBackedUp;
  final bool biometricEnabled;
  final Function(bool) onBiometricToggle;
  final VoidCallback onBackupWallet;
  final VoidCallback onViewSeedPhrase;

  const SecuritySettingsWidget({
    Key? key,
    required this.isBackedUp,
    required this.biometricEnabled,
    required this.onBiometricToggle,
    required this.onBackupWallet,
    required this.onViewSeedPhrase,
  }) : super(key: key);

  @override
  State<SecuritySettingsWidget> createState() => _SecuritySettingsWidgetState();
}

class _SecuritySettingsWidgetState extends State<SecuritySettingsWidget> {
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
                iconName: 'security',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Security Settings',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildSecurityItem(
            icon: 'backup',
            title: 'Wallet Backup',
            subtitle: widget.isBackedUp
                ? 'Your wallet is safely backed up'
                : 'Backup your wallet to secure your funds',
            trailing: widget.isBackedUp
                ? Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.successLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'check_circle',
                          color: AppTheme.successLight,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Backed Up',
                          style: AppTheme.getSuccessTextStyle(
                            isLight: true,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ElevatedButton(
                    onPressed: widget.onBackupWallet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.warningLight,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Backup Now',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
            onTap: widget.isBackedUp
                ? widget.onViewSeedPhrase
                : widget.onBackupWallet,
          ),
          SizedBox(height: 2.h),
          _buildSecurityItem(
            icon: 'fingerprint',
            title: 'Biometric Authentication',
            subtitle:
                'Use fingerprint or face recognition to secure your wallet',
            trailing: Switch(
              value: widget.biometricEnabled,
              onChanged: widget.onBiometricToggle,
              activeColor: AppTheme.lightTheme.primaryColor,
            ),
            onTap: () => widget.onBiometricToggle(!widget.biometricEnabled),
          ),
          SizedBox(height: 2.h),
          _buildSecurityItem(
            icon: 'vpn_key',
            title: 'Seed Phrase',
            subtitle: 'View or manage your wallet recovery phrase',
            trailing: CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: AppTheme.textSecondaryLight,
              size: 16,
            ),
            onTap: widget.onViewSeedPhrase,
          ),
          SizedBox(height: 3.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.warningLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.warningLight.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'warning',
                  color: AppTheme.warningLight,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Never share your seed phrase with anyone. MedAssist247 will never ask for it.',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.warningLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityItem({
    required String icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
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
