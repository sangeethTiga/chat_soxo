import 'package:soxo_chat/feature/chat/domain/models/chat_res/chat_list_response.dart';
import 'package:soxo_chat/feature/person_lists/domain/models/chat_request/chat_request.dart';
import 'package:soxo_chat/feature/person_lists/domain/models/user_response.dart';
import 'package:soxo_chat/shared/utils/result.dart';

abstract class PersonListRepositories {
  Future<ResponseResult<List<UserResponse>>> personList();
  Future<ResponseResult<List<ChatListResponse>>> createChat(ChatRequest req);
}
