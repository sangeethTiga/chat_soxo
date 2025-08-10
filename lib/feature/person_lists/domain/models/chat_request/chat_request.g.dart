// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatRequestImpl _$$ChatRequestImplFromJson(Map<String, dynamic> json) =>
    _$ChatRequestImpl(
      mode: json['mode'] as String?,
      type: json['type'] as String?,
      code: json['code'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String?,
      createdBy: (json['createdBy'] as num?)?.toInt(),
      branchPtr: json['branchPtr'] as String?,
      firmPtr: json['firmPtr'] as String?,
      userChats: (json['userChats'] as List<dynamic>?)
          ?.map((e) => UserChat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ChatRequestImplToJson(_$ChatRequestImpl instance) =>
    <String, dynamic>{
      'mode': instance.mode,
      'type': instance.type,
      'code': instance.code,
      'title': instance.title,
      'description': instance.description,
      'status': instance.status,
      'createdBy': instance.createdBy,
      'branchPtr': instance.branchPtr,
      'firmPtr': instance.firmPtr,
      'userChats': instance.userChats,
    };

_$UserChatImpl _$$UserChatImplFromJson(Map<String, dynamic> json) =>
    _$UserChatImpl(
      userId: (json['userId'] as num?)?.toInt(),
      type: json['type'] as String?,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$$UserChatImplToJson(_$UserChatImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'type': instance.type,
      'role': instance.role,
    };
