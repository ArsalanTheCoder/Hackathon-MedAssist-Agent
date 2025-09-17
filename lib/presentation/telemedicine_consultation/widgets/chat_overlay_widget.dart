import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChatOverlayWidget extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onClose;
  final Function(String) onSendMessage;

  const ChatOverlayWidget({
    super.key,
    required this.isVisible,
    required this.onClose,
    required this.onSendMessage,
  });

  @override
  State<ChatOverlayWidget> createState() => _ChatOverlayWidgetState();
}

class _ChatOverlayWidgetState extends State<ChatOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      "id": 1,
      "sender": "Dr. Sarah Johnson",
      "message": "Hello! I can see you clearly. How are you feeling today?",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 2)),
      "isDoctor": true,
    },
    {
      "id": 2,
      "sender": "You",
      "message": "Hi Doctor, I've been experiencing some chest discomfort.",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 1)),
      "isDoctor": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ChatOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          "id": _messages.length + 1,
          "sender": "You",
          "message": _messageController.text.trim(),
          "timestamp": DateTime.now(),
          "isDoctor": false,
        });
      });
      widget.onSendMessage(_messageController.text.trim());
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: 50.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4.w),
            topRight: Radius.circular(4.w),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildChatHeader(),
            Expanded(child: _buildMessagesList()),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Chat with Doctor',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: widget.onClose,
            child: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isDoctor = message["isDoctor"] as bool;

        return Align(
          alignment: isDoctor ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            margin: EdgeInsets.only(bottom: 1.h),
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            constraints: BoxConstraints(maxWidth: 70.w),
            decoration: BoxDecoration(
              color: isDoctor
                  ? AppTheme.lightTheme.colorScheme.primaryContainer
                  : AppTheme.lightTheme.colorScheme.primary,
              borderRadius: BorderRadius.circular(3.w),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message["message"] as String,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: isDoctor
                        ? AppTheme.lightTheme.colorScheme.onPrimaryContainer
                        : AppTheme.lightTheme.colorScheme.onPrimary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _formatTime(message["timestamp"] as DateTime),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: (isDoctor
                            ? AppTheme.lightTheme.colorScheme.onPrimaryContainer
                            : AppTheme.lightTheme.colorScheme.onPrimary)
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.w),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.lightTheme.colorScheme.surface,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 2.w),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'send',
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 5.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
