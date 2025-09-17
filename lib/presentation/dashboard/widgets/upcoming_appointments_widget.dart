import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/custom_image_widget.dart';

class UpcomingAppointmentsWidget extends StatelessWidget {
  const UpcomingAppointmentsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock upcoming appointments data
    final List<Map<String, dynamic>> upcomingAppointments = [
      {
        "id": 1,
        "doctorName": "Dr. Michael Chen",
        "specialty": "Dermatology",
        "date": "Today",
        "time": "2:30 PM",
        "type": "Video Consultation",
        "avatar":
            "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=150&h=150&fit=crop&crop=face",
        "canJoin": true,
      },
      {
        "id": 2,
        "doctorName": "Dr. Emily Rodriguez",
        "specialty": "General Medicine",
        "date": "Tomorrow",
        "time": "10:00 AM",
        "type": "In-person Visit",
        "avatar":
            "https://images.unsplash.com/photo-1594824475317-8b7b0b3e5b4e?w=150&h=150&fit=crop&crop=face",
        "canJoin": false,
      },
      {
        "id": 3,
        "doctorName": "Dr. James Wilson",
        "specialty": "Cardiology",
        "date": "Dec 18",
        "time": "3:15 PM",
        "type": "Video Consultation",
        "avatar":
            "https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=150&h=150&fit=crop&crop=face",
        "canJoin": false,
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
                  'Upcoming Appointments',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to appointments screen
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
        upcomingAppointments.isEmpty
            ? _buildEmptyState()
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: upcomingAppointments.length > 3
                    ? 3
                    : upcomingAppointments.length,
                separatorBuilder: (context, index) => SizedBox(height: 2.h),
                itemBuilder: (context, index) {
                  final appointment = upcomingAppointments[index];
                  return _buildAppointmentCard(appointment);
                },
              ),
      ],
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    return Container(
      width: double.infinity,
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
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  imageUrl: appointment["avatar"] as String,
                  width: 12.w,
                  height: 12.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment["doctorName"] as String,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      appointment["specialty"] as String,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color: AppTheme.primaryLight,
                          size: 4.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${appointment["date"]} at ${appointment["time"]}',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textPrimaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: appointment["type"] == "Video Consultation"
                      ? AppTheme.primaryLight.withValues(alpha: 0.1)
                      : AppTheme.warningLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  appointment["type"] == "Video Consultation"
                      ? "Video"
                      : "In-person",
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: appointment["type"] == "Video Consultation"
                        ? AppTheme.primaryLight
                        : AppTheme.warningLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Handle reschedule
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    side: BorderSide(color: AppTheme.borderSubtleLight),
                  ),
                  child: Text(
                    'Reschedule',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: appointment["canJoin"] as bool
                      ? () {
                          // Handle join consultation
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    backgroundColor: appointment["canJoin"] as bool
                        ? AppTheme.primaryLight
                        : AppTheme.textDisabledLight,
                  ),
                  child: Text(
                    appointment["canJoin"] as bool
                        ? 'Join Now'
                        : 'View Details',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: appointment["canJoin"] as bool
                          ? AppTheme.onPrimaryLight
                          : AppTheme.textSecondaryLight,
                      fontWeight: FontWeight.w500,
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderSubtleLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'event_available',
            color: AppTheme.textSecondaryLight,
            size: 12.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Upcoming Appointments',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Schedule a consultation with our healthcare professionals',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: () {
              // Navigate to find doctor
            },
            child: Text('Find Doctor'),
          ),
        ],
      ),
    );
  }
}