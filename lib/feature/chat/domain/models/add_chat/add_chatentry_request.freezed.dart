// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_chatentry_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AddChatEntryRequest _$AddChatEntryRequestFromJson(Map<String, dynamic> json) {
  return _AddChatEntryRequest.fromJson(json);
}

/// @nodoc
mixin _$AddChatEntryRequest {
  @JsonKey(name: "chatId")
  int? get chatId => throw _privateConstructorUsedError;
  @JsonKey(name: "senderId")
  int? get senderId => throw _privateConstructorUsedError;
  @JsonKey(name: "type")
  String? get type => throw _privateConstructorUsedError;
  @JsonKey(name: "typeValue")
  int? get typeValue => throw _privateConstructorUsedError;
  @JsonKey(name: "messageType")
  String? get messageType => throw _privateConstructorUsedError;
  @JsonKey(name: "content")
  String? get content => throw _privateConstructorUsedError;
  @JsonKey(name: "source")
  String? get source => throw _privateConstructorUsedError;
  @JsonKey(name: "chatMedias")
  List<ChatMedia>? get chatMedias => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<File>? get attachedFiles => throw _privateConstructorUsedError;

  /// Serializes this AddChatEntryRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AddChatEntryRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AddChatEntryRequestCopyWith<AddChatEntryRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddChatEntryRequestCopyWith<$Res> {
  factory $AddChatEntryRequestCopyWith(
    AddChatEntryRequest value,
    $Res Function(AddChatEntryRequest) then,
  ) = _$AddChatEntryRequestCopyWithImpl<$Res, AddChatEntryRequest>;
  @useResult
  $Res call({
    @JsonKey(name: "chatId") int? chatId,
    @JsonKey(name: "senderId") int? senderId,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "typeValue") int? typeValue,
    @JsonKey(name: "messageType") String? messageType,
    @JsonKey(name: "content") String? content,
    @JsonKey(name: "source") String? source,
    @JsonKey(name: "chatMedias") List<ChatMedia>? chatMedias,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<File>? attachedFiles,
  });
}

/// @nodoc
class _$AddChatEntryRequestCopyWithImpl<$Res, $Val extends AddChatEntryRequest>
    implements $AddChatEntryRequestCopyWith<$Res> {
  _$AddChatEntryRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AddChatEntryRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chatId = freezed,
    Object? senderId = freezed,
    Object? type = freezed,
    Object? typeValue = freezed,
    Object? messageType = freezed,
    Object? content = freezed,
    Object? source = freezed,
    Object? chatMedias = freezed,
    Object? attachedFiles = freezed,
  }) {
    return _then(
      _value.copyWith(
            chatId: freezed == chatId
                ? _value.chatId
                : chatId // ignore: cast_nullable_to_non_nullable
                      as int?,
            senderId: freezed == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                      as int?,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String?,
            typeValue: freezed == typeValue
                ? _value.typeValue
                : typeValue // ignore: cast_nullable_to_non_nullable
                      as int?,
            messageType: freezed == messageType
                ? _value.messageType
                : messageType // ignore: cast_nullable_to_non_nullable
                      as String?,
            content: freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String?,
            source: freezed == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String?,
            chatMedias: freezed == chatMedias
                ? _value.chatMedias
                : chatMedias // ignore: cast_nullable_to_non_nullable
                      as List<ChatMedia>?,
            attachedFiles: freezed == attachedFiles
                ? _value.attachedFiles
                : attachedFiles // ignore: cast_nullable_to_non_nullable
                      as List<File>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AddChatEntryRequestImplCopyWith<$Res>
    implements $AddChatEntryRequestCopyWith<$Res> {
  factory _$$AddChatEntryRequestImplCopyWith(
    _$AddChatEntryRequestImpl value,
    $Res Function(_$AddChatEntryRequestImpl) then,
  ) = __$$AddChatEntryRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "chatId") int? chatId,
    @JsonKey(name: "senderId") int? senderId,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "typeValue") int? typeValue,
    @JsonKey(name: "messageType") String? messageType,
    @JsonKey(name: "content") String? content,
    @JsonKey(name: "source") String? source,
    @JsonKey(name: "chatMedias") List<ChatMedia>? chatMedias,
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<File>? attachedFiles,
  });
}

/// @nodoc
class __$$AddChatEntryRequestImplCopyWithImpl<$Res>
    extends _$AddChatEntryRequestCopyWithImpl<$Res, _$AddChatEntryRequestImpl>
    implements _$$AddChatEntryRequestImplCopyWith<$Res> {
  __$$AddChatEntryRequestImplCopyWithImpl(
    _$AddChatEntryRequestImpl _value,
    $Res Function(_$AddChatEntryRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AddChatEntryRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chatId = freezed,
    Object? senderId = freezed,
    Object? type = freezed,
    Object? typeValue = freezed,
    Object? messageType = freezed,
    Object? content = freezed,
    Object? source = freezed,
    Object? chatMedias = freezed,
    Object? attachedFiles = freezed,
  }) {
    return _then(
      _$AddChatEntryRequestImpl(
        chatId: freezed == chatId
            ? _value.chatId
            : chatId // ignore: cast_nullable_to_non_nullable
                  as int?,
        senderId: freezed == senderId
            ? _value.senderId
            : senderId // ignore: cast_nullable_to_non_nullable
                  as int?,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        typeValue: freezed == typeValue
            ? _value.typeValue
            : typeValue // ignore: cast_nullable_to_non_nullable
                  as int?,
        messageType: freezed == messageType
            ? _value.messageType
            : messageType // ignore: cast_nullable_to_non_nullable
                  as String?,
        content: freezed == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String?,
        source: freezed == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String?,
        chatMedias: freezed == chatMedias
            ? _value._chatMedias
            : chatMedias // ignore: cast_nullable_to_non_nullable
                  as List<ChatMedia>?,
        attachedFiles: freezed == attachedFiles
            ? _value._attachedFiles
            : attachedFiles // ignore: cast_nullable_to_non_nullable
                  as List<File>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AddChatEntryRequestImpl implements _AddChatEntryRequest {
  const _$AddChatEntryRequestImpl({
    @JsonKey(name: "chatId") this.chatId,
    @JsonKey(name: "senderId") this.senderId,
    @JsonKey(name: "type") this.type,
    @JsonKey(name: "typeValue") this.typeValue,
    @JsonKey(name: "messageType") this.messageType,
    @JsonKey(name: "content") this.content,
    @JsonKey(name: "source") this.source,
    @JsonKey(name: "chatMedias") final List<ChatMedia>? chatMedias,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final List<File>? attachedFiles,
  }) : _chatMedias = chatMedias,
       _attachedFiles = attachedFiles;

  factory _$AddChatEntryRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AddChatEntryRequestImplFromJson(json);

  @override
  @JsonKey(name: "chatId")
  final int? chatId;
  @override
  @JsonKey(name: "senderId")
  final int? senderId;
  @override
  @JsonKey(name: "type")
  final String? type;
  @override
  @JsonKey(name: "typeValue")
  final int? typeValue;
  @override
  @JsonKey(name: "messageType")
  final String? messageType;
  @override
  @JsonKey(name: "content")
  final String? content;
  @override
  @JsonKey(name: "source")
  final String? source;
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

  final List<File>? _attachedFiles;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<File>? get attachedFiles {
    final value = _attachedFiles;
    if (value == null) return null;
    if (_attachedFiles is EqualUnmodifiableListView) return _attachedFiles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'AddChatEntryRequest(chatId: $chatId, senderId: $senderId, type: $type, typeValue: $typeValue, messageType: $messageType, content: $content, source: $source, chatMedias: $chatMedias, attachedFiles: $attachedFiles)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddChatEntryRequestImpl &&
            (identical(other.chatId, chatId) || other.chatId == chatId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.typeValue, typeValue) ||
                other.typeValue == typeValue) &&
            (identical(other.messageType, messageType) ||
                other.messageType == messageType) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.source, source) || other.source == source) &&
            const DeepCollectionEquality().equals(
              other._chatMedias,
              _chatMedias,
            ) &&
            const DeepCollectionEquality().equals(
              other._attachedFiles,
              _attachedFiles,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    chatId,
    senderId,
    type,
    typeValue,
    messageType,
    content,
    source,
    const DeepCollectionEquality().hash(_chatMedias),
    const DeepCollectionEquality().hash(_attachedFiles),
  );

  /// Create a copy of AddChatEntryRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddChatEntryRequestImplCopyWith<_$AddChatEntryRequestImpl> get copyWith =>
      __$$AddChatEntryRequestImplCopyWithImpl<_$AddChatEntryRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AddChatEntryRequestImplToJson(this);
  }
}

abstract class _AddChatEntryRequest implements AddChatEntryRequest {
  const factory _AddChatEntryRequest({
    @JsonKey(name: "chatId") final int? chatId,
    @JsonKey(name: "senderId") final int? senderId,
    @JsonKey(name: "type") final String? type,
    @JsonKey(name: "typeValue") final int? typeValue,
    @JsonKey(name: "messageType") final String? messageType,
    @JsonKey(name: "content") final String? content,
    @JsonKey(name: "source") final String? source,
    @JsonKey(name: "chatMedias") final List<ChatMedia>? chatMedias,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final List<File>? attachedFiles,
  }) = _$AddChatEntryRequestImpl;

  factory _AddChatEntryRequest.fromJson(Map<String, dynamic> json) =
      _$AddChatEntryRequestImpl.fromJson;

  @override
  @JsonKey(name: "chatId")
  int? get chatId;
  @override
  @JsonKey(name: "senderId")
  int? get senderId;
  @override
  @JsonKey(name: "type")
  String? get type;
  @override
  @JsonKey(name: "typeValue")
  int? get typeValue;
  @override
  @JsonKey(name: "messageType")
  String? get messageType;
  @override
  @JsonKey(name: "content")
  String? get content;
  @override
  @JsonKey(name: "source")
  String? get source;
  @override
  @JsonKey(name: "chatMedias")
  List<ChatMedia>? get chatMedias;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<File>? get attachedFiles;

  /// Create a copy of AddChatEntryRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddChatEntryRequestImplCopyWith<_$AddChatEntryRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatMedia _$ChatMediaFromJson(Map<String, dynamic> json) {
  return _ChatMedia.fromJson(json);
}

/// @nodoc
mixin _$ChatMedia {
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
  }) {
    return _then(
      _value.copyWith(
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
  }) {
    return _then(
      _$ChatMediaImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMediaImpl implements _ChatMedia {
  const _$ChatMediaImpl({
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
  });

  factory _$ChatMediaImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMediaImplFromJson(json);

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
  String toString() {
    return 'ChatMedia(mediaType: $mediaType, mediaUrl: $mediaUrl, mediaSize: $mediaSize, fileName: $fileName, encryptionKey: $encryptionKey, encryptionLevel: $encryptionLevel, encryption: $encryption, status: $status, branchPtr: $branchPtr, firmPtr: $firmPtr)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMediaImpl &&
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
            (identical(other.firmPtr, firmPtr) || other.firmPtr == firmPtr));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
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
  }) = _$ChatMediaImpl;

  factory _ChatMedia.fromJson(Map<String, dynamic> json) =
      _$ChatMediaImpl.fromJson;

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

  /// Create a copy of ChatMedia
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMediaImplCopyWith<_$ChatMediaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
