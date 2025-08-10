import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:injectable/injectable.dart';
import 'package:soxo_chat/feature/auth/domain/models/auth_res/auth_response.dart';
import 'package:soxo_chat/feature/auth/domain/repositories/auth_repositories.dart';
import 'package:soxo_chat/shared/utils/result.dart';
@LazySingleton(as:AuthRepositories )
class AuthService implements AuthRepositories {
  late Dio dio;
  
  AuthService() {
    dio = Dio();
    
    // Only for development - DO NOT use in production
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };
  }

  @override
  Future<ResponseResult<AuthResponse>> signIn(
    String userName,
    String password,
  ) async {
    try {
      final res = await dio.post(
        'https://dkh-mis-api.onedesk.app/api/Account',
        data: {
          "userName": userName,
          "PASSWORD": '4mgXKHeAzWc648PLCCgWU61qnD3CFQP8GQOSmlk1PMk=',
        },
      );
      
      switch (res.statusCode) {
        case 200:
        case 201:
          return ResponseResult(data: AuthResponse.fromJson(res.data));
        default:
          throw ResponseResult(data: res.statusMessage);
      }
    } catch (e) {
      print('Auth error: $e');
      rethrow;
    }
  }
}