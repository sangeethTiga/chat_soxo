import 'package:soxo_chat/feature/chat/domain/models/chat_res/chat_list_response.dart';
import 'package:soxo_chat/shared/utils/result.dart';

abstract class ChatRepositories {
  Future<ResponseResult<List<ChatListResponse>>> chatList();
}
