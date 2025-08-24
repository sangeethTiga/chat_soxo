// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_entry_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatEntryResponseImpl _$$ChatEntryResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ChatEntryResponseImpl(
  userChats: (json['userChats'] as List<dynamic>?)
      ?.map((e) => UserChat.fromJson(e as Map<String, dynamic>))
      .toList(),
  entries: (json['entries'] as List<dynamic>?)
      ?.map((e) => Entry.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$ChatEntryResponseImplToJson(
  _$ChatEntryResponseImpl instance,
) => <String, dynamic>{
  'userChats': instance.userChats,
  'entries': instance.entries,
};

_$EntryImpl _$$EntryImplFromJson(Map<String, dynamic> json) => _$EntryImpl(
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
  pinned: json['pinned'] as String?,
  userStatus: json['userStatus'] as String?,
  direction: json['direction'] as String?,
  otherDetails1: json['otherDetails1'] as String?,
  sender: json['sender'] == null
      ? null
      : Sender.fromJson(json['sender'] as Map<String, dynamic>),
  chatMedias: (json['chatMedias'] as List<dynamic>?)
      ?.map((e) => ChatMedias.fromJson(e as Map<String, dynamic>))
      .toList(),
  userChats: (json['userChats'] as List<dynamic>?)
      ?.map((e) => UserChat.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$EntryImplToJson(_$EntryImpl instance) =>
    <String, dynamic>{
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
      'pinned': instance.pinned,
      'userStatus': instance.userStatus,
      'direction': instance.direction,
      'otherDetails1': instance.otherDetails1,
      'sender': instance.sender,
      'chatMedias': instance.chatMedias,
      'userChats': instance.userChats,
    };

_$ChatMediasImpl _$$ChatMediasImplFromJson(Map<String, dynamic> json) =>
    _$ChatMediasImpl(
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

Map<String, dynamic> _$$ChatMediasImplToJson(_$ChatMediasImpl instance) =>
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
  imageUrl: json['otherDetails'] as String?,
  sentMessages: json['sentMessages'] as List<dynamic>?,
);

Map<String, dynamic> _$$SenderImplToJson(_$SenderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'otherDetails': instance.imageUrl,
      'sentMessages': instance.sentMessages,
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
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
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
      'user': instance.user,
    };

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  userChats: json['userChats'] as List<dynamic>?,
  otherDetails1: json['otherDetails1'] as String?,
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'userChats': instance.userChats,
      'otherDetails1': instance.otherDetails1,
    };
