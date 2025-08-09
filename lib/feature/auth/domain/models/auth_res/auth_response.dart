// To parse this JSON data, do
//
//     final authResponse = authResponseFromJson(jsonString);

import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

AuthResponse authResponseFromJson(String str) =>
    AuthResponse.fromJson(json.decode(str));

String authResponseToJson(AuthResponse data) => json.encode(data.toJson());

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
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
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

@freezed
class Result with _$Result {
  const factory Result({
    @JsonKey(name: "userId") String? userId,
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
  }) = _Result;

  factory Result.fromJson(Map<String, dynamic> json) => _$ResultFromJson(json);
}
