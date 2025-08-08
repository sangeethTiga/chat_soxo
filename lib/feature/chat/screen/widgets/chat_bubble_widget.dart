import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/htm_Card.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/pdf_viewer_screen.dart'; // Import your MediaPreviewWidget

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
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() => _position = position);
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() => _isPlaying = state == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 280.w),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: widget.isSent ? Colors.blue[100] : Colors.grey[200],
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
        return _buildVoiceMessage();

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
    return Text(
      widget.message,
      style: TextStyle(fontSize: 14.sp, color: Colors.black87),
    );
  }

  Widget _buildVoiceMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.mic, size: 16.sp, color: Colors.grey[600]),
        SizedBox(width: 8.w),
        Text(
          'Voice message',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black87,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaAttachments() {
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
      child: MediaPreviewWidget(media: media),
    );
  }

  Widget _buildMediaGrid() {
    final mediaCount = widget.chatMedias!.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display all media items vertically (column-wise)
        ...widget.chatMedias!.asMap().entries.map((entry) {
          final index = entry.key;
          final media = entry.value;
          final isLast = index == mediaCount - 1;

          return Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
            constraints: BoxConstraints(
              maxHeight: 120.h,
              maxWidth: double.infinity,
            ),
            child: MediaPreviewWidget(media: media),
          );
        }),

        // Show count indicator if there are many items
        if (mediaCount > 3)
          Container(
            margin: EdgeInsets.only(top: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              '$mediaCount attachments',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

// Additional helper widget for better media layout
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
        child: MediaPreviewWidget(media: media),
      ),
    );
  }
}
