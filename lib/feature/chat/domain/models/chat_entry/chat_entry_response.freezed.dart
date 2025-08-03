// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_entry_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatEntryResponse _$ChatEntryResponseFromJson(Map<String, dynamic> json) {
  return _ChatEntryResponse.fromJson(json);
}

/// @nodoc
mixin _$ChatEntryResponse {
  @JsonKey(name: "id")
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "type")
  String? get type => throw _privateConstructorUsedError;
  @JsonKey(name: "typeValue")
  int? get typeValue => throw _privateConstructorUsedError;
  @JsonKey(name: "chatId")
  int? get chatId => throw _privateConstructorUsedError;
  @JsonKey(name: "senderId")
  int? get senderId => throw _privateConstructorUsedError;
  @JsonKey(name: "messageType")
  String? get messageType => throw _privateConstructorUsedError;
  @JsonKey(name: "thread")
  String? get thread => throw _privateConstructorUsedError;
  @JsonKey(name: "content")
  String? get content => throw _privateConstructorUsedError;
  @JsonKey(name: "mediaIds")
  String? get mediaIds => throw _privateConstructorUsedError;
  @JsonKey(name: "createdAt")
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: "sender")
  Sender? get sender => throw _privateConstructorUsedError;
  @JsonKey(name: "chatMedias")
  List<ChatMedia>? get chatMedias => throw _privateConstructorUsedError;
  @JsonKey(name: "userStatus")
  String? get userStatus => throw _privateConstructorUsedError;

  /// Serializes this ChatEntryResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatEntryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatEntryResponseCopyWith<ChatEntryResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatEntryResponseCopyWith<$Res> {
  factory $ChatEntryResponseCopyWith(
    ChatEntryResponse value,
    $Res Function(ChatEntryResponse) then,
  ) = _$ChatEntryResponseCopyWithImpl<$Res, ChatEntryResponse>;
  @useResult
  $Res call({
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
    @JsonKey(name: "chatMedias") List<ChatMedia>? chatMedias,
    @JsonKey(name: "userStatus") String? userStatus,
  });

  $SenderCopyWith<$Res>? get sender;
}

/// @nodoc
class _$ChatEntryResponseCopyWithImpl<$Res, $Val extends ChatEntryResponse>
    implements $ChatEntryResponseCopyWith<$Res> {
  _$ChatEntryResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatEntryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? type = freezed,
    Object? typeValue = freezed,
    Object? chatId = freezed,
    Object? senderId = freezed,
    Object? messageType = freezed,
    Object? thread = freezed,
    Object? content = freezed,
    Object? mediaIds = freezed,
    Object? createdAt = freezed,
    Object? sender = freezed,
    Object? chatMedias = freezed,
    Object? userStatus = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String?,
            typeValue: freezed == typeValue
                ? _value.typeValue
                : typeValue // ignore: cast_nullable_to_non_nullable
                      as int?,
            chatId: freezed == chatId
                ? _value.chatId
                : chatId // ignore: cast_nullable_to_non_nullable
                      as int?,
            senderId: freezed == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                      as int?,
            messageType: freezed == messageType
                ? _value.messageType
                : messageType // ignore: cast_nullable_to_non_nullable
                      as String?,
            thread: freezed == thread
                ? _value.thread
                : thread // ignore: cast_nullable_to_non_nullable
                      as String?,
            content: freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String?,
            mediaIds: freezed == mediaIds
                ? _value.mediaIds
                : mediaIds // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            sender: freezed == sender
                ? _value.sender
                : sender // ignore: cast_nullable_to_non_nullable
                      as Sender?,
            chatMedias: freezed == chatMedias
                ? _value.chatMedias
                : chatMedias // ignore: cast_nullable_to_non_nullable
                      as List<ChatMedia>?,
            userStatus: freezed == userStatus
                ? _value.userStatus
                : userStatus // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of ChatEntryResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SenderCopyWith<$Res>? get sender {
    if (_value.sender == null) {
      return null;
    }

    return $SenderCopyWith<$Res>(_value.sender!, (value) {
      return _then(_value.copyWith(sender: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatEntryResponseImplCopyWith<$Res>
    implements $ChatEntryResponseCopyWith<$Res> {
  factory _$$ChatEntryResponseImplCopyWith(
    _$ChatEntryResponseImpl value,
    $Res Function(_$ChatEntryResponseImpl) then,
  ) = __$$ChatEntryResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
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
    @JsonKey(name: "chatMedias") List<ChatMedia>? chatMedias,
    @JsonKey(name: "userStatus") String? userStatus,
  });

  @override
  $SenderCopyWith<$Res>? get sender;
}

/// @nodoc
class __$$ChatEntryResponseImplCopyWithImpl<$Res>
    extends _$ChatEntryResponseCopyWithImpl<$Res, _$ChatEntryResponseImpl>
    implements _$$ChatEntryResponseImplCopyWith<$Res> {
  __$$ChatEntryResponseImplCopyWithImpl(
    _$ChatEntryResponseImpl _value,
    $Res Function(_$ChatEntryResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatEntryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? type = freezed,
    Object? typeValue = freezed,
    Object? chatId = freezed,
    Object? senderId = freezed,
    Object? messageType = freezed,
    Object? thread = freezed,
    Object? content = freezed,
    Object? mediaIds = freezed,
    Object? createdAt = freezed,
    Object? sender = freezed,
    Object? chatMedias = freezed,
    Object? userStatus = freezed,
  }) {
    return _then(
      _$ChatEntryResponseImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        typeValue: freezed == typeValue
            ? _value.typeValue
            : typeValue // ignore: cast_nullable_to_non_nullable
                  as int?,
        chatId: freezed == chatId
            ? _value.chatId
            : chatId // ignore: cast_nullable_to_non_nullable
                  as int?,
        senderId: freezed == senderId
            ? _value.senderId
            : senderId // ignore: cast_nullable_to_non_nullable
                  as int?,
        messageType: freezed == messageType
            ? _value.messageType
            : messageType // ignore: cast_nullable_to_non_nullable
                  as String?,
        thread: freezed == thread
            ? _value.thread
            : thread // ignore: cast_nullable_to_non_nullable
                  as String?,
        content: freezed == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String?,
        mediaIds: freezed == mediaIds
            ? _value.mediaIds
            : mediaIds // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        sender: freezed == sender
            ? _value.sender
            : sender // ignore: cast_nullable_to_non_nullable
                  as Sender?,
        chatMedias: freezed == chatMedias
            ? _value._chatMedias
            : chatMedias // ignore: cast_nullable_to_non_nullable
                  as List<ChatMedia>?,
        userStatus: freezed == userStatus
            ? _value.userStatus
            : userStatus // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatEntryResponseImpl implements _ChatEntryResponse {
  const _$ChatEntryResponseImpl({
    @JsonKey(name: "id") this.id,
    @JsonKey(name: "type") this.type,
    @JsonKey(name: "typeValue") this.typeValue,
    @JsonKey(name: "chatId") this.chatId,
    @JsonKey(name: "senderId") this.senderId,
    @JsonKey(name: "messageType") this.messageType,
    @JsonKey(name: "thread") this.thread,
    @JsonKey(name: "content") this.content,
    @JsonKey(name: "mediaIds") this.mediaIds,
    @JsonKey(name: "createdAt") this.createdAt,
    @JsonKey(name: "sender") this.sender,
    @JsonKey(name: "chatMedias") final List<ChatMedia>? chatMedias,
    @JsonKey(name: "userStatus") this.userStatus,
  }) : _chatMedias = chatMedias;

  factory _$ChatEntryResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatEntryResponseImplFromJson(json);

  @override
  @JsonKey(name: "id")
  final int? id;
  @override
  @JsonKey(name: "type")
  final String? type;
  @override
  @JsonKey(name: "typeValue")
  final int? typeValue;
  @override
  @JsonKey(name: "chatId")
  final int? chatId;
  @override
  @JsonKey(name: "senderId")
  final int? senderId;
  @override
  @JsonKey(name: "messageType")
  final String? messageType;
  @override
  @JsonKey(name: "thread")
  final String? thread;
  @override
  @JsonKey(name: "content")
  final String? content;
  @override
  @JsonKey(name: "mediaIds")
  final String? mediaIds;
  @override
  @JsonKey(name: "createdAt")
  final String? createdAt;
  @override
  @JsonKey(name: "sender")
  final Sender? sender;
  final List<ChatMedia>? _chatMedias;
  @override
  @JsonKey(name: "chatMedias")
  List<ChatMedia>? get chatMedias {
    final value = _chatMedias;
    if (value == null) return null;
    if (_chatMedias is EqualUnmodifiableListView) return _chatMedias;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: "userStatus")
  final String? userStatus;

  @override
  String toString() {
    return 'ChatEntryResponse(id: $id, type: $type, typeValue: $typeValue, chatId: $chatId, senderId: $senderId, messageType: $messageType, thread: $thread, content: $content, mediaIds: $mediaIds, createdAt: $createdAt, sender: $sender, chatMedias: $chatMedias, userStatus: $userStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatEntryResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.typeValue, typeValue) ||
                other.typeValue == typeValue) &&
            (identical(other.chatId, chatId) || other.chatId == chatId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.messageType, messageType) ||
                other.messageType == messageType) &&
            (identical(other.thread, thread) || other.thread == thread) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.mediaIds, mediaIds) ||
                other.mediaIds == mediaIds) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            const DeepCollectionEquality().equals(
              other._chatMedias,
              _chatMedias,
            ) &&
            (identical(other.userStatus, userStatus) ||
                other.userStatus == userStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    typeValue,
    chatId,
    senderId,
    messageType,
    thread,
    content,
    mediaIds,
    createdAt,
    sender,
    const DeepCollectionEquality().hash(_chatMedias),
    userStatus,
  );

  /// Create a copy of ChatEntryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatEntryResponseImplCopyWith<_$ChatEntryResponseImpl> get copyWith =>
      __$$ChatEntryResponseImplCopyWithImpl<_$ChatEntryResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatEntryResponseImplToJson(this);
  }
}

abstract class _ChatEntryResponse implements ChatEntryResponse {
  const factory _ChatEntryResponse({
    @JsonKey(name: "id") final int? id,
    @JsonKey(name: "type") final String? type,
    @JsonKey(name: "typeValue") final int? typeValue,
    @JsonKey(name: "chatId") final int? chatId,
    @JsonKey(name: "senderId") final int? senderId,
    @JsonKey(name: "messageType") final String? messageType,
    @JsonKey(name: "thread") final String? thread,
    @JsonKey(name: "content") final String? content,
    @JsonKey(name: "mediaIds") final String? mediaIds,
    @JsonKey(name: "createdAt") final String? createdAt,
    @JsonKey(name: "sender") final Sender? sender,
    @JsonKey(name: "chatMedias") final List<ChatMedia>? chatMedias,
    @JsonKey(name: "userStatus") final String? userStatus,
  }) = _$ChatEntryResponseImpl;

  factory _ChatEntryResponse.fromJson(Map<String, dynamic> json) =
      _$ChatEntryResponseImpl.fromJson;

  @override
  @JsonKey(name: "id")
  int? get id;
  @override
  @JsonKey(name: "type")
  String? get type;
  @override
  @JsonKey(name: "typeValue")
  int? get typeValue;
  @override
  @JsonKey(name: "chatId")
  int? get chatId;
  @override
  @JsonKey(name: "senderId")
  int? get senderId;
  @override
  @JsonKey(name: "messageType")
  String? get messageType;
  @override
  @JsonKey(name: "thread")
  String? get thread;
  @override
  @JsonKey(name: "content")
  String? get content;
  @override
  @JsonKey(name: "mediaIds")
  String? get mediaIds;
  @override
  @JsonKey(name: "createdAt")
  String? get createdAt;
  @override
  @JsonKey(name: "sender")
  Sender? get sender;
  @override
  @JsonKey(name: "chatMedias")
  List<ChatMedia>? get chatMedias;
  @override
  @JsonKey(name: "userStatus")
  String? get userStatus;

  /// Create a copy of ChatEntryResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatEntryResponseImplCopyWith<_$ChatEntryResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatMedia _$ChatMediaFromJson(Map<String, dynamic> json) {
  return _ChatMedia.fromJson(json);
}

/// @nodoc
mixin _$ChatMedia {
  @JsonKey(name: "id")
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "chatId")
  int? get chatId => throw _privateConstructorUsedError;
  @JsonKey(name: "mediaType")
  String? get mediaType => throw _privateConstructorUsedError;
  @JsonKey(name: "mediaUrl")
  String? get mediaUrl => throw _privateConstructorUsedError;
  @JsonKey(name: "mediaSize")
  int? get mediaSize => throw _privateConstructorUsedError;
  @JsonKey(name: "fileName")
  String? get fileName => throw _privateConstructorUsedError;
  @JsonKey(name: "encryptionKey")
  String? get encryptionKey => throw _privateConstructorUsedError;
  @JsonKey(name: "encryptionLevel")
  String? get encryptionLevel => throw _privateConstructorUsedError;
  @JsonKey(name: "encryption")
  String? get encryption => throw _privateConstructorUsedError;
  @JsonKey(name: "status")
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: "branchPtr")
  String? get branchPtr => throw _privateConstructorUsedError;
  @JsonKey(name: "firmPtr")
  String? get firmPtr => throw _privateConstructorUsedError;
  @JsonKey(name: "uploadedAt")
  String? get uploadedAt => throw _privateConstructorUsedError;

  /// Serializes this ChatMedia to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMedia
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMediaCopyWith<ChatMedia> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMediaCopyWith<$Res> {
  factory $ChatMediaCopyWith(ChatMedia value, $Res Function(ChatMedia) then) =
      _$ChatMediaCopyWithImpl<$Res, ChatMedia>;
  @useResult
  $Res call({
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
  });
}

/// @nodoc
class _$ChatMediaCopyWithImpl<$Res, $Val extends ChatMedia>
    implements $ChatMediaCopyWith<$Res> {
  _$ChatMediaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMedia
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? chatId = freezed,
    Object? mediaType = freezed,
    Object? mediaUrl = freezed,
    Object? mediaSize = freezed,
    Object? fileName = freezed,
    Object? encryptionKey = freezed,
    Object? encryptionLevel = freezed,
    Object? encryption = freezed,
    Object? status = freezed,
    Object? branchPtr = freezed,
    Object? firmPtr = freezed,
    Object? uploadedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            chatId: freezed == chatId
                ? _value.chatId
                : chatId // ignore: cast_nullable_to_non_nullable
                      as int?,
            mediaType: freezed == mediaType
                ? _value.mediaType
                : mediaType // ignore: cast_nullable_to_non_nullable
                      as String?,
            mediaUrl: freezed == mediaUrl
                ? _value.mediaUrl
                : mediaUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            mediaSize: freezed == mediaSize
                ? _value.mediaSize
                : mediaSize // ignore: cast_nullable_to_non_nullable
                      as int?,
            fileName: freezed == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String?,
            encryptionKey: freezed == encryptionKey
                ? _value.encryptionKey
                : encryptionKey // ignore: cast_nullable_to_non_nullable
                      as String?,
            encryptionLevel: freezed == encryptionLevel
                ? _value.encryptionLevel
                : encryptionLevel // ignore: cast_nullable_to_non_nullable
                      as String?,
            encryption: freezed == encryption
                ? _value.encryption
                : encryption // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            branchPtr: freezed == branchPtr
                ? _value.branchPtr
                : branchPtr // ignore: cast_nullable_to_non_nullable
                      as String?,
            firmPtr: freezed == firmPtr
                ? _value.firmPtr
                : firmPtr // ignore: cast_nullable_to_non_nullable
                      as String?,
            uploadedAt: freezed == uploadedAt
                ? _value.uploadedAt
                : uploadedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatMediaImplCopyWith<$Res>
    implements $ChatMediaCopyWith<$Res> {
  factory _$$ChatMediaImplCopyWith(
    _$ChatMediaImpl value,
    $Res Function(_$ChatMediaImpl) then,
  ) = __$$ChatMediaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
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
  });
}

/// @nodoc
class __$$ChatMediaImplCopyWithImpl<$Res>
    extends _$ChatMediaCopyWithImpl<$Res, _$ChatMediaImpl>
    implements _$$ChatMediaImplCopyWith<$Res> {
  __$$ChatMediaImplCopyWithImpl(
    _$ChatMediaImpl _value,
    $Res Function(_$ChatMediaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMedia
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? chatId = freezed,
    Object? mediaType = freezed,
    Object? mediaUrl = freezed,
    Object? mediaSize = freezed,
    Object? fileName = freezed,
    Object? encryptionKey = freezed,
    Object? encryptionLevel = freezed,
    Object? encryption = freezed,
    Object? status = freezed,
    Object? branchPtr = freezed,
    Object? firmPtr = freezed,
    Object? uploadedAt = freezed,
  }) {
    return _then(
      _$ChatMediaImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        chatId: freezed == chatId
            ? _value.chatId
            : chatId // ignore: cast_nullable_to_non_nullable
                  as int?,
        mediaType: freezed == mediaType
            ? _value.mediaType
            : mediaType // ignore: cast_nullable_to_non_nullable
                  as String?,
        mediaUrl: freezed == mediaUrl
            ? _value.mediaUrl
            : mediaUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        mediaSize: freezed == mediaSize
            ? _value.mediaSize
            : mediaSize // ignore: cast_nullable_to_non_nullable
                  as int?,
        fileName: freezed == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String?,
        encryptionKey: freezed == encryptionKey
            ? _value.encryptionKey
            : encryptionKey // ignore: cast_nullable_to_non_nullable
                  as String?,
        encryptionLevel: freezed == encryptionLevel
            ? _value.encryptionLevel
            : encryptionLevel // ignore: cast_nullable_to_non_nullable
                  as String?,
        encryption: freezed == encryption
            ? _value.encryption
            : encryption // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        branchPtr: freezed == branchPtr
            ? _value.branchPtr
            : branchPtr // ignore: cast_nullable_to_non_nullable
                  as String?,
        firmPtr: freezed == firmPtr
            ? _value.firmPtr
            : firmPtr // ignore: cast_nullable_to_non_nullable
                  as String?,
        uploadedAt: freezed == uploadedAt
            ? _value.uploadedAt
            : uploadedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMediaImpl implements _ChatMedia {
  const _$ChatMediaImpl({
    @JsonKey(name: "id") this.id,
    @JsonKey(name: "chatId") this.chatId,
    @JsonKey(name: "mediaType") this.mediaType,
    @JsonKey(name: "mediaUrl") this.mediaUrl,
    @JsonKey(name: "mediaSize") this.mediaSize,
    @JsonKey(name: "fileName") this.fileName,
    @JsonKey(name: "encryptionKey") this.encryptionKey,
    @JsonKey(name: "encryptionLevel") this.encryptionLevel,
    @JsonKey(name: "encryption") this.encryption,
    @JsonKey(name: "status") this.status,
    @JsonKey(name: "branchPtr") this.branchPtr,
    @JsonKey(name: "firmPtr") this.firmPtr,
    @JsonKey(name: "uploadedAt") this.uploadedAt,
  });

  factory _$ChatMediaImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMediaImplFromJson(json);

  @override
  @JsonKey(name: "id")
  final int? id;
  @override
  @JsonKey(name: "chatId")
  final int? chatId;
  @override
  @JsonKey(name: "mediaType")
  final String? mediaType;
  @override
  @JsonKey(name: "mediaUrl")
  final String? mediaUrl;
  @override
  @JsonKey(name: "mediaSize")
  final int? mediaSize;
  @override
  @JsonKey(name: "fileName")
  final String? fileName;
  @override
  @JsonKey(name: "encryptionKey")
  final String? encryptionKey;
  @override
  @JsonKey(name: "encryptionLevel")
  final String? encryptionLevel;
  @override
  @JsonKey(name: "encryption")
  final String? encryption;
  @override
  @JsonKey(name: "status")
  final String? status;
  @override
  @JsonKey(name: "branchPtr")
  final String? branchPtr;
  @override
  @JsonKey(name: "firmPtr")
  final String? firmPtr;
  @override
  @JsonKey(name: "uploadedAt")
  final String? uploadedAt;

  @override
  String toString() {
    return 'ChatMedia(id: $id, chatId: $chatId, mediaType: $mediaType, mediaUrl: $mediaUrl, mediaSize: $mediaSize, fileName: $fileName, encryptionKey: $encryptionKey, encryptionLevel: $encryptionLevel, encryption: $encryption, status: $status, branchPtr: $branchPtr, firmPtr: $firmPtr, uploadedAt: $uploadedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMediaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chatId, chatId) || other.chatId == chatId) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            (identical(other.mediaSize, mediaSize) ||
                other.mediaSize == mediaSize) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.encryptionKey, encryptionKey) ||
                other.encryptionKey == encryptionKey) &&
            (identical(other.encryptionLevel, encryptionLevel) ||
                other.encryptionLevel == encryptionLevel) &&
            (identical(other.encryption, encryption) ||
                other.encryption == encryption) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.branchPtr, branchPtr) ||
                other.branchPtr == branchPtr) &&
            (identical(other.firmPtr, firmPtr) || other.firmPtr == firmPtr) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    chatId,
    mediaType,
    mediaUrl,
    mediaSize,
    fileName,
    encryptionKey,
    encryptionLevel,
    encryption,
    status,
    branchPtr,
    firmPtr,
    uploadedAt,
  );

  /// Create a copy of ChatMedia
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMediaImplCopyWith<_$ChatMediaImpl> get copyWith =>
      __$$ChatMediaImplCopyWithImpl<_$ChatMediaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMediaImplToJson(this);
  }
}

abstract class _ChatMedia implements ChatMedia {
  const factory _ChatMedia({
    @JsonKey(name: "id") final int? id,
    @JsonKey(name: "chatId") final int? chatId,
    @JsonKey(name: "mediaType") final String? mediaType,
    @JsonKey(name: "mediaUrl") final String? mediaUrl,
    @JsonKey(name: "mediaSize") final int? mediaSize,
    @JsonKey(name: "fileName") final String? fileName,
    @JsonKey(name: "encryptionKey") final String? encryptionKey,
    @JsonKey(name: "encryptionLevel") final String? encryptionLevel,
    @JsonKey(name: "encryption") final String? encryption,
    @JsonKey(name: "status") final String? status,
    @JsonKey(name: "branchPtr") final String? branchPtr,
    @JsonKey(name: "firmPtr") final String? firmPtr,
    @JsonKey(name: "uploadedAt") final String? uploadedAt,
  }) = _$ChatMediaImpl;

  factory _ChatMedia.fromJson(Map<String, dynamic> json) =
      _$ChatMediaImpl.fromJson;

  @override
  @JsonKey(name: "id")
  int? get id;
  @override
  @JsonKey(name: "chatId")
  int? get chatId;
  @override
  @JsonKey(name: "mediaType")
  String? get mediaType;
  @override
  @JsonKey(name: "mediaUrl")
  String? get mediaUrl;
  @override
  @JsonKey(name: "mediaSize")
  int? get mediaSize;
  @override
  @JsonKey(name: "fileName")
  String? get fileName;
  @override
  @JsonKey(name: "encryptionKey")
  String? get encryptionKey;
  @override
  @JsonKey(name: "encryptionLevel")
  String? get encryptionLevel;
  @override
  @JsonKey(name: "encryption")
  String? get encryption;
  @override
  @JsonKey(name: "status")
  String? get status;
  @override
  @JsonKey(name: "branchPtr")
  String? get branchPtr;
  @override
  @JsonKey(name: "firmPtr")
  String? get firmPtr;
  @override
  @JsonKey(name: "uploadedAt")
  String? get uploadedAt;

  /// Create a copy of ChatMedia
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMediaImplCopyWith<_$ChatMediaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Sender _$SenderFromJson(Map<String, dynamic> json) {
  return _Sender.fromJson(json);
}

/// @nodoc
mixin _$Sender {
  @JsonKey(name: "id")
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "name")
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: "sentMessages")
  List<dynamic>? get sentMessages => throw _privateConstructorUsedError;

  /// Serializes this Sender to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Sender
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SenderCopyWith<Sender> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SenderCopyWith<$Res> {
  factory $SenderCopyWith(Sender value, $Res Function(Sender) then) =
      _$SenderCopyWithImpl<$Res, Sender>;
  @useResult
  $Res call({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "sentMessages") List<dynamic>? sentMessages,
  });
}

/// @nodoc
class _$SenderCopyWithImpl<$Res, $Val extends Sender>
    implements $SenderCopyWith<$Res> {
  _$SenderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Sender
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? sentMessages = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            sentMessages: freezed == sentMessages
                ? _value.sentMessages
                : sentMessages // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SenderImplCopyWith<$Res> implements $SenderCopyWith<$Res> {
  factory _$$SenderImplCopyWith(
    _$SenderImpl value,
    $Res Function(_$SenderImpl) then,
  ) = __$$SenderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "sentMessages") List<dynamic>? sentMessages,
  });
}

/// @nodoc
class __$$SenderImplCopyWithImpl<$Res>
    extends _$SenderCopyWithImpl<$Res, _$SenderImpl>
    implements _$$SenderImplCopyWith<$Res> {
  __$$SenderImplCopyWithImpl(
    _$SenderImpl _value,
    $Res Function(_$SenderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Sender
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? sentMessages = freezed,
  }) {
    return _then(
      _$SenderImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        sentMessages: freezed == sentMessages
            ? _value._sentMessages
            : sentMessages // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SenderImpl implements _Sender {
  const _$SenderImpl({
    @JsonKey(name: "id") this.id,
    @JsonKey(name: "name") this.name,
    @JsonKey(name: "sentMessages") final List<dynamic>? sentMessages,
  }) : _sentMessages = sentMessages;

  factory _$SenderImpl.fromJson(Map<String, dynamic> json) =>
      _$$SenderImplFromJson(json);

  @override
  @JsonKey(name: "id")
  final int? id;
  @override
  @JsonKey(name: "name")
  final String? name;
  final List<dynamic>? _sentMessages;
  @override
  @JsonKey(name: "sentMessages")
  List<dynamic>? get sentMessages {
    final value = _sentMessages;
    if (value == null) return null;
    if (_sentMessages is EqualUnmodifiableListView) return _sentMessages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Sender(id: $id, name: $name, sentMessages: $sentMessages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SenderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(
              other._sentMessages,
              _sentMessages,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    const DeepCollectionEquality().hash(_sentMessages),
  );

  /// Create a copy of Sender
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SenderImplCopyWith<_$SenderImpl> get copyWith =>
      __$$SenderImplCopyWithImpl<_$SenderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SenderImplToJson(this);
  }
}

abstract class _Sender implements Sender {
  const factory _Sender({
    @JsonKey(name: "id") final int? id,
    @JsonKey(name: "name") final String? name,
    @JsonKey(name: "sentMessages") final List<dynamic>? sentMessages,
  }) = _$SenderImpl;

  factory _Sender.fromJson(Map<String, dynamic> json) = _$SenderImpl.fromJson;

  @override
  @JsonKey(name: "id")
  int? get id;
  @override
  @JsonKey(name: "name")
  String? get name;
  @override
  @JsonKey(name: "sentMessages")
  List<dynamic>? get sentMessages;

  /// Create a copy of Sender
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SenderImplCopyWith<_$SenderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
