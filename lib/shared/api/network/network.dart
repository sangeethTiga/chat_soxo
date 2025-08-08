import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:soxo_chat/shared/app/extension/helper.dart';
import 'package:soxo_chat/shared/constants/base_url.dart';

final String token =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJwb3N0IiwidW5pcXVlX25hbWUiOiJwb3N0IiwiQnJhbmNoTmFtZSI6IkRBTFEiLCJGaW5ZZWFyIjoiZjIiLCJGaXJtIjoiZjIiLCJVc2VybmFtZSI6InBvc3QiLCJuYmYiOjE3NTQ0NzAwOTgsImV4cCI6MTc1NTc5MDA5OCwiaWF0IjoxNzU0NDcwMDk4fQ.wdu6m5CIfN-hRX_wgRA8Dhv0FIqgDbDTVdLp18eYJF4';

class NetworkProvider {
  final Dio _dio;
  static final Map<String, Response> _cache = {};

  NetworkProvider()
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        logPrint: print,
        retries: 3,
        retryEvaluator: (error, attempt) {
          if (error.response?.statusCode == 403 ||
              error.response?.statusCode == 404 ||
              error.response?.statusCode == 401 ||
              (error.response?.statusCode == 400)) {
            return false;
          }
          return true;
        },
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          log(
            '------------------------------------------------------------------------------------------------',
          );
          String fullUrl = baseUrl + options.path;
          log('Full URL: $fullUrl');

          // Fix: Handle FormData logging properly - DON'T use jsonEncode on FormData
          if (options.data is FormData) {
            final formData = options.data as FormData;
            log('Request Type: FormData');
            log('FormData fields:');
            for (var field in formData.fields) {
              log('  ${field.key}: ${field.value}');
            }
            if (formData.files.isNotEmpty) {
              log('FormData files:');
              for (var file in formData.files) {
                log('  ${file.key}: ${file.value.filename}');
              }
            }
          } else if (options.data != null) {
            // Only use jsonEncode for non-FormData
            try {
              log('Request = ${jsonEncode(options.data)}', name: options.path);
            } catch (e) {
              log('Request = ${options.data.toString()}', name: options.path);
            }
          } else {
            log('Request Type: No data');
          }

          log(
            '------------------------------------------------------------------------------------------------',
          );

          if (options.headers.containsKey('auth')) {
            options.headers.remove('auth');
          } else {
            log("Access token  $token");
            if (token != "") {
              options.headers.addEntries(
                {'Authorization': 'Bearer $token', "userName": "post"}.entries,
              );
            }
            log("token $token");
          }

          return handler.next(options);
        },
        // onRequest: (options, handler) async {
        //   log(
        //     '------------------------------------------------------------------------------------------------',
        //   );
        //   if (options.data is FormData) {
        //     final formData = options.data as FormData;
        //     log('Request Type: FormData');
        //     log('FormData fields:');
        //     for (var field in formData.fields) {
        //       log('  ${field.key}: ${field.value}');
        //     }
        //     if (formData.files.isNotEmpty) {
        //       log('FormData files:');
        //       for (var file in formData.files) {
        //         log(
        //           '  ${file.key}: ${file.value.filename} (${file.value.length} bytes)',
        //         );
        //       }
        //     }
        //   } else if (options.data != null) {
        //     log('Request Type: JSON');
        //     log('Request = ${jsonEncode(options.data)}', name: options.path);
        //   } else {
        //     log('Request Type: No data');
        //   }
        //   //=-=-=-===============================
        //   String fullUrl = baseUrl + options.path;
        //   log('Full URL: $fullUrl');
        //   if (options.contentType == 'multipart/form-data') {
        //     log('Request = ${options.data}', name: options.path);
        //   } else {
        //     log('Request = ${jsonEncode(options.data)}', name: options.path);
        //   }
        //   log(
        //     '------------------------------------------------------------------------------------------------',
        //   );

        //   if (options.headers.containsKey('auth')) {
        //     options.headers.remove('auth');
        //   } else {
        //     // final String? token = await AuthUtils.instance.readAccessToken;

        //     log("Access token  $token");
        //     if (token != "") {
        //       options.headers.addEntries(
        //         {'Authorization': 'Bearer $token', "userName": "post"}.entries,
        //       );
        //     }

        //     log("token $token");
        //   }

        //   return handler.next(options);
        // },
        onResponse: (response, handler) {
          log(
            '************************************************************************************************',
          );
          log(
            'Response = ${response.data.toString()}',
            name: response.requestOptions.path,
          );
          log(
            'Response Status: ${response.statusCode}',
            name: response.requestOptions.path,
          );
          log(
            'Response Headers: ${response.headers}',
            name: response.requestOptions.path,
          );
          log(
            'Response Data: ${response.data.toString()}',
            name: response.requestOptions.path,
          );
          log(
            '************************************************************************************************',
          );

          return handler.next(response);
        },
        onError: (error, handler) async {
          log(
            'Error Status: ${error.response?.statusCode}',
            name: error.requestOptions.path,
          );
          log(
            'Error Headers: ${error.response?.headers}',
            name: error.requestOptions.path,
          );
          log(
            'Error Data: ${error.response?.data}',
            name: error.requestOptions.path,
          );
          log(
            'Error Message: ${error.message}',
            name: error.requestOptions.path,
          );
          if (error.error is SocketException ||
              error.type == DioExceptionType.connectionError) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: 'No internet connection. Please check your network.',
                type: DioExceptionType.connectionError,
              ),
            );
          }

          log(
            'Error-Response [${error.response?.statusCode}] = ${error.response.toString()}',
            name: error.requestOptions.path,
          );

          if (error.response?.statusCode == 403 &&
              !error.requestOptions.extra.containsKey('retry')) {
            try {
              String? accessToken = await _refreshToken();
              if (accessToken != null) {
                error.requestOptions.headers['Authorization'] =
                    'Bearer $accessToken';
                error.requestOptions.extra['retry'] = true;
                final response = await _dio.request(
                  error.requestOptions.path,
                  options: Options(
                    method: error.requestOptions.method,
                    headers: error.requestOptions.headers,
                    responseType: error.requestOptions.responseType,
                  ),
                  queryParameters: error.requestOptions.queryParameters,
                );
                return handler.resolve(response);
              } else {
                return handler.reject(
                  DioException(
                    requestOptions: error.requestOptions,
                    error: 'Failed to refresh token',
                  ),
                );
              }
            } catch (refreshError) {
              return handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  error: 'Failed to refresh token',
                ),
              );
            }
          } else {
            return handler.next(
              DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                error:
                    Helper().errorMapping(error.response) ??
                    'Unknown error occurred',
              ),
            );
          }
        },
      ),
    );
  }

  Future<Response<T>> _makeRequest<T>(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    bool force = false,
  }) async {
    final cacheKey = _generateCacheKey(
      method,
      path,
      data ?? queryParameters ?? {},
    );

    if (_cache.containsKey(cacheKey) && force && method == 'GET') {
      return _cache[cacheKey]! as Response<T>;
    }

    try {
      Response<T> response;
      switch (method) {
        case 'GET':
          response = await _dio.get<T>(
            path,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
            onReceiveProgress: onReceiveProgress,
          );
          break;
        case 'POST':
          final postData = data is FormData
              ? data
              : Helper().removeNullValues(data ?? {});
          response = await _dio.post<T>(
            path,
            data: postData,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          );
          break;
        case 'PUT':
          response = await _dio.put<T>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          );
          break;
        case 'DELETE':
          response = await _dio.delete<T>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
          );
          break;
        case 'PATCH':
          response = await _dio.patch<T>(
            path,
            data: Helper().removeNullValues(data ?? {}),
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
          );
          break;
        default:
          throw UnsupportedError('Unsupported HTTP method');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        _cache[cacheKey] = response;
      }

      return response;
    } catch (error) {
      return Future.error(error);
    }
  }

  // Add this method to your NetworkProvider class
  Future<Response<T>> postFormData<T>(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      log('NetworkProvider: Sending FormData to $path');

      final response = await _dio.post<T>(
        path,
        data: formData, // Pass FormData directly
        queryParameters: queryParameters,
        options:
            options ??
            Options(headers: {'Content-Type': 'multipart/form-data'}),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      log('NetworkProvider: FormData response status ${response.statusCode}');
      return response;
    } catch (error) {
      log('NetworkProvider: FormData error - $error');
      return Future.error(error);
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
    bool force = false,
  }) async {
    return _makeRequest<T>(
      'GET',
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
      force: force,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Map<String, dynamic>? data,
    FormData? formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    bool force = false,
  }) async {
    return _makeRequest<T>(
      'POST',
      path,
      data: data ?? formData,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      force: force,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    bool force = false,
  }) async {
    return _makeRequest<T>(
      'PUT',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      force: force,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool force = false,
  }) async {
    return _makeRequest<T>(
      'DELETE',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      force: force,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool force = false,
  }) async {
    return _makeRequest<T>(
      'PATCH',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      force: force,
    );
  }

  Future<Response<T>> formData<T>(
    String path, {
    FormData? formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    bool force = false,
  }) async {
    return _dio.post<T>(
      path,
      data: formData,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> retryRequest<T>(RequestOptions requestOptions) async {
    final Completer<Response<T>> responseCompleter = Completer<Response<T>>();

    responseCompleter.complete(request<T>(requestOptions));

    return responseCompleter.future;
  }

  Future<Response<T>> request<T>(RequestOptions requestOptions) async {
    return _dio.request<T>(
      requestOptions.path,
      cancelToken: requestOptions.cancelToken,
      data: requestOptions.data,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        sendTimeout: requestOptions.sendTimeout,
        receiveTimeout: requestOptions.receiveTimeout,
        extra: requestOptions.extra,
        headers: requestOptions.headers,
        responseType: requestOptions.responseType,
        contentType: requestOptions.contentType,
        validateStatus: requestOptions.validateStatus,
        receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
        followRedirects: requestOptions.followRedirects,
        maxRedirects: requestOptions.maxRedirects,
        persistentConnection: requestOptions.persistentConnection,
        requestEncoder: requestOptions.requestEncoder,
        responseDecoder: requestOptions.responseDecoder,
        listFormat: requestOptions.listFormat,
      ),
    );
  }

  String _generateCacheKey(
    String method,
    String url,
    Map<String, dynamic> data,
  ) {
    final methodString = method.toString();
    final dataString = jsonEncode(data);
    return '$methodString|$url|$dataString';
  }

  Future<String?> _refreshToken() async {
    log('refresh token called');
    try {
      // String? refreshToken = await AuthUtils.instance.readRefreshTokens;
      Response response = await Dio().post(
        "$baseUrl/users/login/refresh/",
        data: {"refresh": ''},
      );
      if (response.statusCode == 200) {
        String? newAuthToken = response.data['access'];
        // String? newRefreshToken = response.data['refresh'];
        // await AuthUtils.instance.writeAccessTokens(newAuthToken ?? '');
        // await AuthUtils.instance.writeRefreshTokens(newRefreshToken ?? '');
        return newAuthToken;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
