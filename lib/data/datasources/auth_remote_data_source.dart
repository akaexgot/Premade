import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/domain/entities/auth_entity.dart';

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

  @override
  Future<AuthResponse> signUp(SignUpParams params) async {
    try {
      // Usar el método signUp de SupabaseService
      final response = await supabaseService.signUp(
        email: params.email,
        password: params.password,
      );

      // Crear perfil de usuario en BD
      await supabaseService.createUserProfile(
        nickname: params.nickname,
        age: params.age,
        country: params.country,
      );

      return _mapAuthResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthResponse> signIn(SignInParams params) async {
    try {
      final response = await supabaseService.signIn(
        email: params.email,
        password: params.password,
      );
      return _mapAuthResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final didStart = await supabaseService.signInWithGoogle();
      if (!didStart) {
        throw Exception('No se pudo iniciar sesión con Google');
      }

      final session = supabaseService.currentSession;
      final user = supabaseService.getCurrentUser();
      if (session == null || user == null) {
        throw Exception(
            'El login con Google requiere completar la redirección');
      }

      return _mapSession(user, session);
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
      if (profile?['banned_at'] != null) {
        await supabaseService.signOut();
        final reason = profile?['ban_reason']?.toString();
        throw Exception(
          reason == null || reason.isEmpty
              ? 'Tu cuenta ha sido baneada.'
              : 'Tu cuenta ha sido baneada: $reason',
        );
      }

      return AuthUser(
        id: user.id,
        email: user.email ?? '',
        nickname: profile?['nickname']?.toString(),
        isEmailVerified: user.emailConfirmedAt != null,
        createdAt: _parseCreatedAt(user.createdAt),
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

  AuthResponse _mapAuthResponse(supabase.AuthResponse response) {
    final user = response.user;
    final session = response.session;

    if (user == null) {
      throw Exception('Respuesta de autenticación sin usuario');
    }

    return _mapSession(user, session);
  }

  AuthResponse _mapSession(supabase.User user, supabase.Session? session) {
    return AuthResponse(
      user: AuthUser(
        id: user.id,
        email: user.email ?? '',
        nickname: user.userMetadata?['nickname']?.toString(),
        isEmailVerified: user.emailConfirmedAt != null,
        createdAt: _parseCreatedAt(user.createdAt),
      ),
      accessToken: session?.accessToken,
      refreshToken: session?.refreshToken,
    );
  }

  DateTime _parseCreatedAt(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
