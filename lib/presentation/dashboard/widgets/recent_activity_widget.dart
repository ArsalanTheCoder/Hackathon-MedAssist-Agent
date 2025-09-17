import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentActivityWidget extends StatelessWidget {
  const RecentActivityWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock recent activity data
    final List<Map<String, dynamic>> recentActivities = [
      {
        "id": 1,
        "type": "appointment",
        "title": "Consultation with Dr. Sarah Johnson",
        "subtitle": "Cardiology checkup completed",
        "timestamp": "2 hours ago",
        "icon": "medical_services",
        "status": "completed",
      },
      {
        "id": 2,
        "type": "prescription",
        "title": "Prescription Refill",
        "subtitle": "Lisinopril 10mg - Ready for pickup",
        "timestamp": "1 day ago",
        "icon": "medication",
        "status": "ready",
      },
      {
        "id": 3,
        "type": "symptom_report",
        "title": "Symptom Assessment",
        "subtitle": "Mild headache - Low urgency",
        "timestamp": "3 days ago",
        "icon": "assignment",
        "status": "reviewed",
      },
      {
        "id": 4,
        "type": "lab_result",
        "title": "Blood Test Results",
        "subtitle": "All values within normal range",
        "timestamp": "1 week ago",
        "icon": "science",
        "status": "normal",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Recent Activity',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full activity history
                },
                child: Text(
                  'View All',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        SizedBox(
          height: 16.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: recentActivities.length,
            separatorBuilder: (context, index) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final activity = recentActivities[index];
              return _buildActivityCard(activity);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    Color statusColor;
    switch (activity["status"] as String) {
      case "completed":
      case "normal":
        statusColor = AppTheme.successLight;
        break;
      case "ready":
        statusColor = AppTheme.warningLight;
        break;
      case "reviewed":
        statusColor = AppTheme.primaryLight;
        break;
      default:
        statusColor = AppTheme.textSecondaryLight;
    }

    return Container(
      width: 70.w,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderSubtleLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: activity["icon"] as String,
                  color: statusColor,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity["title"] as String,
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      activity["timestamp"] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            activity["subtitle"] as String,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimaryLight,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
