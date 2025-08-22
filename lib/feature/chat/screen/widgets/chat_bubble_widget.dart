import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

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
import 'package:soxo_chat/shared/widgets/media/media_cache.dart';

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
  final ScrollController? scrollController;
  final Map<String, GlobalKey>? messageKeys;
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
    this.scrollController,
    this.messageKeys,
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

  late final Color _bubbleColor;
  late final Color _replyBorderColor;
  late final Color _replyBackgroundColor;
  final bool _isReplyFromMe = false;
  final Set<int> _pinnedMessageIds = {};
  late Map<String, GlobalKey> _messageKeys;
  @override
  void initState() {
    super.initState();
    _messageKeys = widget.messageKeys ?? {};

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
        });
      }
    } catch (e) {
      dev.log('Error getting current user ID: $e');
      if (mounted) {
        setState(() {
          _currentUserId = 0;
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
    final isPinned = widget.isPinned;
    // final pinnedBorderColor = isPinned ? Colors.amber[600]! : null;

    return Stack(
      children: [
        Container(
          padding: widget.isBeingRepliedTo
              ? EdgeInsets.all(6.w)
              : EdgeInsets.zero,
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
              if (widget.isBeingRepliedTo)
                _ReplyStatusIndicator(widget: widget),
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
        ),
        if (isPinned)
          Positioned(
            right: 16.w,
            child: Icon(Icons.push_pin, size: 18, color: Colors.amber[600]),
          ),
      ],
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
            padding: BubbleEdges.only(left: 3, right: 3),
            margin: BubbleEdges.only(top: 6),
            alignment: widget.isSent ? Alignment.topRight : Alignment.topLeft,
            nipWidth: 18,
            nipHeight: 10,
            radius: Radius.circular(12.r),
            nip: widget.isSent ? BubbleNip.rightTop : BubbleNip.leftTop,
            color: bubbleColor,
            child: SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.isSent &&
                      widget.messageData?.sender?.name != null)
                    Padding(
                      padding: EdgeInsets.only(left: 3.w, bottom: 3.h),
                      child: _SenderName(
                        name: widget.messageData!.sender!.name!,
                      ),
                    ),
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
    return CachedChatAvatar(
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
            color: getColorFromName(name),
          ),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }
}

Color getColorFromName(String name) {
  final int hash = name.hashCode;
  final int index = hash % nameColors.length;
  return nameColors[index];
}

final List<Color> nameColors = [
  Colors.red,
  Colors.orange,
  Colors.blue,
  Colors.green,
  Colors.purple,
  Colors.teal,
  Colors.pink,
  Colors.indigo,
  Colors.amber,
];

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
              FutureBuilder(
                future: AuthUtils.instance.readUserData(),
                builder: (context, asyncSnapshot) {
                  dev.log(
                    "ID =- =-= ${widget.replyToMessage?.senderId == asyncSnapshot.data?.result?.userId}. ${widget.replyToMessage?.senderId}. ${asyncSnapshot.data?.result?.userId}",
                  );
                  return Text(
                    widget.replyToMessage?.senderId ==
                            asyncSnapshot.data?.result?.userId
                        ? 'You'
                        : (replyMessage.sender?.name ?? ''),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: replyBorderColor.withOpacity(0.9),
                    ),
                  );
                },
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
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: SelectableText(
        message,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }
}

class _MediaGrid extends StatelessWidget {
  final List<ChatMedias> chatMedias;
  static const int maxDisplayCount = 4;

  const _MediaGrid({required this.chatMedias});

  @override
  Widget build(BuildContext context) {
    final mediaCount = chatMedias.length;
    final displayCount = mediaCount > maxDisplayCount
        ? maxDisplayCount
        : mediaCount;

    final imageMedias = chatMedias
        .where((media) => _isImageMedia(media))
        .toList();
    final imageCount = imageMedias.length;

    if (imageCount == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(displayCount, (index) {
            final media = chatMedias[index];
            final isLast = index == displayCount - 1;

            return Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
              child: OptimizedMediaPreview(media: media, isInChatBubble: true),
            );
          }),
          if (mediaCount > maxDisplayCount) ...[
            SizedBox(height: 8.h),
            _MediaCountIndicator(totalCount: mediaCount),
          ],
        ],
      );
    }

    return _buildImageGrid(context, imageMedias, mediaCount);
  }

  bool _isImageMedia(ChatMedias media) {
    final mediaType = media.mediaType?.toLowerCase() ?? '';
    final mediaUrl = media.mediaUrl?.toLowerCase() ?? '';

    return mediaType.contains('image') ||
        mediaUrl.endsWith('.jpg') ||
        mediaUrl.endsWith('.jpeg') ||
        mediaUrl.endsWith('.png') ||
        mediaUrl.endsWith('.gif') ||
        mediaUrl.endsWith('.webp');
  }

  Widget _buildImageGrid(
    BuildContext context,
    List<ChatMedias> imageMedias,
    int totalMediaCount,
  ) {
    final imageCount = imageMedias.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageCount == 1)
          _buildSingleImage(context, imageMedias[0])
        else if (imageCount == 2)
          _buildTwoImages(context, imageMedias)
        else if (imageCount == 3)
          _buildThreeImages(context, imageMedias)
        else
          _buildFourOrMoreImages(context, imageMedias),

        if (totalMediaCount > imageCount) ...[
          SizedBox(height: 8.h),
          _MediaCountIndicator(totalCount: totalMediaCount - imageCount),
        ],
      ],
    );
  }

  Widget _buildSingleImage(BuildContext context, ChatMedias media) {
    return GestureDetector(
      onTap: () => _showImageViewer(context, [media], 0),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: double.infinity,
          maxHeight: 300.h,
          minWidth: double.infinity,
          minHeight: 80.h,
        ),
        child: Hero(
          tag: 'image_${media.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: _FixedSizeImageWrapper(
              media: media,
              width: null,
              height: null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTwoImages(BuildContext context, List<ChatMedias> imageMedias) {
    return Container(
      height: 180.h,
      constraints: BoxConstraints(minWidth: 200.w),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showImageViewer(context, imageMedias, 0),
              child: Hero(
                tag: 'image_${imageMedias[0].id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    bottomLeft: Radius.circular(12.r),
                  ),
                  child: _FixedSizeImageWrapper(
                    media: imageMedias[0],
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: GestureDetector(
              onTap: () => _showImageViewer(context, imageMedias, 1),
              child: Hero(
                tag: 'image_${imageMedias[1].id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12.r),
                    bottomRight: Radius.circular(12.r),
                  ),
                  child: _FixedSizeImageWrapper(
                    media: imageMedias[1],
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreeImages(BuildContext context, List<ChatMedias> imageMedias) {
    return Container(
      height: 180.h,
      constraints: BoxConstraints(minWidth: 200.w),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () => _showImageViewer(context, imageMedias, 0),
              child: Hero(
                tag: 'image_${imageMedias[0].id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    bottomLeft: Radius.circular(12.r),
                  ),
                  child: _FixedSizeImageWrapper(
                    media: imageMedias[0],
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showImageViewer(context, imageMedias, 1),
                    child: Hero(
                      tag: 'image_${imageMedias[1].id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12.r),
                        ),
                        child: _FixedSizeImageWrapper(
                          media: imageMedias[1],
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showImageViewer(context, imageMedias, 2),
                    child: Hero(
                      tag: 'image_${imageMedias[2].id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(12.r),
                        ),
                        child: _FixedSizeImageWrapper(
                          media: imageMedias[2],
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFourOrMoreImages(
    BuildContext context,
    List<ChatMedias> imageMedias,
  ) {
    final hasMoreImages = imageMedias.length > 4;

    return Container(
      height: 180.h,
      constraints: BoxConstraints(minWidth: 200.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showImageViewer(context, imageMedias, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.r),
                      ),
                      child: _FixedSizeImageWrapper(
                        media: imageMedias[0],
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showImageViewer(context, imageMedias, 1),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12.r),
                      ),
                      child: _FixedSizeImageWrapper(
                        media: imageMedias[1],
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showImageViewer(context, imageMedias, 2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12.r),
                      ),
                      child: _FixedSizeImageWrapper(
                        media: imageMedias[2],
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Expanded(
                  child: GestureDetector(
                    onTap: hasMoreImages
                        ? () => _showImageGallery(context, imageMedias)
                        : () => _showImageViewer(context, imageMedias, 3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(12.r),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _FixedSizeImageWrapper(
                            media: imageMedias[3],
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          if (hasMoreImages)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(12.r),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '+${imageMedias.length - 4}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImageViewer(
    BuildContext context,
    List<ChatMedias> images,
    int initialIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ImageViewerScreen(images: images, initialIndex: initialIndex),
      ),
    );
  }

  void _showImageGallery(BuildContext context, List<ChatMedias> images) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageGalleryScreen(images: images),
      ),
    );
  }
}

class ImageGalleryScreen extends StatelessWidget {
  final List<ChatMedias> images;

  const ImageGalleryScreen({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${images.length} Photos',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _openImageViewer(context, index),
            child: Hero(
              tag: 'image_${images[index].id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: _EnhancedImagePreview(
                  media: images[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openImageViewer(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ImageViewerScreen(images: images, initialIndex: index),
      ),
    );
  }
}

class ImageViewerScreen extends StatefulWidget {
  final List<ChatMedias> images;
  final int initialIndex;

  const ImageViewerScreen({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} of ${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareImage(widget.images[_currentIndex]),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () => _downloadImage(widget.images[_currentIndex]),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return Center(
            child: Hero(
              tag: 'image_${widget.images[index].id}',
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: _EnhancedImagePreview(
                  media: widget.images[index],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < widget.images.length && i < 10; i++)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _currentIndex ? Colors.white : Colors.grey,
                ),
              ),
            if (widget.images.length > 10)
              const Text(' ...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _shareImage(ChatMedias image) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality would be implemented here'),
      ),
    );
  }

  void _downloadImage(ChatMedias image) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download functionality would be implemented here'),
      ),
    );
  }
}

class _FixedSizeImageWrapper extends StatelessWidget {
  final ChatMedias media;
  final double? width;
  final double? height;

  const _FixedSizeImageWrapper({required this.media, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: Colors.grey[100]),
      child: RepaintBoundary(
        child: MediaPreviewWidget(
          key: ValueKey('media_${media.id}'),
          media: media,
          isInChatBubble: true,
          maxWidth: width,
          maxHeight: height,
        ),
      ),
    );
  }
}

class _EnhancedImagePreview extends StatelessWidget {
  final ChatMedias media;
  final BoxFit fit;

  const _EnhancedImagePreview({required this.media, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ChatCubit>();
    final fileUrl = cubit.getFileUrl(media.id.toString());
    final isLoading = cubit.isFileLoading(media.id.toString());

    if (fileUrl != null && !MediaCache.isLoading(media.id.toString())) {
      return _buildImage(fileUrl);
    }

    if (fileUrl == null &&
        !isLoading &&
        !MediaCache.isLoading(media.id.toString())) {
      if (media.mediaUrl != null && media.mediaUrl!.isNotEmpty) {
        return _buildImage(media.mediaUrl!);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.read<ChatCubit>().loadMediaFile(media);
        }
      });

      MediaCache.setLoading(media.id.toString());
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: 20.w,
          height: 20.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('data:')) {
      return FutureBuilder<Uint8List?>(
        future: _decodeBase64Image(imageUrl),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.memory(
              snapshot.data!,
              fit: fit,
              width: double.infinity,
              height: double.infinity,
            );
          }
          return _buildErrorPlaceholder();
        },
      );
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
      );
    }

    return FutureBuilder<bool>(
      future: File(imageUrl).exists(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          return Image.file(
            File(imageUrl),
            fit: fit,
            width: double.infinity,
            height: double.infinity,
          );
        }
        return _buildErrorPlaceholder();
      },
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: 20.w,
          height: 20.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 24.sp, color: Colors.grey[400]),
          SizedBox(height: 4.h),
          Text(
            'Image unavailable',
            style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Future<Uint8List?> _decodeBase64Image(String dataUrl) async {
    try {
      final base64Data = dataUrl.contains(',')
          ? dataUrl.split(',').last
          : dataUrl;
      return base64Decode(base64Data);
    } catch (e) {
      return null;
    }
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

    return RepaintBoundary(
      child: MediaPreviewWidget(
        key: ValueKey('media_${media!.id}'),
        media: media,
        isInChatBubble: isInChatBubble,
        maxWidth: maxWidth ?? double.infinity,
        maxHeight: maxHeight,
      ),
    );
  }
}

class _MediaAttachments extends StatelessWidget {
  final List<ChatMedias> chatMedias;

  const _MediaAttachments({required this.chatMedias});

  @override
  Widget build(BuildContext context) {
    if (chatMedias.isEmpty) return const SizedBox.shrink();

    final imageMedias = chatMedias
        .where((media) => _isImageMedia(media))
        .toList();
    final otherMedias = chatMedias
        .where((media) => !_isImageMedia(media))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageMedias.isNotEmpty) _MediaGrid(chatMedias: imageMedias),
        if (otherMedias.isNotEmpty) ...[
          if (imageMedias.isNotEmpty) SizedBox(height: 8.h),
          ...otherMedias.map(
            (media) => Container(
              margin: EdgeInsets.only(bottom: 8.h),
              child: OptimizedMediaPreview(media: media, isInChatBubble: true),
            ),
          ),
        ],
      ],
    );
  }

  bool _isImageMedia(ChatMedias media) {
    final mediaType = media.mediaType?.toLowerCase() ?? '';
    final mediaUrl = media.mediaUrl?.toLowerCase() ?? '';

    return mediaType.contains('image') ||
        mediaUrl.endsWith('.jpg') ||
        mediaUrl.endsWith('.jpeg') ||
        mediaUrl.endsWith('.png') ||
        mediaUrl.endsWith('.gif') ||
        mediaUrl.endsWith('.webp');
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
