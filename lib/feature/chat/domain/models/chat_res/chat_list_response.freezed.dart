// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_list_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatListResponse _$ChatListResponseFromJson(Map<String, dynamic> json) {
  return _ChatListResponse.fromJson(json);
}

/// @nodoc
mixin _$ChatListResponse {
  @JsonKey(name: "chatId")
  int? get chatId => throw _privateConstructorUsedError;
  @JsonKey(name: "mode")
  String? get mode => throw _privateConstructorUsedError;
  @JsonKey(name: "type")
  String? get type => throw _privateConstructorUsedError;
  @JsonKey(name: "code")
  String? get code => throw _privateConstructorUsedError;
  @JsonKey(name: "title")
  String? get title => throw _privateConstructorUsedError;
  @JsonKey(name: "description")
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: "status")
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: "createdBy")
  int? get createdBy => throw _privateConstructorUsedError;
  @JsonKey(name: "createdAt")
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: "updatedAt")
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: "branchPtr")
  String? get branchPtr => throw _privateConstructorUsedError;
  @JsonKey(name: "firmPtr")
  String? get firmPtr => throw _privateConstructorUsedError;
  @JsonKey(name: "userChats")
  List<UserChat>? get userChats => throw _privateConstructorUsedError;
  @JsonKey(name: "otherDetail1")
  String? get otherDetail1 => throw _privateConstructorUsedError;

  /// Serializes this ChatListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatListResponseCopyWith<ChatListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatListResponseCopyWith<$Res> {
  factory $ChatListResponseCopyWith(
    ChatListResponse value,
    $Res Function(ChatListResponse) then,
  ) = _$ChatListResponseCopyWithImpl<$Res, ChatListResponse>;
  @useResult
  $Res call({
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
    @JsonKey(name: "otherDetail1") String? otherDetail1,
  });
}

/// @nodoc
class _$ChatListResponseCopyWithImpl<$Res, $Val extends ChatListResponse>
    implements $ChatListResponseCopyWith<$Res> {
  _$ChatListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chatId = freezed,
    Object? mode = freezed,
    Object? type = freezed,
    Object? code = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? status = freezed,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? branchPtr = freezed,
    Object? firmPtr = freezed,
    Object? userChats = freezed,
    Object? otherDetail1 = freezed,
  }) {
    return _then(
      _value.copyWith(
            chatId: freezed == chatId
                ? _value.chatId
                : chatId // ignore: cast_nullable_to_non_nullable
                      as int?,
            mode: freezed == mode
                ? _value.mode
                : mode // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String?,
            code: freezed == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdBy: freezed == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as int?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            branchPtr: freezed == branchPtr
                ? _value.branchPtr
                : branchPtr // ignore: cast_nullable_to_non_nullable
                      as String?,
            firmPtr: freezed == firmPtr
                ? _value.firmPtr
                : firmPtr // ignore: cast_nullable_to_non_nullable
                      as String?,
            userChats: freezed == userChats
                ? _value.userChats
                : userChats // ignore: cast_nullable_to_non_nullable
                      as List<UserChat>?,
            otherDetail1: freezed == otherDetail1
                ? _value.otherDetail1
                : otherDetail1 // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatListResponseImplCopyWith<$Res>
    implements $ChatListResponseCopyWith<$Res> {
  factory _$$ChatListResponseImplCopyWith(
    _$ChatListResponseImpl value,
    $Res Function(_$ChatListResponseImpl) then,
  ) = __$$ChatListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
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
    @JsonKey(name: "otherDetail1") String? otherDetail1,
  });
}

/// @nodoc
class __$$ChatListResponseImplCopyWithImpl<$Res>
    extends _$ChatListResponseCopyWithImpl<$Res, _$ChatListResponseImpl>
    implements _$$ChatListResponseImplCopyWith<$Res> {
  __$$ChatListResponseImplCopyWithImpl(
    _$ChatListResponseImpl _value,
    $Res Function(_$ChatListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chatId = freezed,
    Object? mode = freezed,
    Object? type = freezed,
    Object? code = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? status = freezed,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? branchPtr = freezed,
    Object? firmPtr = freezed,
    Object? userChats = freezed,
    Object? otherDetail1 = freezed,
  }) {
    return _then(
      _$ChatListResponseImpl(
        chatId: freezed == chatId
            ? _value.chatId
            : chatId // ignore: cast_nullable_to_non_nullable
                  as int?,
        mode: freezed == mode
            ? _value.mode
            : mode // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdBy: freezed == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        branchPtr: freezed == branchPtr
            ? _value.branchPtr
            : branchPtr // ignore: cast_nullable_to_non_nullable
                  as String?,
        firmPtr: freezed == firmPtr
            ? _value.firmPtr
            : firmPtr // ignore: cast_nullable_to_non_nullable
                  as String?,
        userChats: freezed == userChats
            ? _value._userChats
            : userChats // ignore: cast_nullable_to_non_nullable
                  as List<UserChat>?,
        otherDetail1: freezed == otherDetail1
            ? _value.otherDetail1
            : otherDetail1 // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatListResponseImpl implements _ChatListResponse {
  const _$ChatListResponseImpl({
    @JsonKey(name: "chatId") this.chatId,
    @JsonKey(name: "mode") this.mode,
    @JsonKey(name: "type") this.type,
    @JsonKey(name: "code") this.code,
    @JsonKey(name: "title") this.title,
    @JsonKey(name: "description") this.description,
    @JsonKey(name: "status") this.status,
    @JsonKey(name: "createdBy") this.createdBy,
    @JsonKey(name: "createdAt") this.createdAt,
    @JsonKey(name: "updatedAt") this.updatedAt,
    @JsonKey(name: "branchPtr") this.branchPtr,
    @JsonKey(name: "firmPtr") this.firmPtr,
    @JsonKey(name: "userChats") final List<UserChat>? userChats,
    @JsonKey(name: "otherDetail1") this.otherDetail1,
  }) : _userChats = userChats;

  factory _$ChatListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatListResponseImplFromJson(json);

  @override
  @JsonKey(name: "chatId")
  final int? chatId;
  @override
  @JsonKey(name: "mode")
  final String? mode;
  @override
  @JsonKey(name: "type")
  final String? type;
  @override
  @JsonKey(name: "code")
  final String? code;
  @override
  @JsonKey(name: "title")
  final String? title;
  @override
  @JsonKey(name: "description")
  final String? description;
  @override
  @JsonKey(name: "status")
  final String? status;
  @override
  @JsonKey(name: "createdBy")
  final int? createdBy;
  @override
  @JsonKey(name: "createdAt")
  final String? createdAt;
  @override
  @JsonKey(name: "updatedAt")
  final String? updatedAt;
  @override
  @JsonKey(name: "branchPtr")
  final String? branchPtr;
  @override
  @JsonKey(name: "firmPtr")
  final String? firmPtr;
  final List<UserChat>? _userChats;
  @override
  @JsonKey(name: "userChats")
  List<UserChat>? get userChats {
    final value = _userChats;
    if (value == null) return null;
    if (_userChats is EqualUnmodifiableListView) return _userChats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: "otherDetail1")
  final String? otherDetail1;

  @override
  String toString() {
    return 'ChatListResponse(chatId: $chatId, mode: $mode, type: $type, code: $code, title: $title, description: $description, status: $status, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, branchPtr: $branchPtr, firmPtr: $firmPtr, userChats: $userChats, otherDetail1: $otherDetail1)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatListResponseImpl &&
            (identical(other.chatId, chatId) || other.chatId == chatId) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.branchPtr, branchPtr) ||
                other.branchPtr == branchPtr) &&
            (identical(other.firmPtr, firmPtr) || other.firmPtr == firmPtr) &&
            const DeepCollectionEquality().equals(
              other._userChats,
              _userChats,
            ) &&
            (identical(other.otherDetail1, otherDetail1) ||
                other.otherDetail1 == otherDetail1));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    chatId,
    mode,
    type,
    code,
    title,
    description,
    status,
    createdBy,
    createdAt,
    updatedAt,
    branchPtr,
    firmPtr,
    const DeepCollectionEquality().hash(_userChats),
    otherDetail1,
  );

  /// Create a copy of ChatListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatListResponseImplCopyWith<_$ChatListResponseImpl> get copyWith =>
      __$$ChatListResponseImplCopyWithImpl<_$ChatListResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatListResponseImplToJson(this);
  }
}

abstract class _ChatListResponse implements ChatListResponse {
  const factory _ChatListResponse({
    @JsonKey(name: "chatId") final int? chatId,
    @JsonKey(name: "mode") final String? mode,
    @JsonKey(name: "type") final String? type,
    @JsonKey(name: "code") final String? code,
    @JsonKey(name: "title") final String? title,
    @JsonKey(name: "description") final String? description,
    @JsonKey(name: "status") final String? status,
    @JsonKey(name: "createdBy") final int? createdBy,
    @JsonKey(name: "createdAt") final String? createdAt,
    @JsonKey(name: "updatedAt") final String? updatedAt,
    @JsonKey(name: "branchPtr") final String? branchPtr,
    @JsonKey(name: "firmPtr") final String? firmPtr,
    @JsonKey(name: "userChats") final List<UserChat>? userChats,
    @JsonKey(name: "otherDetail1") final String? otherDetail1,
  }) = _$ChatListResponseImpl;

  factory _ChatListResponse.fromJson(Map<String, dynamic> json) =
      _$ChatListResponseImpl.fromJson;

  @override
  @JsonKey(name: "chatId")
  int? get chatId;
  @override
  @JsonKey(name: "mode")
  String? get mode;
  @override
  @JsonKey(name: "type")
  String? get type;
  @override
  @JsonKey(name: "code")
  String? get code;
  @override
  @JsonKey(name: "title")
  String? get title;
  @override
  @JsonKey(name: "description")
  String? get description;
  @override
  @JsonKey(name: "status")
  String? get status;
  @override
  @JsonKey(name: "createdBy")
  int? get createdBy;
  @override
  @JsonKey(name: "createdAt")
  String? get createdAt;
  @override
  @JsonKey(name: "updatedAt")
  String? get updatedAt;
  @override
  @JsonKey(name: "branchPtr")
  String? get branchPtr;
  @override
  @JsonKey(name: "firmPtr")
  String? get firmPtr;
  @override
  @JsonKey(name: "userChats")
  List<UserChat>? get userChats;
  @override
  @JsonKey(name: "otherDetail1")
  String? get otherDetail1;

  /// Create a copy of ChatListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatListResponseImplCopyWith<_$ChatListResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserChat _$UserChatFromJson(Map<String, dynamic> json) {
  return _UserChat.fromJson(json);
}

/// @nodoc
mixin _$UserChat {
  @JsonKey(name: "id")
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "chatId")
  int? get chatId => throw _privateConstructorUsedError;
  @JsonKey(name: "userId")
  int? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: "type")
  String? get type => throw _privateConstructorUsedError;
  @JsonKey(name: "role")
  String? get role => throw _privateConstructorUsedError;
  @JsonKey(name: "lastSeenMsgId")
  int? get lastSeenMsgId => throw _privateConstructorUsedError;
  @JsonKey(name: "createdAt")
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: "otherDetail1")
  String? get otherDetail1 => throw _privateConstructorUsedError;

  /// Serializes this UserChat to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserChat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserChatCopyWith<UserChat> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserChatCopyWith<$Res> {
  factory $UserChatCopyWith(UserChat value, $Res Function(UserChat) then) =
      _$UserChatCopyWithImpl<$Res, UserChat>;
  @useResult
  $Res call({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "chatId") int? chatId,
    @JsonKey(name: "userId") int? userId,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "role") String? role,
    @JsonKey(name: "lastSeenMsgId") int? lastSeenMsgId,
    @JsonKey(name: "createdAt") String? createdAt,
    @JsonKey(name: "otherDetail1") String? otherDetail1,
  });
}

/// @nodoc
class _$UserChatCopyWithImpl<$Res, $Val extends UserChat>
    implements $UserChatCopyWith<$Res> {
  _$UserChatCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserChat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? chatId = freezed,
    Object? userId = freezed,
    Object? type = freezed,
    Object? role = freezed,
    Object? lastSeenMsgId = freezed,
    Object? createdAt = freezed,
    Object? otherDetail1 = freezed,
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
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int?,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String?,
            role: freezed == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastSeenMsgId: freezed == lastSeenMsgId
                ? _value.lastSeenMsgId
                : lastSeenMsgId // ignore: cast_nullable_to_non_nullable
                      as int?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            otherDetail1: freezed == otherDetail1
                ? _value.otherDetail1
                : otherDetail1 // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserChatImplCopyWith<$Res>
    implements $UserChatCopyWith<$Res> {
  factory _$$UserChatImplCopyWith(
    _$UserChatImpl value,
    $Res Function(_$UserChatImpl) then,
  ) = __$$UserChatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "chatId") int? chatId,
    @JsonKey(name: "userId") int? userId,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "role") String? role,
    @JsonKey(name: "lastSeenMsgId") int? lastSeenMsgId,
    @JsonKey(name: "createdAt") String? createdAt,
    @JsonKey(name: "otherDetail1") String? otherDetail1,
  });
}

/// @nodoc
class __$$UserChatImplCopyWithImpl<$Res>
    extends _$UserChatCopyWithImpl<$Res, _$UserChatImpl>
    implements _$$UserChatImplCopyWith<$Res> {
  __$$UserChatImplCopyWithImpl(
    _$UserChatImpl _value,
    $Res Function(_$UserChatImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserChat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? chatId = freezed,
    Object? userId = freezed,
    Object? type = freezed,
    Object? role = freezed,
    Object? lastSeenMsgId = freezed,
    Object? createdAt = freezed,
    Object? otherDetail1 = freezed,
  }) {
    return _then(
      _$UserChatImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        chatId: freezed == chatId
            ? _value.chatId
            : chatId // ignore: cast_nullable_to_non_nullable
                  as int?,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int?,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        role: freezed == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastSeenMsgId: freezed == lastSeenMsgId
            ? _value.lastSeenMsgId
            : lastSeenMsgId // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        otherDetail1: freezed == otherDetail1
            ? _value.otherDetail1
            : otherDetail1 // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserChatImpl implements _UserChat {
  const _$UserChatImpl({
    @JsonKey(name: "id") this.id,
    @JsonKey(name: "chatId") this.chatId,
    @JsonKey(name: "userId") this.userId,
    @JsonKey(name: "type") this.type,
    @JsonKey(name: "role") this.role,
    @JsonKey(name: "lastSeenMsgId") this.lastSeenMsgId,
    @JsonKey(name: "createdAt") this.createdAt,
    @JsonKey(name: "otherDetail1") this.otherDetail1,
  });

  factory _$UserChatImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserChatImplFromJson(json);

  @override
  @JsonKey(name: "id")
  final int? id;
  @override
  @JsonKey(name: "chatId")
  final int? chatId;
  @override
  @JsonKey(name: "userId")
  final int? userId;
  @override
  @JsonKey(name: "type")
  final String? type;
  @override
  @JsonKey(name: "role")
  final String? role;
  @override
  @JsonKey(name: "lastSeenMsgId")
  final int? lastSeenMsgId;
  @override
  @JsonKey(name: "createdAt")
  final String? createdAt;
  @override
  @JsonKey(name: "otherDetail1")
  final String? otherDetail1;

  @override
  String toString() {
    return 'UserChat(id: $id, chatId: $chatId, userId: $userId, type: $type, role: $role, lastSeenMsgId: $lastSeenMsgId, createdAt: $createdAt, otherDetail1: $otherDetail1)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserChatImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chatId, chatId) || other.chatId == chatId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.lastSeenMsgId, lastSeenMsgId) ||
                other.lastSeenMsgId == lastSeenMsgId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.otherDetail1, otherDetail1) ||
                other.otherDetail1 == otherDetail1));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    chatId,
    userId,
    type,
    role,
    lastSeenMsgId,
    createdAt,
    otherDetail1,
  );

  /// Create a copy of UserChat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserChatImplCopyWith<_$UserChatImpl> get copyWith =>
      __$$UserChatImplCopyWithImpl<_$UserChatImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserChatImplToJson(this);
  }
}

abstract class _UserChat implements UserChat {
  const factory _UserChat({
    @JsonKey(name: "id") final int? id,
    @JsonKey(name: "chatId") final int? chatId,
    @JsonKey(name: "userId") final int? userId,
    @JsonKey(name: "type") final String? type,
    @JsonKey(name: "role") final String? role,
    @JsonKey(name: "lastSeenMsgId") final int? lastSeenMsgId,
    @JsonKey(name: "createdAt") final String? createdAt,
    @JsonKey(name: "otherDetail1") final String? otherDetail1,
  }) = _$UserChatImpl;

  factory _UserChat.fromJson(Map<String, dynamic> json) =
      _$UserChatImpl.fromJson;

  @override
  @JsonKey(name: "id")
  int? get id;
  @override
  @JsonKey(name: "chatId")
  int? get chatId;
  @override
  @JsonKey(name: "userId")
  int? get userId;
  @override
  @JsonKey(name: "type")
  String? get type;
  @override
  @JsonKey(name: "role")
  String? get role;
  @override
  @JsonKey(name: "lastSeenMsgId")
  int? get lastSeenMsgId;
  @override
  @JsonKey(name: "createdAt")
  String? get createdAt;
  @override
  @JsonKey(name: "otherDetail1")
  String? get otherDetail1;

  /// Create a copy of UserChat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserChatImplCopyWith<_$UserChatImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
