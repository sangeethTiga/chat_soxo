import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:soxo_chat/feature/auth/domain/models/auth_res/auth_response.dart';
import 'package:soxo_chat/shared/app/extension/helper.dart';
import 'package:soxo_chat/shared/constants/base_url.dart';
import 'package:soxo_chat/shared/utils/auth/auth_utils.dart';

class NetworkProvider {
  final Dio _dio;
  static final Map<String, Response> _cache = {};

  NetworkProvider()
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Retry interceptor
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        logPrint: print,
        retries: 3,
        retryEvaluator: (error, attempt) {
          // Don't retry for client errors
          if (error.response?.statusCode == 403 ||
              error.response?.statusCode == 404 ||
              error.response?.statusCode == 401 ||
              error.response?.statusCode == 400) {
            return false;
          }
          return true;
        },
      ),
    );

    // Main interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    _logRequest(options);

    // Skip auth for auth endpoints
    if (options.headers.containsKey('auth')) {
      options.headers.remove('auth');
    } else {
      // Dynamically get token for each request
      final String? token = await AuthUtils.instance.readAccessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        log("Access token applied: ${token.substring(0, 10)}...");

        // Your API requires userName header - get it from stored user data
        final AuthResponse? userName = await AuthUtils.instance.readUserData();
        if (userName != null && userName.result?.userName != null) {
          options.headers['userName'] = userName.result?.userName;
          log("UserName header applied: $userName");
        } else {
          log("Warning: No userName available for API call");
        }
      } else {
        log("No access token available");
      }
    }

    handler.next(options);
  }

  void _logRequest(RequestOptions options) {
    log(
      '------------------------------------------------------------------------------------------------',
    );
    String fullUrl = baseUrl + options.path;
    log('Full URL: $fullUrl');

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
  }

  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    log(
      '************************************************************************************************',
    );
    log(
      'Response Status: ${response.statusCode}',
      name: response.requestOptions.path,
    );
    log(
      'Response Data: ${response.data.toString()}',
      name: response.requestOptions.path,
    );
    log(
      '************************************************************************************************',
    );
    handler.next(response);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    log(
      'Error Status: ${error.response?.statusCode}',
      name: error.requestOptions.path,
    );
    log('Error Message: ${error.message}', name: error.requestOptions.path);

    // Handle network errors
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

    // Handle token refresh for 401/403 errors
    if ((error.response?.statusCode == 401 ||
            error.response?.statusCode == 403) &&
        !error.requestOptions.extra.containsKey('retry')) {
      try {
        String? newToken = await _refreshToken();
        if (newToken != null) {
          // Update token and retry request
          error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          error.requestOptions.extra['retry'] = true;

          final response = await _dio.request(
            error.requestOptions.path,
            options: Options(
              method: error.requestOptions.method,
              headers: error.requestOptions.headers,
              responseType: error.requestOptions.responseType,
            ),
            data: error.requestOptions.data,
            queryParameters: error.requestOptions.queryParameters,
          );
          return handler.resolve(response);
        }
      } catch (refreshError) {
        log('Token refresh failed: $refreshError');
      }

      // If refresh fails, redirect to login
      _handleAuthFailure();
    }

    // Return processed error
    handler.reject(
      DioException(
        requestOptions: error.requestOptions,
        response: error.response,
        error:
            Helper().errorMapping(error.response) ?? 'Unknown error occurred',
      ),
    );
  }

  void _handleAuthFailure() {
    // Clear stored tokens
    // AuthUtils.instance.clearTokens();
    // TODO: Navigate to login screen or emit auth failure event
    log('Authentication failed - user should be redirected to login');
  }

  Future<String?> _refreshToken() async {
    log('Attempting token refresh...');
    try {
      String? refreshToken = await AuthUtils.instance.readAccessToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        log('No refresh token available');
        return null;
      }

      Response response = await Dio().post(
        "$baseUrl/users/login/refresh/",
        data: {"refresh": refreshToken},
      );

      if (response.statusCode == 200) {
        String? newAccessToken = response.data['access'];
        String? newRefreshToken = response.data['refresh'];

        if (newAccessToken != null) {
          await AuthUtils.instance.writeAccessTokens(newAccessToken);
          if (newRefreshToken != null) {
            await AuthUtils.instance.writeRefreshTokens(newRefreshToken);
          }
          log('Token refreshed successfully');
          return newAccessToken;
        }
      }
      return null;
    } catch (e) {
      log('Token refresh error: $e');
      return null;
    }
  }

  // HTTP Methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
    bool useCache = true,
  }) async {
    final cacheKey = _generateCacheKey('GET', path, queryParameters ?? {});

    if (useCache && _cache.containsKey(cacheKey)) {
      log('Returning cached response for GET $path');
      return _cache[cacheKey]! as Response<T>;
    }

    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      if (useCache &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        _cache[cacheKey] = response;
      }

      return response;
    } catch (error) {
      return Future.error(error);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final processedData = data is FormData
          ? data
          : Helper().removeNullValues(data ?? {});

      return await _dio.post<T>(
        path,
        data: processedData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (error) {
      return Future.error(error);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: Helper().removeNullValues(data ?? {}),
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (error) {
      return Future.error(error);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (error) {
      return Future.error(error);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: Helper().removeNullValues(data ?? {}),
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (error) {
      return Future.error(error);
    }
  }

  // Specialized method for FormData uploads (keeping original method name)
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

  // Alternative method name for better clarity
  Future<Response<T>> uploadFormData<T>(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return postFormData<T>(
      path,
      formData: formData,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // Cache management
  String _generateCacheKey(
    String method,
    String url,
    Map<String, dynamic> data,
  ) {
    final dataString = jsonEncode(data);
    return '$method|$url|$dataString';
  }

  void clearCache() {
    _cache.clear();
    log('Network cache cleared');
  }

  void removeCacheEntry(String method, String path, Map<String, dynamic> data) {
    final key = _generateCacheKey(method, path, data);
    _cache.remove(key);
  }
}
