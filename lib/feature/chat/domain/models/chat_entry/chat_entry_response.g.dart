// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_entry_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatEntryResponseImpl _$$ChatEntryResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ChatEntryResponseImpl(
  id: (json['id'] as num?)?.toInt(),
  type: json['type'] as String?,
  typeValue: (json['typeValue'] as num?)?.toInt(),
  chatId: (json['chatId'] as num?)?.toInt(),
  senderId: (json['senderId'] as num?)?.toInt(),
  messageType: json['messageType'] as String?,
  thread: json['thread'] as String?,
  content: json['content'] as String?,
  mediaIds: json['mediaIds'] as String?,
  createdAt: json['createdAt'] as String?,
  sender: json['sender'] == null
      ? null
      : Sender.fromJson(json['sender'] as Map<String, dynamic>),
  chatMedias: (json['chatMedias'] as List<dynamic>?)
      ?.map((e) => ChatMedia.fromJson(e as Map<String, dynamic>))
      .toList(),
  userStatus: json['userStatus'] as String?,
);

Map<String, dynamic> _$$ChatEntryResponseImplToJson(
  _$ChatEntryResponseImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'typeValue': instance.typeValue,
  'chatId': instance.chatId,
  'senderId': instance.senderId,
  'messageType': instance.messageType,
  'thread': instance.thread,
  'content': instance.content,
  'mediaIds': instance.mediaIds,
  'createdAt': instance.createdAt,
  'sender': instance.sender,
  'chatMedias': instance.chatMedias,
  'userStatus': instance.userStatus,
};

_$ChatMediaImpl _$$ChatMediaImplFromJson(Map<String, dynamic> json) =>
    _$ChatMediaImpl(
      id: (json['id'] as num?)?.toInt(),
      chatId: (json['chatId'] as num?)?.toInt(),
      mediaType: json['mediaType'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      mediaSize: (json['mediaSize'] as num?)?.toInt(),
      fileName: json['fileName'] as String?,
      encryptionKey: json['encryptionKey'] as String?,
      encryptionLevel: json['encryptionLevel'] as String?,
      encryption: json['encryption'] as String?,
      status: json['status'] as String?,
      branchPtr: json['branchPtr'] as String?,
      firmPtr: json['firmPtr'] as String?,
      uploadedAt: json['uploadedAt'] as String?,
    );

Map<String, dynamic> _$$ChatMediaImplToJson(_$ChatMediaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatId': instance.chatId,
      'mediaType': instance.mediaType,
      'mediaUrl': instance.mediaUrl,
      'mediaSize': instance.mediaSize,
      'fileName': instance.fileName,
      'encryptionKey': instance.encryptionKey,
      'encryptionLevel': instance.encryptionLevel,
      'encryption': instance.encryption,
      'status': instance.status,
      'branchPtr': instance.branchPtr,
      'firmPtr': instance.firmPtr,
      'uploadedAt': instance.uploadedAt,
    };

_$SenderImpl _$$SenderImplFromJson(Map<String, dynamic> json) => _$SenderImpl(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  sentMessages: json['sentMessages'] as List<dynamic>?,
);

Map<String, dynamic> _$$SenderImplToJson(_$SenderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sentMessages': instance.sentMessages,
    };
