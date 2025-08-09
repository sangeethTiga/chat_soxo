import 'package:soxo_chat/feature/auth/domain/models/auth_res/auth_response.dart';
import 'package:soxo_chat/shared/utils/result.dart';

abstract class AuthRepositories {
  Future<ResponseResult<AuthResponse>> signIn(String userName, String password);
}
