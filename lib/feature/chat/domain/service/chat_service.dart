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
  Future<ResponseResult<List<ChatEntryResponse>>> chatEntry(
    int chatId,
    int userId,
  ) async {
    final res = await NetworkProvider().get(
      ApiEndpoints.chatEntry(chatId, userId),
    );
    switch (res.statusCode) {
      case 200:
        return ResponseResult(
          data: List<ChatEntryResponse>.from(
            res.data?.map((e) => ChatEntryResponse.fromJson(e)),
          ).toList(),
        );
      default:
        throw ResponseResult(data: res.statusMessage);
    }
  }
}
