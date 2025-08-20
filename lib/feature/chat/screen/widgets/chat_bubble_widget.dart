import 'dart:developer';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/chat_card.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/htm_Card.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/user_data.dart';
import 'package:soxo_chat/shared/utils/auth/auth_utils.dart';

class ChatBubbleMessage extends StatefulWidget {
  final String? type;
  final String message;
  final String timestamp;
  final bool isSent;
  final List<ChatMedias>? chatMedias;
  final Entry? messageData;
  final Entry? replyToMessage;
  final bool isPinned;
  final bool isBeingRepliedTo;
  final VoidCallback? onReply;
  final VoidCallback? onPin;
  final VoidCallback? onScrollToReply;
  final String? chatId;
  final String? chatEntryId;

  const ChatBubbleMessage({
    super.key,
    this.type,
    required this.message,
    required this.timestamp,
    required this.isSent,
    this.chatMedias,
    this.messageData,
    this.replyToMessage,
    this.isPinned = false,
    this.isBeingRepliedTo = false,
    this.onReply,
    this.onPin,
    this.onScrollToReply,
    this.chatEntryId,
    this.chatId,
  });

  @override
  State<ChatBubbleMessage> createState() => _ChatBubbleMessageState();
}

class _ChatBubbleMessageState extends State<ChatBubbleMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _swipeAnimationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _replyIconAnimation;

  double _dragDistance = 0.0;
  bool _isDragging = false;
  bool _hasTriggeredReply = false;

  static const double _replyThreshold = 60.0;
  static const double _maxDragDistance = 100.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _swipeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _swipeAnimationController, curve: Curves.easeOut),
    );

    _replyIconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _swipeAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _swipeAnimationController.dispose();
    super.dispose();
  }

  void _onLongPress() {
    HapticFeedback.mediumImpact();
    _showMessageOptions();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _isDragging = true;
    _hasTriggeredReply = false;
    _swipeAnimationController.reset();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    double delta = widget.isSent ? -details.delta.dx : details.delta.dx;

    if (delta > 0) {
      setState(() {
        _dragDistance = (_dragDistance + delta).clamp(0.0, _maxDragDistance);
      });

      if (_dragDistance >= _replyThreshold && !_hasTriggeredReply) {
        _hasTriggeredReply = true;
        HapticFeedback.mediumImpact();
        _swipeAnimationController.forward();
      } else if (_dragDistance < _replyThreshold && _hasTriggeredReply) {
        _hasTriggeredReply = false;
        _swipeAnimationController.reverse();
      }
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _isDragging = false;

    if (_dragDistance >= _replyThreshold) {
      HapticFeedback.lightImpact();
      widget.onReply?.call();
    }
    _resetSwipe();
  }

  void _resetSwipe() {
    setState(() {
      _dragDistance = 0.0;
      _hasTriggeredReply = false;
    });
    _swipeAnimationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onLongPress: _onLongPress,
      onTap: widget.replyToMessage != null ? widget.onScrollToReply : null,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        child: Stack(
          children: [
            if (_dragDistance > 0) _buildReplyIcon(),
            AnimatedContainer(
              duration: _isDragging
                  ? Duration.zero
                  : const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              transform: Matrix4.identity()
                ..translate(
                  widget.isSent ? -_dragDistance : _dragDistance,
                  0.0,
                ),
              child: _buildMessageContainer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyIcon() {
    return Positioned(
      right: widget.isSent ? 20.w : null,
      left: widget.isSent ? null : 20.w,
      top: 0,
      bottom: 0,
      child: AnimatedBuilder(
        animation: _replyIconAnimation,
        builder: (context, child) {
          return Center(
            child: Transform.scale(
              scale: 0.5 + (_replyIconAnimation.value * 0.5),
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: _hasTriggeredReply
                      ? Colors.blue
                      : Colors.grey.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.reply, color: Colors.white, size: 20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageContainer() {
    return Container(
      padding: widget.isBeingRepliedTo ? EdgeInsets.all(6.w) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: widget.isBeingRepliedTo
            ? Colors.green.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        border: widget.isBeingRepliedTo
            ? Border.all(color: Colors.blue.withOpacity(0.6), width: 2.w)
            : null,
        boxShadow: widget.isBeingRepliedTo
            ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: widget.isSent
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (widget.isBeingRepliedTo) _buildReplyStatusIndicator(),
          _buildMainBubbleWithReplyAlternative(),
        ],
      ),
    );
  }

  Widget _buildReplyStatusIndicator() {
    return Container(
      margin: EdgeInsets.only(
        left: widget.isSent ? 0 : 50.w,
        right: widget.isSent ? 50.w : 0,
        bottom: 4.h,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.reply_rounded,
            size: 14,
            color: Colors.blue.withOpacity(0.8),
          ),
          SizedBox(width: 4.w),
          Text(
            'Replying to this message',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.blue.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Replace your _buildMainBubbleWithReply method with this corrected version:

  // Widget _buildMainBubbleWithReply() {
  //   Color bubbleColor;
  //   if (widget.isBeingRepliedTo) {
  //     bubbleColor = widget.isSent
  //         ? const Color(0xFFE6F7FF)
  //         : const Color(0xFFF0F8FF);
  //   } else {
  //     bubbleColor = widget.isSent ? const Color(0xFFE6F2EC) : Colors.grey[200]!;
  //   }

  //   return Row(
  //     mainAxisAlignment: widget.isSent
  //         ? MainAxisAlignment.end
  //         : MainAxisAlignment.start,
  //     crossAxisAlignment: CrossAxisAlignment.end,
  //     children: [
  //       // Show avatar only for received messages (not sent by current user)
  //       if (!widget.isSent) ...[
  //         ChatAvatar(
  //           name: widget.messageData?.sender?.imageUrl ?? '',
  //           // You can also pass other properties like:
  //           // imageUrl: widget.messageData?.sender?.imageUrl,
  //           // userName: widget.messageData?.sender?.name,
  //         ),
  //         SizedBox(width: 8.w), // Add some spacing
  //       ],

  //       // Message bubble
  //       Flexible(
  //         child: Bubble(
  //           margin: BubbleEdges.only(top: 6),
  //           alignment: widget.isSent ? Alignment.topRight : Alignment.topLeft,
  //           nipWidth: 18,
  //           nipHeight: 10,
  //           radius: Radius.circular(12.r),
  //           nip: widget.isSent ? BubbleNip.rightTop : BubbleNip.leftTop,
  //           color: bubbleColor,
  //           child: SizedBox(
  //             width: 220.w,
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 if (widget.replyToMessage != null) _buildInlineReplyPreview(),
  //                 _buildMessageContent(),
  //                 if (widget.chatMedias != null &&
  //                     widget.chatMedias!.isNotEmpty) ...[
  //                   5.verticalSpace,
  //                   _buildMediaAttachments(),
  //                 ],
  //                 SizedBox(height: 4.h),
  //                 _buildTimestampWithStatus(),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),

  //       // Show avatar only for sent messages (sent by current user)
  //       if (widget.isSent) ...[
  //         SizedBox(width: 8.w), // Add some spacing
  //         FutureBuilder(
  //           future: AuthUtils.instance.readUserData(),
  //           builder: (context, snapshot) {
  //             final currentUser = snapshot.data?.result;
  //             return ChatAvatar(name: currentUser?.userName ?? '');
  //           },
  //         ),
  //       ],
  //     ],
  //   );
  // }

  // Alternative approach if you want to show both users' avatars differently:
  Widget _buildMainBubbleWithReplyAlternative() {
    Color bubbleColor;
    if (widget.isBeingRepliedTo) {
      bubbleColor = widget.isSent
          ? const Color(0xFFE6F7FF)
          : const Color(0xFFF0F8FF);
    } else {
      bubbleColor = widget.isSent ? const Color(0xFFE6F2EC) : Colors.grey[200]!;
    }

    return Row(
      mainAxisAlignment: widget.isSent
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment:
          CrossAxisAlignment.start, // Changed to start for top alignment
      children: [
        // Left side avatar (for received messages)
        if (!widget.isSent) ...[
          Padding(
            padding: EdgeInsets.only(top: 6.h), // Match bubble's top margin
            child: _buildUserAvatar(isCurrentUser: false),
          ),
          SizedBox(width: 8.w),
        ],

        // Message bubble
        Flexible(
          child: Bubble(
            margin: BubbleEdges.only(top: 6),
            alignment: widget.isSent ? Alignment.topRight : Alignment.topLeft,
            nipWidth: 18,
            nipHeight: 10,
            radius: Radius.circular(12.r),
            nip: widget.isSent ? BubbleNip.rightTop : BubbleNip.leftTop,
            color: bubbleColor,
            child: SizedBox(
              width: 260.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.isSent &&
                      widget.messageData?.sender?.name != null) ...[
                    Text(
                      widget.messageData!.sender!.name!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                  if (widget.replyToMessage != null) _buildInlineReplyPreview(),
                  _buildMessageContent(),
                  if (widget.chatMedias != null &&
                      widget.chatMedias!.isNotEmpty) ...[
                    5.verticalSpace,
                    _buildMediaAttachments(),
                  ],
                  SizedBox(height: 4.h),
                  _buildTimestampWithStatus(),
                ],
              ),
            ),
          ),
        ),

        // Right side avatar (for sent messages)
        if (widget.isSent) ...[
          SizedBox(width: 8.w),
          Padding(
            padding: EdgeInsets.only(top: 6.h), // Match bubble's top margin
            child: _buildUserAvatar(isCurrentUser: true),
          ),
        ],
      ],
    );
  }

  // Helper method to build user avatar
  Widget _buildUserAvatar({required bool isCurrentUser}) {
    if (isCurrentUser) {
      return FutureBuilder(
        future: AuthUtils.instance.readUserData(),
        builder: (context, snapshot) {
          final currentUser = snapshot.data?.result;
          return ChatAvatar(size: 26.h, name: currentUser?.userName ?? '');
        },
      );
    } else {
      // For other users (received messages)
      return ChatAvatar(
        size: 26.h,
        name: widget.messageData?.sender?.name ?? '',
        imageUrl: widget.messageData?.sender?.imageUrl,
      );
    }
  }

  // // Helper method to build user avatar
  // Widget _buildUserAvatar({required bool isCurrentUser}) {
  //   if (isCurrentUser) {
  //     // For current user (sent messages)
  //     return FutureBuilder(
  //       future: AuthUtils.instance.readUserData(),
  //       builder: (context, snapshot) {
  //         final currentUser = snapshot.data?.result;
  //         return ChatAvatar(name: currentUser?.userName ?? "");
  //       },
  //     );
  //   } else {
  //     // For other users (received messages)
  //     return ChatAvatar(
  //       size: 30.h,
  //       name: widget.messageData?.sender?.imageUrl ?? '',
  //       imageUrl: widget.messageData?.sender?.imageUrl,
  //     );
  //   }
  // }

  Widget _buildTimestampWithStatus() {
    return Row(
      mainAxisAlignment: widget.isSent
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (widget.isBeingRepliedTo) ...[
          Icon(Icons.reply, size: 10, color: Colors.blue.withOpacity(0.7)),
          SizedBox(width: 2.w),
        ],
        Text(
          widget.timestamp,
          style: TextStyle(
            fontSize: 10,
            color: widget.isBeingRepliedTo
                ? Colors.blue[600]
                : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Replace your _buildInlineReplyPreview method with this corrected version:

  Widget _buildInlineReplyPreview() {
    final replyMessage = widget.replyToMessage!;

    return FutureBuilder<int?>(
      future: _getCurrentUserId(),
      builder: (context, snapshot) {
        final currentUserId = snapshot.data ?? 0;

        final isReplyFromMe = replyMessage.senderId == currentUserId;

        final replyBorderColor = widget.isBeingRepliedTo
            ? (widget.isSent ? Colors.green[600] : Colors.blue[600])
            : (widget.isSent ? Colors.green : Colors.blue);

        final replyBackgroundColor = widget.isBeingRepliedTo
            ? (widget.isSent
                  ? Colors.green.withOpacity(0.15)
                  : Colors.blue.withOpacity(0.15))
            : (widget.isSent
                  ? Colors.green.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1));

        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: replyBackgroundColor,
            borderRadius: BorderRadius.circular(6.r),
            border: Border(
              left: BorderSide(
                color: replyBorderColor!,
                width: widget.isBeingRepliedTo ? 4.w : 3.w,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.reply, size: 12, color: replyBorderColor),
                  SizedBox(width: 4.w),
                  Text(
                    isReplyFromMe
                        ? 'You'
                        : (replyMessage.sender?.name ?? 'User'),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: replyBorderColor.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                replyMessage.content ?? '',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (replyMessage.chatMedias?.isNotEmpty == true)
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Row(
                    children: [
                      Icon(
                        _getMediaIcon(replyMessage.chatMedias!.first),
                        size: 10,
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        _getMediaTypeText(replyMessage.chatMedias!.first),
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Add this helper method to your ChatBubbleMessage class:
  Future<int?> _getCurrentUserId() async {
    try {
      final user = await AuthUtils.instance.readUserData();
      return int.tryParse(user?.result?.userId?.toString() ?? '0') ?? 0;
    } catch (e) {
      log('Error getting current user ID: $e');
      return 0;
    }
  }

  // Widget _buildInlineReplyPreview() async {
  //   final replyMessage = widget.replyToMessage!;
  //   final user = await AuthUtils.instance.readUserData();
  //   final currentUserId = await user?.result?.userId ?? 0;
  //   final isReplyFromMe = replyMessage.senderId == widget.messageData?.senderId;
  //   final replyBorderColor = widget.isBeingRepliedTo
  //       ? (widget.isSent ? Colors.green[600] : Colors.blue[600])
  //       : (widget.isSent ? Colors.green : Colors.blue);

  //   final replyBackgroundColor = widget.isBeingRepliedTo
  //       ? (widget.isSent
  //             ? Colors.green.withOpacity(0.15)
  //             : Colors.blue.withOpacity(0.15))
  //       : (widget.isSent
  //             ? Colors.green.withOpacity(0.1)
  //             : Colors.blue.withOpacity(0.1));

  //   return Container(
  //     margin: EdgeInsets.only(bottom: 8.h),
  //     padding: EdgeInsets.all(8.w),
  //     decoration: BoxDecoration(
  //       color: replyBackgroundColor,
  //       borderRadius: BorderRadius.circular(6.r),
  //       border: Border(
  //         left: BorderSide(
  //           color: replyBorderColor!,
  //           width: widget.isBeingRepliedTo ? 4.w : 3.w,
  //         ),
  //       ),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Icon(Icons.reply, size: 12, color: replyBorderColor),
  //             SizedBox(width: 4.w),
  //             Text(
  //               isReplyFromMe ? 'You' : (replyMessage.sender?.name ?? 'User'),
  //               style: TextStyle(
  //                 fontSize: 11.sp,
  //                 fontWeight: FontWeight.w600,
  //                 color: replyBorderColor.withOpacity(0.9),
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 2.h),
  //         Text(
  //           replyMessage.content ?? '',
  //           style: TextStyle(
  //             fontSize: 11.sp,
  //             color: Colors.grey[600],
  //             fontStyle: FontStyle.italic,
  //           ),
  //           maxLines: 2,
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //         if (replyMessage.chatMedias?.isNotEmpty == true)
  //           Padding(
  //             padding: EdgeInsets.only(top: 2.h),
  //             child: Row(
  //               children: [
  //                 Icon(
  //                   _getMediaIcon(replyMessage.chatMedias!.first),
  //                   size: 10,
  //                   color: Colors.grey[500],
  //                 ),
  //                 SizedBox(width: 2.w),
  //                 Text(
  //                   _getMediaTypeText(replyMessage.chatMedias!.first),
  //                   style: TextStyle(fontSize: 9.sp, color: Colors.grey[500]),
  //                 ),
  //               ],
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  void _showMessageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => MessageOptionsBottomSheet(
        message: widget.message,
        isSent: widget.isSent,
        isPinned: widget.isPinned,
        isBeingRepliedTo: widget.isBeingRepliedTo,
        onReply: () {
          Navigator.pop(context);
          widget.onReply?.call();
        },
        onPin: () {
          Navigator.pop(context);
          widget.onPin?.call();
        },
        onCopy: () {
          Navigator.pop(context);
          Clipboard.setData(ClipboardData(text: widget.message));
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Message copied')));
        },
        onDelete: () {
          Navigator.pop(context);
          _showDeleteDialog();
        },
        onDeleteEveryOne: () {
          Navigator.pop(context);
          _showDeleteEveryOneDialog();
        },
        clearChat: () {
          Navigator.pop(context);
          _showClearChatDialog();
        },
      ),
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Message'),
        content: const Text('Are you sure you want to clear all message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatCubit>().deleteApi(
                chatEntryId: widget.chatEntryId,
                chatId: widget.chatId,
                mode: 'CCLR',
              );
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteEveryOneDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatCubit>().deleteApi(
                chatEntryId: widget.chatEntryId,
                chatId: widget.chatId,
                mode: 'CDISA',
              );
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatCubit>().deleteApi(
                chatEntryId: widget.chatEntryId,
                chatId: widget.chatId,
                mode: 'CDIS',
              );
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  IconData _getMediaIcon(ChatMedias media) {
    final mediaUrl = media.mediaUrl?.toLowerCase() ?? '';
    if (mediaUrl.contains('image') ||
        mediaUrl.endsWith('.jpg') ||
        mediaUrl.endsWith('.png') ||
        mediaUrl.endsWith('.jpeg')) {
      return Icons.image;
    } else if (mediaUrl.contains('video') || mediaUrl.endsWith('.mp4')) {
      return Icons.videocam;
    } else if (mediaUrl.contains('audio') || mediaUrl.endsWith('.mp3')) {
      return Icons.audiotrack;
    } else {
      return Icons.attach_file;
    }
  }

  String _getMediaTypeText(ChatMedias media) {
    final mediaUrl = media.mediaUrl?.toLowerCase() ?? '';
    if (mediaUrl.contains('image') ||
        mediaUrl.endsWith('.jpg') ||
        mediaUrl.endsWith('.png') ||
        mediaUrl.endsWith('.jpeg')) {
      return 'Photo';
    } else if (mediaUrl.contains('video') || mediaUrl.endsWith('.mp4')) {
      return 'Video';
    } else if (mediaUrl.contains('audio') || mediaUrl.endsWith('.mp3')) {
      return 'Audio';
    } else {
      return 'File';
    }
  }

  Widget _buildMessageContent() {
    switch (widget.type?.toLowerCase()) {
      case 'html':
        return FixedSizeHtmlWidget(htmlContent: widget.message);
      case 'voice':
        return widget.message.isNotEmpty
            ? _buildTextContent()
            : const SizedBox.shrink();
      case 'file':
      case 'image':
      case 'document':
        return widget.message.isNotEmpty
            ? _buildTextContent()
            : const SizedBox.shrink();
      default:
        return _buildTextContent();
    }
  }

  Widget _buildTextContent() {
    return SelectableText(
      widget.message,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
    );
  }

  Widget _buildMediaAttachments() {
    if (widget.chatMedias == null || widget.chatMedias!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.chatMedias!.length > 1)
          _buildMediaGrid()
        else
          _buildSingleMedia(widget.chatMedias!.first),
      ],
    );
  }

  Widget _buildSingleMedia(ChatMedias media) {
    return Container(
      constraints: BoxConstraints(maxWidth: 200.w, maxHeight: 200.h),
      child: OptimizedMediaPreview(media: media, isInChatBubble: true),
    );
  }

  Widget _buildMediaGrid() {
    final mediaCount = widget.chatMedias!.length;
    final maxDisplayCount = 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(
          mediaCount > maxDisplayCount ? maxDisplayCount : mediaCount,
          (index) {
            final media = widget.chatMedias![index];
            final isLast =
                index ==
                (mediaCount > maxDisplayCount
                    ? maxDisplayCount - 1
                    : mediaCount - 1);

            return Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
              constraints: BoxConstraints(
                maxHeight: 120.h,
                maxWidth: double.infinity,
              ),
              child: OptimizedMediaPreview(
                media: media,
                isInChatBubble: true,
                maxHeight: 120.h,
              ),
            );
          },
        ),
        if (mediaCount > maxDisplayCount) ...[
          SizedBox(height: 8.h),
          _buildMediaCountIndicator(mediaCount),
        ],
      ],
    );
  }

  Widget _buildMediaCountIndicator(int totalCount) {
    const maxDisplayCount = 3;
    final remainingCount = totalCount - maxDisplayCount;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attach_file, size: 14, color: Colors.grey[600]),
          SizedBox(width: 4.w),
          Text(
            '+$remainingCount more attachment${remainingCount > 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class MessageOptionsBottomSheet extends StatelessWidget {
  final String message;
  final bool isSent;
  final bool isPinned;
  final bool isBeingRepliedTo;
  final VoidCallback? onReply;
  final VoidCallback? onPin;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;
  final VoidCallback? onDeleteEveryOne;
  final VoidCallback? clearChat;

  const MessageOptionsBottomSheet({
    super.key,
    required this.message,
    required this.isSent,
    required this.isPinned,
    this.isBeingRepliedTo = false,
    this.onReply,
    this.onPin,
    this.onCopy,
    this.onDelete,
    this.onDeleteEveryOne,
    this.clearChat,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Header with message preview
            if (message.isNotEmpty) ...[
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  message.length > 50
                      ? '${message.substring(0, 50)}...'
                      : message,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14.sp,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[200],
                indent: 20.w,
                endIndent: 20.w,
              ),
            ],

            // Main actions
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.h),
                  child: Column(
                    children: [
                      _buildOption(
                        icon: Icons.reply_rounded,
                        title: 'Reply',
                        onTap: onReply,
                        isHighlighted: isBeingRepliedTo,
                      ),
                      _buildOption(
                        icon: isPinned
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                        title: isPinned ? 'Unpin Message' : 'Pin Message',
                        onTap: onPin,
                      ),
                      _buildOption(
                        icon: Icons.content_copy_rounded,
                        title: 'Copy Text',
                        onTap: onCopy,
                      ),

                      // Divider before destructive actions
                      Divider(
                        height: 24.h,
                        thickness: 1,
                        color: Colors.grey[200],
                        indent: 20.w,
                        endIndent: 20.w,
                      ),

                      // Destructive actions
                      _buildOption(
                        icon: Icons.delete_outline_rounded,
                        title: 'Delete for Me',
                        onTap: onDelete,
                        isDestructive: true,
                      ),
                      if (isSent)
                        _buildOption(
                          icon: Icons.delete_sweep_outlined,
                          title: 'Delete for Everyone',
                          onTap: onDeleteEveryOne,
                          isDestructive: true,
                        ),
                      _buildOption(
                        icon: Icons.clear_all_rounded,
                        title: 'Clear Chat',
                        onTap: clearChat,
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool isDestructive = false,
    bool isHighlighted = false,
  }) {
    final primaryColor = isDestructive
        ? Colors.red[600]!
        : isHighlighted
        ? Colors.blue[600]!
        : Colors.grey[800]!;

    final backgroundColor = isHighlighted
        ? Colors.blue[50]!
        : Colors.transparent;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: isHighlighted
            ? Border.all(color: Colors.blue[200]!, width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          splashColor: isDestructive
              ? Colors.red.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          highlightColor: isDestructive
              ? Colors.red.withOpacity(0.05)
              : Colors.grey.withOpacity(0.05),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: primaryColor, size: 20.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isDestructive ? Colors.red[700] : Colors.grey[800],
                      fontSize: 14.sp,
                      fontWeight: isHighlighted
                          ? FontWeight.w600
                          : FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (isHighlighted) ...[
                  SizedBox(width: 8.w),
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: Colors.blue[700],
                      size: 16.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OptimizedMediaPreview extends StatelessWidget {
  final ChatMedias? media;
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const OptimizedMediaPreview({
    super.key,
    this.media,
    this.isInChatBubble = true,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (media == null) return const SizedBox.shrink();
    return MediaPreviewWidget(
      key: ValueKey('media_${media!.id}'),
      media: media,
      isInChatBubble: isInChatBubble,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }
}

class MediaContainer extends StatelessWidget {
  final ChatMedias media;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const MediaContainer({
    super.key,
    required this.media,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8.r),
        child: OptimizedMediaPreview(
          media: media,
          maxWidth: width,
          maxHeight: height,
        ),
      ),
    );
  }
}
