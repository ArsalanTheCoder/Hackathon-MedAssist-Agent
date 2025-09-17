import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionCardWidget extends StatefulWidget {
  final String title;
  final String iconName;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback onTap;
  final bool isEmergency;

  const QuickActionCardWidget({
    Key? key,
    required this.title,
    required this.iconName,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.isEmergency = false,
  }) : super(key: key);

  @override
  State<QuickActionCardWidget> createState() => _QuickActionCardWidgetState();
}

class _QuickActionCardWidgetState extends State<QuickActionCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ??
        (widget.isEmergency
            ? AppTheme.errorLight.withValues(alpha: 0.1)
            : AppTheme.lightTheme.colorScheme.surface);

    final iconColor = widget.iconColor ??
        (widget.isEmergency ? AppTheme.errorLight : AppTheme.primaryLight);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              _animationController.forward();
              HapticFeedback.lightImpact();
            },
            onTapUp: (_) {
              _animationController.reverse();
              widget.onTap();
            },
            onTapCancel: () {
              _animationController.reverse();
            },
            child: Container(
              width: double.infinity,
              height: 20.h,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isEmergency
                      ? AppTheme.errorLight.withValues(alpha: 0.3)
                      : AppTheme.borderSubtleLight,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: widget.iconName,
                      color: iconColor,
                      size: 8.w,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Text(
                      widget.title,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.isEmergency
                            ? AppTheme.errorLight
                            : AppTheme.textPrimaryLight,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
