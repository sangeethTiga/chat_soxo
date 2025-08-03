import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_res/chat_list_response.dart';
import 'package:soxo_chat/feature/chat/domain/repositories/chat_repositories.dart';
import 'package:soxo_chat/shared/api/endpoint/api_endpoints.dart';
import 'package:soxo_chat/shared/api/network/network.dart';
import 'package:soxo_chat/shared/utils/result.dart';

@LazySingleton(as: ChatRepositories)
class ChatService implements ChatRepositories {
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
  @override
  Future<ResponseResult<List<ChatEntryResponse>>> chatEntry(
    int chatId,
    int userId,
  ) async {
    try {
      final res = await NetworkProvider().get(
        ApiEndpoints.chatEntry(chatId, userId),
      );

      // If we get here, the request was successful (200)
      if (res.data != null) {
        return ResponseResult(
          data: List<ChatEntryResponse>.from(
            res.data?.map((e) => ChatEntryResponse.fromJson(e)) ?? [],
          ).toList(),
        );
      } else {
        // Empty but successful response
        return ResponseResult(data: []);
      }
    } on DioException catch (e) {
      // Handle specific Dio errors
      switch (e.response?.statusCode) {
        case 404:
          // No chat records found - this is normal, return empty list
          print(
            'No chat entry records found for chatId: $chatId, userId: $userId',
          );
          return ResponseResult(data: []);

        case 401:
          print('Authentication failed - token might be expired');
          throw ResponseResult(
            data: 'Authentication failed. Please login again.',
          );

        case 403:
          print('Access forbidden for chatId: $chatId');
          throw ResponseResult(
            data: 'You don\'t have permission to access this chat.',
          );

        case 500:
          print('Server error occurred');
          throw ResponseResult(data: 'Server error. Please try again later.');

        default:
          print('API Error: ${e.response?.statusCode} - ${e.message}');
          throw ResponseResult(
            data:
                'Failed to load chat. Error: ${e.response?.statusCode ?? "Unknown"}',
          );
      }
    } catch (e) {
      // Handle other errors (network, parsing, etc.)
      print('Unexpected error in chatEntry: $e');
      throw ResponseResult(
        data: 'Network error. Please check your connection.',
      );
    }
  }
}
