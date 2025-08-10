import 'package:injectable/injectable.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_res/chat_list_response.dart';
import 'package:soxo_chat/feature/person_lists/domain/models/chat_request/chat_request.dart';
import 'package:soxo_chat/feature/person_lists/domain/models/user_response.dart';
import 'package:soxo_chat/feature/person_lists/domain/repositories/person_repositories.dart';
import 'package:soxo_chat/shared/api/endpoint/api_endpoints.dart';
import 'package:soxo_chat/shared/api/network/network.dart';
import 'package:soxo_chat/shared/utils/result.dart';

@LazySingleton(as: PersonListRepositories)
class PersonService implements PersonListRepositories {
  @override
  Future<ResponseResult<List<UserResponse>>> personList() async {
    final res = await NetworkProvider().get(ApiEndpoints.userList);
    switch (res.statusCode) {
      case 200:
        return ResponseResult(
          data: List<UserResponse>.from(
            res.data?.map((e) => UserResponse.fromJson(e)),
          ).toList(),
        );
      default:
        throw ResponseResult(data: res.statusMessage);
    }
  }

  @override
  Future<ResponseResult<ChatListResponse>> createChat(ChatRequest req) async {
    final res = await NetworkProvider().post(
      ApiEndpoints.createChat,
      data: req.toJson(),
    );
    switch (res.statusCode) {
      case 200:
        return ResponseResult(data: ChatListResponse.fromJson(res.data));
      default:
        throw ResponseResult(data: res.statusMessage);
    }
  }
}
