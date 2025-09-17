import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/quick_action_card_widget.dart';
import './widgets/recent_activity_widget.dart';
import './widgets/solana_wallet_card_widget.dart';
import './widgets/upcoming_appointments_widget.dart';
import './widgets/weather_widget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Tab Bar
            Container(
              color: AppTheme.lightTheme.colorScheme.surface,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Dashboard'),
                  Tab(text: 'Symptoms'),
                  Tab(text: 'Consultations'),
                  Tab(text: 'Profile'),
                ],
              ),
            ),
            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(),
                  _buildPlaceholderTab('Symptoms'),
                  _buildPlaceholderTab('Consultations'),
                  _buildPlaceholderTab('Profile'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.pushNamed(context, '/symptom-assessment');
              },
              backgroundColor: AppTheme.primaryLight,
              foregroundColor: AppTheme.onPrimaryLight,
              icon: CustomIconWidget(
                iconName: 'health_and_safety',
                color: AppTheme.onPrimaryLight,
                size: 6.w,
              ),
              label: Text(
                'Quick Symptom Check',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.primaryLight,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Header
            GreetingHeaderWidget(
              userName: 'Alex',
              currentDate: _getCurrentDate(),
            ),
            SizedBox(height: 3.h),

            // Weather Widget
            const WeatherWidget(),
            SizedBox(height: 3.h),

            // Quick Actions Grid
            Text(
              'Quick Actions',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            SizedBox(height: 2.h),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 1.0,
              children: [
                QuickActionCardWidget(
                  title: 'Check Symptoms',
                  iconName: 'medical_services',
                  onTap: () {
                    Navigator.pushNamed(context, '/symptom-assessment');
                  },
                ),
                QuickActionCardWidget(
                  title: 'Find Doctor',
                  iconName: 'person_search',
                  onTap: () {
                    Navigator.pushNamed(
                        context, '/healthcare-facility-locator');
                  },
                ),
                QuickActionCardWidget(
                  title: 'Emergency',
                  iconName: 'emergency',
                  isEmergency: true,
                  onTap: () {
                    _showEmergencyDialog();
                  },
                ),
                QuickActionCardWidget(
                  title: 'Pharmacy Locator',
                  iconName: 'local_pharmacy',
                  onTap: () {
                    Navigator.pushNamed(
                        context, '/healthcare-facility-locator');
                  },
                ),
              ],
            ),
            SizedBox(height: 4.h),

            // Recent Activity
            const RecentActivityWidget(),
            SizedBox(height: 4.h),

            // Upcoming Appointments
            const UpcomingAppointmentsWidget(),
            SizedBox(height: 4.h),

            // Solana Wallet Card
            const SolanaWalletCardWidget(),
            SizedBox(height: 10.h), // Extra space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab(String tabName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'construction',
            color: AppTheme.textSecondaryLight,
            size: 15.w,
          ),
          SizedBox(height: 2.h),
          Text(
            '$tabName Coming Soon',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'This feature is under development',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'emergency',
                color: AppTheme.errorLight,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Emergency',
                style: AppTheme.getErrorTextStyle(
                  isLight: true,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'If this is a life-threatening emergency, please call 911 immediately.',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimaryLight,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'For non-emergency urgent care:',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle emergency contact
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorLight,
              ),
              child: Text(
                'Call 911',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onErrorLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/healthcare-facility-locator');
              },
              child: Text('Find Urgent Care'),
            ),
          ],
        );
      },
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}
