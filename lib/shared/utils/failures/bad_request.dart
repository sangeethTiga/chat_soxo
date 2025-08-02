import 'dart:convert';

class BadRequest {
  BadRequest({
    this.errorField,
    this.error,
  });

  String? errorField;
  List<String>? error;

  factory BadRequest.fromRawJson(String str) =>
      BadRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BadRequest.fromJson(Map<String, dynamic> json) => BadRequest(
        errorField: json['error_field'],
        error: List<String>.from(json['error'].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        'error_field': errorField,
        'error': List<dynamic>.from(error?.map((x) => x) ?? []),
      };
}
