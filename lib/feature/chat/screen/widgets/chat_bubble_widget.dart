import 'package:flutter/material.dart';
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

  const ChatBubbleMessage({
    super.key,
    this.type,
    required this.message,
    required this.timestamp,
    required this.isSent,
    this.chatMedias,
  });

  @override
  State<ChatBubbleMessage> createState() => _ChatBubbleMessageState();
}

class _ChatBubbleMessageState extends State<ChatBubbleMessage> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 280.w),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: widget.isSent ? Color(0xFFE6F2EC) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMessageContent(),

            // Media attachments section
            if (widget.chatMedias != null && widget.chatMedias!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              _buildMediaAttachments(),
            ],

            SizedBox(height: 4.h),
            Text(
              widget.timestamp,
              style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (widget.type?.toLowerCase()) {
      case 'html':
        return FixedSizeHtmlWidget(htmlContent: widget.message);

      case 'voice':
        // REMOVED: Don't show separate voice UI here
        // Voice will be handled by MediaPreviewWidget in _buildMediaAttachments()
        return widget.message.isNotEmpty
            ? _buildTextContent()
            : const SizedBox.shrink();

      case 'file':
      case 'image':
      case 'document':
        // For these types, we'll show the message text (if any) and media will be shown separately
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
      style: TextStyle(fontSize: 14.sp, color: Colors.black87),
    );
  }

  Widget _buildMediaAttachments() {
    if (widget.chatMedias == null || widget.chatMedias!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Media grid for multiple attachments
        if (widget.chatMedias!.length > 1)
          _buildMediaGrid()
        else
          // Single media item
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
        // Display media items efficiently using ListView.separated for better performance
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

        // Show count indicator if there are more than maxDisplayCount items
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
          Icon(Icons.attach_file, size: 14.sp, color: Colors.grey[600]),
          SizedBox(width: 4.w),
          Text(
            '+$remainingCount more attachment${remainingCount > 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Optimized media preview that prevents memory leaks
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

    // Use a key to prevent unnecessary rebuilds
    return MediaPreviewWidget(
      key: ValueKey('media_${media!.id}'),
      media: media,
      isInChatBubble: isInChatBubble,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }
}

/// Enhanced media container with better error handling
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
