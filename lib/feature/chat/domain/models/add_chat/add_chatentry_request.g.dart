// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_chatentry_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AddChatEntryRequestImpl _$$AddChatEntryRequestImplFromJson(
  Map<String, dynamic> json,
) => _$AddChatEntryRequestImpl(
  chatId: (json['chatId'] as num?)?.toInt(),
  senderId: (json['senderId'] as num?)?.toInt(),
  type: json['type'] as String?,
  pinned: json['pinned'] as String?,
  typeValue: (json['typeValue'] as num?)?.toInt(),
  messageType: json['messageType'] as String?,
  content: json['content'] as String?,
  source: json['source'] as String?,
  chatMedias: (json['chatMedias'] as List<dynamic>?)
      ?.map((e) => ChatMedia.fromJson(e as Map<String, dynamic>))
      .toList(),
  otherDetails1: json['otherDetails1'] as String?,
);

Map<String, dynamic> _$$AddChatEntryRequestImplToJson(
  _$AddChatEntryRequestImpl instance,
) => <String, dynamic>{
  'chatId': instance.chatId,
  'senderId': instance.senderId,
  'type': instance.type,
  'pinned': instance.pinned,
  'typeValue': instance.typeValue,
  'messageType': instance.messageType,
  'content': instance.content,
  'source': instance.source,
  'chatMedias': instance.chatMedias,
  'otherDetails1': instance.otherDetails1,
};

_$ChatMediaImpl _$$ChatMediaImplFromJson(Map<String, dynamic> json) =>
    _$ChatMediaImpl(
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
    );

Map<String, dynamic> _$$ChatMediaImplToJson(_$ChatMediaImpl instance) =>
    <String, dynamic>{
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
    };
