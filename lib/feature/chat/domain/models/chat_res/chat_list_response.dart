// To parse this JSON data, do
//
//     final chatListResponse = chatListResponseFromJson(jsonString);

import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_list_response.freezed.dart';
part 'chat_list_response.g.dart';

List<ChatListResponse> chatListResponseFromJson(String str) =>
    List<ChatListResponse>.from(
      json.decode(str).map((x) => ChatListResponse.fromJson(x)),
    );

String chatListResponseToJson(List<ChatListResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@freezed
class ChatListResponse with _$ChatListResponse {
  const factory ChatListResponse({
    @JsonKey(name: "chatId") int? chatId,
    @JsonKey(name: "mode") String? mode,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "code") String? code,
    @JsonKey(name: "title") String? title,
    @JsonKey(name: "description") String? description,
    @JsonKey(name: "status") String? status,
    @JsonKey(name: "createdBy") int? createdBy,
    @JsonKey(name: "createdAt") String? createdAt,
    @JsonKey(name: "updatedAt") String? updatedAt,
    @JsonKey(name: "branchPtr") String? branchPtr,
    @JsonKey(name: "firmPtr") String? firmPtr,
    @JsonKey(name: "userChats") List<UserChat>? userChats,
  }) = _ChatListResponse;

  factory ChatListResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatListResponseFromJson(json);
}

@freezed
class UserChat with _$UserChat {
  const factory UserChat({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "chatId") int? chatId,
    @JsonKey(name: "userId") int? userId,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "role") String? role,
    @JsonKey(name: "lastSeenMsgId") int? lastSeenMsgId,
    @JsonKey(name: "createdAt") String? createdAt,
  }) = _UserChat;

  factory UserChat.fromJson(Map<String, dynamic> json) =>
      _$UserChatFromJson(json);
}
