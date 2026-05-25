import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/domain/entities/auth_entity.dart';
import 'package:gotrue/gotrue.dart' as gotrue;

abstract class AuthRemoteDataSource {
  Future<AuthResponse> signUp(SignUpParams params);
  Future<AuthResponse> signIn(SignInParams params);
  Future<AuthResponse> signInWithGoogle();
  Future<void> signOut();
  Future<void> resetPassword(ResetPasswordParams params);
  Future<AuthUser?> getCurrentUser();
  Future<bool> isUserAuthenticated();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseService supabaseService;

  AuthRemoteDataSourceImpl(this.supabaseService);

  AuthResponse _mapAuthResponse(gotrue.AuthResponse response) {
    final user = response.user;
    if (user == null) throw Exception('No user found in response');

    return AuthResponse(
      user: AuthUser(
        id: user.id,
        email: user.email ?? '',
        nickname: user.userMetadata?['nickname'],
        isEmailVerified: user.emailConfirmedAt != null,
        createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      ),
      accessToken: response.session?.accessToken,
      refreshToken: response.session?.refreshToken,
    );
  }

  @override
  Future<AuthResponse> signUp(SignUpParams params) async {
    try {
      print(
          'DEBUG: AuthRemoteDataSourceImpl.signUp - Iniciando signUp en Supabase...');
      final response = await supabaseService.signUp(
        email: params.email,
        password: params.password,
      );
      print(
          'DEBUG: AuthRemoteDataSourceImpl.signUp - signUp en Supabase completado');

      print(
          'DEBUG: AuthRemoteDataSourceImpl.signUp - Creando perfil de usuario...');
      await supabaseService.createUserProfile(
        userId: response.user?.id,
        email: response.user?.email,
        nickname: params.nickname,
        age: params.age,
        country: params.country,
      );
      print('DEBUG: AuthRemoteDataSourceImpl.signUp - Perfil creado');

      return _mapAuthResponse(response);
    } catch (e) {
      print('DEBUG: Error en AuthRemoteDataSourceImpl.signUp: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signIn(SignInParams params) async {
    try {
      // Test de conectividad primero
      print('DEBUG: Testeando conectividad con Supabase...');
      try {
        final testResponse = await supabaseService.client
            .from('users')
            .select('id')
            .limit(1)
            .timeout(const Duration(seconds: 10));
        print('DEBUG: Conectividad OK - hay ${testResponse.length} usuarios');
      } catch (e) {
        print('DEBUG: ERROR DE CONECTIVIDAD: $e');
        throw Exception(
            'No se puede conectar con el servidor. Verifica tu conexión a internet.');
      }

      // Limpiar sesión anterior
      print('DEBUG: Limpiando sesión anterior...');
      try {
        supabaseService.clearProfileCache();
        await supabaseService.client.auth.signOut().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            print('DEBUG: signOut timeout (ignorado)');
          },
        );
      } catch (_) {}

      print('DEBUG: Intentando signIn con email: ${params.email}');
      final response = await supabaseService.client.auth
          .signInWithPassword(
            email: params.email,
            password: params.password,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Timeout de 30s en signIn'),
          );

      print('DEBUG: signIn completado. User ID: ${response.user?.id}');
      return _mapAuthResponse(response);
    } catch (e) {
      print('DEBUG: Error en signIn: $e');
      rethrow;
    }
  }

  @override
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final success = await supabaseService.signInWithGoogle();
      if (!success) throw Exception('Google sign in was not successful');

      final session = supabaseService.currentSession;
      final user = supabaseService.currentUser;

      if (session == null || user == null)
        throw Exception('No session after Google sign in');

      return AuthResponse(
        user: AuthUser(
          id: user.id,
          email: user.email ?? '',
          nickname: user.userMetadata?['nickname'],
          isEmailVerified: user.emailConfirmedAt != null,
          createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
        ),
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      return await supabaseService.signOut();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(ResetPasswordParams params) async {
    try {
      return await supabaseService.resetPassword(email: params.email);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      final user = supabaseService.getCurrentUser();
      if (user == null) return null;

      final profile = await supabaseService.getUserProfile(user.id);
      if (profile == null) return null;

      return AuthUser(
        id: user.id,
        email: user.email ?? '',
        nickname: profile['nickname'],
        isEmailVerified: user.emailConfirmedAt != null,
        createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isUserAuthenticated() async {
    try {
      final user = supabaseService.getCurrentUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }
}
