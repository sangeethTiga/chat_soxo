// To parse this JSON data, do
//
//     final userResponse = userResponseFromJson(jsonString);

import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_response.freezed.dart';
part 'user_response.g.dart';

List<UserResponse> userResponseFromJson(String str) => List<UserResponse>.from(
  json.decode(str).map((x) => UserResponse.fromJson(x)),
);

String userResponseToJson(List<UserResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@freezed
class UserResponse with _$UserResponse {
  const factory UserResponse({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "otherDetails1") String? otherDetails,
    @JsonKey(name: "role") String? role,
    @JsonKey(name: "type") String? type,
    @JsonKey(name: "userId") int? userId,
  }) = _UserResponse;

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);
}
