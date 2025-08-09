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

/// Enhanced cache with better state management
class _MediaCache {
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
    if (fileUrl != null && !_MediaCache.isLoading(mediaId)) {
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
    if (fileUrl == null && !isLoading && !_MediaCache.isLoading(mediaId)) {
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
      _MediaCache.setLoading(mediaId);
    }

    // Show loading state
    if (isLoading || _MediaCache.isLoading(mediaId)) {
      return _CompactLoadingWidget(
        isInChatBubble: isInChatBubble,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
    }

    // Only show error after giving it a chance to load
    return FutureBuilder(
      future: _waitAndCheckAgain(context, mediaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _CompactLoadingWidget(
            isInChatBubble: isInChatBubble,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
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
        _MediaCache.clearLoading(mediaId);
        return url;
      }

      // Check if we can use media.url directly
      if (media.mediaUrl != null && media.mediaUrl!.isNotEmpty) {
        return media.mediaUrl;
      }
    }

    _MediaCache.clearLoading(mediaId);
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

/// Cached image display with instant loading
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
    final cachedImage = _MediaCache.getImage(mediaId);
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
          return _CompactLoadingWidget(isInChatBubble: isInChatBubble);
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
          return _CompactLoadingWidget(isInChatBubble: isInChatBubble);
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
        return _CompactLoadingWidget(isInChatBubble: isInChatBubble);
      },
    );
  }

  Future<Uint8List?> _decodeBase64Image(String dataUrl, String mediaId) async {
    try {
      final base64Data = dataUrl.contains(',')
          ? dataUrl.split(',').last
          : dataUrl;
      final bytes = base64Decode(base64Data);
      _MediaCache.setImage(mediaId, bytes);
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
        _MediaCache.setImage(mediaId, bytes);
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

/// Instant audio player with file caching
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
    final cachedPath = _MediaCache.getFilePath(widget.mediaId);
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
          _MediaCache.setFilePath(widget.mediaId, _filePath!);
        }
      } else {
        _filePath = widget.fileUrl;
        _MediaCache.setFilePath(widget.mediaId, _filePath!);
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
      return _CompactLoadingWidget(isInChatBubble: widget.isCompact);
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
      String? filePath = _MediaCache.getFilePath(mediaId);

      if (filePath == null) {
        if (fileUrl.startsWith('data:')) {
          filePath = await _FileUtils.saveBase64ToFile(
            fileUrl,
            'document_$mediaId.pdf',
          );
          if (filePath != null) {
            _MediaCache.setFilePath(mediaId, filePath);
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

/// Compact loading widget
class _CompactLoadingWidget extends StatelessWidget {
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _CompactLoadingWidget({
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
      ),
      child: Center(
        child: SizedBox(
          width: 20.w,
          height: 20.h,
          child: const CircularProgressIndicator(strokeWidth: 2),
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
