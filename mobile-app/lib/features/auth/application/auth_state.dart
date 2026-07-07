import 'package:qishloq_ai_mobile/features/auth/data/auth_models.dart';

class AuthState {
  final AuthUser? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  factory AuthState.initial() {
    return const AuthState();
  }

  factory AuthState.loading() {
    return const AuthState(isLoading: true);
  }

  factory AuthState.authenticated(AuthUser user) {
    return AuthState(user: user);
  }

  factory AuthState.unauthenticated({String? errorMessage}) {
    return AuthState(errorMessage: errorMessage);
  }

  factory AuthState.failure(String errorMessage) {
    return AuthState(errorMessage: errorMessage);
  }
}
