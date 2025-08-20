import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:injectable/injectable.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soxo_chat/feature/chat/domain/models/add_chat/add_chatentry_request.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart'
    hide ChatMedia;
import 'package:soxo_chat/feature/chat/domain/models/chat_res/chat_list_response.dart';
import 'package:soxo_chat/feature/chat/domain/repositories/chat_repositories.dart';
import 'package:soxo_chat/shared/api/endpoint/api_endpoints.dart';
import 'package:soxo_chat/shared/api/network/network.dart';
import 'package:soxo_chat/shared/utils/auth/auth_utils.dart';
import 'package:soxo_chat/shared/utils/result.dart';

@LazySingleton(as: ChatRepositories)
class ChatService implements ChatRepositories {
  final NetworkProvider _networkProvider = NetworkProvider();
  static final Map<String, Map<String, dynamic>> _mediaCache = {};

  @override
  Future<ResponseResult<List<ChatListResponse>>> chatList() async {
    final user = await AuthUtils.instance.readUserData();
    final res = await NetworkProvider().get(
      ApiEndpoints.chatList(user?.result?.userId ?? 0),
    );
    switch (res.statusCode) {
      case 200:
        return ResponseResult(
          data: List<ChatListResponse>.from(
            res.data?.map((e) => ChatListResponse.fromJson(e)),
          ).toList(),
        );
      default:
        throw ResponseResult(data: res.statusMessage);
    }
  }

  @override
  Future<ResponseResult<ChatEntryResponse>> chatEntry(int chatId) async {
    try {
      final user = await AuthUtils.instance.readUserData();
      final res = await _networkProvider.get(
        ApiEndpoints.chatEntry(chatId, user?.result?.userId ?? 0),
      );

      if (res.statusCode == 200) {
        return ResponseResult(data: ChatEntryResponse.fromJson(res.data));
      } else {
        return ResponseResult(data: ChatEntryResponse());
      }
    } on DioException catch (e) {
      switch (e.response?.statusCode) {
        case 404:
          return ResponseResult(data: ChatEntryResponse());
        case 401:
          throw ResponseResult(
            data: 'Authentication failed. Please login again.',
          );
        case 403:
          throw ResponseResult(
            data: 'You don\'t have permission to access this chat.',
          );
        case 500:
          throw ResponseResult(data: 'Server error. Please try again later.');
        default:
          throw ResponseResult(
            data:
                'Failed to load chat. Error: ${e.response?.statusCode ?? "Unknown"}',
          );
      }
    } catch (e) {
      log('Unexpected error in chatEntry: $e');
      throw ResponseResult(
        data: 'Network error. Please check your connection.',
      );
    }
  }

  @override
  Future<ResponseResult<Entry>> addChatEntry({
    AddChatEntryRequest? req,
    List<File>? files,
  }) async {
    try {
      log('ChatService: Starting addChatEntry');
      log('Files count: ${files?.length ?? 0}');

      final formData = FormData();

      if (req != null) {
        // Create chatMedias array for uploaded files
        List<ChatMedia> chatMedias = [];

        if (files != null && files.isNotEmpty) {
          for (int i = 0; i < files.length; i++) {
            final file = files[i];
            final fileName = file.path.split('/').last;
            final extension = fileName.split('.').last.toLowerCase();
            final fileSize = await file.length();

            // Determine media type
            String mediaType = 'document';
            if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
              mediaType = 'image';
            } else if (['mp4', 'mov', 'avi'].contains(extension)) {
              mediaType = 'video';
            } else if (['mp3', 'wav', 'm4a', 'aac'].contains(extension)) {
              mediaType = 'audio';
            }

            // Create ChatMedia object
            final chatMedia = ChatMedia(
              mediaType: mediaType,
              mediaUrl: "/media/$fileName",
              mediaSize: fileSize,
              fileName: fileName,
              encryptionKey: "", // Server will generate if needed
              encryptionLevel: "L1",
              encryption: "", // Server will generate if needed
              status: "Open",
              branchPtr: "DALQ", // Use your branch code
              firmPtr: "f2", // Use your firm code
            );

            chatMedias.add(chatMedia);
          }
        }

        // Create request with required fields
        final requestMap = {
          "chatId": req.chatId ?? 1,
          "senderId": req.senderId ?? 45,
          "type": req.type ?? "N",
          "typeValue": req.typeValue ?? 0,
          "messageType": req.messageType ?? "text",
          "content": req.content ?? "",
          "source": req.source ?? "Mobile",
          "visitNo": "DCRT030725R1BAH1",
          "templateCode": "ABNTMP", // Use required template
          "chatMedias": chatMedias, // Always include array (empty if no files)
          "otherDetails1": req.otherDetails1,
          "pinned": req.pinned,
        };

        final jsonString = jsonEncode(requestMap);
        formData.fields.add(MapEntry('chatEntryJson', jsonString));
        log('Complete chatEntryJson: $jsonString');
      }

      if (files != null && files.isNotEmpty) {
        for (var file in files) {
          formData.files.add(
            MapEntry(
              'files',
              await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
                contentType: MediaType.parse(_getContentType(file.path)),
              ),
            ),
          );
        }
        log('Added ${files.length} files to FormData');
      }

      log('ChatService: Calling postFormData');

      final res = await _networkProvider.postFormData(
        ApiEndpoints.addChatENtry,
        formData: formData,
      );

      log('ChatService: SUCCESS! Response status ${res.statusCode}');
      return _handleResponse(res);
    } catch (e) {
      log('ChatService Error: $e');
      throw ResponseResult(data: 'Failed to send message: $e');
    }
  }

  ResponseResult<Entry> _handleResponse(Response res) {
    log('Handling response with status: ${res.statusCode}');
    switch (res.statusCode) {
      case 200:
      case 201:
        log('Success response: ${res.data}');
        return ResponseResult(data: Entry.fromJson(res.data));
      default:
        log('Error response: ${res.statusMessage}');
        throw ResponseResult(data: res.statusMessage ?? 'Unknown error');
    }
  }

  String _getContentType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'm4a':
      case 'aac':
        return 'audio/aac';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'txt':
        return 'text/plain';
      case 'json':
        return 'application/json';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      default:
        return 'application/octet-stream';
    }
  }

  // UPDATE your existing getFileFromApi method in ChatCubit

  @override
  Future<Map<String, dynamic>> getFileFromApi(String media) async {
    try {
      // Check if we already have this media cached
      if (_mediaCache.containsKey(media)) {
        final cached = _mediaCache[media]!;
        // Verify the file still exists for audio/video types
        if (cached['type'] == 'audio' || cached['type'] == 'video') {
          if (await File(cached['data']).exists()) {
            log('Using cached file for: $media');
            return cached;
          } else {
            // Remove from cache if file doesn't exist
            _mediaCache.remove(media);
          }
        } else {
          log('Using cached data for: $media');
          return cached;
        }
      }

      log('Fetching from API: $media');

      final response = await _networkProvider.get(
        ApiEndpoints.mediaType(media),
        options: Options(
          headers: {
            'Authorization':
                'Bearer ${await AuthUtils.instance.readAccessToken}',
          },
          responseType: ResponseType.bytes,
        ),
      );

      if (response.data == null) {
        throw Exception('No data received from server');
      }

      final bytes = response.data as List<int>;
      final mimeType = lookupMimeType(media) ?? 'application/octet-stream';
      final fileType = _getFileType(mimeType);

      Map<String, dynamic> result;

      // Handle all file types consistently
      switch (fileType) {
        case 'image':
          // Images as base64 (existing working logic)
          final base64String = base64Encode(bytes);
          result = {
            'type': 'image',
            'data': 'data:$mimeType;base64,$base64String',
            'bytes': bytes,
            'mimeType': mimeType,
          };
          break;

        case 'document':
          // PDFs as base64
          final base64String = base64Encode(bytes);
          result = {
            'type': 'document',
            'data': 'data:$mimeType;base64,$base64String',
            'bytes': bytes,
            'mimeType': mimeType,
          };
          break;

        case 'audio':
          // FIXED: Audio files with consistent naming for caching
          final extension = media.toLowerCase().split('.').last;
          final persistentFile = await _saveToPersistentFile(
            bytes,
            media,
            extension,
          );
          result = {
            'type': 'audio',
            'data': persistentFile.path,
            'bytes': bytes,
            'mimeType': mimeType,
            'mediaId': _generateConsistentId(media), // Add consistent media ID
          };
          break;

        case 'video':
          // Video files with consistent naming
          final extension = media.toLowerCase().split('.').last;
          final persistentFile = await _saveToPersistentFile(
            bytes,
            media,
            extension,
          );
          result = {
            'type': 'video',
            'data': persistentFile.path,
            'bytes': bytes,
            'mimeType': mimeType,
            'mediaId': _generateConsistentId(media),
          };
          break;

        default:
          // Unknown files as base64
          final base64String = base64Encode(bytes);
          result = {
            'type': 'unknown',
            'data': 'data:$mimeType;base64,$base64String',
            'bytes': bytes,
            'mimeType': mimeType,
          };
          break;
      }

      // Cache the result
      _mediaCache[media] = result;
      log('Successfully cached: $media');

      return result;
    } catch (e) {
      log('API call failed: $e');
      rethrow;
    }
  }

  String _getFileType(String mimeType) {
    if (mimeType.startsWith('image/')) return 'image';
    if (mimeType.startsWith('audio/')) return 'audio';
    if (mimeType.startsWith('video/')) return 'video';
    if (mimeType == 'application/pdf') return 'document';
    if (mimeType.startsWith('application/')) return 'document';
    return 'unknown';
  }

  /// FIXED: Generate consistent ID from media filename
  String _generateConsistentId(String media) {
    // Use MD5 hash of the media path/name for consistent IDs
    final bytes = utf8.encode(media);
    final digest = md5.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  /// FIXED: Save files with consistent naming based on content hash
  Future<File> _saveToPersistentFile(
    List<int> bytes,
    String media,
    String extension,
  ) async {
    // Generate consistent filename based on media identifier
    final mediaId = _generateConsistentId(media);
    final fileName = 'media_$mediaId.$extension';

    Directory directory;

    // Use permanent storage for audio/video files that need to persist
    if (_isAudioVideoExtension(extension)) {
      directory = await getApplicationDocumentsDirectory();

      // Create subdirectory for better organization
      final mediaDir = Directory('${directory.path}/media_files');
      if (!await mediaDir.exists()) {
        await mediaDir.create(recursive: true);
      }
      directory = mediaDir;
    } else {
      directory = await getTemporaryDirectory();
    }

    final file = File('${directory.path}/$fileName');

    // Check if file already exists and is valid
    if (await file.exists()) {
      try {
        final existingBytes = await file.readAsBytes();
        if (existingBytes.length == bytes.length) {
          log('File already exists and is valid: ${file.path}');
          return file;
        } else {
          log('Existing file size mismatch, recreating: ${file.path}');
          await file.delete();
        }
      } catch (e) {
        log('Error reading existing file, recreating: $e');
        await file.delete();
      }
    }

    // Write the file
    await file.writeAsBytes(bytes);

    // Verify the file was written correctly
    if (!await file.exists()) {
      throw Exception('Failed to create file: ${file.path}');
    }

    final writtenSize = await file.length();
    if (writtenSize != bytes.length) {
      await file.delete();
      throw Exception('File size mismatch after writing');
    }

    log('File saved successfully: ${file.path} (${bytes.length} bytes)');
    return file;
  }

  bool _isAudioVideoExtension(String extension) {
    const audioVideoExtensions = [
      'mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac', // Audio
      'mp4', 'mov', 'avi', 'mkv', 'webm', // Video
    ];
    return audioVideoExtensions.contains(extension.toLowerCase());
  }

  /// Clear the media cache (call this when user logs out or memory is low)
  static void clearCache() {
    _mediaCache.clear();
    log('Media cache cleared');
  }

  /// Clean up old media files (call this periodically)
  static Future<void> cleanupOldFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final mediaDir = Directory('${directory.path}/media_files');

      if (!await mediaDir.exists()) return;

      final files = await mediaDir.list().toList();
      final cutoffTime = DateTime.now().subtract(const Duration(days: 7));
      int deletedCount = 0;

      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffTime)) {
            await entity.delete();
            deletedCount++;
          }
        }
      }

      log('Cleaned up $deletedCount old media files');
    } catch (e) {
      log('Error during cleanup: $e');
    }
  }

  /// Get cache statistics (for debugging)
  static Map<String, dynamic> getCacheStats() {
    int audioCount = 0;
    int videoCount = 0;
    int imageCount = 0;
    int documentCount = 0;

    _mediaCache.forEach((key, value) {
      switch (value['type']) {
        case 'audio':
          audioCount++;
          break;
        case 'video':
          videoCount++;
          break;
        case 'image':
          imageCount++;
          break;
        case 'document':
          documentCount++;
          break;
      }
    });

    return {
      'total': _mediaCache.length,
      'audio': audioCount,
      'video': videoCount,
      'image': imageCount,
      'document': documentCount,
    };
  }

  @override
  Future<ResponseResult> deleteChat({
    String? mode,
    String? chatId,
    String? chatEntryId,
  }) async {
    final res = await NetworkProvider().delete(
      ApiEndpoints.deleteCHat(chatId ?? '', chatEntryId ?? '', mode ?? ''),
    );
    if (res.statusCode == 200) {
      return ResponseResult(data: res.data);
    } else {
      throw Error();
    }
  }
}
