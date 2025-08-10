import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/htm_Card.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/chat_card.dart';

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
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Stream subscriptions for proper cleanup
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    // Only initialize audio player if we actually need it
    if (widget.type?.toLowerCase() == 'voice') {
      _initializeAudioPlayer();
    }
  }

  void _initializeAudioPlayer() {
    _audioPlayer = AudioPlayer();

    // Store subscriptions so we can cancel them properly
    _durationSubscription = _audioPlayer!.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() => _duration = duration);
      }
    });

    _positionSubscription = _audioPlayer!.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });

    _playerStateSubscription = _audioPlayer!.onPlayerStateChanged.listen((
      state,
    ) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });
  }

  @override
  void dispose() {
    // Cancel all subscriptions before disposing
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();

    // Dispose audio player
    _audioPlayer?.dispose();

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
    return SelectableText(
      widget.message,
      style: TextStyle(fontSize: 14.sp, color: Colors.black87),
    );
  }

  Widget _buildVoiceMessage() {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _toggleVoicePlayback,
            child: Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 16.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.mic, size: 12.sp, color: Colors.blue[600]),
                  SizedBox(width: 4.w),
                  Text(
                    'Voice message',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                _formatDuration(_duration),
                style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleVoicePlayback() async {
    if (_audioPlayer == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer!.pause();
      } else {
        // Here you would play the actual voice file
        // For now, this is just a placeholder
        // await _audioPlayer!.play(DeviceFileSource(voiceFilePath));
      }
    } catch (e) {
      // Handle playback error
      debugPrint('Voice playback error: $e');
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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

/// Mixin to help with audio player lifecycle management
mixin AudioPlayerMixin<T extends StatefulWidget> on State<T> {
  AudioPlayer? audioPlayer;
  StreamSubscription<Duration>? durationSubscription;
  StreamSubscription<Duration>? positionSubscription;
  StreamSubscription<PlayerState>? playerStateSubscription;

  void initializeAudioPlayer() {
    audioPlayer = AudioPlayer();

    durationSubscription = audioPlayer!.onDurationChanged.listen((duration) {
      if (mounted) onDurationChanged(duration);
    });

    positionSubscription = audioPlayer!.onPositionChanged.listen((position) {
      if (mounted) onPositionChanged(position);
    });

    playerStateSubscription = audioPlayer!.onPlayerStateChanged.listen((state) {
      if (mounted) onPlayerStateChanged(state);
    });
  }

  void disposeAudioPlayer() {
    durationSubscription?.cancel();
    positionSubscription?.cancel();
    playerStateSubscription?.cancel();
    audioPlayer?.dispose();
  }

  // Abstract methods to be implemented by the mixing class
  void onDurationChanged(Duration duration);
  void onPositionChanged(Duration position);
  void onPlayerStateChanged(PlayerState state);
}
