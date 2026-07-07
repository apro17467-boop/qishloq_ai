import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qishloq_ai_mobile/core/providers/core_providers.dart';
import 'package:qishloq_ai_mobile/features/auth/application/auth_state.dart';
import 'package:qishloq_ai_mobile/features/auth/data/auth_models.dart';

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState.initial();
  }

  Future<bool> checkAuth() async {
    state = AuthState.loading();
    final tokenStorage = ref.read(tokenStorageProvider);
    final authService = ref.read(authServiceProvider);
    try {
      final token = await tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        state = AuthState.unauthenticated();
        return false;
      }

      final user = await authService.getMe();
      if (!user.isActive) {
        await tokenStorage.clearAccessToken();
        state = AuthState.unauthenticated(errorMessage: 'Foydalanuvchi faol emas');
        return false;
      }

      state = AuthState.authenticated(user);
      return true;
    } catch (e) {
      await tokenStorage.clearAccessToken();
      state = AuthState.unauthenticated(errorMessage: 'Sessiya muddati tugagan. Qayta kiring.');
      return false;
    }
  }

  void setAuthenticatedFromLogin(AuthUser user) {
    state = AuthState.authenticated(user);
  }

  Future<void> logout() async {
    final tokenStorage = ref.read(tokenStorageProvider);
    await tokenStorage.clearAccessToken();
    state = AuthState.unauthenticated();
  }
}
