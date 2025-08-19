import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_chatentry_request.freezed.dart';
part 'add_chatentry_request.g.dart';

@freezed
class AddChatEntryRequest with _$AddChatEntryRequest {
  const factory AddChatEntryRequest({
    @JsonKey(name: "chatId") int? chatId,
    @JsonKey(name: "senderId") int? senderId,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "typeValue") int? typeValue,
    @JsonKey(name: "messageType") String? messageType,
    @JsonKey(name: "content") String? content,
    @JsonKey(name: "source") String? source,
    @JsonKey(name: "chatMedias") List<ChatMedia>? chatMedias,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<File>? attachedFiles,
    @JsonKey(name: "otherDetails1") String? otherDetails1,
  }) = _AddChatEntryRequest;

  factory AddChatEntryRequest.fromJson(Map<String, dynamic> json) =>
      _$AddChatEntryRequestFromJson(json);
}

@freezed
class ChatMedia with _$ChatMedia {
  const factory ChatMedia({
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
  }) = _ChatMedia;

  factory ChatMedia.fromJson(Map<String, dynamic> json) =>
      _$ChatMediaFromJson(json);
}
