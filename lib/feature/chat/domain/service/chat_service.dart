import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:soxo_chat/feature/chat/domain/models/add_chat/add_chatentry_request.dart';
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
  Future<ResponseResult<ChatEntryResponse>> chatEntry(
    int chatId,
    int userId,
  ) async {
    try {
      final res = await NetworkProvider().get(
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
      print('Unexpected error in chatEntry: $e');
      throw ResponseResult(
        data: 'Network error. Please check your connection.',
      );
    }
  }

  @override
  Future<ResponseResult<Entry>> addChatEntry({
    AddChatEntryRequest? req,
  }) async {
    final res = await NetworkProvider().post(
      ApiEndpoints.addChatENtry,
      data: req?.toJson(),
    );
    switch (res.statusCode) {
      case 200:
        return ResponseResult(data: Entry.fromJson(res.data));
      default:
        throw ResponseResult(data: res.statusMessage);
    }
  }
}
