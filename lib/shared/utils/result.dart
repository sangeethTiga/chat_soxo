class ResponseResult<T> {
  final T? data;
  final String? error;

  ResponseResult({this.data, this.error});

  bool get isSuccess => data != null;
}
