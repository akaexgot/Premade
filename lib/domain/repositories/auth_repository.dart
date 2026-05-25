abstract class AuthRepository {
  Future<void> registerWithEmail({
    required String email,
    required String password,
  });

  Future<void> loginWithEmail({
    required String email,
    required String password,
  });

  Future<void> loginWithGoogle();

  Future<void> logout();

  Future<String?> getCurrentUserId();

  Future<bool> isAuthenticated();
}
