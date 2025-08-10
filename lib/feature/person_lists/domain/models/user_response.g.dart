// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserResponseImpl _$$UserResponseImplFromJson(Map<String, dynamic> json) =>
    _$UserResponseImpl(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      otherDetails: json['otherDetails'] as String?,
      role: json['role'] as String?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$$UserResponseImplToJson(_$UserResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'otherDetails': instance.otherDetails,
      'role': instance.role,
      'type': instance.type,
    };
