import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';

/// Optimized media preview widget with improved performance and error handling
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

  @override
  Widget build(BuildContext context) {
    if (media?.id == null) return const SizedBox.shrink();

    final mediaId = media!.id.toString();

    // Use BlocSelector to only rebuild when specific media state changes
    return BlocSelector<ChatCubit, ChatState, _MediaData>(
      selector: (state) {
        final cubit = context.read<ChatCubit>();
        return _MediaData(
          fileUrl: cubit.getFileUrl(mediaId),
          fileType: cubit.getFileType(mediaId),
          isLoading: cubit.isFileLoading(mediaId),
        );
      },
      builder: (context, mediaData) {
        return _MediaContentBuilder(
          media: media!,
          fileUrl: mediaData.fileUrl,
          fileType: mediaData.fileType,
          isLoading: mediaData.isLoading,
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
      },
    );
  }
}

/// Immutable data class for media state
class _MediaData {
  final String? fileUrl;
  final String? fileType;
  final bool isLoading;

  const _MediaData({this.fileUrl, this.fileType, this.isLoading = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _MediaData &&
          runtimeType == other.runtimeType &&
          fileUrl == other.fileUrl &&
          fileType == other.fileType &&
          isLoading == other.isLoading;

  @override
  int get hashCode => fileUrl.hashCode ^ fileType.hashCode ^ isLoading.hashCode;
}

/// Builds media content based on type and state
class _MediaContentBuilder extends StatelessWidget {
  final ChatMedias media;
  final String? fileUrl;
  final String? fileType;
  final bool isLoading;
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _MediaContentBuilder({
    required this.media,
    required this.fileUrl,
    required this.fileType,
    required this.isLoading,
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (fileUrl == null && !isLoading) {
      context.read<ChatCubit>().loadMediaFile(media);
    }

    if (isLoading) {
      return _LoadingWidget(
        isInChatBubble: isInChatBubble,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
    }

    if (fileUrl == null) {
      return _ErrorWidget(
        message: 'Media not available',
        isInChatBubble: isInChatBubble,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
    }

    return _MediaByType(
      fileUrl: fileUrl!,
      fileType: fileType ?? 'unknown',
      mediaId: media.id.toString(),
      isInChatBubble: isInChatBubble,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }
}

/// Alternative implementation using BlocBuilder for better state management
class MediaPreviewWidgetV2 extends StatelessWidget {
  final ChatMedias? media;
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const MediaPreviewWidgetV2({
    super.key,
    required this.media,
    this.isInChatBubble = true,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (media?.id == null) return const SizedBox.shrink();

    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final mediaId = media!.id.toString();
        final cubit = context.read<ChatCubit>();

        final fileUrl = cubit.getFileUrl(mediaId);
        final fileType = cubit.getFileType(mediaId);
        final isLoading = cubit.isFileLoading(mediaId);

        return _MediaContentBuilder(
          media: media!,
          fileUrl: fileUrl,
          fileType: fileType,
          isLoading: isLoading,
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
      },
    );
  }
}

class _MediaByType extends StatelessWidget {
  final String fileUrl;
  final String fileType;
  final String mediaId;
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _MediaByType({
    required this.fileUrl,
    required this.fileType,
    required this.mediaId,
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    switch (fileType.toLowerCase()) {
      case 'image':
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return _ImagePreview(
          fileUrl: fileUrl,
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );

      case 'audio':
      case 'mp3':
      case 'm4a':
      case 'wav':
      case 'voice':
        return _AudioPreview(
          fileUrl: fileUrl,
          mediaId: mediaId,
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );

      case 'document':
      case 'pdf':
        return _DocumentPreview(
          fileUrl: fileUrl,
          mediaId: mediaId,
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );

      default:
        return _UnknownFilePreview(
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
    }
  }
}

/// Optimized image preview with memory management and caching
class _ImagePreview extends StatelessWidget {
  final String fileUrl;
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _ImagePreview({
    required this.fileUrl,
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? (isInChatBubble ? 200.w : double.infinity),
        maxHeight: maxHeight ?? (isInChatBubble ? 200.h : double.infinity),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: _CachedImageWidget(
          fileUrl: fileUrl,
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
      ),
    );
  }
}

/// Cached image widget that prevents unnecessary rebuilds
class _CachedImageWidget extends StatefulWidget {
  final String fileUrl;
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _CachedImageWidget({
    required this.fileUrl,
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  State<_CachedImageWidget> createState() => _CachedImageWidgetState();
}

class _CachedImageWidgetState extends State<_CachedImageWidget> {
  Uint8List? _cachedImageBytes;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(_CachedImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fileUrl != widget.fileUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (widget.fileUrl.startsWith('data:')) {
        final base64Data = widget.fileUrl.contains(',')
            ? widget.fileUrl.split(',').last
            : widget.fileUrl;
        _cachedImageBytes = base64Decode(base64Data);
      } else if (widget.fileUrl.startsWith('http')) {
        // For network images, we'll use Image.network directly
        _cachedImageBytes = null;
      } else {
        final file = File(widget.fileUrl);
        if (await file.exists()) {
          _cachedImageBytes = await file.readAsBytes();
        } else {
          throw Exception('File not found');
        }
      }
    } catch (e) {
      log('Image loading error: $e');
      if (mounted) {
        setState(() => _error = 'Failed to load image');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _LoadingWidget(
        isInChatBubble: widget.isInChatBubble,
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
      );
    }

    if (_error != null) {
      return _ErrorWidget(
        message: _error!,
        isInChatBubble: widget.isInChatBubble,
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
      );
    }

    if (_cachedImageBytes != null) {
      return Image.memory(
        _cachedImageBytes!,
        fit: BoxFit.cover,
        cacheWidth: widget.isInChatBubble ? 400 : null,
        errorBuilder: (context, error, stackTrace) {
          return _ErrorWidget(
            message: 'Invalid image',
            isInChatBubble: widget.isInChatBubble,
            maxWidth: widget.maxWidth,
            maxHeight: widget.maxHeight,
          );
        },
      );
    } else if (widget.fileUrl.startsWith('http')) {
      return Image.network(
        widget.fileUrl,
        fit: BoxFit.cover,
        cacheWidth: widget.isInChatBubble ? 400 : null,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _LoadingWidget(
            isInChatBubble: widget.isInChatBubble,
            maxWidth: widget.maxWidth,
            maxHeight: widget.maxHeight,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _ErrorWidget(
            message: 'Failed to load',
            isInChatBubble: widget.isInChatBubble,
            maxWidth: widget.maxWidth,
            maxHeight: widget.maxHeight,
          );
        },
      );
    }

    return _ErrorWidget(
      message: 'Unsupported image format',
      isInChatBubble: widget.isInChatBubble,
      maxWidth: widget.maxWidth,
      maxHeight: widget.maxHeight,
    );
  }
}

/// Audio preview with optimized player
class _AudioPreview extends StatelessWidget {
  final String fileUrl;
  final String mediaId;
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _AudioPreview({
    required this.fileUrl,
    required this.mediaId,
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: maxWidth ?? (isInChatBubble ? 250.w : 300.w),
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? (isInChatBubble ? 80.h : 120.h),
      ),
      child: OptimizedAudioPlayer(
        fileUrl: fileUrl,
        mediaId: mediaId,
        isCompact: isInChatBubble,
      ),
    );
  }
}

/// Document preview with tap handling
class _DocumentPreview extends StatelessWidget {
  final String fileUrl;
  final String mediaId;
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _DocumentPreview({
    required this.fileUrl,
    required this.mediaId,
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: maxWidth ?? (isInChatBubble ? 150.w : 200.w),
      height: maxHeight ?? (isInChatBubble ? 60.h : 80.h),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: InkWell(
        onTap: () => _handleDocumentTap(context),
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

  Future<void> _handleDocumentTap(BuildContext context) async {
    try {
      String? filePath;

      if (fileUrl.startsWith('data:')) {
        filePath = await _FileUtils.saveBase64ToFile(
          fileUrl,
          'temp_pdf_$mediaId.pdf',
        );
      } else if (fileUrl.startsWith('/') || File(fileUrl).existsSync()) {
        filePath = fileUrl;
      }

      if (filePath != null && await File(filePath).exists()) {
        // Navigate to PDF viewer
        // Navigator.push(context, MaterialPageRoute(builder: (_) => PdfViewScreen(filePath: filePath!)));
        log('Opening PDF: $filePath');
      } else {
        _showErrorSnackBar(context, 'PDF file not found or invalid');
      }
    } catch (e) {
      log('Document open error: $e');
      _showErrorSnackBar(context, 'Failed to open document');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Reusable widgets for common states
class _LoadingWidget extends StatelessWidget {
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _LoadingWidget({
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: maxWidth ?? (isInChatBubble ? 100.w : 200.w),
      height: maxHeight ?? (isInChatBubble ? 100.h : 200.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _ErrorWidget({
    required this.message,
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              message,
              style: TextStyle(
                fontSize: isInChatBubble ? 8.sp : 10.sp,
                color: Colors.red[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnknownFilePreview extends StatelessWidget {
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _UnknownFilePreview({
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
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
}

/// Optimized audio player with better state management and memoization
class OptimizedAudioPlayer extends StatefulWidget {
  final String fileUrl;
  final String mediaId;
  final bool isCompact;

  const OptimizedAudioPlayer({
    super.key,
    required this.fileUrl,
    required this.mediaId,
    this.isCompact = true,
  });

  @override
  State<OptimizedAudioPlayer> createState() => _OptimizedAudioPlayerState();
}

class _OptimizedAudioPlayerState extends State<OptimizedAudioPlayer>
    with AutomaticKeepAliveClientMixin {
  late AudioPlayer _audioPlayer;

  // State variables
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _hasError = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _filePath;
  String? _currentFileUrl;

  // Keep the widget alive to prevent unnecessary rebuilds
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeAudioPlayer();
  }

  @override
  void didUpdateWidget(OptimizedAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reinitialize if the file URL actually changed
    if (oldWidget.fileUrl != widget.fileUrl) {
      _currentFileUrl = null;
      _prepareAudio();
    }
  }

  void _initializeAudioPlayer() {
    _audioPlayer = AudioPlayer();
    _setupAudioListeners();
    _prepareAudio();
  }

  void _setupAudioListeners() {
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _duration = duration);
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) setState(() => _position = position);
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  Future<void> _prepareAudio() async {
    // Avoid re-preparing the same file
    if (_currentFileUrl == widget.fileUrl && _filePath != null) return;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      if (widget.fileUrl.startsWith('data:')) {
        _filePath = await _FileUtils.saveBase64ToFile(
          widget.fileUrl,
          'temp_audio_${widget.mediaId}.m4a',
        );
      } else {
        _filePath = widget.fileUrl;
      }

      if (_filePath == null || !await File(_filePath!).exists()) {
        throw Exception('Audio file not found');
      }

      _currentFileUrl = widget.fileUrl;
    } catch (e) {
      log('Audio preparation error: $e');
      if (mounted) setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _togglePlayPause() async {
    if (_filePath == null || _hasError) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(DeviceFileSource(_filePath!));
      }
    } catch (e) {
      log('Audio playback error: $e');
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (_isLoading) return _buildLoadingState();
    if (_hasError) return _buildErrorState();
    return _buildPlayerState();
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: _getContainerDecoration(),
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

  Widget _buildErrorState() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: _getContainerDecoration(isError: true),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 16.sp, color: Colors.red[600]),
          const SizedBox(width: 8),
          const Text('Audio error'),
        ],
      ),
    );
  }

  Widget _buildPlayerState() {
    return Container(
      padding: EdgeInsets.all(widget.isCompact ? 8.w : 12.w),
      decoration: _getContainerDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPlayButton(),
          SizedBox(width: 8.w),
          Expanded(child: _buildProgressSection()),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: _togglePlayPause,
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
    );
  }

  Widget _buildProgressSection() {
    return Column(
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
        ] else
          _buildFullProgress(),
      ],
    );
  }

  Widget _buildFullProgress() {
    return Column(
      children: [
        SizedBox(height: 4.h),
        LinearProgressIndicator(
          value: _duration.inSeconds > 0
              ? _position.inSeconds / _duration.inSeconds
              : 0.0,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(_position),
              style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
            ),
            Text(
              _formatDuration(_duration),
              style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  BoxDecoration _getContainerDecoration({bool isError = false}) {
    return BoxDecoration(
      color: isError ? Colors.red[50] : Colors.blue[50],
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: isError ? Colors.red[200]! : Colors.blue[200]!),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// Utility class for file operations
class _FileUtils {
  static Future<String?> saveBase64ToFile(
    String base64Data,
    String fileName,
  ) async {
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
}
