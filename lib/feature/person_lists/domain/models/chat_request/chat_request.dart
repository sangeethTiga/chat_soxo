import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soxo_chat/feature/person_lists/domain/models/user_response.dart';

part 'chat_request.freezed.dart';
part 'chat_request.g.dart';

@freezed
class ChatRequest with _$ChatRequest {
  const factory ChatRequest({
    @JsonKey(name: "mode") String? mode,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "code") String? code,
    @JsonKey(name: "title") String? title,
    @JsonKey(name: "description") String? description,
    @JsonKey(name: "status") String? status,
    @JsonKey(name: "createdBy") int? createdBy,
    @JsonKey(name: "branchPtr") String? branchPtr,
    @JsonKey(name: "firmPtr") String? firmPtr,
    @JsonKey(name: "userChats") List<UserResponse>? userChats,
  }) = _ChatRequest;

  factory ChatRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatRequestFromJson(json);
}

@freezed
class UserChat with _$UserChat {
  const factory UserChat({
    @JsonKey(name: "userId") int? userId,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "role") String? role,
  }) = _UserChat;

  factory UserChat.fromJson(Map<String, dynamic> json) =>
      _$UserChatFromJson(json);
}
