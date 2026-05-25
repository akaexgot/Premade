import 'package:fpdart/fpdart.dart';
import 'package:premade/core/errors/failures.dart';
import 'package:premade/domain/entities/matching_entity.dart';
import 'package:premade/domain/repositories/matching_repository.dart';

/// Obtener candidatos para swipear
class GetMatchCandidatesUseCase {
  final MatchingRepository repository;

  GetMatchCandidatesUseCase(this.repository);

  Future<Either<Failure, List<MatchCard>>> call() {
    return repository.getMatchCandidates();
  }
}

/// Crear un swipe (like/pass)
class CreateSwipeUseCase {
  final MatchingRepository repository;

  CreateSwipeUseCase(this.repository);

  Future<Either<Failure, SwipeResult>> call(CreateSwipeParams params) {
    return repository.createSwipe(params);
  }
}

/// Obtener matches del usuario actual
class GetUserMatchesUseCase {
  final MatchingRepository repository;

  GetUserMatchesUseCase(this.repository);

  Future<Either<Failure, List<Match>>> call() {
    return repository.getUserMatches();
  }
}

/// Obtener swipes hechos por el usuario
class GetUserSwipesUseCase {
  final MatchingRepository repository;

  GetUserSwipesUseCase(this.repository);

  Future<Either<Failure, List<Swipe>>> call() {
    return repository.getUserSwipes();
  }
}

/// Obtener swipes recibidos (likes de otros usuarios)
class GetReceivedSwipesUseCase {
  final MatchingRepository repository;

  GetReceivedSwipesUseCase(this.repository);

  Future<Either<Failure, List<Swipe>>> call() {
    return repository.getReceivedSwipes();
  }
}

/// Desbloquear un match (reveal que ambos se likearon)
class UnlockMatchUseCase {
  final MatchingRepository repository;

  UnlockMatchUseCase(this.repository);

  Future<Either<Failure, Match>> call(String matchId) {
    return repository.unlockMatch(matchId);
  }
}

/// Obtener detalles de un match específico
class GetMatchDetailsUseCase {
  final MatchingRepository repository;

  GetMatchDetailsUseCase(this.repository);

  Future<Either<Failure, Match>> call(String matchId) {
    return repository.getMatchDetails(matchId);
  }
}
