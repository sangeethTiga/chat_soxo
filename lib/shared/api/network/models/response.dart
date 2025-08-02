class ResponseData {
  final int? statusCode;
  final bool? success;
  final String? message;

  ResponseData({
    this.statusCode,
    this.success = false,
    this.message,
  });
}
