// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatRequest _$ChatRequestFromJson(Map<String, dynamic> json) {
  return _ChatRequest.fromJson(json);
}

/// @nodoc
mixin _$ChatRequest {
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
  @JsonKey(name: "branchPtr")
  String? get branchPtr => throw _privateConstructorUsedError;
  @JsonKey(name: "firmPtr")
  String? get firmPtr => throw _privateConstructorUsedError;
  @JsonKey(name: "userChats")
  List<UserChat>? get userChats => throw _privateConstructorUsedError;

  /// Serializes this ChatRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatRequestCopyWith<ChatRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatRequestCopyWith<$Res> {
  factory $ChatRequestCopyWith(
    ChatRequest value,
    $Res Function(ChatRequest) then,
  ) = _$ChatRequestCopyWithImpl<$Res, ChatRequest>;
  @useResult
  $Res call({
    @JsonKey(name: "mode") String? mode,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "code") String? code,
    @JsonKey(name: "title") String? title,
    @JsonKey(name: "description") String? description,
    @JsonKey(name: "status") String? status,
    @JsonKey(name: "createdBy") int? createdBy,
    @JsonKey(name: "branchPtr") String? branchPtr,
    @JsonKey(name: "firmPtr") String? firmPtr,
    @JsonKey(name: "userChats") List<UserChat>? userChats,
  });
}

/// @nodoc
class _$ChatRequestCopyWithImpl<$Res, $Val extends ChatRequest>
    implements $ChatRequestCopyWith<$Res> {
  _$ChatRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = freezed,
    Object? type = freezed,
    Object? code = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? status = freezed,
    Object? createdBy = freezed,
    Object? branchPtr = freezed,
    Object? firmPtr = freezed,
    Object? userChats = freezed,
  }) {
    return _then(
      _value.copyWith(
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatRequestImplCopyWith<$Res>
    implements $ChatRequestCopyWith<$Res> {
  factory _$$ChatRequestImplCopyWith(
    _$ChatRequestImpl value,
    $Res Function(_$ChatRequestImpl) then,
  ) = __$$ChatRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "mode") String? mode,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "code") String? code,
    @JsonKey(name: "title") String? title,
    @JsonKey(name: "description") String? description,
    @JsonKey(name: "status") String? status,
    @JsonKey(name: "createdBy") int? createdBy,
    @JsonKey(name: "branchPtr") String? branchPtr,
    @JsonKey(name: "firmPtr") String? firmPtr,
    @JsonKey(name: "userChats") List<UserChat>? userChats,
  });
}

/// @nodoc
class __$$ChatRequestImplCopyWithImpl<$Res>
    extends _$ChatRequestCopyWithImpl<$Res, _$ChatRequestImpl>
    implements _$$ChatRequestImplCopyWith<$Res> {
  __$$ChatRequestImplCopyWithImpl(
    _$ChatRequestImpl _value,
    $Res Function(_$ChatRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = freezed,
    Object? type = freezed,
    Object? code = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? status = freezed,
    Object? createdBy = freezed,
    Object? branchPtr = freezed,
    Object? firmPtr = freezed,
    Object? userChats = freezed,
  }) {
    return _then(
      _$ChatRequestImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatRequestImpl implements _ChatRequest {
  const _$ChatRequestImpl({
    @JsonKey(name: "mode") this.mode,
    @JsonKey(name: "type") this.type,
    @JsonKey(name: "code") this.code,
    @JsonKey(name: "title") this.title,
    @JsonKey(name: "description") this.description,
    @JsonKey(name: "status") this.status,
    @JsonKey(name: "createdBy") this.createdBy,
    @JsonKey(name: "branchPtr") this.branchPtr,
    @JsonKey(name: "firmPtr") this.firmPtr,
    @JsonKey(name: "userChats") final List<UserChat>? userChats,
  }) : _userChats = userChats;

  factory _$ChatRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatRequestImplFromJson(json);

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
  String toString() {
    return 'ChatRequest(mode: $mode, type: $type, code: $code, title: $title, description: $description, status: $status, createdBy: $createdBy, branchPtr: $branchPtr, firmPtr: $firmPtr, userChats: $userChats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatRequestImpl &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.branchPtr, branchPtr) ||
                other.branchPtr == branchPtr) &&
            (identical(other.firmPtr, firmPtr) || other.firmPtr == firmPtr) &&
            const DeepCollectionEquality().equals(
              other._userChats,
              _userChats,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    mode,
    type,
    code,
    title,
    description,
    status,
    createdBy,
    branchPtr,
    firmPtr,
    const DeepCollectionEquality().hash(_userChats),
  );

  /// Create a copy of ChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatRequestImplCopyWith<_$ChatRequestImpl> get copyWith =>
      __$$ChatRequestImplCopyWithImpl<_$ChatRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatRequestImplToJson(this);
  }
}

abstract class _ChatRequest implements ChatRequest {
  const factory _ChatRequest({
    @JsonKey(name: "mode") final String? mode,
    @JsonKey(name: "type") final String? type,
    @JsonKey(name: "code") final String? code,
    @JsonKey(name: "title") final String? title,
    @JsonKey(name: "description") final String? description,
    @JsonKey(name: "status") final String? status,
    @JsonKey(name: "createdBy") final int? createdBy,
    @JsonKey(name: "branchPtr") final String? branchPtr,
    @JsonKey(name: "firmPtr") final String? firmPtr,
    @JsonKey(name: "userChats") final List<UserChat>? userChats,
  }) = _$ChatRequestImpl;

  factory _ChatRequest.fromJson(Map<String, dynamic> json) =
      _$ChatRequestImpl.fromJson;

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
  @JsonKey(name: "branchPtr")
  String? get branchPtr;
  @override
  @JsonKey(name: "firmPtr")
  String? get firmPtr;
  @override
  @JsonKey(name: "userChats")
  List<UserChat>? get userChats;

  /// Create a copy of ChatRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatRequestImplCopyWith<_$ChatRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserChat _$UserChatFromJson(Map<String, dynamic> json) {
  return _UserChat.fromJson(json);
}

/// @nodoc
mixin _$UserChat {
  @JsonKey(name: "userId")
  int? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: "type")
  String? get type => throw _privateConstructorUsedError;
  @JsonKey(name: "role")
  String? get role => throw _privateConstructorUsedError;

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
    @JsonKey(name: "userId") int? userId,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "role") String? role,
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
    Object? userId = freezed,
    Object? type = freezed,
    Object? role = freezed,
  }) {
    return _then(
      _value.copyWith(
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
    @JsonKey(name: "userId") int? userId,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "role") String? role,
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
    Object? userId = freezed,
    Object? type = freezed,
    Object? role = freezed,
  }) {
    return _then(
      _$UserChatImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserChatImpl implements _UserChat {
  const _$UserChatImpl({
    @JsonKey(name: "userId") this.userId,
    @JsonKey(name: "type") this.type,
    @JsonKey(name: "role") this.role,
  });

  factory _$UserChatImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserChatImplFromJson(json);

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
  String toString() {
    return 'UserChat(userId: $userId, type: $type, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserChatImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, type, role);

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
    @JsonKey(name: "userId") final int? userId,
    @JsonKey(name: "type") final String? type,
    @JsonKey(name: "role") final String? role,
  }) = _$UserChatImpl;

  factory _UserChat.fromJson(Map<String, dynamic> json) =
      _$UserChatImpl.fromJson;

  @override
  @JsonKey(name: "userId")
  int? get userId;
  @override
  @JsonKey(name: "type")
  String? get type;
  @override
  @JsonKey(name: "role")
  String? get role;

  /// Create a copy of UserChat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserChatImplCopyWith<_$UserChatImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
