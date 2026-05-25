import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:premade/core/errors/failures.dart';
import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/data/datasources/profile_remote_data_source.dart';
import 'package:premade/data/repositories/profile_repository_impl.dart';
import 'package:premade/domain/entities/user_profile_entity.dart';
import 'package:premade/domain/usecases/profile_usecases.dart';
import 'package:premade/application/providers/auth_providers.dart';

// ============================================================================
// Providers de DataSource
// ============================================================================

final profileRemoteDataSourceProvider =
    Provider<ProfileRemoteDataSource>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return ProfileRemoteDataSourceImpl(supabaseService);
});

// ============================================================================
// Provider del Repositorio
// ============================================================================

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(dataSource);
});

// ============================================================================
// Providers de Use Cases
// ============================================================================

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return GetUserProfileUseCase(repository);
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return UpdateProfileUseCase(repository);
});

final uploadAvatarUseCaseProvider = Provider<UploadAvatarUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return UploadAvatarUseCase(repository);
});

final addUserGameUseCaseProvider = Provider<AddUserGameUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return AddUserGameUseCase(repository);
});

final getUserGamesUseCaseProvider = Provider<GetUserGamesUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return GetUserGamesUseCase(repository);
});

final removeUserGameUseCaseProvider = Provider<RemoveUserGameUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return RemoveUserGameUseCase(repository);
});

final updateUserGameUseCaseProvider = Provider<UpdateUserGameUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return UpdateUserGameUseCase(repository);
});

final getGamesListUseCaseProvider = Provider<GetGamesListUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return GetGamesListUseCase(repository);
});

final getGameRolesUseCaseProvider = Provider<GetGameRolesUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return GetGameRolesUseCase(repository);
});

final getGameRanksUseCaseProvider = Provider<GetGameRanksUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return GetGameRanksUseCase(repository);
});

// ============================================================================
// Estado del perfil actual del usuario
// ============================================================================

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  return UserProfileNotifier(ref);
});

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  final Ref ref;

  UserProfileNotifier(this.ref) : super(null);

  Future<void> loadProfile(String userId) async {
    try {
      final result = await ref.read(getUserProfileUseCaseProvider).call(userId);
      result.fold(
        (failure) { state = null; },
        (profile) { state = profile; },
      );
    } catch (e) {
      state = null;
    }
  }

  Future<void> updateProfile(UpdateProfileParams params) async {
    try {
      final result =
          await ref.read(updateProfileUseCaseProvider).call(params);
      result.fold(
        (failure) {
          throw Exception((failure as Failure).message);
        },
        (profile) {
          state = profile;
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadAvatar(UploadAvatarParams params) async {
    try {
      final result =
          await ref.read(uploadAvatarUseCaseProvider).call(params);
      return result.fold(
        (failure) {
          throw Exception(failure.message);
        },
        (avatarUrl) {
          // Actualizar el avatar en el estado
          if (state != null) {
            state = state!.copyWith(avatarUrl: avatarUrl);
          }
          return avatarUrl;
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addGame(AddUserGameParams params) async {
    try {
      final result = await ref.read(addUserGameUseCaseProvider).call(params);
      result.fold(
        (failure) {
          throw Exception((failure as Failure).message);
        },
        (_) {
          // Juego agregado exitosamente
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}

// ============================================================================
// Estado de juegos del usuario
// ============================================================================

final userGamesProvider =
    StateNotifierProvider<UserGamesNotifier, List<UserGameSelection>?>((ref) {
  return UserGamesNotifier(ref);
});

class UserGamesNotifier extends StateNotifier<List<UserGameSelection>?> {
  final Ref ref;

  UserGamesNotifier(this.ref) : super(null);

  Future<void> loadGames(String userId) async {
    try {
      final result = await ref.read(getUserGamesUseCaseProvider).call(userId);
      result.fold(
        (failure) => state = [],
        (games) => state = games,
      );
    } catch (e) {
      state = [];
    }
  }

  Future<void> addGame(AddUserGameParams params) async {
    try {
      final result = await ref.read(addUserGameUseCaseProvider).call(params);
      result.fold(
        (failure) {
          throw Exception((failure as Failure).message);
        },
        (_) {
          // Recargar juegos
          final userId = ref.read(authUserProvider)?.id;
          if (userId != null) {
            loadGames(userId);
          }
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeGame(String gameId) async {
    try {
      final result = await ref.read(removeUserGameUseCaseProvider).call(gameId);
      result.fold(
        (failure) {
          throw Exception((failure as Failure).message);
        },
        (_) {
          // Remover del estado local
          state = state?.where((g) => g.gameId != gameId).toList();
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateGame(AddUserGameParams params) async {
    try {
      final result =
          await ref.read(updateUserGameUseCaseProvider).call(params);
      result.fold(
        (failure) {
          throw Exception((failure as Failure).message);
        },
        (_) {
          // Recargar juegos
          final userId = ref.read(authUserProvider)?.id;
          if (userId != null) {
            loadGames(userId);
          }
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}

// ============================================================================
// Lista de juegos disponibles
// ============================================================================

final gamesListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final result = await ref.read(getGamesListUseCaseProvider).call();
    return result.fold(
      (failure) {
        print('DEBUG gamesListProvider: Error al obtener juegos: ${failure.message}');
        return <Map<String, dynamic>>[];
      },
      (games) {
        print('DEBUG gamesListProvider: ${games.length} juegos cargados');
        return games;
      },
    );
  } catch (e) {
    print('DEBUG gamesListProvider: Excepción inesperada: $e');
    return <Map<String, dynamic>>[];
  }
});

// ============================================================================
// Roles de un juego específico
// ============================================================================

final gameRolesProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, gameId) async {
  final result = await ref.read(getGameRolesUseCaseProvider).call(gameId);
  return result.fold(
    (failure) => [],
    (roles) => roles,
  );
});

// ============================================================================
// Rangos de un juego específico
// ============================================================================

final gameRanksProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, gameId) async {
  final result = await ref.read(getGameRanksUseCaseProvider).call(gameId);
  return result.fold(
    (failure) => [],
    (ranks) => ranks,
  );
});

// ============================================================================
// Loading y Error states
// ============================================================================

final profileLoadingProvider =
    StateNotifierProvider<ProfileLoadingNotifier, bool>((ref) {
  return ProfileLoadingNotifier();
});

class ProfileLoadingNotifier extends StateNotifier<bool> {
  ProfileLoadingNotifier() : super(false);

  void setLoading(bool value) => state = value;
}

final profileErrorProvider =
    StateNotifierProvider<ProfileErrorNotifier, String?>((ref) {
  return ProfileErrorNotifier();
});

class ProfileErrorNotifier extends StateNotifier<String?> {
  ProfileErrorNotifier() : super(null);

  void setError(String? error) => state = error;
  void clearError() => state = null;
}
