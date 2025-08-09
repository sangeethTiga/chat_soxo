part of 'auth_cubit.dart';

class AuthState extends Equatable {
  final ApiFetchStatus? isSignIn;
  final AuthResponse? authResponse;
  const AuthState({this.isSignIn, this.authResponse});
  AuthState copyWith({ApiFetchStatus? isSignIn, AuthResponse? authResponse}) {
    return AuthState(
      isSignIn: isSignIn ?? this.isSignIn,
      authResponse: authResponse ?? this.authResponse,
    );
  }

  @override
  List<Object?> get props => [isSignIn, authResponse];
}

class InitialAuthState extends AuthState {}
