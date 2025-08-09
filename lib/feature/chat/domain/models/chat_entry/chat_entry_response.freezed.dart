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
  @JsonKey(name: "userChats")
  List<UserChat>? get userChats => throw _privateConstructorUsedError;
  @JsonKey(name: "entries")
  List<Entry>? get entries => throw _privateConstructorUsedError;

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
    @JsonKey(name: "userChats") List<UserChat>? userChats,
    @JsonKey(name: "entries") List<Entry>? entries,
  });
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
  $Res call({Object? userChats = freezed, Object? entries = freezed}) {
    return _then(
      _value.copyWith(
            userChats: freezed == userChats
                ? _value.userChats
                : userChats // ignore: cast_nullable_to_non_nullable
                      as List<UserChat>?,
            entries: freezed == entries
                ? _value.entries
                : entries // ignore: cast_nullable_to_non_nullable
                      as List<Entry>?,
          )
          as $Val,
    );
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
    @JsonKey(name: "userChats") List<UserChat>? userChats,
    @JsonKey(name: "entries") List<Entry>? entries,
  });
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
  $Res call({Object? userChats = freezed, Object? entries = freezed}) {
    return _then(
      _$ChatEntryResponseImpl(
        userChats: freezed == userChats
            ? _value._userChats
            : userChats // ignore: cast_nullable_to_non_nullable
                  as List<UserChat>?,
        entries: freezed == entries
            ? _value._entries
            : entries // ignore: cast_nullable_to_non_nullable
                  as List<Entry>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatEntryResponseImpl implements _ChatEntryResponse {
  const _$ChatEntryResponseImpl({
    @JsonKey(name: "userChats") final List<UserChat>? userChats,
    @JsonKey(name: "entries") final List<Entry>? entries,
  }) : _userChats = userChats,
       _entries = entries;

  factory _$ChatEntryResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatEntryResponseImplFromJson(json);

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

  final List<Entry>? _entries;
  @override
  @JsonKey(name: "entries")
  List<Entry>? get entries {
    final value = _entries;
    if (value == null) return null;
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ChatEntryResponse(userChats: $userChats, entries: $entries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatEntryResponseImpl &&
            const DeepCollectionEquality().equals(
              other._userChats,
              _userChats,
            ) &&
            const DeepCollectionEquality().equals(other._entries, _entries));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_userChats),
    const DeepCollectionEquality().hash(_entries),
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
    @JsonKey(name: "userChats") final List<UserChat>? userChats,
    @JsonKey(name: "entries") final List<Entry>? entries,
  }) = _$ChatEntryResponseImpl;

  factory _ChatEntryResponse.fromJson(Map<String, dynamic> json) =
      _$ChatEntryResponseImpl.fromJson;

  @override
  @JsonKey(name: "userChats")
  List<UserChat>? get userChats;
  @override
  @JsonKey(name: "entries")
  List<Entry>? get entries;

  /// Create a copy of ChatEntryResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatEntryResponseImplCopyWith<_$ChatEntryResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Entry _$EntryFromJson(Map<String, dynamic> json) {
  return _Entry.fromJson(json);
}

/// @nodoc
mixin _$Entry {
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
  @JsonKey(name: "pinned")
  String? get pinned => throw _privateConstructorUsedError;
  @JsonKey(name: "sender")
  Sender? get sender => throw _privateConstructorUsedError;
  @JsonKey(name: "chatMedias")
  List<ChatMedias>? get chatMedias => throw _privateConstructorUsedError;
  @JsonKey(name: "userStatus")
  String? get userStatus => throw _privateConstructorUsedError;
  @JsonKey(name: "userChats")
  List<UserChat>? get userChats => throw _privateConstructorUsedError;

  /// Serializes this Entry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Entry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EntryCopyWith<Entry> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EntryCopyWith<$Res> {
  factory $EntryCopyWith(Entry value, $Res Function(Entry) then) =
      _$EntryCopyWithImpl<$Res, Entry>;
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
    @JsonKey(name: "pinned") String? pinned,
    @JsonKey(name: "sender") Sender? sender,
    @JsonKey(name: "chatMedias") List<ChatMedias>? chatMedias,
    @JsonKey(name: "userStatus") String? userStatus,
    @JsonKey(name: "userChats") List<UserChat>? userChats,
  });

  $SenderCopyWith<$Res>? get sender;
}

/// @nodoc
class _$EntryCopyWithImpl<$Res, $Val extends Entry>
    implements $EntryCopyWith<$Res> {
  _$EntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Entry
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
    Object? pinned = freezed,
    Object? sender = freezed,
    Object? chatMedias = freezed,
    Object? userStatus = freezed,
    Object? userChats = freezed,
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
            pinned: freezed == pinned
                ? _value.pinned
                : pinned // ignore: cast_nullable_to_non_nullable
                      as String?,
            sender: freezed == sender
                ? _value.sender
                : sender // ignore: cast_nullable_to_non_nullable
                      as Sender?,
            chatMedias: freezed == chatMedias
                ? _value.chatMedias
                : chatMedias // ignore: cast_nullable_to_non_nullable
                      as List<ChatMedias>?,
            userStatus: freezed == userStatus
                ? _value.userStatus
                : userStatus // ignore: cast_nullable_to_non_nullable
                      as String?,
            userChats: freezed == userChats
                ? _value.userChats
                : userChats // ignore: cast_nullable_to_non_nullable
                      as List<UserChat>?,
          )
          as $Val,
    );
  }

  /// Create a copy of Entry
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
abstract class _$$EntryImplCopyWith<$Res> implements $EntryCopyWith<$Res> {
  factory _$$EntryImplCopyWith(
    _$EntryImpl value,
    $Res Function(_$EntryImpl) then,
  ) = __$$EntryImplCopyWithImpl<$Res>;
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
    @JsonKey(name: "pinned") String? pinned,
    @JsonKey(name: "sender") Sender? sender,
    @JsonKey(name: "chatMedias") List<ChatMedias>? chatMedias,
    @JsonKey(name: "userStatus") String? userStatus,
    @JsonKey(name: "userChats") List<UserChat>? userChats,
  });

  @override
  $SenderCopyWith<$Res>? get sender;
}

/// @nodoc
class __$$EntryImplCopyWithImpl<$Res>
    extends _$EntryCopyWithImpl<$Res, _$EntryImpl>
    implements _$$EntryImplCopyWith<$Res> {
  __$$EntryImplCopyWithImpl(
    _$EntryImpl _value,
    $Res Function(_$EntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Entry
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
    Object? pinned = freezed,
    Object? sender = freezed,
    Object? chatMedias = freezed,
    Object? userStatus = freezed,
    Object? userChats = freezed,
  }) {
    return _then(
      _$EntryImpl(
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
        pinned: freezed == pinned
            ? _value.pinned
            : pinned // ignore: cast_nullable_to_non_nullable
                  as String?,
        sender: freezed == sender
            ? _value.sender
            : sender // ignore: cast_nullable_to_non_nullable
                  as Sender?,
        chatMedias: freezed == chatMedias
            ? _value._chatMedias
            : chatMedias // ignore: cast_nullable_to_non_nullable
                  as List<ChatMedias>?,
        userStatus: freezed == userStatus
            ? _value.userStatus
            : userStatus // ignore: cast_nullable_to_non_nullable
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
class _$EntryImpl implements _Entry {
  const _$EntryImpl({
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
    @JsonKey(name: "pinned") this.pinned,
    @JsonKey(name: "sender") this.sender,
    @JsonKey(name: "chatMedias") final List<ChatMedias>? chatMedias,
    @JsonKey(name: "userStatus") this.userStatus,
    @JsonKey(name: "userChats") final List<UserChat>? userChats,
  }) : _chatMedias = chatMedias,
       _userChats = userChats;

  factory _$EntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$EntryImplFromJson(json);

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
  @JsonKey(name: "pinned")
  final String? pinned;
  @override
  @JsonKey(name: "sender")
  final Sender? sender;
  final List<ChatMedias>? _chatMedias;
  @override
  @JsonKey(name: "chatMedias")
  List<ChatMedias>? get chatMedias {
    final value = _chatMedias;
    if (value == null) return null;
    if (_chatMedias is EqualUnmodifiableListView) return _chatMedias;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: "userStatus")
  final String? userStatus;
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
    return 'Entry(id: $id, type: $type, typeValue: $typeValue, chatId: $chatId, senderId: $senderId, messageType: $messageType, thread: $thread, content: $content, mediaIds: $mediaIds, createdAt: $createdAt, pinned: $pinned, sender: $sender, chatMedias: $chatMedias, userStatus: $userStatus, userChats: $userChats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EntryImpl &&
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
            (identical(other.pinned, pinned) || other.pinned == pinned) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            const DeepCollectionEquality().equals(
              other._chatMedias,
              _chatMedias,
            ) &&
            (identical(other.userStatus, userStatus) ||
                other.userStatus == userStatus) &&
            const DeepCollectionEquality().equals(
              other._userChats,
              _userChats,
            ));
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
    pinned,
    sender,
    const DeepCollectionEquality().hash(_chatMedias),
    userStatus,
    const DeepCollectionEquality().hash(_userChats),
  );

  /// Create a copy of Entry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EntryImplCopyWith<_$EntryImpl> get copyWith =>
      __$$EntryImplCopyWithImpl<_$EntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EntryImplToJson(this);
  }
}

abstract class _Entry implements Entry {
  const factory _Entry({
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
    @JsonKey(name: "pinned") final String? pinned,
    @JsonKey(name: "sender") final Sender? sender,
    @JsonKey(name: "chatMedias") final List<ChatMedias>? chatMedias,
    @JsonKey(name: "userStatus") final String? userStatus,
    @JsonKey(name: "userChats") final List<UserChat>? userChats,
  }) = _$EntryImpl;

  factory _Entry.fromJson(Map<String, dynamic> json) = _$EntryImpl.fromJson;

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
  @JsonKey(name: "pinned")
  String? get pinned;
  @override
  @JsonKey(name: "sender")
  Sender? get sender;
  @override
  @JsonKey(name: "chatMedias")
  List<ChatMedias>? get chatMedias;
  @override
  @JsonKey(name: "userStatus")
  String? get userStatus;
  @override
  @JsonKey(name: "userChats")
  List<UserChat>? get userChats;

  /// Create a copy of Entry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EntryImplCopyWith<_$EntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatMedias _$ChatMediasFromJson(Map<String, dynamic> json) {
  return _ChatMedias.fromJson(json);
}

/// @nodoc
mixin _$ChatMedias {
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

  /// Serializes this ChatMedias to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMedias
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMediasCopyWith<ChatMedias> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMediasCopyWith<$Res> {
  factory $ChatMediasCopyWith(
    ChatMedias value,
    $Res Function(ChatMedias) then,
  ) = _$ChatMediasCopyWithImpl<$Res, ChatMedias>;
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
class _$ChatMediasCopyWithImpl<$Res, $Val extends ChatMedias>
    implements $ChatMediasCopyWith<$Res> {
  _$ChatMediasCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMedias
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
abstract class _$$ChatMediasImplCopyWith<$Res>
    implements $ChatMediasCopyWith<$Res> {
  factory _$$ChatMediasImplCopyWith(
    _$ChatMediasImpl value,
    $Res Function(_$ChatMediasImpl) then,
  ) = __$$ChatMediasImplCopyWithImpl<$Res>;
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
class __$$ChatMediasImplCopyWithImpl<$Res>
    extends _$ChatMediasCopyWithImpl<$Res, _$ChatMediasImpl>
    implements _$$ChatMediasImplCopyWith<$Res> {
  __$$ChatMediasImplCopyWithImpl(
    _$ChatMediasImpl _value,
    $Res Function(_$ChatMediasImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMedias
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
      _$ChatMediasImpl(
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
class _$ChatMediasImpl implements _ChatMedias {
  const _$ChatMediasImpl({
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

  factory _$ChatMediasImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMediasImplFromJson(json);

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
    return 'ChatMedias(id: $id, chatId: $chatId, mediaType: $mediaType, mediaUrl: $mediaUrl, mediaSize: $mediaSize, fileName: $fileName, encryptionKey: $encryptionKey, encryptionLevel: $encryptionLevel, encryption: $encryption, status: $status, branchPtr: $branchPtr, firmPtr: $firmPtr, uploadedAt: $uploadedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMediasImpl &&
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

  /// Create a copy of ChatMedias
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMediasImplCopyWith<_$ChatMediasImpl> get copyWith =>
      __$$ChatMediasImplCopyWithImpl<_$ChatMediasImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMediasImplToJson(this);
  }
}

abstract class _ChatMedias implements ChatMedias {
  const factory _ChatMedias({
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
  }) = _$ChatMediasImpl;

  factory _ChatMedias.fromJson(Map<String, dynamic> json) =
      _$ChatMediasImpl.fromJson;

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

  /// Create a copy of ChatMedias
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMediasImplCopyWith<_$ChatMediasImpl> get copyWith =>
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
  @JsonKey(name: "user")
  User? get user => throw _privateConstructorUsedError;

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
    @JsonKey(name: "user") User? user,
  });

  $UserCopyWith<$Res>? get user;
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
    Object? user = freezed,
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
            user: freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as User?,
          )
          as $Val,
    );
  }

  /// Create a copy of UserChat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
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
    @JsonKey(name: "user") User? user,
  });

  @override
  $UserCopyWith<$Res>? get user;
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
    Object? user = freezed,
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
        user: freezed == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as User?,
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
    @JsonKey(name: "user") this.user,
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
  @JsonKey(name: "user")
  final User? user;

  @override
  String toString() {
    return 'UserChat(id: $id, chatId: $chatId, userId: $userId, type: $type, role: $role, lastSeenMsgId: $lastSeenMsgId, createdAt: $createdAt, user: $user)';
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
            (identical(other.user, user) || other.user == user));
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
    user,
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
    @JsonKey(name: "user") final User? user,
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
  @JsonKey(name: "user")
  User? get user;

  /// Create a copy of UserChat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserChatImplCopyWith<_$UserChatImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  @JsonKey(name: "id")
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "name")
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: "userChats")
  List<dynamic>? get userChats => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "userChats") List<dynamic>? userChats,
  });
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? userChats = freezed,
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
            userChats: freezed == userChats
                ? _value.userChats
                : userChats // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
    _$UserImpl value,
    $Res Function(_$UserImpl) then,
  ) = __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "userChats") List<dynamic>? userChats,
  });
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
    : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? userChats = freezed,
  }) {
    return _then(
      _$UserImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        userChats: freezed == userChats
            ? _value._userChats
            : userChats // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl({
    @JsonKey(name: "id") this.id,
    @JsonKey(name: "name") this.name,
    @JsonKey(name: "userChats") final List<dynamic>? userChats,
  }) : _userChats = userChats;

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  @JsonKey(name: "id")
  final int? id;
  @override
  @JsonKey(name: "name")
  final String? name;
  final List<dynamic>? _userChats;
  @override
  @JsonKey(name: "userChats")
  List<dynamic>? get userChats {
    final value = _userChats;
    if (value == null) return null;
    if (_userChats is EqualUnmodifiableListView) return _userChats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, userChats: $userChats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(
              other._userChats,
              _userChats,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    const DeepCollectionEquality().hash(_userChats),
  );

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(this);
  }
}

abstract class _User implements User {
  const factory _User({
    @JsonKey(name: "id") final int? id,
    @JsonKey(name: "name") final String? name,
    @JsonKey(name: "userChats") final List<dynamic>? userChats,
  }) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  @JsonKey(name: "id")
  int? get id;
  @override
  @JsonKey(name: "name")
  String? get name;
  @override
  @JsonKey(name: "userChats")
  List<dynamic>? get userChats;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
