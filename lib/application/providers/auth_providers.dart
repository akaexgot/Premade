import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:premade/core/errors/failures.dart';
import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/data/datasources/auth_remote_data_source.dart';
import 'package:premade/data/repositories/auth_repository_impl.dart';
import 'package:premade/domain/entities/auth_entity.dart';
import 'package:premade/domain/usecases/auth_usecases.dart';

// ============================================================================
// Providers de DataSource
// ============================================================================

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AuthRemoteDataSourceImpl(supabaseService);
});

// ============================================================================
// Provider del Repositorio
// ============================================================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

// ============================================================================
// Providers de Use Cases
// ============================================================================

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUpUseCase(repository);
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInUseCase(repository);
});

final signInWithGoogleUseCaseProvider =
    Provider<SignInWithGoogleUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithGoogleUseCase(repository);
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(repository);
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ResetPasswordUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final isUserAuthenticatedUseCaseProvider =
    Provider<IsUserAuthenticatedUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return IsUserAuthenticatedUseCase(repository);
});

// ============================================================================
// Estado actual del usuario autenticado
// ============================================================================

final authUserProvider = StateNotifierProvider<AuthUserNotifier, AuthUser?>(
  (ref) => AuthUserNotifier(ref),
);

class AuthUserNotifier extends StateNotifier<AuthUser?> {
  final Ref ref;

  AuthUserNotifier(this.ref) : super(null) {
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    try {
      final result =
          await ref.read(getCurrentUserUseCaseProvider).call();
      result.fold(
        (failure) => state = null,
        (user) => state = user,
      );
    } catch (e) {
      state = null;
    }
  }

  Future<void> signUp(SignUpParams params) async {
    try {
      final result = await ref.read(signUpUseCaseProvider).call(params);
      result.fold(
        (failure) {
          throw Exception((failure as Failure).message);
        },
        (response) {
          state = response.user;
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signIn(SignInParams params) async {
    try {
      final result = await ref.read(signInUseCaseProvider).call(params);
      result.fold(
        (failure) {
          throw Exception((failure as Failure).message);
        },
        (response) {
          state = response.user;
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final result = await ref.read(signInWithGoogleUseCaseProvider).call();
      result.fold(
        (failure) {
          throw Exception((failure as Failure).message);
        },
        (response) {
          state = response.user;
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      final result = await ref.read(signOutUseCaseProvider).call();
      result.fold(
        (failure) {
          throw Exception((failure as Failure).message);
        },
        (_) {
          state = null;
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(ResetPasswordParams params) async {
    try {
      final result = await ref.read(resetPasswordUseCaseProvider).call(params);
      result.fold(
        (failure) {
          throw Exception((failure as Failure).message);
        },
        (_) {
          // Usuario recibe correo de reset
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}

// ============================================================================
// Provider derivado: Es usuario autenticado?
// ============================================================================

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authUser = ref.watch(authUserProvider);
  return authUser != null && authUser.isAuthenticated;
});

// ============================================================================
// AsyncNotifier para loading states
// ============================================================================

final authLoadingProvider =
    StateNotifierProvider<AuthLoadingNotifier, bool>((ref) {
  return AuthLoadingNotifier();
});

class AuthLoadingNotifier extends StateNotifier<bool> {
  AuthLoadingNotifier() : super(false);

  void setLoading(bool value) => state = value;
}

// ============================================================================
// Provider para manejo de errores
// ============================================================================

final authErrorProvider =
    StateNotifierProvider<AuthErrorNotifier, String?>((ref) {
  return AuthErrorNotifier();
});

class AuthErrorNotifier extends StateNotifier<String?> {
  AuthErrorNotifier() : super(null);

  void setError(String? error) => state = error;
  void clearError() => state = null;
}
