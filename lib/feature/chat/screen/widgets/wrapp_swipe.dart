// 1. First, create the wrapp_swipe.dart file with the SwipeableChatBubble:
// File: lib/feature/chat/screen/widgets/wrapp_swipe.dart

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/shared/constants/colors.dart';

class SwipeableChatBubble extends StatefulWidget {
  final Widget child;
  final bool isSent;
  final VoidCallback? onReply;
  final VoidCallback? onPin;
  final VoidCallback? onDelete;
  final String messageId;
  final bool isPinned;

  const SwipeableChatBubble({
    super.key,
    required this.child,
    required this.isSent,
    this.onReply,
    this.onPin,
    this.onDelete,
    required this.messageId,
    this.isPinned = false,
  });

  @override
  State<SwipeableChatBubble> createState() => _SwipeableChatBubbleState();
}

class _SwipeableChatBubbleState extends State<SwipeableChatBubble>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _replyIconController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _replyIconAnimation;
  late Animation<Color?> _replyIconColorAnimation;

  double _dragExtent = 0;
  bool _dragUnderway = false;
  final double _replyThreshold =
      70.0; // Reduced threshold for easier triggering

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _replyIconController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(widget.isSent ? -0.12 : 0.12, 0), // Reduced slide distance
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _replyIconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _replyIconController, curve: Curves.elasticOut),
    );

    _replyIconColorAnimation =
        ColorTween(begin: Colors.grey.shade300, end: kPrimaryColor).animate(
          CurvedAnimation(
            parent: _replyIconController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _replyIconController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _dragUnderway = true;
    HapticFeedback.lightImpact();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_dragUnderway) return;

    final delta = details.primaryDelta ?? 0;

    if (widget.isSent) {
      // For sent messages, swipe left (negative delta)
      _dragExtent = (_dragExtent + delta).clamp(-_replyThreshold, 0.0);
    } else {
      // For received messages, swipe right (positive delta)
      _dragExtent = (_dragExtent + delta).clamp(0.0, _replyThreshold);
    }

    final progress = (_dragExtent.abs() / _replyThreshold).clamp(0.0, 1.0);
    _slideController.value = progress;

    // Show reply icon when progress reaches 25%
    if (progress >= 0.25 && _replyIconController.value < 1.0) {
      _replyIconController.forward();
      HapticFeedback.mediumImpact();
    } else if (progress < 0.25 && _replyIconController.value > 0.0) {
      _replyIconController.reverse();
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_dragUnderway) return;

    _dragUnderway = false;
    final progress = (_dragExtent.abs() / _replyThreshold).clamp(0.0, 1.0);

    if (progress >= 0.35) {
      // Reduced threshold for easier triggering
      // Trigger reply
      HapticFeedback.heavyImpact();
      widget.onReply?.call();
      log('🎯 Swipe reply triggered! Progress: $progress');
    }

    // Reset animations
    _slideController.reverse();
    _replyIconController.reverse();
    _dragExtent = 0;
  }

  void _showMessageOptions() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MessageOptionsBottomSheet(
        onReply: widget.onReply,
        onPin: widget.onPin,
        onDelete: widget.onDelete,
        isPinned: widget.isPinned,
        isSent: widget.isSent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      onLongPress: _showMessageOptions,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          alignment: widget.isSent
              ? Alignment.centerLeft
              : Alignment.centerRight,
          children: [
            // Enhanced reply icon
            Positioned(
              right: widget.isSent ? null : 15.w,
              left: widget.isSent ? 15.w : null,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _replyIconAnimation,
                  _replyIconColorAnimation,
                ]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _replyIconAnimation.value,
                    child: Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color:
                            (_replyIconColorAnimation.value ??
                                    Colors.grey.shade300)
                                .withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              _replyIconColorAnimation.value ??
                              Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.reply,
                        size: 20.sp,
                        color:
                            _replyIconColorAnimation.value ??
                            Colors.grey.shade600,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Main message bubble
            SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: widget.isSent
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Pin indicator
                  if (widget.isPinned) ...[
                    Container(
                      margin: EdgeInsets.only(
                        left: widget.isSent ? 50.w : 16.w,
                        right: widget.isSent ? 16.w : 50.w,
                        bottom: 6.h,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(
                          color: Colors.amber.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.push_pin,
                            size: 12.sp,
                            color: Colors.amber.shade700,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Pinned',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.amber.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Main message content
                  widget.child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageOptionsBottomSheet extends StatelessWidget {
  final VoidCallback? onReply;
  final VoidCallback? onPin;
  final VoidCallback? onDelete;
  final bool isPinned;
  final bool isSent;

  const MessageOptionsBottomSheet({
    super.key,
    this.onReply,
    this.onPin,
    this.onDelete,
    required this.isPinned,
    required this.isSent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Title
            Text(
              'Message Options',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16.h),

            // Options
            _buildOption(
              icon: Icons.reply,
              title: 'Reply',
              onTap: () {
                Navigator.pop(context);
                onReply?.call();
              },
            ),

            _buildOption(
              icon: isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              title: isPinned ? 'Unpin' : 'Pin',
              onTap: () {
                Navigator.pop(context);
                onPin?.call();
              },
            ),

            _buildOption(
              icon: Icons.copy,
              title: 'Copy',
              onTap: () {
                Navigator.pop(context);
                // Handle copy functionality here
              },
            ),

            if (isSent) ...[
              _buildOption(
                icon: Icons.edit,
                title: 'Edit',
                onTap: () {
                  Navigator.pop(context);
                  // Handle edit functionality here
                },
              ),
            ],

            _buildOption(
              icon: Icons.delete_outline,
              title: 'Delete',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                onDelete?.call();
              },
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.grey.shade700,
        size: 24.sp,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 16.sp,
        ),
      ),
      onTap: onTap,
    );
  }
}

class ReplyMessageWidget extends StatelessWidget {
  final String? replyToSender;
  final String? replyToContent;
  final bool isIncoming;

  const ReplyMessageWidget({
    super.key,
    this.replyToSender,
    this.replyToContent,
    this.isIncoming = false,
  });

  @override
  Widget build(BuildContext context) {
    if (replyToContent == null || replyToSender == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: isIncoming
            ? Colors.grey.shade200.withOpacity(0.5)
            : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.r),
        border: Border(
          left: BorderSide(
            color: isIncoming ? Colors.blue : Colors.white,
            width: 3.w,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            replyToSender!,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isIncoming ? Colors.blue : Colors.white70,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            replyToContent!,
            style: TextStyle(
              fontSize: 13.sp,
              color: isIncoming ? Colors.grey.shade700 : Colors.white70,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class ReplyPreviewWidget extends StatelessWidget {
  final String? replyToMessage;
  final String? replyToSender;
  final VoidCallback onCancel;

  const ReplyPreviewWidget({
    super.key,
    this.replyToMessage,
    this.replyToSender,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: const Offset(0, 0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Left colored bar
            Container(
              width: 4.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  bottomLeft: Radius.circular(12.r),
                ),
              ),
            ),

            // Reply icon
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Icon(Icons.reply, size: 20.sp, color: kPrimaryColor),
            ),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Replying to ${replyToSender ?? 'Unknown'}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    replyToMessage ?? '',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade700,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Close button
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: InkWell(
                onTap: onCancel,
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  child: Icon(
                    Icons.close,
                    size: 18.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
