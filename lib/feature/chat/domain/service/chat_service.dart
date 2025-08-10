import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:injectable/injectable.dart';
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

  @override
  Future<ResponseResult<List<ChatListResponse>>> chatList() async {
    final res = await NetworkProvider().get(ApiEndpoints.chatList);
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
  Future<ResponseResult<ChatEntryResponse>> chatEntry(
    int chatId,
    int userId,
  ) async {
    try {
      final res = await _networkProvider.get(
        ApiEndpoints.chatEntry(chatId, userId),
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
          "visitNo": "DCRT030725R1BAH1", // Use required format
          "templateCode": "ABNTMP", // Use required template
          "chatMedias": chatMedias, // Always include array (empty if no files)
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

  @override
  Future<Map<String, dynamic>> getFileFromApi(String media) async {
    try {
      final response = await _networkProvider.get(
        ApiEndpoints.mediaType(media ?? ''),
        options: Options(
          headers: {
            'Authorization':
                'Bearer ${await AuthUtils.instance.readAccessToken}', // Use your actual token
          },
          responseType: ResponseType.bytes,
        ),
      );

      if (response.data != null) {
        final bytes = response.data as List<int>;
        final fileName = media;
        final extension = fileName.toLowerCase().split('.').last;

        String mimeType;
        String fileType;

        switch (extension) {
          case 'jpg':
          case 'jpeg':
            mimeType = 'image/jpeg';
            fileType = 'image';
            break;
          case 'png':
            mimeType = 'image/png';
            fileType = 'image';
            break;
          case 'gif':
            mimeType = 'image/gif';
            fileType = 'image';
            break;
          case 'pdf':
            mimeType = 'application/pdf';
            fileType = 'document';
            break;
          case 'doc':
          case 'docx':
            mimeType = 'application/msword';
            fileType = 'document';
            break;
          case 'mp3':
            mimeType = 'audio/mpeg';
            fileType = 'audio';
            break;
          case 'wav':
            mimeType = 'audio/wav';
            fileType = 'audio';
            break;
          case 'm4a':
          case 'aac':
            mimeType = 'audio/aac';
            fileType = 'audio';
            break;
          case 'mp4':
            mimeType = 'video/mp4';
            fileType = 'video';
            break;
          default:
            mimeType = 'application/octet-stream';
            fileType = 'document';
        }

        if (fileType == 'image') {
          final base64String = base64Encode(bytes);
          return {
            'type': 'image',
            'data': 'data:$mimeType;base64,$base64String',
            'bytes': bytes,
          };
        } else if (fileType == 'audio') {
          final tempFile = await _saveToTempFile(bytes, extension);
          return {'type': 'audio', 'data': tempFile.path, 'bytes': bytes};
        } else {
          final tempFile = await _saveToTempFile(bytes, extension);
          return {
            'type': 'document',
            'data': tempFile.path,
            'bytes': bytes,
            'mimeType': mimeType,
          };
        }
      }
    } catch (e) {
      log('API call failed: $e');
      rethrow;
    }

    throw Exception('Failed to load file');
  }

  Future<File> _saveToTempFile(List<int> bytes, String extension) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
      '${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.$extension',
    );
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  }
}
