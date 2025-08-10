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

/// Shimmer Animation Widget
class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Enhanced cache with better state management
class MediaCache {
  static final Map<String, Uint8List> _imageCache = {};
  static final Map<String, String> _filePathCache = {};
  static final Set<String> _loadingItems = {};
  static final Set<String> _failedItems = {};

  static Uint8List? getImage(String key) => _imageCache[key];
  static void setImage(String key, Uint8List data) {
    _imageCache[key] = data;
    _failedItems.remove(key);
  }

  static String? getFilePath(String key) => _filePathCache[key];
  static void setFilePath(String key, String path) {
    _filePathCache[key] = path;
    _failedItems.remove(key);
  }

  static bool isLoading(String key) => _loadingItems.contains(key);
  static void setLoading(String key) {
    _loadingItems.add(key);
    _failedItems.remove(key);
  }

  static void clearLoading(String key) => _loadingItems.remove(key);

  static bool hasFailed(String key) => _failedItems.contains(key);
  static void setFailed(String key) {
    _failedItems.add(key);
    _loadingItems.remove(key);
  }

  static void clearFailed(String key) => _failedItems.remove(key);

  static void clear() {
    _imageCache.clear();
    _filePathCache.clear();
    _loadingItems.clear();
    _failedItems.clear();
  }

  static void clearForMedia(String key) {
    _imageCache.remove(key);
    _filePathCache.remove(key);
    _loadingItems.remove(key);
    _failedItems.remove(key);
  }
}

/// Instant loading media preview widget
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

    // Use a more efficient approach - get cubit instance once
    return Builder(
      builder: (context) {
        final cubit = context.watch<ChatCubit>();
        final fileUrl = cubit.getFileUrl(mediaId);
        final fileType = cubit.getFileType(mediaId);
        final isLoading = cubit.isFileLoading(mediaId);

        return _InstantMediaBuilder(
          key: ValueKey('media_$mediaId'), // Prevent unnecessary rebuilds
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

/// Optimized media builder with better error handling
class _InstantMediaBuilder extends StatelessWidget {
  final ChatMedias media;
  final String? fileUrl;
  final String? fileType;
  final bool isLoading;
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _InstantMediaBuilder({
    super.key,
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
    final mediaId = media.id.toString();

    // Debug logging to track the issue
    debugPrint(
      'Media $mediaId: fileUrl=$fileUrl, isLoading=$isLoading, type=$fileType',
    );

    // Check cache first for instant loading
    if (fileUrl != null && !MediaCache.isLoading(mediaId)) {
      return _MediaTypeDispatcher(
        fileUrl: fileUrl!,
        fileType: fileType ?? _inferTypeFromMedia(media),
        mediaId: mediaId,
        isInChatBubble: isInChatBubble,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
    }

    // If we have media data but no fileUrl, try to process it directly
    if (fileUrl == null && !isLoading && !MediaCache.isLoading(mediaId)) {
      // Check if media has direct data we can use
      if (media.mediaUrl != null && media.mediaUrl!.isNotEmpty) {
        debugPrint('Using media.url directly: ${media.mediaUrl}');
        return _MediaTypeDispatcher(
          fileUrl: media.mediaUrl!,
          fileType: fileType ?? _inferTypeFromMedia(media),
          mediaId: mediaId,
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
      }

      // Try to trigger loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          debugPrint('Triggering loadMediaFile for $mediaId');
          context.read<ChatCubit>().loadMediaFile(media);
        }
      });

      // Set loading state to prevent multiple requests
      MediaCache.setLoading(mediaId);
    }

    // Show loading state with shimmer
    if (isLoading || MediaCache.isLoading(mediaId)) {
      return _ShimmerLoadingWidget(
        isInChatBubble: isInChatBubble,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        mediaType: _inferTypeFromMedia(media),
      );
    }

    // Only show error after giving it a chance to load
    return FutureBuilder(
      future: _waitAndCheckAgain(context, mediaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _ShimmerLoadingWidget(
            isInChatBubble: isInChatBubble,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            mediaType: _inferTypeFromMedia(media),
          );
        }

        final result = snapshot.data;
        if (result != null && result.isNotEmpty) {
          return _MediaTypeDispatcher(
            fileUrl: result,
            fileType: fileType ?? _inferTypeFromMedia(media),
            mediaId: mediaId,
            isInChatBubble: isInChatBubble,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          );
        }

        // Final fallback - show error
        debugPrint('Media $mediaId finally unavailable after all attempts');
        return _CompactErrorWidget(
          message: 'Media unavailable',
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
      },
    );
  }

  /// Wait a moment and check again for the file URL
  Future<String?> _waitAndCheckAgain(
    BuildContext context,
    String mediaId,
  ) async {
    // Wait a short time for async operations to complete
    await Future.delayed(const Duration(milliseconds: 500));

    if (context.mounted) {
      final cubit = context.read<ChatCubit>();
      final url = cubit.getFileUrl(mediaId);
      if (url != null) {
        MediaCache.clearLoading(mediaId);
        return url;
      }

      // Check if we can use media.url directly
      if (media.mediaUrl != null && media.mediaUrl!.isNotEmpty) {
        return media.mediaUrl;
      }
    }

    MediaCache.clearLoading(mediaId);
    return null;
  }

  String _inferTypeFromMedia(ChatMedias media) {
    if (media.mediaUrl != null && media.mediaType!.isNotEmpty) {
      return media.mediaType!.toLowerCase();
    }

    final url = media.mediaUrl ?? '';
    if (url.contains('.')) {
      final extension = url.split('.').last.toLowerCase();
      switch (extension) {
        case 'jpg':
        case 'jpeg':
        case 'png':
        case 'gif':
        case 'webp':
          return 'image';
        case 'mp3':
        case 'm4a':
        case 'wav':
        case 'ogg':
          return 'audio';
        case 'pdf':
          return 'document';
        case 'mp4':
        case 'mov':
        case 'avi':
          return 'video';
      }
    }

    // Check MIME type patterns in data URLs
    if (url.startsWith('data:')) {
      if (url.contains('image/')) return 'image';
      if (url.contains('audio/')) return 'audio';
      if (url.contains('video/')) return 'video';
      if (url.contains('application/pdf')) return 'document';
    }

    // Default fallback
    return 'unknown';
  }
}

/// Optimized media type dispatcher
class _MediaTypeDispatcher extends StatelessWidget {
  final String fileUrl;
  final String fileType;
  final String mediaId;
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _MediaTypeDispatcher({
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
        return _InstantImagePreview(
          fileUrl: fileUrl,
          mediaId: mediaId,
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );

      case 'audio':
      case 'mp3':
      case 'm4a':
      case 'wav':
      case 'voice':
        return _InstantAudioPreview(
          fileUrl: fileUrl,
          mediaId: mediaId,
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );

      case 'document':
      case 'pdf':
        return _InstantDocumentPreview(
          fileUrl: fileUrl,
          mediaId: mediaId,
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );

      default:
        return _GenericFilePreview(
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
    }
  }
}

/// Instant image preview with aggressive caching
class _InstantImagePreview extends StatelessWidget {
  final String fileUrl;
  final String mediaId;
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _InstantImagePreview({
    required this.fileUrl,
    required this.mediaId,
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
        child: _CachedImageDisplay(
          fileUrl: fileUrl,
          mediaId: mediaId,
          isInChatBubble: isInChatBubble,
        ),
      ),
    );
  }
}

/// Cached image display with instant loading and shimmer
class _CachedImageDisplay extends StatelessWidget {
  final String fileUrl;
  final String mediaId;
  final bool isInChatBubble;

  const _CachedImageDisplay({
    required this.fileUrl,
    required this.mediaId,
    required this.isInChatBubble,
  });

  @override
  Widget build(BuildContext context) {
    // Check cache first for instant display
    final cachedImage = MediaCache.getImage(mediaId);
    if (cachedImage != null) {
      return Image.memory(
        cachedImage,
        fit: BoxFit.cover,
        cacheWidth: isInChatBubble ? 400 : null,
      );
    }

    // For data URLs, decode immediately
    if (fileUrl.startsWith('data:')) {
      return FutureBuilder<Uint8List?>(
        future: _decodeBase64Image(fileUrl, mediaId),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              cacheWidth: isInChatBubble ? 400 : null,
            );
          }
          if (snapshot.hasError) {
            return _CompactErrorWidget(
              message: 'Invalid image',
              isInChatBubble: isInChatBubble,
            );
          }
          return _ShimmerLoadingWidget(
            isInChatBubble: isInChatBubble,
            mediaType: 'image',
          );
        },
      );
    }

    // For network URLs
    if (fileUrl.startsWith('http')) {
      return Image.network(
        fileUrl,
        fit: BoxFit.cover,
        cacheWidth: isInChatBubble ? 400 : null,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _ShimmerLoadingWidget(
            isInChatBubble: isInChatBubble,
            mediaType: 'image',
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _CompactErrorWidget(
            message: 'Failed to load',
            isInChatBubble: isInChatBubble,
          );
        },
      );
    }

    // For file paths
    return FutureBuilder<Uint8List?>(
      future: _loadFileImage(fileUrl, mediaId),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            cacheWidth: isInChatBubble ? 400 : null,
          );
        }
        if (snapshot.hasError) {
          return _CompactErrorWidget(
            message: 'File not found',
            isInChatBubble: isInChatBubble,
          );
        }
        return _ShimmerLoadingWidget(
          isInChatBubble: isInChatBubble,
          mediaType: 'image',
        );
      },
    );
  }

  Future<Uint8List?> _decodeBase64Image(String dataUrl, String mediaId) async {
    try {
      final base64Data = dataUrl.contains(',')
          ? dataUrl.split(',').last
          : dataUrl;
      final bytes = base64Decode(base64Data);
      MediaCache.setImage(mediaId, bytes);
      return bytes;
    } catch (e) {
      log('Base64 decode error: $e');
      return null;
    }
  }

  Future<Uint8List?> _loadFileImage(String filePath, String mediaId) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        MediaCache.setImage(mediaId, bytes);
        return bytes;
      }
      return null;
    } catch (e) {
      log('File load error: $e');
      return null;
    }
  }
}

/// Instant audio preview with cached file paths
class _InstantAudioPreview extends StatelessWidget {
  final String fileUrl;
  final String mediaId;
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _InstantAudioPreview({
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
      child: _InstantAudioPlayer(
        fileUrl: fileUrl,
        mediaId: mediaId,
        isCompact: isInChatBubble,
      ),
    );
  }
}

/// Instant audio player with file caching and shimmer loading
class _InstantAudioPlayer extends StatefulWidget {
  final String fileUrl;
  final String mediaId;
  final bool isCompact;

  const _InstantAudioPlayer({
    required this.fileUrl,
    required this.mediaId,
    this.isCompact = true,
  });

  @override
  State<_InstantAudioPlayer> createState() => _InstantAudioPlayerState();
}

class _InstantAudioPlayerState extends State<_InstantAudioPlayer> {
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isReady = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _prepareAudioInstantly();
  }

  Future<void> _prepareAudioInstantly() async {
    // Check cache first
    final cachedPath = MediaCache.getFilePath(widget.mediaId);
    if (cachedPath != null && await File(cachedPath).exists()) {
      _filePath = cachedPath;
      _initializePlayer();
      return;
    }

    try {
      if (widget.fileUrl.startsWith('data:')) {
        _filePath = await _FileUtils.saveBase64ToFile(
          widget.fileUrl,
          'audio_${widget.mediaId}.m4a',
        );
        if (_filePath != null) {
          MediaCache.setFilePath(widget.mediaId, _filePath!);
        }
      } else {
        _filePath = widget.fileUrl;
        MediaCache.setFilePath(widget.mediaId, _filePath!);
      }

      if (_filePath != null && await File(_filePath!).exists()) {
        _initializePlayer();
      }
    } catch (e) {
      log('Audio preparation error: $e');
    }
  }

  void _initializePlayer() {
    if (mounted) {
      setState(() => _isReady = true);
      _audioPlayer = AudioPlayer();

      _audioPlayer!.onDurationChanged.listen((duration) {
        if (mounted) setState(() => _duration = duration);
      });

      _audioPlayer!.onPositionChanged.listen((position) {
        if (mounted) setState(() => _position = position);
      });

      _audioPlayer!.onPlayerStateChanged.listen((state) {
        if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
      });
    }
  }

  Future<void> _togglePlayPause() async {
    if (_audioPlayer == null || _filePath == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer!.pause();
      } else {
        await _audioPlayer!.play(DeviceFileSource(_filePath!));
      }
    } catch (e) {
      log('Audio playback error: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return _ShimmerLoadingWidget(
        isInChatBubble: widget.isCompact,
        mediaType: 'audio',
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
          GestureDetector(
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
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
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
                if (widget.isCompact) ...[
                  SizedBox(height: 2.h),
                  Text(
                    _formatDuration(_duration),
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
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
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// Instant document preview
class _InstantDocumentPreview extends StatelessWidget {
  final String fileUrl;
  final String mediaId;
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _InstantDocumentPreview({
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
                child: Text(
                  'PDF Document',
                  style: TextStyle(
                    fontSize: isInChatBubble ? 12.sp : 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
      String? filePath = MediaCache.getFilePath(mediaId);

      if (filePath == null) {
        if (fileUrl.startsWith('data:')) {
          filePath = await _FileUtils.saveBase64ToFile(
            fileUrl,
            'document_$mediaId.pdf',
          );
          if (filePath != null) {
            MediaCache.setFilePath(mediaId, filePath);
          }
        } else {
          filePath = fileUrl;
        }
      }

      if (filePath != null && await File(filePath).exists()) {
        log('Opening PDF: $filePath');
        // Navigator.push(context, MaterialPageRoute(builder: (_) => PdfViewScreen(filePath: filePath!)));
      } else {
        _showSnackBar(context, 'PDF file not found');
      }
    } catch (e) {
      log('Document open error: $e');
      _showSnackBar(context, 'Failed to open document');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Shimmer loading widget with media type specific layouts
class _ShimmerLoadingWidget extends StatelessWidget {
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;
  final String mediaType;

  const _ShimmerLoadingWidget({
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
    this.mediaType = 'unknown',
  });

  @override
  Widget build(BuildContext context) {
    switch (mediaType.toLowerCase()) {
      case 'image':
        return _ImageShimmer(
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
      case 'audio':
      case 'voice':
        return _AudioShimmer(
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
      case 'document':
      case 'pdf':
        return _DocumentShimmer(
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
      default:
        return _GenericShimmer(
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
    }
  }
}

/// Image-specific shimmer
class _ImageShimmer extends StatelessWidget {
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _ImageShimmer({
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        width: maxWidth ?? (isInChatBubble ? 200.w : double.infinity),
        height: maxHeight ?? (isInChatBubble ? 150.h : 200.h),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: isInChatBubble ? 32.sp : 48.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 8.h),
            Container(
              width: 60.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Audio-specific shimmer
class _AudioShimmer extends StatelessWidget {
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _AudioShimmer({
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        width: maxWidth ?? (isInChatBubble ? 250.w : 300.w),
        height: maxHeight ?? (isInChatBubble ? 60.h : 80.h),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Row(
            children: [
              Container(
                width: isInChatBubble ? 32.w : 40.w,
                height: isInChatBubble ? 32.h : 40.h,
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.blue[300],
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      width: 40.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: Colors.blue[200],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Document-specific shimmer
class _DocumentShimmer extends StatelessWidget {
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _DocumentShimmer({
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        width: maxWidth ?? (isInChatBubble ? 150.w : 200.w),
        height: maxHeight ?? (isInChatBubble ? 60.h : 80.h),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Row(
            children: [
              Container(
                width: isInChatBubble ? 24.w : 32.w,
                height: isInChatBubble ? 24.h : 32.h,
                decoration: BoxDecoration(
                  color: Colors.red[300],
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.red[300],
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      width: 60.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: Colors.red[200],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Generic shimmer for unknown media types
class _GenericShimmer extends StatelessWidget {
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _GenericShimmer({
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        width: maxWidth ?? (isInChatBubble ? 120.w : 150.w),
        height: maxHeight ?? (isInChatBubble ? 60.h : 80.h),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              width: 40.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact error widget
class _CompactErrorWidget extends StatelessWidget {
  final String message;
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _CompactErrorWidget({
    required this.message,
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: maxWidth ?? (isInChatBubble ? 80.w : 120.w),
      height: maxHeight ?? (isInChatBubble ? 60.h : 80.h),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 16.sp, color: Colors.red[600]),
          SizedBox(height: 2.h),
          Text(
            message,
            style: TextStyle(fontSize: 8.sp, color: Colors.red[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Generic file preview
class _GenericFilePreview extends StatelessWidget {
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _GenericFilePreview({
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: maxWidth ?? (isInChatBubble ? 80.w : 120.w),
      height: maxHeight ?? (isInChatBubble ? 60.h : 80.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file, size: 20.sp, color: Colors.grey[600]),
          SizedBox(height: 2.h),
          Text(
            'File',
            style: TextStyle(fontSize: 8.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

/// Optimized file utils with caching
class _FileUtils {
  static final Map<String, String> _pathCache = {};

  static Future<String?> saveBase64ToFile(
    String base64Data,
    String fileName,
  ) async {
    // Check cache first
    if (_pathCache.containsKey(fileName)) {
      final cachedPath = _pathCache[fileName]!;
      if (await File(cachedPath).exists()) {
        return cachedPath;
      }
    }

    try {
      String cleanBase64 = base64Data;
      if (base64Data.contains(',')) {
        cleanBase64 = base64Data.split(',').last;
      }

      final bytes = base64Decode(cleanBase64);
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      _pathCache[fileName] = file.path;
      return file.path;
    } catch (e) {
      log('Error saving base64 to file: $e');
      return null;
    }
  }
}
