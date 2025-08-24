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
import 'package:soxo_chat/feature/chat/domain/repositories/chat_repositories.dart';
import 'package:soxo_chat/feature/chat/screen/chat_screen.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/image_show.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/pdf_viewer.dart';
import 'package:soxo_chat/shared/widgets/audio_player.dart/audi_player.dart';
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
          media: media ?? ChatMedias(),
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

    if (fileUrl != null && !MediaCache.isLoading(mediaId)) {
      return _MediaTypeDispatcher(
        media: media,
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
          media: media,
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
            media: media,
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
    if (media.mediaUrl != null && (media.mediaType?.isNotEmpty ?? false)) {
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
  final ChatMedias media;

  const _MediaTypeDispatcher({
    required this.fileUrl,
    required this.fileType,
    required this.mediaId,
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
    required this.media,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleMediaTap(context),
      child: _buildMediaWidget(),
    );
  }

  Widget _buildMediaWidget() {
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
          enableTap: true,
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
        return InstantDocumentPreview(
          fileUrl: fileUrl,
          mediaId: mediaId,
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          enableTap: true,
          media: media,
        );

      default:
        return _GenericFilePreview(
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
    }
  }

  void _handleMediaTap(BuildContext context) {
    log('📱 Media tapped: ${media.id}, type: $fileType');
    context.read<ChatCubit>().viewMediaFile(media);
  }
}

class _InstantImagePreview extends StatelessWidget {
  final String fileUrl;
  final String mediaId;
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;
  final bool enableTap;

  const _InstantImagePreview({
    required this.fileUrl,
    required this.mediaId,
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
    this.enableTap = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = Container(
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
    );

    if (enableTap) {
      return GestureDetector(
        onTap: () => showMyDialog(context, fileUrl, mediaId),
        child: imageWidget,
      );
    }

    return imageWidget;
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

class InstantDocumentPreview extends StatelessWidget {
  final String fileUrl;
  final String mediaId;
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;
  final bool enableTap;
  final ChatMedias media;
  final String? customFileName;

  const InstantDocumentPreview({
    required this.fileUrl,
    required this.mediaId,
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
    this.enableTap = true,
    required this.media,
    this.customFileName,
  });
  String get fileName {
    // Priority 1: Custom filename if provided
    if (customFileName != null && customFileName!.isNotEmpty) {
      return customFileName!;
    }

    // Priority 2: From media object if it has a name/filename property
    if (media.fileName != null && media.fileName!.isNotEmpty) {
      return media.fileName!;
    }

    // Priority 3: Extract from URL
    if (fileUrl.isNotEmpty) {
      return PdfNameExtractor.extractFileNameFromUrl(fileUrl);
    }

    // Fallback
    return 'Document.pdf';
  }

  @override
  Widget build(BuildContext context) {
    Widget documentWidget = Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? (isInChatBubble ? 200.w : double.infinity),
        maxHeight: maxHeight ?? (isInChatBubble ? 60.h : 80.h),
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Row(
          children: [
            Image.asset('assets/icons/pdf.png', height: 24.h, width: 24),

            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                      fileName,
                      style: TextStyle(
                        fontSize: isInChatBubble ? 12 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: isInChatBubble ? 3 : 2,
                    ),
                  ),
                  if (!isInChatBubble) ...[
                    SizedBox(height: 2.h),
                    Text(
                      'Tap to open',
                      style: TextStyle(fontSize: 10, color: Colors.red[600]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (enableTap) {
      return InkWell(
        onTap: () => _handleDocumentTap(context, media),
        borderRadius: BorderRadius.circular(8.r),
        child: documentWidget,
      );
    }

    return documentWidget;
  }

  Future<void> _handleDocumentTap(
    BuildContext context,
    ChatMedias media,
  ) async {
    try {
      _showLoadingSnackBar(context, 'Loading PDF...');

      String? filePath = MediaCache.getFilePath(mediaId);

      if (filePath != null && filePath.contains('/cache/temp_')) {
        log('🔄 Detected old temp file, forcing reload: $filePath');
        MediaCache.clearFilePath(mediaId);
        filePath = null;
      }

      if (fileUrl.contains('/cache/temp_')) {
        log('🔄 FileUrl is old temp path, forcing complete reload: $fileUrl');
        return;
      }

      if (filePath == null || !await File(filePath).exists()) {
        log('📄 No valid cached file, processing fileUrl: $fileUrl');

        if (fileUrl.startsWith('data:')) {
          log('📄 Converting base64 to PDF file...');
          filePath = await _FileUtils.saveBase64ToFile(
            fileUrl,
            'document_$mediaId.pdf',
          );

          if (filePath != null) {
            MediaCache.setFilePath(mediaId, filePath);
            log('✅ PDF saved to: $filePath');
          }
        } else if (fileUrl.startsWith('http')) {
          log('📄 Downloading from server...');
          filePath = await _downloadPdfFromServer(context, fileUrl);
          if (filePath != null) {
            MediaCache.setFilePath(mediaId, filePath);
          }
        } else if (await File(fileUrl).exists()) {
          filePath = fileUrl;
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          log('❌ Invalid fileUrl, forcing reload: $fileUrl');
          return;
        }
      } else {
        log('📄 Using cached file: $filePath');
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (filePath != null && await File(filePath).exists()) {
        log('✅ Opening PDF: $filePath');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PdfViewScreen(filePath: filePath!, fileName: 'PDF Document'),
          ),
        );
      } else {
        _showSnackBar(context, 'Could not load PDF file');
        log('❌ PDF file not accessible: $filePath');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      log('❌ Document error: $e');
      _showSnackBar(context, 'Error opening document: ${e.toString()}');
    }
  }

  void _showLoadingSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text(message),
          ],
        ),
        duration: Duration(seconds: 10),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<String?> _downloadPdfFromServer(
    BuildContext context,
    String serverUrl,
  ) async {
    try {
      log('📥 Downloading PDF from server: $serverUrl');

      final cubit = context.read<ChatCubit>();

      final existingFileUrl = cubit.getFileUrl(mediaId);
      final existingFileType = cubit.getFileType(mediaId);

      if (existingFileUrl != null && existingFileType == 'document') {
        if (!existingFileUrl.startsWith('http') &&
            !existingFileUrl.startsWith('data:')) {
          if (await File(existingFileUrl).exists()) {
            return existingFileUrl;
          }
        }
      }

      final tempMedia = ChatMedias(
        id: int.tryParse(mediaId),
        mediaUrl: serverUrl,
        mediaType: 'document',
      );

      await cubit.loadMediaFile(tempMedia);

      await Future.delayed(const Duration(milliseconds: 1000));

      final downloadedFileUrl = cubit.getFileUrl(mediaId);

      if (downloadedFileUrl != null) {
        if (downloadedFileUrl.startsWith('data:')) {
          return await _FileUtils.saveBase64ToFile(
            downloadedFileUrl,
            'downloaded_$mediaId.pdf',
          );
        } else if (!downloadedFileUrl.startsWith('http')) {
          if (await File(downloadedFileUrl).exists()) {
            return downloadedFileUrl;
          }
        }
      }
      ChatRepositories? chatRespositories;

      log('📥 Fallback: Direct download from repository');
      final fileData = await chatRespositories!.getFileFromApi(serverUrl);

      if (fileData['data'] != null) {
        if (fileData['type'] == 'document' && fileData['data'] is String) {
          final data = fileData['data'] as String;

          if (data.startsWith('data:')) {
            return await _FileUtils.saveBase64ToFile(
              data,
              'repository_$mediaId.pdf',
            );
          } else {
            if (await File(data).exists()) {
              return data;
            }
          }
        }
      }

      log('❌ Failed to download PDF from server');
      return null;
    } catch (e) {
      log('❌ Error downloading PDF: $e');
      return null;
    }
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
          Icon(Icons.error_outline, size: 16, color: Colors.red[600]),
          SizedBox(height: 2.h),
          Text(
            message,
            style: TextStyle(fontSize: 8, color: Colors.red[600]),
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
          Icon(Icons.insert_drive_file, size: 20, color: Colors.grey[600]),
          SizedBox(height: 2.h),
          Text('File', style: TextStyle(fontSize: 8, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

/// File utilities
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
        log('📄 Using cached PDF: $cachedPath');
        return cachedPath;
      } else {
        log('📄 Cached file no longer exists, creating new one');
        _pathCache.remove(fileName);
      }
    }
    log('📄 Converting base64 to file: $fileName');

    try {
      String cleanBase64 = base64Data;
      if (base64Data.contains(',')) {
        cleanBase64 = base64Data.split(',').last;
      }

      final bytes = base64Decode(cleanBase64);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      _pathCache[fileName] = file.path;
      log('✅ PDF saved successfully: ${file.path} (${bytes.length} bytes)');

      return file.path;
    } catch (e) {
      log('Error saving base64 to file: $e');
      return null;
    }
  }
}
