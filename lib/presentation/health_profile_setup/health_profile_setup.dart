import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/medical_form_widget.dart';
import './widgets/privacy_notice_widget.dart';
import './widgets/profile_photo_widget.dart';
import './widgets/progress_bar_widget.dart';

class HealthProfileSetup extends StatefulWidget {
  const HealthProfileSetup({Key? key}) : super(key: key);

  @override
  State<HealthProfileSetup> createState() => _HealthProfileSetupState();
}

class _HealthProfileSetupState extends State<HealthProfileSetup> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  XFile? _profileImage;
  Map<String, dynamic> _formData = {};
  bool _hasUnsavedChanges = false;
  bool _isAutoSaving = false;

  // Mock auto-save data
  final Map<String, dynamic> _autoSaveData = {
    'lastSaved': DateTime.now(),
    'draftExists': false,
  };

  @override
  void initState() {
    super.initState();
    _loadDraftData();

    // Listen for keyboard changes to adjust scroll position
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(Duration(milliseconds: 300), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadDraftData() {
    // Simulate loading draft data
    setState(() {
      _autoSaveData['draftExists'] = false;
    });
  }

  void _onImageSelected(XFile? image) {
    setState(() {
      _profileImage = image;
      _hasUnsavedChanges = true;
    });
    _autoSave();
  }

  void _onFormChanged(Map<String, dynamic> formData) {
    setState(() {
      _formData = formData;
      _hasUnsavedChanges = true;
    });
    _autoSave();
  }

  void _autoSave() {
    if (_isAutoSaving) return;

    setState(() {
      _isAutoSaving = true;
    });

    // Simulate auto-save with delay
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isAutoSaving = false;
          _autoSaveData['lastSaved'] = DateTime.now();
          _autoSaveData['draftExists'] = true;
        });
      }
    });
  }

  double _calculateProgress() {
    int completedFields = 0;
    int totalRequiredFields =
        4; // fullName, dateOfBirth, gender, emergencyContact

    if (_formData['fullName']?.isNotEmpty == true) completedFields++;
    if (_formData['dateOfBirth'] != null) completedFields++;
    if (_formData['gender']?.isNotEmpty == true) completedFields++;
    if (_formData['emergencyContact']?.isNotEmpty == true) completedFields++;

    return completedFields / totalRequiredFields;
  }

  bool _isFormValid() {
    return _formData['fullName']?.isNotEmpty == true &&
        _formData['dateOfBirth'] != null &&
        _formData['gender']?.isNotEmpty == true &&
        _formData['emergencyContact']?.isNotEmpty == true;
  }

  String _getStepText() {
    double progress = _calculateProgress();
    if (progress == 0) return 'Getting Started';
    if (progress < 0.5) return 'Basic Information';
    if (progress < 1.0) return 'Almost Complete';
    return 'Profile Complete';
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Unsaved Changes',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            content: Text(
              'You have unsaved changes. Are you sure you want to leave?',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Leave',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _saveProfile() {
    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              SizedBox(height: 2.h),
              Text(
                'Saving your profile...',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );

    // Simulate save process
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close loading dialog
      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.tertiary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 32,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Profile Saved Successfully!',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.tertiary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Your health profile has been securely saved and encrypted.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                child: Text('Continue to Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _skipForNow() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Skip Profile Setup?',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'You can complete your profile later, but having this information helps provide more accurate health assessments.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Continue Setup'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
            child: Text(
              'Skip for Now',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Progress Bar
              ProgressBarWidget(
                progress: _calculateProgress(),
                stepText: _getStepText(),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 3.h),

                      // Header
                      Text(
                        'Complete Your Health Profile',
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Help us provide personalized health assessments and recommendations by completing your medical profile.',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 4.h),

                      // Profile Photo
                      Center(
                        child: ProfilePhotoWidget(
                          onImageSelected: _onImageSelected,
                        ),
                      ),
                      SizedBox(height: 4.h),

                      // Medical Form
                      Focus(
                        focusNode: _focusNode,
                        child: MedicalFormWidget(
                          onFormChanged: _onFormChanged,
                        ),
                      ),
                      SizedBox(height: 3.h),

                      // Privacy Notice
                      PrivacyNoticeWidget(),
                      SizedBox(height: 3.h),

                      // Auto-save indicator
                      if (_isAutoSaving)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: AppTheme
                                .lightTheme.colorScheme.primaryContainer
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 4.w,
                                height: 4.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Auto-saving...',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (!_isAutoSaving &&
                          _autoSaveData['draftExists'] == true)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: AppTheme
                                .lightTheme.colorScheme.tertiaryContainer
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'check_circle_outline',
                                color: AppTheme.lightTheme.colorScheme.tertiary,
                                size: 16,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Draft saved automatically',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.tertiary,
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 12.h), // Space for bottom buttons
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom Action Buttons
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.shadow,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isFormValid() ? _saveProfile : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFormValid()
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline,
                      foregroundColor: _isFormValid()
                          ? AppTheme.lightTheme.colorScheme.onPrimary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    child: Text('Save Profile'),
                  ),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _skipForNow,
                    child: Text('Skip for Now'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
