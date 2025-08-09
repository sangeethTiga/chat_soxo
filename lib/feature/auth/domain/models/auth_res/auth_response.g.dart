// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthResponseImpl _$$AuthResponseImplFromJson(Map<String, dynamic> json) =>
    _$AuthResponseImpl(
      result: json['result'] == null
          ? null
          : Result.fromJson(json['result'] as Map<String, dynamic>),
      id: (json['id'] as num?)?.toInt(),
      exception: json['exception'],
      status: (json['status'] as num?)?.toInt(),
      isCanceled: json['isCanceled'] as bool?,
      isCompleted: json['isCompleted'] as bool?,
      isCompletedSuccessfully: json['isCompletedSuccessfully'] as bool?,
      creationOptions: (json['creationOptions'] as num?)?.toInt(),
      asyncState: json['asyncState'],
      isFaulted: json['isFaulted'] as bool?,
    );

Map<String, dynamic> _$$AuthResponseImplToJson(_$AuthResponseImpl instance) =>
    <String, dynamic>{
      'result': instance.result,
      'id': instance.id,
      'exception': instance.exception,
      'status': instance.status,
      'isCanceled': instance.isCanceled,
      'isCompleted': instance.isCompleted,
      'isCompletedSuccessfully': instance.isCompletedSuccessfully,
      'creationOptions': instance.creationOptions,
      'asyncState': instance.asyncState,
      'isFaulted': instance.isFaulted,
    };

_$ResultImpl _$$ResultImplFromJson(Map<String, dynamic> json) => _$ResultImpl(
  userId: json['userId'] as String?,
  userName: json['userName'] as String?,
  mobile: json['mobile'],
  email: json['email'],
  twoFa: json['twoFa'],
  jwtToken: json['jwtToken'] as String?,
  branchName: json['branchName'] as String?,
  organisationDetails: json['organisationDetails'] as String?,
  databaseType: json['databaseType'] as String?,
  expiresIn: (json['expiresIn'] as num?)?.toInt(),
  menus: json['menus'],
  status: json['status'] as String?,
  userRole: json['userRole'],
  isAdmin: json['isAdmin'],
);

Map<String, dynamic> _$$ResultImplToJson(_$ResultImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'mobile': instance.mobile,
      'email': instance.email,
      'twoFa': instance.twoFa,
      'jwtToken': instance.jwtToken,
      'branchName': instance.branchName,
      'organisationDetails': instance.organisationDetails,
      'databaseType': instance.databaseType,
      'expiresIn': instance.expiresIn,
      'menus': instance.menus,
      'status': instance.status,
      'userRole': instance.userRole,
      'isAdmin': instance.isAdmin,
    };
