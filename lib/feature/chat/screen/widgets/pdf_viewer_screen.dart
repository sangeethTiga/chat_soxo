import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';

class MediaPreviewWidget extends StatelessWidget {
  final ChatMedias? media;
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const MediaPreviewWidget({
    super.key,
    required this.media,
    this.isInChatBubble = true,
    this.maxWidth,
    this.maxHeight,
  });

  Future<String?> _saveBase64ToFile(String base64Data, String fileName) async {
    try {
      String cleanBase64 = base64Data;
      if (base64Data.contains(',')) {
        cleanBase64 = base64Data.split(',').last;
      }

      final bytes = base64Decode(cleanBase64);
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      log('Error saving base64 to file: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (media == null) return const SizedBox.shrink();

    final cubit = context.watch<ChatCubit>();
    final mediaId = media?.id.toString();
    final fileUrl = cubit.getFileUrl(mediaId ?? '');
    final fileType = cubit.getFileType(mediaId ?? '');
    final isLoading = cubit.isFileLoading(mediaId ?? '');

    if (fileUrl == null && !isLoading) {
      context.read<ChatCubit>().loadMediaFile(media ?? ChatMedias());
    }

    if (isLoading) {
      return Container(
        width: maxWidth ?? (isInChatBubble ? 100.w : 200.w),
        height: maxHeight ?? (isInChatBubble ? 100.h : 200.h),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // Handle different file types
    switch (fileType) {
      case 'image':
        return _buildImageWidget(fileUrl);
      case 'audio':
        return _buildAudioWidget(fileUrl, mediaId ?? '');

      case 'document':
        return _buildDocumentWidget(context, fileUrl, mediaId ?? '');
      default:
        return _buildUnknownFileWidget();
    }
  }

  Widget _buildImageWidget(String? fileUrl) {
    if (fileUrl == null) return const SizedBox.shrink();

    try {
      final imageBytes = base64Decode(fileUrl.split(',').last);
      return Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? (isInChatBubble ? 200.w : double.infinity),
          maxHeight: maxHeight ?? (isInChatBubble ? 200.h : double.infinity),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget('Failed to load image');
            },
          ),
        ),
      );
    } catch (e) {
      return _buildErrorWidget('Invalid image data');
    }
  }

  Widget _buildAudioWidget(String? fileUrl, String mediaId) {
    if (fileUrl == null) return const SizedBox.shrink();

    return Container(
      width: maxWidth ?? (isInChatBubble ? 250.w : 300.w),
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? (isInChatBubble ? 80.h : 120.h),
      ),
      child: CompactAudioPlayerWidget(
        fileUrl: fileUrl,
        mediaId: mediaId,
        saveBase64ToFile: _saveBase64ToFile,
        isCompact: isInChatBubble,
      ),
    );
  }

  Widget _buildDocumentWidget(
    BuildContext context,
    String? fileUrl,
    String mediaId,
  ) {
    if (fileUrl == null) return const SizedBox.shrink();

    return Container(
      width: maxWidth ?? (isInChatBubble ? 150.w : 200.w),
      height: maxHeight ?? (isInChatBubble ? 60.h : 80.h),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: InkWell(
        onTap: () => _openPDF(context, fileUrl, mediaId),
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Row(
            children: [
              Icon(
                Icons.picture_as_pdf,
                color: Colors.red[700],
                size: isInChatBubble ? 24.sp : 32.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PDF Document',
                      style: TextStyle(
                        fontSize: isInChatBubble ? 12.sp : 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isInChatBubble) ...[
                      SizedBox(height: 2.h),
                      Text(
                        'Tap to view',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnknownFileWidget() {
    return Container(
      width: maxWidth ?? (isInChatBubble ? 100.w : 150.w),
      height: maxHeight ?? (isInChatBubble ? 60.h : 80.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file,
            size: isInChatBubble ? 24.sp : 32.sp,
            color: Colors.grey[600],
          ),
          SizedBox(height: 4.h),
          Text(
            'File',
            style: TextStyle(
              fontSize: isInChatBubble ? 10.sp : 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      width: maxWidth ?? (isInChatBubble ? 100.w : 150.w),
      height: maxHeight ?? (isInChatBubble ? 80.h : 100.h),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: isInChatBubble ? 24.sp : 32.sp,
            color: Colors.red[600],
          ),
          SizedBox(height: 4.h),
          Text(
            message,
            style: TextStyle(
              fontSize: isInChatBubble ? 8.sp : 10.sp,
              color: Colors.red[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _openPDF(
    BuildContext context,
    String fileUrl,
    String mediaId,
  ) async {
    String? filePath;

    if (fileUrl.startsWith('data:')) {
      filePath = await _saveBase64ToFile(fileUrl, 'temp_pdf_$mediaId.pdf');
    } else if (fileUrl.startsWith('/')) {
      filePath = fileUrl;
    }

    if (filePath != null && await File(filePath).exists()) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => PdfViewScreen(filePath: filePath!),
      //   ),
      // );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF file not found or invalid')),
      );
    }
  }
}

// Compact Audio Player for Chat Bubbles
class CompactAudioPlayerWidget extends StatefulWidget {
  final String fileUrl;
  final String mediaId;
  final Future<String?> Function(String, String) saveBase64ToFile;
  final bool isCompact;

  const CompactAudioPlayerWidget({
    super.key,
    required this.fileUrl,
    required this.mediaId,
    required this.saveBase64ToFile,
    this.isCompact = true,
  });

  @override
  State<CompactAudioPlayerWidget> createState() =>
      _CompactAudioPlayerWidgetState();
}

class _CompactAudioPlayerWidgetState extends State<CompactAudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
    _prepareAudio();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() => _position = position);
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() => _isPlaying = state == PlayerState.playing);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  Future<void> _prepareAudio() async {
    setState(() => _isLoading = true);

    try {
      if (widget.fileUrl.startsWith('data:')) {
        _filePath = await widget.saveBase64ToFile(
          widget.fileUrl,
          'temp_audio_${widget.mediaId}.m4a',
        );
      } else {
        _filePath = widget.fileUrl;
      }
    } catch (e) {
      log('Error preparing audio: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _playPause() async {
    if (_filePath == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(DeviceFileSource(_filePath!));
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Loading audio...'),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(widget.isCompact ? 8.w : 12.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause button
          GestureDetector(
            onTap: _playPause,
            child: Container(
              width: widget.isCompact ? 32.w : 40.w,
              height: widget.isCompact ? 32.h : 40.h,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: widget.isCompact ? 16.sp : 20.sp,
              ),
            ),
          ),

          SizedBox(width: 8.w),

          // Progress and duration
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.mic,
                      size: widget.isCompact ? 12.sp : 14.sp,
                      color: Colors.blue[600],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Voice message',
                      style: TextStyle(
                        fontSize: widget.isCompact ? 10.sp : 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),

                if (widget.isCompact) ...[
                  SizedBox(height: 2.h),
                  Text(
                    _formatDuration(_duration),
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                  ),
                ] else ...[
                  SizedBox(height: 4.h),
                  LinearProgressIndicator(
                    value: _duration.inSeconds > 0
                        ? _position.inSeconds / _duration.inSeconds
                        : 0.0,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue[600]!,
                    ),
                  ),
                  SizedBox(height: 2.h),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
