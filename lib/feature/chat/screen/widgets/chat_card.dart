import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/audio_player.dart';
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
  final ChatMedias? media;

  const _MediaTypeDispatcher({
    required this.fileUrl,
    required this.fileType,
    required this.mediaId,
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
    this.media,
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
        return InstantAudioPreview(
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
                  'PDF document',
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
