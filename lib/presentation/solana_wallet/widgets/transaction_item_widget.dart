import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TransactionItemWidget extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onTap;
  final VoidCallback onViewReceipt;

  const TransactionItemWidget({
    Key? key,
    required this.transaction,
    required this.onTap,
    required this.onViewReceipt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String type = transaction['type'] as String;
    final String status = transaction['status'] as String;
    final double amount = transaction['amount'] as double;
    final String providerName = transaction['providerName'] as String;
    final DateTime timestamp = transaction['timestamp'] as DateTime;
    final bool isIncoming = type == 'received';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: isIncoming
                        ? AppTheme.successLight.withValues(alpha: 0.1)
                        : AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: isIncoming ? 'arrow_downward' : 'arrow_upward',
                    color: isIncoming
                        ? AppTheme.successLight
                        : AppTheme.lightTheme.primaryColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        providerName,
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        _formatTimestamp(timestamp),
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isIncoming ? '+' : '-'}${amount.toStringAsFixed(4)} SOL',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: isIncoming
                            ? AppTheme.successLight
                            : AppTheme.lightTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.w600,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTap,
                    icon: CustomIconWidget(
                      iconName: 'open_in_new',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 16,
                    ),
                    label: Text(
                      'View on Explorer',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      side: BorderSide(
                        color: AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onViewReceipt,
                    icon: CustomIconWidget(
                      iconName: 'receipt',
                      color: Colors.white,
                      size: 16,
                    ),
                    label: Text(
                      'Receipt',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.successLight;
      case 'pending':
        return AppTheme.warningLight;
      case 'failed':
        return AppTheme.errorLight;
      default:
        return AppTheme.textSecondaryLight;
    }
  }
}
