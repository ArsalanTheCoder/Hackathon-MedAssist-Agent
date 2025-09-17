import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BalanceCardWidget extends StatelessWidget {
  final double solBalance;
  final double usdValue;
  final VoidCallback onAddFunds;
  final VoidCallback onSendSol;

  const BalanceCardWidget({
    Key? key,
    required this.solBalance,
    required this.usdValue,
    required this.onAddFunds,
    required this.onSendSol,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.primaryColor,
            AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Wallet Balance',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              CustomIconWidget(
                iconName: 'account_balance_wallet',
                color: Colors.white.withValues(alpha: 0.9),
                size: 24,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            '${solBalance.toStringAsFixed(4)} SOL',
            style: AppTheme.lightTheme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 32.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            '\$${usdValue.toStringAsFixed(2)} USD',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAddFunds,
                  icon: CustomIconWidget(
                    iconName: 'add',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 20,
                  ),
                  label: Text(
                    'Add Funds',
                    style: TextStyle(
                      color: AppTheme.lightTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.lightTheme.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSendSol,
                  icon: CustomIconWidget(
                    iconName: 'send',
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    'Send SOL',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
