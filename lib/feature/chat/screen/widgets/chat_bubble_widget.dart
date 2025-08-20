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
  int? _currentUserId;

  static const double _replyThreshold = 60.0;
  static const double _maxDragDistance = 100.0;

  // Cache computed values
  late final Color _bubbleColor;
  late final Color _replyBorderColor;
  late final Color _replyBackgroundColor;
  bool _isReplyFromMe = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeColors();
    _loadCurrentUserId();
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

  void _initializeColors() {
    if (widget.isBeingRepliedTo) {
      _bubbleColor = widget.isSent
          ? const Color(0xFFE6F7FF)
          : const Color(0xFFF0F8FF);
      _replyBorderColor = widget.isSent
          ? Colors.green[600]!
          : Colors.blue[600]!;
      _replyBackgroundColor = widget.isSent
          ? Colors.green.withOpacity(0.15)
          : Colors.blue.withOpacity(0.15);
    } else {
      _bubbleColor = widget.isSent
          ? const Color(0xFFE6F2EC)
          : Colors.grey[200]!;
      _replyBorderColor = widget.isSent ? Colors.green : Colors.blue;
      _replyBackgroundColor = widget.isSent
          ? Colors.green.withOpacity(0.1)
          : Colors.blue.withOpacity(0.1);
    }
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final user = await AuthUtils.instance.readUserData();
      final userId = int.tryParse(user?.result?.userId?.toString() ?? '0') ?? 0;
      if (mounted) {
        setState(() {
          _currentUserId = userId;
          _isReplyFromMe = widget.replyToMessage?.senderId == userId;
        });
      }
    } catch (e) {
      log('Error getting current user ID: $e');
      if (mounted) {
        setState(() {
          _currentUserId = 0;
          _isReplyFromMe = false;
        });
      }
    }
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
            if (_dragDistance > 0)
              _ReplyIcon(
                isSent: widget.isSent,
                hasTriggeredReply: _hasTriggeredReply,
                animation: _replyIconAnimation,
              ),
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
              child: _MessageContainer(
                widget: widget,
                bubbleColor: _bubbleColor,
                replyBorderColor: _replyBorderColor,
                replyBackgroundColor: _replyBackgroundColor,
                isReplyFromMe: _isReplyFromMe,
                currentUserId: _currentUserId,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}

// Extracted static widgets to prevent rebuilds
class _ReplyIcon extends StatelessWidget {
  final bool isSent;
  final bool hasTriggeredReply;
  final Animation<double> animation;

  const _ReplyIcon({
    required this.isSent,
    required this.hasTriggeredReply,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: isSent ? 20.w : null,
      left: isSent ? null : 20.w,
      top: 0,
      bottom: 0,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Center(
            child: Transform.scale(
              scale: 0.5 + (animation.value * 0.5),
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: hasTriggeredReply
                      ? Colors.blue
                      : Colors.grey.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.reply, color: Colors.white, size: 20),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MessageContainer extends StatelessWidget {
  final ChatBubbleMessage widget;
  final Color bubbleColor;
  final Color replyBorderColor;
  final Color replyBackgroundColor;
  final bool isReplyFromMe;
  final int? currentUserId;

  const _MessageContainer({
    required this.widget,
    required this.bubbleColor,
    required this.replyBorderColor,
    required this.replyBackgroundColor,
    required this.isReplyFromMe,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
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
          if (widget.isBeingRepliedTo) _ReplyStatusIndicator(widget: widget),
          _MainBubble(
            widget: widget,
            bubbleColor: bubbleColor,
            replyBorderColor: replyBorderColor,
            replyBackgroundColor: replyBackgroundColor,
            isReplyFromMe: isReplyFromMe,
            currentUserId: currentUserId,
          ),
        ],
      ),
    );
  }
}

class _ReplyStatusIndicator extends StatelessWidget {
  final ChatBubbleMessage widget;

  const _ReplyStatusIndicator({required this.widget});

  @override
  Widget build(BuildContext context) {
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
}

class _MainBubble extends StatelessWidget {
  final ChatBubbleMessage widget;
  final Color bubbleColor;
  final Color replyBorderColor;
  final Color replyBackgroundColor;
  final bool isReplyFromMe;
  final int? currentUserId;

  const _MainBubble({
    required this.widget,
    required this.bubbleColor,
    required this.replyBorderColor,
    required this.replyBackgroundColor,
    required this.isReplyFromMe,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: widget.isSent
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.isSent) ...[
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: _UserAvatar(messageData: widget.messageData),
          ),
          SizedBox(width: 8.w),
        ],
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
              width: 270.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.isSent &&
                      widget.messageData?.sender?.name != null)
                    _SenderName(name: widget.messageData!.sender!.name!),
                  if (widget.replyToMessage != null)
                    _InlineReplyPreview(
                      widget: widget,
                      replyBorderColor: replyBorderColor,
                      replyBackgroundColor: replyBackgroundColor,
                      isReplyFromMe: isReplyFromMe,
                    ),
                  _MessageContent(type: widget.type, message: widget.message),
                  if (widget.chatMedias?.isNotEmpty == true) ...[
                    SizedBox(height: 5.h),
                    _MediaAttachments(chatMedias: widget.chatMedias!),
                  ],
                  SizedBox(height: 4.h),
                  _TimestampWithStatus(widget: widget),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final Entry? messageData;

  const _UserAvatar({required this.messageData});

  @override
  Widget build(BuildContext context) {
    return ChatAvatar(
      size: 26.h,
      name: messageData?.sender?.name ?? '',
      imageUrl: messageData?.sender?.imageUrl,
    );
  }
}

class _SenderName extends StatelessWidget {
  final String name;

  const _SenderName({required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }
}

class _InlineReplyPreview extends StatelessWidget {
  final ChatBubbleMessage widget;
  final Color replyBorderColor;
  final Color replyBackgroundColor;
  final bool isReplyFromMe;

  const _InlineReplyPreview({
    required this.widget,
    required this.replyBorderColor,
    required this.replyBackgroundColor,
    required this.isReplyFromMe,
  });

  @override
  Widget build(BuildContext context) {
    final replyMessage = widget.replyToMessage!;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: replyBackgroundColor,
        borderRadius: BorderRadius.circular(6.r),
        border: Border(
          left: BorderSide(
            color: replyBorderColor,
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
                isReplyFromMe ? 'You' : (replyMessage.sender?.name ?? 'User'),
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
                    style: TextStyle(fontSize: 9.sp, color: Colors.grey[500]),
                  ),
                ],
              ),
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
}

class _MessageContent extends StatelessWidget {
  final String? type;
  final String message;

  const _MessageContent({required this.type, required this.message});

  @override
  Widget build(BuildContext context) {
    switch (type?.toLowerCase()) {
      case 'html':
        return FixedSizeHtmlWidget(htmlContent: message);
      case 'voice':
      case 'file':
      case 'image':
      case 'document':
        return message.isNotEmpty
            ? _TextContent(message: message)
            : const SizedBox.shrink();
      default:
        return _TextContent(message: message);
    }
  }
}

class _TextContent extends StatelessWidget {
  final String message;

  const _TextContent({required this.message});

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      message,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
    );
  }
}

class _MediaAttachments extends StatelessWidget {
  final List<ChatMedias> chatMedias;

  const _MediaAttachments({required this.chatMedias});

  @override
  Widget build(BuildContext context) {
    if (chatMedias.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (chatMedias.length > 1)
          _MediaGrid(chatMedias: chatMedias)
        else
          _SingleMedia(media: chatMedias.first),
      ],
    );
  }
}

class _SingleMedia extends StatelessWidget {
  final ChatMedias media;

  const _SingleMedia({required this.media});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 200.w, maxHeight: 200.h),
      child: OptimizedMediaPreview(media: media, isInChatBubble: true),
    );
  }
}

class _MediaGrid extends StatelessWidget {
  final List<ChatMedias> chatMedias;
  static const int maxDisplayCount = 3;

  const _MediaGrid({required this.chatMedias});

  @override
  Widget build(BuildContext context) {
    final mediaCount = chatMedias.length;
    final displayCount = mediaCount > maxDisplayCount
        ? maxDisplayCount
        : mediaCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(displayCount, (index) {
          final media = chatMedias[index];
          final isLast = index == displayCount - 1;

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
        }),
        if (mediaCount > maxDisplayCount) ...[
          SizedBox(height: 8.h),
          _MediaCountIndicator(totalCount: mediaCount),
        ],
      ],
    );
  }
}

class _MediaCountIndicator extends StatelessWidget {
  final int totalCount;
  static const int maxDisplayCount = 3;

  const _MediaCountIndicator({required this.totalCount});

  @override
  Widget build(BuildContext context) {
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

class _TimestampWithStatus extends StatelessWidget {
  final ChatBubbleMessage widget;

  const _TimestampWithStatus({required this.widget});

  @override
  Widget build(BuildContext context) {
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
}

// Bottom sheet remains the same but extracted for clarity
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

                      Divider(
                        height: 24.h,
                        thickness: 1,
                        color: Colors.grey[200],
                        indent: 20.w,
                        endIndent: 20.w,
                      ),

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

// Optimized media preview widgets
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
