import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';
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
    print('Message type: ${widget.type}');
    print('Chat medias: ${widget.chatMedias?.length ?? 0}');
    if (widget.chatMedias != null) {
      for (var media in widget.chatMedias!) {
        print('Media type: ${media.mediaType}, fileName: ${media.fileName}');
      }
    }
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
            // _buildImageContent(),
            // if (widget.chatMedias?.any(
            //       (media) =>
            //           media.mediaType == 'document' ||
            //           media.fileName?.toLowerCase().endsWith('.pdf') == true,
            //     ) ??
            //     false)
            //   _buildDocumentContent()
            // else
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

  Widget _buildImageContent() {
    if (widget.chatMedias?.isNotEmpty ?? false) {
      return Column(
        children: [
          ...widget.chatMedias!
              .where((media) => media.mediaType == 'image')
              .map(
                (media) => Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      'http://20.244.37.96:5002${media.mediaUrl}',
                      width: 200.w,
                      height: 150.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200.w,
                          height: 150.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 40.sp,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                media.fileName ?? 'Image',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          if (widget.message.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              widget.message,
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),
          ],
        ],
      );
    }
    return _buildTextContent();
  }

  Widget _buildDocumentContent() {
    if (widget.chatMedias?.isNotEmpty ?? false) {
      return Column(
        children: [
          ...widget.chatMedias!
              .where(
                (media) =>
                    media.mediaType == 'document' ||
                    media.fileName?.toLowerCase().endsWith('.pdf') == true,
              )
              .map(
                (media) => Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                        size: 32.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              media.fileName ?? 'Document',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _formatFileSize(media.mediaSize ?? 0),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _downloadFile(media.mediaUrl),
                        icon: Icon(Icons.download, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
          if (widget.message.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              widget.message,
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),
          ],
        ],
      );
    }
    return _buildTextContent();
  }

  Widget _buildVoiceContent() {
    if (widget.chatMedias?.isNotEmpty ?? false) {
      final voiceMedia = widget.chatMedias!.firstWhere(
        (media) => media.mediaType == 'audio' || media.mediaType == 'voice',
        orElse: () => widget.chatMedias!.first,
      );

      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _togglePlayPause(voiceMedia.mediaUrl),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _duration.inMilliseconds > 0
                        ? _position.inMilliseconds / _duration.inMilliseconds
                        : 0.0,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return _buildTextContent();
  }

  Widget _buildVideoContent() {
    if (widget.chatMedias?.isNotEmpty ?? false) {
      final videoMedia = widget.chatMedias!.firstWhere(
        (media) => media.mediaType == 'video',
        orElse: () => widget.chatMedias!.first,
      );

      return Container(
        margin: EdgeInsets.only(bottom: 8.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Stack(
            children: [
              Container(
                width: 200.w,
                height: 150.h,
                color: Colors.black12,
                child: Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    size: 50.sp,
                    color: Colors.white70,
                  ),
                ),
              ),
              Positioned(
                bottom: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    videoMedia.fileName ?? 'Video',
                    style: TextStyle(fontSize: 10.sp, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return _buildTextContent();
  }

  Future<void> _togglePlayPause(String? audioUrl) async {
    if (audioUrl == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource('http://20.244.37.96:5002$audioUrl'));
    }
  }

  void _downloadFile(String? fileUrl) {
    if (fileUrl != null) {
      // Implement file download logic
      // You can use packages like dio for downloading
      print('Downloading file: http://20.244.37.96:5002$fileUrl');
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    int i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(1)} ${suffixes[i]}';
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

// Widget _buildMessageContent(
//   BuildContext context,
//   bool isSentMessage,
//   String html,
// ) {
//   // if (html == 'html') {
//   return FixedSizeHtmlWidget(htmlContent: message);
// }
//   // {
//   //   return Text('Hello');
//   // }
//   //  else {
//   //   return _buildTextMessage(isSentMessage);
//   // }
//   // }

// //   Widget _buildTextMessage(bool isSentMessage) {
// //     return Text(
// //       message,
// //       style: isSentMessage
// //           ? const TextStyle(fontSize: 14, color: Color(0xFF4C4C4C))
// //           : FontPalette.hW500S14.copyWith(color: const Color(0XFF4C4C4C)),
// //     );
// //   }
// // }
