import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:premade/application/providers/auth_providers.dart';
import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/core/errors/failures.dart';
import 'package:premade/data/datasources/matching_remote_data_source.dart';
import 'package:premade/data/repositories/matching_repository_impl.dart';
import 'package:premade/domain/entities/matching_entity.dart';
import 'package:premade/domain/repositories/matching_repository.dart';
import 'package:premade/domain/usecases/matching_usecases.dart';

// ============ DEPENDENCY INJECTION PROVIDERS ============

/// Data source para matching
final matchingRemoteDataSourceProvider = Provider<MatchingRemoteDataSource>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return MatchingRemoteDataSourceImpl(supabaseService);
});

/// Repository para matching
final matchingRepositoryProvider = Provider<MatchingRepository>((ref) {
  final dataSource = ref.watch(matchingRemoteDataSourceProvider);
  return MatchingRepositoryImpl(dataSource);
});

/// Use cases
final getMatchCandidatesUseCaseProvider = Provider<GetMatchCandidatesUseCase>((ref) {
  final repository = ref.watch(matchingRepositoryProvider);
  return GetMatchCandidatesUseCase(repository);
});

final createSwipeUseCaseProvider = Provider<CreateSwipeUseCase>((ref) {
  final repository = ref.watch(matchingRepositoryProvider);
  return CreateSwipeUseCase(repository);
});

final getUserMatchesUseCaseProvider = Provider<GetUserMatchesUseCase>((ref) {
  final repository = ref.watch(matchingRepositoryProvider);
  return GetUserMatchesUseCase(repository);
});

final getUserSwipesUseCaseProvider = Provider<GetUserSwipesUseCase>((ref) {
  final repository = ref.watch(matchingRepositoryProvider);
  return GetUserSwipesUseCase(repository);
});

final getReceivedSwipesUseCaseProvider = Provider<GetReceivedSwipesUseCase>((ref) {
  final repository = ref.watch(matchingRepositoryProvider);
  return GetReceivedSwipesUseCase(repository);
});

final unlockMatchUseCaseProvider = Provider<UnlockMatchUseCase>((ref) {
  final repository = ref.watch(matchingRepositoryProvider);
  return UnlockMatchUseCase(repository);
});

final getMatchDetailsUseCaseProvider = Provider<GetMatchDetailsUseCase>((ref) {
  final repository = ref.watch(matchingRepositoryProvider);
  return GetMatchDetailsUseCase(repository);
});

// ============ STATE NOTIFIERS ============

/// State notifier para candidatos de match
class MatchCandidatesNotifier extends StateNotifier<List<MatchCard>> {
  final GetMatchCandidatesUseCase getCandidatesUseCase;

  MatchCandidatesNotifier(this.getCandidatesUseCase) : super([]);

  /// Cargar candidatos
  Future<void> loadCandidates() async {
    print('DEBUG: MatchCandidatesNotifier.loadCandidates() llamado');
    try {
      final result = await getCandidatesUseCase();
      result.fold(
        (failure) {
          print('DEBUG: loadCandidates fallo: ${failure.message}');
          state = [];
        },
        (candidates) {
          print('DEBUG: loadCandidates éxito: ${candidates.length} candidatos');
          state = candidates;
        },
      );
    } catch (e) {
      print('DEBUG: loadCandidates excepción: $e');
      state = [];
    }
  }

  /// Remover candidato después de swipear
  void removeCandidate(String userId) {
    state = state.where((card) => card.userId != userId).toList();
  }
}

/// State notifier para matches del usuario
class UserMatchesNotifier extends StateNotifier<List<Match>> {
  final GetUserMatchesUseCase getMatchesUseCase;

  UserMatchesNotifier(this.getMatchesUseCase) : super([]);

  /// Cargar matches
  Future<void> loadMatches() async {
    print('DEBUG: UserMatchesNotifier.loadMatches() llamado');
    try {
      final result = await getMatchesUseCase();
      result.fold(
        (failure) {
          print('DEBUG: loadMatches fallo: ${failure.message}');
          state = [];
        },
        (matches) {
          print('DEBUG: loadMatches éxito: ${matches.length} matches');
          state = matches;
        },
      );
    } catch (e) {
      print('DEBUG: loadMatches excepción: $e');
      state = [];
    }
  }

  /// Agregar match a la lista
  void addMatch(Match match) {
    state = [...state, match];
  }
}

// ============ STATE PROVIDERS ============

/// Provider para candidatos de match
final matchCandidatesProvider = StateNotifierProvider<MatchCandidatesNotifier, List<MatchCard>>((ref) {
  final useCase = ref.watch(getMatchCandidatesUseCaseProvider);
  return MatchCandidatesNotifier(useCase);
});

/// Provider para matches del usuario
final userMatchesProvider = StateNotifierProvider<UserMatchesNotifier, List<Match>>((ref) {
  final useCase = ref.watch(getUserMatchesUseCaseProvider);
  return UserMatchesNotifier(useCase);
});

/// Provider para candidatos con FutureProvider (auto-load)
final matchCandidatesFutureProvider = FutureProvider<List<MatchCard>>((ref) async {
  final useCase = ref.watch(getMatchCandidatesUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => [],
    (candidates) => candidates,
  );
});

/// Provider para matches del usuario con FutureProvider
final userMatchesFutureProvider = FutureProvider<List<Match>>((ref) async {
  final useCase = ref.watch(getUserMatchesUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => [],
    (matches) => matches,
  );
});

// ============ LOADING & ERROR PROVIDERS ============

/// Provider para estado de carga del matching
final matchingLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider para errores del matching
final matchingErrorProvider = StateProvider<String?>((ref) => null);

/// Provider para tracking de swipes realizados (para evitar duplicados)
final swipedUsersProvider = StateProvider<Set<String>>((ref) => {});
