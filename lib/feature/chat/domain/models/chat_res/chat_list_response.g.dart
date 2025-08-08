// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatListResponseImpl _$$ChatListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ChatListResponseImpl(
  chatId: (json['chatId'] as num?)?.toInt(),
  mode: json['mode'] as String?,
  type: json['type'] as String?,
  code: json['code'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  status: json['status'] as String?,
  createdBy: (json['createdBy'] as num?)?.toInt(),
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  branchPtr: json['branchPtr'] as String?,
  firmPtr: json['firmPtr'] as String?,
  userChats: (json['userChats'] as List<dynamic>?)
      ?.map((e) => UserChat.fromJson(e as Map<String, dynamic>))
      .toList(),
  otherDetail1: json['otherDetail1'] as String?,
);

Map<String, dynamic> _$$ChatListResponseImplToJson(
  _$ChatListResponseImpl instance,
) => <String, dynamic>{
  'chatId': instance.chatId,
  'mode': instance.mode,
  'type': instance.type,
  'code': instance.code,
  'title': instance.title,
  'description': instance.description,
  'status': instance.status,
  'createdBy': instance.createdBy,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'branchPtr': instance.branchPtr,
  'firmPtr': instance.firmPtr,
  'userChats': instance.userChats,
  'otherDetail1': instance.otherDetail1,
};

_$UserChatImpl _$$UserChatImplFromJson(Map<String, dynamic> json) =>
    _$UserChatImpl(
      id: (json['id'] as num?)?.toInt(),
      chatId: (json['chatId'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      type: json['type'] as String?,
      role: json['role'] as String?,
      lastSeenMsgId: (json['lastSeenMsgId'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
      otherDetail1: json['otherDetail1'] as String?,
    );

Map<String, dynamic> _$$UserChatImplToJson(_$UserChatImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatId': instance.chatId,
      'userId': instance.userId,
      'type': instance.type,
      'role': instance.role,
      'lastSeenMsgId': instance.lastSeenMsgId,
      'createdAt': instance.createdAt,
      'otherDetail1': instance.otherDetail1,
    };
