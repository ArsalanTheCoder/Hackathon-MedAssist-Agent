import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FacilityCardWidget extends StatelessWidget {
  final Map<String, dynamic> facility;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onDirections;
  final VoidCallback? onFavorite;

  const FacilityCardWidget({
    Key? key,
    required this.facility,
    this.onTap,
    this.onCall,
    this.onDirections,
    this.onFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String facilityType =
        (facility['type'] as String? ?? 'hospital').toLowerCase();
    final bool isFavorite = facility['isFavorite'] as bool? ?? false;
    final double rating = (facility['rating'] as num?)?.toDouble() ?? 0.0;
    final int waitTime = facility['waitTime'] as int? ?? 0;
    final bool isOpen = facility['isOpen'] as bool? ?? true;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceElevatedDark
            : AppTheme.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: _getFacilityColor(facilityType)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: _getFacilityIcon(facilityType),
                          color: _getFacilityColor(facilityType),
                          size: 6.w,
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            facility['name'] as String? ?? 'Unknown Facility',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'location_on',
                                color: isDark
                                    ? AppTheme.textSecondaryDark
                                    : AppTheme.textSecondaryLight,
                                size: 4.w,
                              ),
                              SizedBox(width: 1.w),
                              Expanded(
                                child: Text(
                                  '${facility['distance'] ?? '0.0'} km away',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onFavorite,
                      icon: CustomIconWidget(
                        iconName: isFavorite ? 'favorite' : 'favorite_border',
                        color: isFavorite
                            ? (isDark
                                ? AppTheme.errorDark
                                : AppTheme.errorLight)
                            : (isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight),
                        size: 5.w,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    if (rating > 0) ...[
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'star',
                            color: Colors.amber,
                            size: 4.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            rating.toStringAsFixed(1),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ],
                      ),
                      SizedBox(width: 4.w),
                    ],
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: isOpen
                            ? (isDark
                                    ? AppTheme.successDark
                                    : AppTheme.successLight)
                                .withValues(alpha: 0.1)
                            : (isDark
                                    ? AppTheme.errorDark
                                    : AppTheme.errorLight)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isOpen ? 'Open' : 'Closed',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isOpen
                                  ? (isDark
                                      ? AppTheme.successDark
                                      : AppTheme.successLight)
                                  : (isDark
                                      ? AppTheme.errorDark
                                      : AppTheme.errorLight),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    if (waitTime > 0) ...[
                      SizedBox(width: 3.w),
                      Text(
                        '${waitTime}min wait',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppTheme.warningDark
                                  : AppTheme.warningLight,
                            ),
                      ),
                    ],
                  ],
                ),
                if (facility['address'] != null) ...[
                  SizedBox(height: 1.h),
                  Text(
                    facility['address'] as String,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onCall,
                        icon: CustomIconWidget(
                          iconName: 'phone',
                          color: isDark
                              ? AppTheme.primaryDark
                              : AppTheme.primaryLight,
                          size: 4.w,
                        ),
                        label: Text('Call'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onDirections,
                        icon: CustomIconWidget(
                          iconName: 'directions',
                          color: isDark
                              ? AppTheme.onPrimaryDark
                              : AppTheme.onPrimaryLight,
                          size: 4.w,
                        ),
                        label: Text('Directions'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFacilityIcon(String type) {
    switch (type) {
      case 'hospital':
        return 'local_hospital';
      case 'pharmacy':
        return 'local_pharmacy';
      case 'urgent_care':
        return 'medical_services';
      case 'specialist':
        return 'person';
      case 'clinic':
        return 'healing';
      default:
        return 'local_hospital';
    }
  }

  Color _getFacilityColor(String type) {
    switch (type) {
      case 'hospital':
        return const Color(0xFFE53E3E);
      case 'pharmacy':
        return const Color(0xFF38A169);
      case 'urgent_care':
        return const Color(0xFFD69E2E);
      case 'specialist':
        return const Color(0xFF3182CE);
      case 'clinic':
        return const Color(0xFF805AD5);
      default:
        return const Color(0xFFE53E3E);
    }
  }
}
