// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) {
  return _AuthResponse.fromJson(json);
}

/// @nodoc
mixin _$AuthResponse {
  @JsonKey(name: "result")
  Result? get result => throw _privateConstructorUsedError;
  @JsonKey(name: "id")
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "exception")
  dynamic get exception => throw _privateConstructorUsedError;
  @JsonKey(name: "status")
  int? get status => throw _privateConstructorUsedError;
  @JsonKey(name: "isCanceled")
  bool? get isCanceled => throw _privateConstructorUsedError;
  @JsonKey(name: "isCompleted")
  bool? get isCompleted => throw _privateConstructorUsedError;
  @JsonKey(name: "isCompletedSuccessfully")
  bool? get isCompletedSuccessfully => throw _privateConstructorUsedError;
  @JsonKey(name: "creationOptions")
  int? get creationOptions => throw _privateConstructorUsedError;
  @JsonKey(name: "asyncState")
  dynamic get asyncState => throw _privateConstructorUsedError;
  @JsonKey(name: "isFaulted")
  bool? get isFaulted => throw _privateConstructorUsedError;

  /// Serializes this AuthResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthResponseCopyWith<AuthResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResponseCopyWith<$Res> {
  factory $AuthResponseCopyWith(
    AuthResponse value,
    $Res Function(AuthResponse) then,
  ) = _$AuthResponseCopyWithImpl<$Res, AuthResponse>;
  @useResult
  $Res call({
    @JsonKey(name: "result") Result? result,
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "exception") dynamic exception,
    @JsonKey(name: "status") int? status,
    @JsonKey(name: "isCanceled") bool? isCanceled,
    @JsonKey(name: "isCompleted") bool? isCompleted,
    @JsonKey(name: "isCompletedSuccessfully") bool? isCompletedSuccessfully,
    @JsonKey(name: "creationOptions") int? creationOptions,
    @JsonKey(name: "asyncState") dynamic asyncState,
    @JsonKey(name: "isFaulted") bool? isFaulted,
  });

  $ResultCopyWith<$Res>? get result;
}

/// @nodoc
class _$AuthResponseCopyWithImpl<$Res, $Val extends AuthResponse>
    implements $AuthResponseCopyWith<$Res> {
  _$AuthResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? result = freezed,
    Object? id = freezed,
    Object? exception = freezed,
    Object? status = freezed,
    Object? isCanceled = freezed,
    Object? isCompleted = freezed,
    Object? isCompletedSuccessfully = freezed,
    Object? creationOptions = freezed,
    Object? asyncState = freezed,
    Object? isFaulted = freezed,
  }) {
    return _then(
      _value.copyWith(
            result: freezed == result
                ? _value.result
                : result // ignore: cast_nullable_to_non_nullable
                      as Result?,
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            exception: freezed == exception
                ? _value.exception
                : exception // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as int?,
            isCanceled: freezed == isCanceled
                ? _value.isCanceled
                : isCanceled // ignore: cast_nullable_to_non_nullable
                      as bool?,
            isCompleted: freezed == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool?,
            isCompletedSuccessfully: freezed == isCompletedSuccessfully
                ? _value.isCompletedSuccessfully
                : isCompletedSuccessfully // ignore: cast_nullable_to_non_nullable
                      as bool?,
            creationOptions: freezed == creationOptions
                ? _value.creationOptions
                : creationOptions // ignore: cast_nullable_to_non_nullable
                      as int?,
            asyncState: freezed == asyncState
                ? _value.asyncState
                : asyncState // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            isFaulted: freezed == isFaulted
                ? _value.isFaulted
                : isFaulted // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ResultCopyWith<$Res>? get result {
    if (_value.result == null) {
      return null;
    }

    return $ResultCopyWith<$Res>(_value.result!, (value) {
      return _then(_value.copyWith(result: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthResponseImplCopyWith<$Res>
    implements $AuthResponseCopyWith<$Res> {
  factory _$$AuthResponseImplCopyWith(
    _$AuthResponseImpl value,
    $Res Function(_$AuthResponseImpl) then,
  ) = __$$AuthResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "result") Result? result,
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "exception") dynamic exception,
    @JsonKey(name: "status") int? status,
    @JsonKey(name: "isCanceled") bool? isCanceled,
    @JsonKey(name: "isCompleted") bool? isCompleted,
    @JsonKey(name: "isCompletedSuccessfully") bool? isCompletedSuccessfully,
    @JsonKey(name: "creationOptions") int? creationOptions,
    @JsonKey(name: "asyncState") dynamic asyncState,
    @JsonKey(name: "isFaulted") bool? isFaulted,
  });

  @override
  $ResultCopyWith<$Res>? get result;
}

/// @nodoc
class __$$AuthResponseImplCopyWithImpl<$Res>
    extends _$AuthResponseCopyWithImpl<$Res, _$AuthResponseImpl>
    implements _$$AuthResponseImplCopyWith<$Res> {
  __$$AuthResponseImplCopyWithImpl(
    _$AuthResponseImpl _value,
    $Res Function(_$AuthResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? result = freezed,
    Object? id = freezed,
    Object? exception = freezed,
    Object? status = freezed,
    Object? isCanceled = freezed,
    Object? isCompleted = freezed,
    Object? isCompletedSuccessfully = freezed,
    Object? creationOptions = freezed,
    Object? asyncState = freezed,
    Object? isFaulted = freezed,
  }) {
    return _then(
      _$AuthResponseImpl(
        result: freezed == result
            ? _value.result
            : result // ignore: cast_nullable_to_non_nullable
                  as Result?,
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        exception: freezed == exception
            ? _value.exception
            : exception // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as int?,
        isCanceled: freezed == isCanceled
            ? _value.isCanceled
            : isCanceled // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isCompleted: freezed == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isCompletedSuccessfully: freezed == isCompletedSuccessfully
            ? _value.isCompletedSuccessfully
            : isCompletedSuccessfully // ignore: cast_nullable_to_non_nullable
                  as bool?,
        creationOptions: freezed == creationOptions
            ? _value.creationOptions
            : creationOptions // ignore: cast_nullable_to_non_nullable
                  as int?,
        asyncState: freezed == asyncState
            ? _value.asyncState
            : asyncState // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        isFaulted: freezed == isFaulted
            ? _value.isFaulted
            : isFaulted // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthResponseImpl implements _AuthResponse {
  const _$AuthResponseImpl({
    @JsonKey(name: "result") this.result,
    @JsonKey(name: "id") this.id,
    @JsonKey(name: "exception") this.exception,
    @JsonKey(name: "status") this.status,
    @JsonKey(name: "isCanceled") this.isCanceled,
    @JsonKey(name: "isCompleted") this.isCompleted,
    @JsonKey(name: "isCompletedSuccessfully") this.isCompletedSuccessfully,
    @JsonKey(name: "creationOptions") this.creationOptions,
    @JsonKey(name: "asyncState") this.asyncState,
    @JsonKey(name: "isFaulted") this.isFaulted,
  });

  factory _$AuthResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthResponseImplFromJson(json);

  @override
  @JsonKey(name: "result")
  final Result? result;
  @override
  @JsonKey(name: "id")
  final int? id;
  @override
  @JsonKey(name: "exception")
  final dynamic exception;
  @override
  @JsonKey(name: "status")
  final int? status;
  @override
  @JsonKey(name: "isCanceled")
  final bool? isCanceled;
  @override
  @JsonKey(name: "isCompleted")
  final bool? isCompleted;
  @override
  @JsonKey(name: "isCompletedSuccessfully")
  final bool? isCompletedSuccessfully;
  @override
  @JsonKey(name: "creationOptions")
  final int? creationOptions;
  @override
  @JsonKey(name: "asyncState")
  final dynamic asyncState;
  @override
  @JsonKey(name: "isFaulted")
  final bool? isFaulted;

  @override
  String toString() {
    return 'AuthResponse(result: $result, id: $id, exception: $exception, status: $status, isCanceled: $isCanceled, isCompleted: $isCompleted, isCompletedSuccessfully: $isCompletedSuccessfully, creationOptions: $creationOptions, asyncState: $asyncState, isFaulted: $isFaulted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResponseImpl &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other.exception, exception) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isCanceled, isCanceled) ||
                other.isCanceled == isCanceled) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(
                  other.isCompletedSuccessfully,
                  isCompletedSuccessfully,
                ) ||
                other.isCompletedSuccessfully == isCompletedSuccessfully) &&
            (identical(other.creationOptions, creationOptions) ||
                other.creationOptions == creationOptions) &&
            const DeepCollectionEquality().equals(
              other.asyncState,
              asyncState,
            ) &&
            (identical(other.isFaulted, isFaulted) ||
                other.isFaulted == isFaulted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    result,
    id,
    const DeepCollectionEquality().hash(exception),
    status,
    isCanceled,
    isCompleted,
    isCompletedSuccessfully,
    creationOptions,
    const DeepCollectionEquality().hash(asyncState),
    isFaulted,
  );

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      __$$AuthResponseImplCopyWithImpl<_$AuthResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthResponseImplToJson(this);
  }
}

abstract class _AuthResponse implements AuthResponse {
  const factory _AuthResponse({
    @JsonKey(name: "result") final Result? result,
    @JsonKey(name: "id") final int? id,
    @JsonKey(name: "exception") final dynamic exception,
    @JsonKey(name: "status") final int? status,
    @JsonKey(name: "isCanceled") final bool? isCanceled,
    @JsonKey(name: "isCompleted") final bool? isCompleted,
    @JsonKey(name: "isCompletedSuccessfully")
    final bool? isCompletedSuccessfully,
    @JsonKey(name: "creationOptions") final int? creationOptions,
    @JsonKey(name: "asyncState") final dynamic asyncState,
    @JsonKey(name: "isFaulted") final bool? isFaulted,
  }) = _$AuthResponseImpl;

  factory _AuthResponse.fromJson(Map<String, dynamic> json) =
      _$AuthResponseImpl.fromJson;

  @override
  @JsonKey(name: "result")
  Result? get result;
  @override
  @JsonKey(name: "id")
  int? get id;
  @override
  @JsonKey(name: "exception")
  dynamic get exception;
  @override
  @JsonKey(name: "status")
  int? get status;
  @override
  @JsonKey(name: "isCanceled")
  bool? get isCanceled;
  @override
  @JsonKey(name: "isCompleted")
  bool? get isCompleted;
  @override
  @JsonKey(name: "isCompletedSuccessfully")
  bool? get isCompletedSuccessfully;
  @override
  @JsonKey(name: "creationOptions")
  int? get creationOptions;
  @override
  @JsonKey(name: "asyncState")
  dynamic get asyncState;
  @override
  @JsonKey(name: "isFaulted")
  bool? get isFaulted;

  /// Create a copy of AuthResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Result _$ResultFromJson(Map<String, dynamic> json) {
  return _Result.fromJson(json);
}

/// @nodoc
mixin _$Result {
  @JsonKey(name: "userId")
  int? get userId => throw _privateConstructorUsedError;
  @JsonKey(name: "userName")
  String? get userName => throw _privateConstructorUsedError;
  @JsonKey(name: "mobile")
  dynamic get mobile => throw _privateConstructorUsedError;
  @JsonKey(name: "email")
  dynamic get email => throw _privateConstructorUsedError;
  @JsonKey(name: "twoFa")
  dynamic get twoFa => throw _privateConstructorUsedError;
  @JsonKey(name: "jwtToken")
  String? get jwtToken => throw _privateConstructorUsedError;
  @JsonKey(name: "branchName")
  String? get branchName => throw _privateConstructorUsedError;
  @JsonKey(name: "organisationDetails")
  String? get organisationDetails => throw _privateConstructorUsedError;
  @JsonKey(name: "databaseType")
  String? get databaseType => throw _privateConstructorUsedError;
  @JsonKey(name: "expiresIn")
  int? get expiresIn => throw _privateConstructorUsedError;
  @JsonKey(name: "menus")
  dynamic get menus => throw _privateConstructorUsedError;
  @JsonKey(name: "status")
  String? get status => throw _privateConstructorUsedError;
  @JsonKey(name: "userRole")
  dynamic get userRole => throw _privateConstructorUsedError;
  @JsonKey(name: "isAdmin")
  dynamic get isAdmin => throw _privateConstructorUsedError;

  /// Serializes this Result to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResultCopyWith<Result> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultCopyWith<$Res> {
  factory $ResultCopyWith(Result value, $Res Function(Result) then) =
      _$ResultCopyWithImpl<$Res, Result>;
  @useResult
  $Res call({
    @JsonKey(name: "userId") int? userId,
    @JsonKey(name: "userName") String? userName,
    @JsonKey(name: "mobile") dynamic mobile,
    @JsonKey(name: "email") dynamic email,
    @JsonKey(name: "twoFa") dynamic twoFa,
    @JsonKey(name: "jwtToken") String? jwtToken,
    @JsonKey(name: "branchName") String? branchName,
    @JsonKey(name: "organisationDetails") String? organisationDetails,
    @JsonKey(name: "databaseType") String? databaseType,
    @JsonKey(name: "expiresIn") int? expiresIn,
    @JsonKey(name: "menus") dynamic menus,
    @JsonKey(name: "status") String? status,
    @JsonKey(name: "userRole") dynamic userRole,
    @JsonKey(name: "isAdmin") dynamic isAdmin,
  });
}

/// @nodoc
class _$ResultCopyWithImpl<$Res, $Val extends Result>
    implements $ResultCopyWith<$Res> {
  _$ResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? userName = freezed,
    Object? mobile = freezed,
    Object? email = freezed,
    Object? twoFa = freezed,
    Object? jwtToken = freezed,
    Object? branchName = freezed,
    Object? organisationDetails = freezed,
    Object? databaseType = freezed,
    Object? expiresIn = freezed,
    Object? menus = freezed,
    Object? status = freezed,
    Object? userRole = freezed,
    Object? isAdmin = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int?,
            userName: freezed == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String?,
            mobile: freezed == mobile
                ? _value.mobile
                : mobile // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            twoFa: freezed == twoFa
                ? _value.twoFa
                : twoFa // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            jwtToken: freezed == jwtToken
                ? _value.jwtToken
                : jwtToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            branchName: freezed == branchName
                ? _value.branchName
                : branchName // ignore: cast_nullable_to_non_nullable
                      as String?,
            organisationDetails: freezed == organisationDetails
                ? _value.organisationDetails
                : organisationDetails // ignore: cast_nullable_to_non_nullable
                      as String?,
            databaseType: freezed == databaseType
                ? _value.databaseType
                : databaseType // ignore: cast_nullable_to_non_nullable
                      as String?,
            expiresIn: freezed == expiresIn
                ? _value.expiresIn
                : expiresIn // ignore: cast_nullable_to_non_nullable
                      as int?,
            menus: freezed == menus
                ? _value.menus
                : menus // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            userRole: freezed == userRole
                ? _value.userRole
                : userRole // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            isAdmin: freezed == isAdmin
                ? _value.isAdmin
                : isAdmin // ignore: cast_nullable_to_non_nullable
                      as dynamic,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ResultImplCopyWith<$Res> implements $ResultCopyWith<$Res> {
  factory _$$ResultImplCopyWith(
    _$ResultImpl value,
    $Res Function(_$ResultImpl) then,
  ) = __$$ResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "userId") int? userId,
    @JsonKey(name: "userName") String? userName,
    @JsonKey(name: "mobile") dynamic mobile,
    @JsonKey(name: "email") dynamic email,
    @JsonKey(name: "twoFa") dynamic twoFa,
    @JsonKey(name: "jwtToken") String? jwtToken,
    @JsonKey(name: "branchName") String? branchName,
    @JsonKey(name: "organisationDetails") String? organisationDetails,
    @JsonKey(name: "databaseType") String? databaseType,
    @JsonKey(name: "expiresIn") int? expiresIn,
    @JsonKey(name: "menus") dynamic menus,
    @JsonKey(name: "status") String? status,
    @JsonKey(name: "userRole") dynamic userRole,
    @JsonKey(name: "isAdmin") dynamic isAdmin,
  });
}

/// @nodoc
class __$$ResultImplCopyWithImpl<$Res>
    extends _$ResultCopyWithImpl<$Res, _$ResultImpl>
    implements _$$ResultImplCopyWith<$Res> {
  __$$ResultImplCopyWithImpl(
    _$ResultImpl _value,
    $Res Function(_$ResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? userName = freezed,
    Object? mobile = freezed,
    Object? email = freezed,
    Object? twoFa = freezed,
    Object? jwtToken = freezed,
    Object? branchName = freezed,
    Object? organisationDetails = freezed,
    Object? databaseType = freezed,
    Object? expiresIn = freezed,
    Object? menus = freezed,
    Object? status = freezed,
    Object? userRole = freezed,
    Object? isAdmin = freezed,
  }) {
    return _then(
      _$ResultImpl(
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int?,
        userName: freezed == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String?,
        mobile: freezed == mobile
            ? _value.mobile
            : mobile // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        twoFa: freezed == twoFa
            ? _value.twoFa
            : twoFa // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        jwtToken: freezed == jwtToken
            ? _value.jwtToken
            : jwtToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        branchName: freezed == branchName
            ? _value.branchName
            : branchName // ignore: cast_nullable_to_non_nullable
                  as String?,
        organisationDetails: freezed == organisationDetails
            ? _value.organisationDetails
            : organisationDetails // ignore: cast_nullable_to_non_nullable
                  as String?,
        databaseType: freezed == databaseType
            ? _value.databaseType
            : databaseType // ignore: cast_nullable_to_non_nullable
                  as String?,
        expiresIn: freezed == expiresIn
            ? _value.expiresIn
            : expiresIn // ignore: cast_nullable_to_non_nullable
                  as int?,
        menus: freezed == menus
            ? _value.menus
            : menus // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        userRole: freezed == userRole
            ? _value.userRole
            : userRole // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        isAdmin: freezed == isAdmin
            ? _value.isAdmin
            : isAdmin // ignore: cast_nullable_to_non_nullable
                  as dynamic,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ResultImpl implements _Result {
  const _$ResultImpl({
    @JsonKey(name: "userId") this.userId,
    @JsonKey(name: "userName") this.userName,
    @JsonKey(name: "mobile") this.mobile,
    @JsonKey(name: "email") this.email,
    @JsonKey(name: "twoFa") this.twoFa,
    @JsonKey(name: "jwtToken") this.jwtToken,
    @JsonKey(name: "branchName") this.branchName,
    @JsonKey(name: "organisationDetails") this.organisationDetails,
    @JsonKey(name: "databaseType") this.databaseType,
    @JsonKey(name: "expiresIn") this.expiresIn,
    @JsonKey(name: "menus") this.menus,
    @JsonKey(name: "status") this.status,
    @JsonKey(name: "userRole") this.userRole,
    @JsonKey(name: "isAdmin") this.isAdmin,
  });

  factory _$ResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResultImplFromJson(json);

  @override
  @JsonKey(name: "userId")
  final int? userId;
  @override
  @JsonKey(name: "userName")
  final String? userName;
  @override
  @JsonKey(name: "mobile")
  final dynamic mobile;
  @override
  @JsonKey(name: "email")
  final dynamic email;
  @override
  @JsonKey(name: "twoFa")
  final dynamic twoFa;
  @override
  @JsonKey(name: "jwtToken")
  final String? jwtToken;
  @override
  @JsonKey(name: "branchName")
  final String? branchName;
  @override
  @JsonKey(name: "organisationDetails")
  final String? organisationDetails;
  @override
  @JsonKey(name: "databaseType")
  final String? databaseType;
  @override
  @JsonKey(name: "expiresIn")
  final int? expiresIn;
  @override
  @JsonKey(name: "menus")
  final dynamic menus;
  @override
  @JsonKey(name: "status")
  final String? status;
  @override
  @JsonKey(name: "userRole")
  final dynamic userRole;
  @override
  @JsonKey(name: "isAdmin")
  final dynamic isAdmin;

  @override
  String toString() {
    return 'Result(userId: $userId, userName: $userName, mobile: $mobile, email: $email, twoFa: $twoFa, jwtToken: $jwtToken, branchName: $branchName, organisationDetails: $organisationDetails, databaseType: $databaseType, expiresIn: $expiresIn, menus: $menus, status: $status, userRole: $userRole, isAdmin: $isAdmin)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResultImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            const DeepCollectionEquality().equals(other.mobile, mobile) &&
            const DeepCollectionEquality().equals(other.email, email) &&
            const DeepCollectionEquality().equals(other.twoFa, twoFa) &&
            (identical(other.jwtToken, jwtToken) ||
                other.jwtToken == jwtToken) &&
            (identical(other.branchName, branchName) ||
                other.branchName == branchName) &&
            (identical(other.organisationDetails, organisationDetails) ||
                other.organisationDetails == organisationDetails) &&
            (identical(other.databaseType, databaseType) ||
                other.databaseType == databaseType) &&
            (identical(other.expiresIn, expiresIn) ||
                other.expiresIn == expiresIn) &&
            const DeepCollectionEquality().equals(other.menus, menus) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other.userRole, userRole) &&
            const DeepCollectionEquality().equals(other.isAdmin, isAdmin));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    userName,
    const DeepCollectionEquality().hash(mobile),
    const DeepCollectionEquality().hash(email),
    const DeepCollectionEquality().hash(twoFa),
    jwtToken,
    branchName,
    organisationDetails,
    databaseType,
    expiresIn,
    const DeepCollectionEquality().hash(menus),
    status,
    const DeepCollectionEquality().hash(userRole),
    const DeepCollectionEquality().hash(isAdmin),
  );

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResultImplCopyWith<_$ResultImpl> get copyWith =>
      __$$ResultImplCopyWithImpl<_$ResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResultImplToJson(this);
  }
}

abstract class _Result implements Result {
  const factory _Result({
    @JsonKey(name: "userId") final int? userId,
    @JsonKey(name: "userName") final String? userName,
    @JsonKey(name: "mobile") final dynamic mobile,
    @JsonKey(name: "email") final dynamic email,
    @JsonKey(name: "twoFa") final dynamic twoFa,
    @JsonKey(name: "jwtToken") final String? jwtToken,
    @JsonKey(name: "branchName") final String? branchName,
    @JsonKey(name: "organisationDetails") final String? organisationDetails,
    @JsonKey(name: "databaseType") final String? databaseType,
    @JsonKey(name: "expiresIn") final int? expiresIn,
    @JsonKey(name: "menus") final dynamic menus,
    @JsonKey(name: "status") final String? status,
    @JsonKey(name: "userRole") final dynamic userRole,
    @JsonKey(name: "isAdmin") final dynamic isAdmin,
  }) = _$ResultImpl;

  factory _Result.fromJson(Map<String, dynamic> json) = _$ResultImpl.fromJson;

  @override
  @JsonKey(name: "userId")
  int? get userId;
  @override
  @JsonKey(name: "userName")
  String? get userName;
  @override
  @JsonKey(name: "mobile")
  dynamic get mobile;
  @override
  @JsonKey(name: "email")
  dynamic get email;
  @override
  @JsonKey(name: "twoFa")
  dynamic get twoFa;
  @override
  @JsonKey(name: "jwtToken")
  String? get jwtToken;
  @override
  @JsonKey(name: "branchName")
  String? get branchName;
  @override
  @JsonKey(name: "organisationDetails")
  String? get organisationDetails;
  @override
  @JsonKey(name: "databaseType")
  String? get databaseType;
  @override
  @JsonKey(name: "expiresIn")
  int? get expiresIn;
  @override
  @JsonKey(name: "menus")
  dynamic get menus;
  @override
  @JsonKey(name: "status")
  String? get status;
  @override
  @JsonKey(name: "userRole")
  dynamic get userRole;
  @override
  @JsonKey(name: "isAdmin")
  dynamic get isAdmin;

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResultImplCopyWith<_$ResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
