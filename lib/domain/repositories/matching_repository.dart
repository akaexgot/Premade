import 'package:fpdart/fpdart.dart';
import 'package:premade/core/errors/failures.dart';
import 'package:premade/domain/entities/matching_entity.dart';

/// Interface abstracta para operaciones de matching
abstract class MatchingRepository {
  /// Obtener candidatos para swipear (usuarios no swiped aún)
  Future<Either<Failure, List<MatchCard>>> getMatchCandidates();

  /// Hacer un swipe (like/pass)
  /// Retorna SwipeResult que puede contener un Match si hay mutuo like
  Future<Either<Failure, SwipeResult>> createSwipe(CreateSwipeParams params);

  /// Obtener todos los matches del usuario
  Future<Either<Failure, List<Match>>> getUserMatches();

  /// Obtener todos los swipes hechos por el usuario
  Future<Either<Failure, List<Swipe>>> getUserSwipes();

  /// Obtener swipes recibidos de otros usuarios
  Future<Either<Failure, List<Swipe>>> getReceivedSwipes();

  /// Desbloquear un match (reveal)
  Future<Either<Failure, Match>> unlockMatch(String matchId);

  /// Obtener detalles de un match
  Future<Either<Failure, Match>> getMatchDetails(String matchId);
}
