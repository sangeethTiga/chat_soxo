import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/chat_card.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/htm_Card.dart';

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
  });

  @override
  State<ChatBubbleMessage> createState() => _ChatBubbleMessageState();
}

class _ChatBubbleMessageState extends State<ChatBubbleMessage> {
  bool _isLongPressed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onLongPress() {
    setState(() => _isLongPressed = true);
    HapticFeedback.mediumImpact();
    _showMessageOptions();
  }

  void _onTapUp() {
    if (_isLongPressed) {
      setState(() => _isLongPressed = false);
    }
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
        onDelete: widget.isSent
            ? () {
                Navigator.pop(context);
                _showDeleteDialog();
              }
            : null,
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
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
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
      child: GestureDetector(
        onLongPress: _onLongPress,
        onTapUp: (_) => _onTapUp(),
        onTap: widget.replyToMessage != null ? widget.onScrollToReply : null,
        child: Column(
          crossAxisAlignment: widget.isSent
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (widget.isBeingRepliedTo) _buildReplyStatusIndicator(),
            _buildMainBubbleWithReply(),
          ],
        ),
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

  Widget _buildMainBubbleWithReply() {
    Color bubbleColor;
    if (widget.isBeingRepliedTo) {
      bubbleColor = widget.isSent ? Color(0xFFE6F7FF) : Color(0xFFF0F8FF);
    } else {
      bubbleColor = widget.isSent ? Color(0xFFE6F2EC) : Colors.grey[200]!;
    }

    return Bubble(
      margin: BubbleEdges.only(top: 6),
      alignment: widget.isSent ? Alignment.topRight : Alignment.topLeft,
      nipWidth: 18,
      nipHeight: 10,
      radius: Radius.circular(12.r),
      nip: widget.isSent ? BubbleNip.rightTop : BubbleNip.leftTop,
      color: bubbleColor,
      child: SizedBox(
        width: 220.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.replyToMessage != null) _buildInlineReplyPreview(),
            _buildMessageContent(),
            if (widget.chatMedias != null && widget.chatMedias!.isNotEmpty) ...[
              5.verticalSpace,
              _buildMediaAttachments(),
            ],
            SizedBox(height: 4.h),
            _buildTimestampWithStatus(),
          ],
        ),
      ),
    );
  }

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

  Widget _buildInlineReplyPreview() {
    final replyMessage = widget.replyToMessage!;
    final isReplyFromMe = replyMessage.senderId == widget.messageData?.senderId;
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
      style: TextStyle(fontSize: 14, color: Colors.black87),
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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          Column(
            children: [
              _buildOption(
                icon: Icons.reply,
                title: 'Reply',
                onTap: onReply,
                isHighlighted: isBeingRepliedTo,
              ),
              _buildOption(
                icon: isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                title: isPinned ? 'Unpin' : 'Pin',
                onTap: onPin,
              ),
              _buildOption(icon: Icons.copy, title: 'Copy', onTap: onCopy),
              // if (isSent && onDelete != null)
              // _buildOption(
              //   icon: Icons.delete_outline,
              //   title: 'Delete',
              //   onTap: onDelete,
              //   isDestructive: true,
              // ),
            ],
          ),
          SizedBox(height: 20.h),
        ],
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
    final color = isDestructive
        ? Colors.red
        : isHighlighted
        ? Colors.blue
        : Colors.grey[700];

    return Container(
      decoration: isHighlighted
          ? BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              border: Border(
                left: BorderSide(color: Colors.blue, width: 3.w),
              ),
            )
          : null,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.black87,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        trailing: isHighlighted
            ? Icon(Icons.keyboard_arrow_right, color: Colors.blue)
            : null,
        onTap: onTap,
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
