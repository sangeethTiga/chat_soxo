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
import 'package:soxo_chat/feature/chat/screen/widgets/image_show.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/pdf_viewer.dart';
import 'package:soxo_chat/shared/widgets/media/media_cache.dart';
import 'package:soxo_chat/shared/widgets/shimmer/shimmer_card.dart';

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

    return Builder(
      builder: (context) {
        final cubit = context.watch<ChatCubit>();
        final fileUrl = cubit.getFileUrl(mediaId);
        final fileType = cubit.getFileType(mediaId);
        final isLoading = cubit.isFileLoading(mediaId);

        return _InstantMediaBuilder(
          key: ValueKey('media_$mediaId'),
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

    if (fileUrl == null && !isLoading && !MediaCache.isLoading(mediaId)) {
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

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          debugPrint('Triggering loadMediaFile for $mediaId');
          context.read<ChatCubit>().loadMediaFile(media);
        }
      });

      MediaCache.setLoading(mediaId);
    }

    if (isLoading || MediaCache.isLoading(mediaId)) {
      return ShimmerLoadingWidget(
        isInChatBubble: isInChatBubble,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        mediaType: _inferTypeFromMedia(media),
      );
    }

    return FutureBuilder(
      future: _waitAndCheckAgain(context, mediaId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerLoadingWidget(
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

  Future<String?> _waitAndCheckAgain(
    BuildContext context,
    String mediaId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (context.mounted) {
      final cubit = context.read<ChatCubit>();
      final url = cubit.getFileUrl(mediaId);
      if (url != null) {
        MediaCache.clearLoading(mediaId);
        return url;
      }

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

    if (url.startsWith('data:')) {
      if (url.contains('image/')) return 'image';
      if (url.contains('audio/')) return 'audio';
      if (url.contains('video/')) return 'video';
      if (url.contains('application/pdf')) return 'document';
    }

    return 'unknown';
  }
}

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
    return GestureDetector(
      onTap: () {
        showMyDialog(context, fileUrl, mediaId);
      },
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? (isInChatBubble ? 200.w : double.infinity),
          maxHeight: maxHeight ?? (isInChatBubble ? 200.h : double.infinity),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: CachedImageDisplay(
            fileUrl: fileUrl,
            mediaId: mediaId,
            isInChatBubble: isInChatBubble,
          ),
        ),
      ),
    );
  }
}

class CachedImageDisplay extends StatelessWidget {
  final String fileUrl;
  final String mediaId;
  final bool isInChatBubble;

  const CachedImageDisplay({
    super.key,
    required this.fileUrl,
    required this.mediaId,
    required this.isInChatBubble,
  });

  @override
  Widget build(BuildContext context) {
    final cachedImage = MediaCache.getImage(mediaId);
    if (cachedImage != null) {
      return Image.memory(
        cachedImage,
        fit: BoxFit.cover,
        cacheWidth: isInChatBubble ? 400 : null,
      );
    }

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
          return ShimmerLoadingWidget(
            isInChatBubble: isInChatBubble,
            mediaType: 'image',
          );
        },
      );
    }

    if (fileUrl.startsWith('http')) {
      return Image.network(
        fileUrl,
        fit: BoxFit.cover,
        cacheWidth: isInChatBubble ? 400 : null,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return ShimmerLoadingWidget(
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
        return ShimmerLoadingWidget(
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PdfViewScreen(filePath: filePath!, fileName: 'PDF VIEWER'),
          ),
        );
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

/// Enhanced Audio Cache with better lifecycle management
class AudioCache {
  static final Map<String, String> _audioPathCache = {};
  static final Map<String, AudioPlayer> _playerCache = {};
  static final Map<String, Duration> _durationCache = {};
  static final Set<String> _processingFiles = {};
  static final Map<String, String> _errorCache = {};
  static final Map<String, double> _speedCache = {}; // Cache playback speeds

  static String? getAudioPath(String mediaId) => _audioPathCache[mediaId];
  static void setAudioPath(String mediaId, String path) =>
      _audioPathCache[mediaId] = path;

  static AudioPlayer? getPlayer(String mediaId) => _playerCache[mediaId];
  static void setPlayer(String mediaId, AudioPlayer player) =>
      _playerCache[mediaId] = player;

  static Duration? getDuration(String mediaId) => _durationCache[mediaId];
  static void setDuration(String mediaId, Duration duration) =>
      _durationCache[mediaId] = duration;

  static double getSpeed(String mediaId) => _speedCache[mediaId] ?? 1.0;
  static void setSpeed(String mediaId, double speed) =>
      _speedCache[mediaId] = speed;

  static bool isProcessing(String mediaId) =>
      _processingFiles.contains(mediaId);
  static void setProcessing(String mediaId) => _processingFiles.add(mediaId);
  static void clearProcessing(String mediaId) =>
      _processingFiles.remove(mediaId);

  static String? getError(String mediaId) => _errorCache[mediaId];
  static void setError(String mediaId, String error) =>
      _errorCache[mediaId] = error;
  static void clearError(String mediaId) => _errorCache.remove(mediaId);

  static void disposePlayer(String mediaId) {
    _playerCache[mediaId]?.dispose();
    _playerCache.remove(mediaId);
    _processingFiles.remove(mediaId);
    _errorCache.remove(mediaId);
    _speedCache.remove(mediaId);
  }

  static void clearAll() {
    for (var player in _playerCache.values) {
      player.dispose();
    }
    _playerCache.clear();
    _audioPathCache.clear();
    _durationCache.clear();
    _processingFiles.clear();
    _errorCache.clear();
    _speedCache.clear();
  }
}

/// WhatsApp-style Audio Preview Widget
class _InstantAudioPreview extends StatelessWidget {
  final String fileUrl;
  final String mediaId;
  final bool isInChatBubble;
  final bool isSent;
  final double? maxWidth;
  final double? maxHeight;

  const _InstantAudioPreview({
    required this.fileUrl,
    required this.mediaId,
    required this.isInChatBubble,
    this.isSent = false,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: maxWidth ?? (isInChatBubble ? 300.w : 340.w),
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? (isInChatBubble ? 70.h : 90.h),
      ),
      child: _WhatsAppAudioPlayer(
        fileUrl: fileUrl,
        mediaId: mediaId,
        isCompact: isInChatBubble,
        isSent: isSent,
      ),
    );
  }
}

/// WhatsApp-style audio player with speed control and seekable waveform
class _WhatsAppAudioPlayer extends StatefulWidget {
  final String fileUrl;
  final String mediaId;
  final bool isCompact;
  final bool isSent;

  const _WhatsAppAudioPlayer({
    required this.fileUrl,
    required this.mediaId,
    this.isCompact = true,
    this.isSent = false,
  });

  @override
  State<_WhatsAppAudioPlayer> createState() => _WhatsAppAudioPlayerState();
}

class _WhatsAppAudioPlayerState extends State<_WhatsAppAudioPlayer>
    with TickerProviderStateMixin {
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isReady = false;
  bool _isLoading = true;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _filePath;
  String? _errorMessage;
  double _playbackSpeed = 1.0;
  bool _isDragging = false;

  // Animation controllers for WhatsApp-style effects
  late AnimationController _playButtonController;
  late AnimationController _waveAnimationController;
  late AnimationController _speedButtonController;
  late Animation<double> _playButtonScale;
  late Animation<double> _speedButtonScale;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeAudioOnce();
  }

  void _initializeAnimations() {
    _playButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _speedButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _playButtonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _playButtonController, curve: Curves.easeInOut),
    );

    _speedButtonScale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _speedButtonController, curve: Curves.easeInOut),
    );
  }

  /// Initialize audio only once per media ID
  Future<void> _initializeAudioOnce() async {
    debugPrint(
      'Audio ${widget.mediaId}: Starting initialization with URL: ${widget.fileUrl}',
    );

    // Restore cached speed
    _playbackSpeed = AudioCache.getSpeed(widget.mediaId);

    // Check for cached error
    final cachedError = AudioCache.getError(widget.mediaId);
    if (cachedError != null) {
      setState(() {
        _errorMessage = cachedError;
        _isLoading = false;
      });
      return;
    }

    // Check if already cached and ready
    final cachedPath = AudioCache.getAudioPath(widget.mediaId);
    final cachedPlayer = AudioCache.getPlayer(widget.mediaId);

    if (cachedPath != null && cachedPlayer != null) {
      debugPrint('Audio ${widget.mediaId}: Using cached data');
      _filePath = cachedPath;
      _audioPlayer = cachedPlayer;
      _duration = AudioCache.getDuration(widget.mediaId) ?? Duration.zero;
      _setupPlayerListeners();
      setState(() {
        _isReady = true;
        _isLoading = false;
      });
      return;
    }

    // Prevent multiple simultaneous processing
    if (AudioCache.isProcessing(widget.mediaId)) {
      debugPrint('Audio ${widget.mediaId}: Already processing, waiting...');
      _waitForProcessing();
      return;
    }

    AudioCache.setProcessing(widget.mediaId);
    await _processAudioFile();
  }

  /// Wait for another widget to finish processing this audio
  Future<void> _waitForProcessing() async {
    int attempts = 0;
    while (AudioCache.isProcessing(widget.mediaId) && attempts < 30) {
      await Future.delayed(const Duration(milliseconds: 200));
      attempts++;

      if (AudioCache.getAudioPath(widget.mediaId) != null) {
        break;
      }
    }

    final cachedPath = AudioCache.getAudioPath(widget.mediaId);
    final cachedError = AudioCache.getError(widget.mediaId);

    if (cachedError != null && mounted) {
      setState(() {
        _errorMessage = cachedError;
        _isLoading = false;
      });
    } else if (cachedPath != null && mounted) {
      _filePath = cachedPath;
      _audioPlayer = AudioCache.getPlayer(widget.mediaId);
      _duration = AudioCache.getDuration(widget.mediaId) ?? Duration.zero;

      if (_audioPlayer != null) {
        _setupPlayerListeners();
      } else {
        await _createNewPlayer();
      }

      setState(() {
        _isReady = true;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _errorMessage = 'Failed to load audio';
        _isLoading = false;
      });
    }
  }

  /// Process audio file with better source detection
  Future<void> _processAudioFile() async {
    try {
      debugPrint('Audio ${widget.mediaId}: Processing file...');

      if (widget.fileUrl.startsWith('data:')) {
        debugPrint('Audio ${widget.mediaId}: Processing base64 data');
        _filePath = await _AudioFileUtils.saveBase64Audio(
          widget.fileUrl,
          'audio_${widget.mediaId}',
        );

        if (_filePath == null) {
          throw Exception('Failed to decode base64 audio data');
        }
      } else if (widget.fileUrl.startsWith('http://') ||
          widget.fileUrl.startsWith('https://')) {
        debugPrint('Audio ${widget.mediaId}: Using network URL');
        _filePath = widget.fileUrl;
      } else if (widget.fileUrl.startsWith('file://')) {
        debugPrint('Audio ${widget.mediaId}: Using file URL');
        _filePath = widget.fileUrl.replaceFirst('file://', '');
      } else if (widget.fileUrl.startsWith('/')) {
        debugPrint('Audio ${widget.mediaId}: Using absolute file path');
        _filePath = widget.fileUrl;
      } else {
        debugPrint('Audio ${widget.mediaId}: Treating as relative file path');
        _filePath = widget.fileUrl;
      }

      if (_filePath != null) {
        if (!_isNetworkUrl(_filePath!) && !await File(_filePath!).exists()) {
          throw Exception('Audio file not found: $_filePath');
        }

        debugPrint('Audio ${widget.mediaId}: File path resolved: $_filePath');
        AudioCache.setAudioPath(widget.mediaId, _filePath!);
        await _createNewPlayer();

        if (mounted) {
          setState(() {
            _isReady = true;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to resolve audio file path');
      }
    } catch (e) {
      final errorMsg = 'Audio error: ${e.toString()}';
      debugPrint('Audio ${widget.mediaId}: $errorMsg');
      AudioCache.setError(widget.mediaId, errorMsg);

      if (mounted) {
        setState(() {
          _errorMessage = 'Cannot load audio';
          _isLoading = false;
        });
      }
    } finally {
      AudioCache.clearProcessing(widget.mediaId);
    }
  }

  bool _isNetworkUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  /// Create and cache new audio player
  Future<void> _createNewPlayer() async {
    try {
      _audioPlayer = AudioPlayer();
      AudioCache.setPlayer(widget.mediaId, _audioPlayer!);
      _setupPlayerListeners();

      debugPrint(
        'Audio ${widget.mediaId}: Player created, source will be set on first play',
      );
    } catch (e) {
      debugPrint('Audio ${widget.mediaId}: Player creation error: $e');
      throw Exception('Failed to create audio player: $e');
    }
  }

  /// Setup player listeners
  void _setupPlayerListeners() {
    if (_audioPlayer == null) return;

    _audioPlayer!.onDurationChanged.listen((duration) {
      if (mounted && duration.inMilliseconds > 0) {
        AudioCache.setDuration(widget.mediaId, duration);
        setState(() => _duration = duration);
        debugPrint(
          'Audio ${widget.mediaId}: Duration updated: ${duration.inSeconds}s',
        );
      }
    });

    _audioPlayer!.onPositionChanged.listen((position) {
      if (mounted && !_isDragging) {
        setState(() => _position = position);
      }
    });

    _audioPlayer!.onPlayerStateChanged.listen((state) {
      if (mounted) {
        final wasPlaying = _isPlaying;
        setState(() => _isPlaying = state == PlayerState.playing);

        if (state == PlayerState.completed) {
          setState(() => _position = Duration.zero);
          _waveAnimationController.stop();
          _waveAnimationController.reset();
        }

        // Start/stop wave animation
        if (_isPlaying && !wasPlaying) {
          _waveAnimationController.repeat();
        } else if (!_isPlaying && wasPlaying) {
          _waveAnimationController.stop();
        }

        if (wasPlaying != _isPlaying) {
          debugPrint('Audio ${widget.mediaId}: State changed to $state');
        }
      }
    });
  }

  /// WhatsApp-style play/pause toggle
  Future<void> _togglePlayPause() async {
    if (_audioPlayer == null || _filePath == null) {
      debugPrint('Audio ${widget.mediaId}: Player or file path not ready');
      return;
    }

    // Button press animation
    _playButtonController.forward().then((_) {
      _playButtonController.reverse();
    });

    try {
      if (_isPlaying) {
        await _audioPlayer!.pause();
        debugPrint('Audio ${widget.mediaId}: Paused');
      } else {
        // Set playback speed before playing
        await _audioPlayer!.setPlaybackRate(_playbackSpeed);

        if (_isNetworkUrl(_filePath!)) {
          await _audioPlayer!.play(UrlSource(_filePath!));
        } else {
          await _audioPlayer!.play(DeviceFileSource(_filePath!));
        }
        debugPrint(
          'Audio ${widget.mediaId}: Started playing at ${_playbackSpeed}x speed',
        );
      }
    } catch (e) {
      debugPrint('Audio ${widget.mediaId}: Playback error: $e');
      if (mounted) {
        setState(() => _errorMessage = 'Playback failed');
      }
    }
  }

  /// Change playback speed (1x -> 1.5x -> 2x -> 1x)
  Future<void> _toggleSpeed() async {
    if (_audioPlayer == null) return;

    _speedButtonController.forward().then((_) {
      _speedButtonController.reverse();
    });

    setState(() {
      if (_playbackSpeed == 1.0) {
        _playbackSpeed = 1.5;
      } else if (_playbackSpeed == 1.5) {
        _playbackSpeed = 2.0;
      } else {
        _playbackSpeed = 1.0;
      }
    });

    // Cache the speed
    AudioCache.setSpeed(widget.mediaId, _playbackSpeed);

    // Apply speed if currently playing
    if (_isPlaying) {
      try {
        await _audioPlayer!.setPlaybackRate(_playbackSpeed);
        debugPrint(
          'Audio ${widget.mediaId}: Speed changed to ${_playbackSpeed}x',
        );
      } catch (e) {
        debugPrint('Audio ${widget.mediaId}: Speed change error: $e');
      }
    }
  }

  /// Seek to specific position in audio
  Future<void> _seekToPosition(double progress) async {
    if (_audioPlayer == null || _duration.inMilliseconds == 0) return;

    final newPosition = Duration(
      milliseconds: (_duration.inMilliseconds * progress).round(),
    );

    try {
      await _audioPlayer!.seek(newPosition);
      setState(() => _position = newPosition);
      debugPrint(
        'Audio ${widget.mediaId}: Seeked to ${newPosition.inSeconds}s',
      );
    } catch (e) {
      debugPrint('Audio ${widget.mediaId}: Seek error: $e');
    }
  }

  @override
  void dispose() {
    _playButtonController.dispose();
    _waveAnimationController.dispose();
    _speedButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _WhatsAppAudioShimmer(
        isCompact: widget.isCompact,
        isSent: widget.isSent,
      );
    }

    if (_errorMessage != null) {
      return _WhatsAppAudioError(
        message: _errorMessage!,
        isCompact: widget.isCompact,
        isSent: widget.isSent,
        onRetry: () {
          AudioCache.clearError(widget.mediaId);
          AudioCache.disposePlayer(widget.mediaId);
          // setState(() {
          //   _errorMessage = null;
          //   _isLoading = true;
          //   _isReady = false;
          // });
          _initializeAudioOnce();
        },
      );
    }

    return _buildWhatsAppAudioWidget();
  }

  Widget _buildWhatsAppAudioWidget() {
    final primaryColor = widget.isSent ? Colors.white : Colors.green[600]!;
    final backgroundColor = widget.isSent ? Colors.green[100] : Colors.white;
    final textColor = widget.isSent ? Colors.green[700]! : Colors.black87;

    return Container(
      height: 90,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          // Main audio controls row
          Row(
            children: [
              // Play/Pause button
              AnimatedBuilder(
                animation: _playButtonScale,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _playButtonScale.value,
                    child: GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: widget.isSent
                              ? Colors.green[600]
                              : Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(width: 12.w),

              // Waveform and controls
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    10.verticalSpace,
                    // Interactive waveform
                    GestureDetector(
                      onTapDown: (details) {
                        setState(() => _isDragging = true);
                        final progress =
                            details.localPosition.dx / (300.w - 56.w);
                        _seekToPosition(progress.clamp(0.0, 1.0));
                      },
                      onPanUpdate: (details) {
                        final progress =
                            details.localPosition.dx / (300.w - 56.w);
                        _seekToPosition(progress.clamp(0.0, 1.0));
                      },
                      onPanEnd: (details) {
                        setState(() => _isDragging = false);
                      },
                      child: _buildInteractiveWaveform(),
                    ),

                    SizedBox(height: 6.h),

                    // Duration, speed, and status row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Duration display
                        Text(
                          _isPlaying || _position.inMilliseconds > 0
                              ? '${_formatDuration(_position)} / ${_formatDuration(_duration)}'
                              : _formatDuration(_duration),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: textColor.withOpacity(0.7),
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        // Speed control and status
                        Row(
                          children: [
                            if (_isPlaying) ...[
                              Icon(
                                Icons.keyboard_voice,
                                size: 12.sp,
                                color: Colors.green[600],
                              ),
                              SizedBox(width: 8.w),
                            ],

                            // Speed button
                            AnimatedBuilder(
                              animation: _speedButtonScale,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _speedButtonScale.value,
                                  child: GestureDetector(
                                    onTap: _toggleSpeed,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _playbackSpeed != 1.0
                                            ? Colors.green[600]
                                            : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Text(
                                        '${_playbackSpeed.toString().replaceAll('.0', '')}x',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: _playbackSpeed != 1.0
                                              ? Colors.white
                                              : Colors.grey[600],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveWaveform() {
    return SizedBox(
      height: 30.h,
      child: Row(
        children: List.generate(25, (index) {
          return Expanded(child: _buildInteractiveWaveformBar(index));
        }),
      ),
    );
  }

  Widget _buildInteractiveWaveformBar(int index) {
    // Create realistic waveform heights
    final heights = [
      0.3,
      0.8,
      0.6,
      1.0,
      0.4,
      0.9,
      0.7,
      0.5,
      0.8,
      0.6,
      0.4,
      0.7,
      0.9,
      0.3,
      0.6,
      0.8,
      0.5,
      0.7,
      0.4,
      0.6,
      0.8,
      0.5,
      0.9,
      0.3,
      0.7,
    ];

    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    final barProgress = index / 25;
    final isPlayed = barProgress <= progress;
    final isActive =
        _isPlaying &&
        (barProgress - 0.04) <= progress &&
        progress <= (barProgress + 0.04);

    return AnimatedBuilder(
      animation: _waveAnimationController,
      builder: (context, child) {
        final baseHeight = heights[index];
        final animatedHeight = isActive && _isPlaying
            ? baseHeight * (0.7 + 0.6 * _waveAnimationController.value)
            : baseHeight;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 0.5.w),
          child: Align(
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 2.5.w,
              height: (animatedHeight * 24.h).clamp(3.h, 24.h),
              decoration: BoxDecoration(
                color: isPlayed
                    ? Colors.green[600]
                    : (widget.isSent ? Colors.green[300] : Colors.grey[400]),
                borderRadius: BorderRadius.circular(1.5.r),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// WhatsApp-style loading shimmer
class _WhatsAppAudioShimmer extends StatelessWidget {
  final bool isCompact;
  final bool isSent;

  const _WhatsAppAudioShimmer({required this.isCompact, required this.isSent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCompact ? 300.w : 340.w,
      height: isCompact ? 70.h : 90.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSent ? Colors.green[100] : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Shimmer play button
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shimmer waveform
                    Row(
                      children: List.generate(25, (index) {
                        return Container(
                          width: 2.5.w,
                          height: (8 + (index % 4) * 4).h,
                          margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(1.5.r),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 6.h),
                    // Shimmer controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 60.w,
                          height: 10.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                        ),
                        Container(
                          width: 24.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// WhatsApp-style error widget
class _WhatsAppAudioError extends StatelessWidget {
  final String message;
  final bool isCompact;
  final bool isSent;
  final VoidCallback? onRetry;

  const _WhatsAppAudioError({
    required this.message,
    required this.isCompact,
    required this.isSent,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCompact ? 300.w : 340.w,
      height: isCompact ? 70.h : 90.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSent ? Colors.green[100] : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: InkWell(
        onTap: onRetry,
        borderRadius: BorderRadius.circular(12.r),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: Colors.red[100],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red[600],
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Voice message failed',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Tap to retry',
                    style: TextStyle(fontSize: 10.sp, color: Colors.red[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Optimized audio file utilities
class _AudioFileUtils {
  static final Map<String, String> _audioPathCache = {};

  static Future<String?> saveBase64Audio(
    String base64Data,
    String baseFileName,
  ) async {
    try {
      String cleanBase64 = base64Data;
      String extension = '.m4a';

      if (base64Data.contains(',')) {
        final parts = base64Data.split(',');
        final header = parts.first;
        cleanBase64 = parts.last;

        if (header.contains('audio/mp3') || header.contains('audio/mpeg')) {
          extension = '.mp3';
        } else if (header.contains('audio/wav')) {
          extension = '.wav';
        } else if (header.contains('audio/ogg')) {
          extension = '.ogg';
        } else if (header.contains('audio/m4a') ||
            header.contains('audio/mp4')) {
          extension = '.m4a';
        }
      }

      final fileName = '$baseFileName$extension';

      if (_audioPathCache.containsKey(fileName)) {
        final cachedPath = _audioPathCache[fileName]!;
        if (await File(cachedPath).exists()) {
          debugPrint('Audio file cache hit: $fileName');
          return cachedPath;
        }
      }

      final bytes = base64Decode(cleanBase64);
      if (bytes.isEmpty) {
        throw Exception('Empty audio data after base64 decode');
      }

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (!await file.exists()) {
        throw Exception('Failed to write audio file');
      }

      debugPrint('Audio file saved: ${file.path} (${bytes.length} bytes)');
      _audioPathCache[fileName] = file.path;
      return file.path;
    } catch (e) {
      debugPrint('Error saving base64 audio: $e');
      return null;
    }
  }
}
