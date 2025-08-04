import 'package:soxo_chat/feature/person_lists/domain/models/user_response.dart';
import 'package:soxo_chat/shared/utils/result.dart';

abstract class PersonListRepositories {
  Future<ResponseResult<List<UserResponse>>> personList();
}
