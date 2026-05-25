// Placeholder para Auth Datasource
abstract class AuthRemoteDatasource {
  Future<void> registerWithEmail({required String email, required String password});
  Future<void> loginWithEmail({required String email, required String password});
  Future<void> logout();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  @override
  Future<void> loginWithEmail({required String email, required String password}) async {
    // Se implementará en el siguiente paso
  }

  @override
  Future<void> registerWithEmail({required String email, required String password}) async {
    // Se implementará en el siguiente paso
  }

  @override
  Future<void> logout() async {
    // Se implementará en el siguiente paso
  }
}
