import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_entry_response.freezed.dart';
part 'chat_entry_response.g.dart';

@freezed
class ChatEntryResponse with _$ChatEntryResponse {
  const factory ChatEntryResponse({
    @JsonKey(name: "userChats") List<UserChat>? userChats,
    @JsonKey(name: "entries") List<Entry>? entries,
  }) = _ChatEntryResponse;

  factory ChatEntryResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatEntryResponseFromJson(json);
}

@freezed
class Entry with _$Entry {
  const factory Entry({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "typeValue") int? typeValue,
    @JsonKey(name: "chatId") int? chatId,
    @JsonKey(name: "senderId") int? senderId,
    @JsonKey(name: "messageType") String? messageType,
    @JsonKey(name: "thread") String? thread,
    @JsonKey(name: "content") String? content,
    @JsonKey(name: "mediaIds") String? mediaIds,
    @JsonKey(name: "createdAt") String? createdAt,
    @JsonKey(name: "sender") Sender? sender,
    @JsonKey(name: "chatMedias") List<ChatMedias>? chatMedias,
    @JsonKey(name: "userStatus") String? userStatus,
    @JsonKey(name: "userChats") List<UserChat>? userChats,
  }) = _Entry;

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);
}

@freezed
class ChatMedias with _$ChatMedias {
  const factory ChatMedias({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "chatId") int? chatId,
    @JsonKey(name: "mediaType") String? mediaType,
    @JsonKey(name: "mediaUrl") String? mediaUrl,
    @JsonKey(name: "mediaSize") int? mediaSize,
    @JsonKey(name: "fileName") String? fileName,
    @JsonKey(name: "encryptionKey") String? encryptionKey,
    @JsonKey(name: "encryptionLevel") String? encryptionLevel,
    @JsonKey(name: "encryption") String? encryption,
    @JsonKey(name: "status") String? status,
    @JsonKey(name: "branchPtr") String? branchPtr,
    @JsonKey(name: "firmPtr") String? firmPtr,
    @JsonKey(name: "uploadedAt") String? uploadedAt,
  }) = _ChatMedias;

  factory ChatMedias.fromJson(Map<String, dynamic> json) =>
      _$ChatMediasFromJson(json);
}

@freezed
class Sender with _$Sender {
  const factory Sender({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "sentMessages") List<dynamic>? sentMessages,
  }) = _Sender;

  factory Sender.fromJson(Map<String, dynamic> json) => _$SenderFromJson(json);
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
    @JsonKey(name: "user") User? user,
  }) = _UserChat;

  factory UserChat.fromJson(Map<String, dynamic> json) =>
      _$UserChatFromJson(json);
}

@freezed
class User with _$User {
  const factory User({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "userChats") List<dynamic>? userChats,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
