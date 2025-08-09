import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:soxo_chat/feature/auth/domain/models/auth_res/auth_response.dart';
import 'package:soxo_chat/feature/auth/domain/repositories/auth_repositories.dart';
import 'package:soxo_chat/shared/app/enums/api_fetch_status.dart';

part 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthRepositories repositories;
  AuthCubit(this.repositories) : super(InitialAuthState());

  Future<void> authSignIn(String userName, String password) async {
    emit(state.copyWith(isSignIn: ApiFetchStatus.loading));
    final res = await repositories.signIn(userName, password);

    if (res.data != null) {
      emit(
        state.copyWith(
          isSignIn: ApiFetchStatus.success,
          authResponse: res.data,
        ),
      );
    }
    emit(state.copyWith(isSignIn: ApiFetchStatus.failed));
  }
}
