import 'package:fpdart/fpdart.dart';
import 'package:premade/core/errors/failures.dart';
import 'package:premade/data/datasources/matching_remote_data_source.dart';
import 'package:premade/domain/entities/matching_entity.dart';
import 'package:premade/domain/repositories/matching_repository.dart';

/// Implementación del repositorio de matching con error handling
class MatchingRepositoryImpl implements MatchingRepository {
  final MatchingRemoteDataSource remoteDataSource;

  MatchingRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<MatchCard>>> getMatchCandidates() async {
    try {
      final candidates = await remoteDataSource.getMatchCandidates();
      return Right(candidates);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al cargar candidatos de match: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, SwipeResult>> createSwipe(
      CreateSwipeParams params) async {
    try {
      final result = await remoteDataSource.createSwipe(params);
      return Right(result);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al hacer swipe: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Match>>> getUserMatches() async {
    try {
      final matches = await remoteDataSource.getUserMatches();
      return Right(matches);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al cargar matches: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Swipe>>> getUserSwipes() async {
    try {
      final swipes = await remoteDataSource.getUserSwipes();
      return Right(swipes);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al cargar swipes: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Swipe>>> getReceivedSwipes() async {
    try {
      final swipes = await remoteDataSource.getReceivedSwipes();
      return Right(swipes);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al cargar swipes recibidos: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Match>> unlockMatch(String matchId) async {
    try {
      final match = await remoteDataSource.unlockMatch(matchId);
      return Right(match);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al desbloquear match: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Match>> getMatchDetails(String matchId) async {
    try {
      final match = await remoteDataSource.getMatchDetails(matchId);
      return Right(match);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al cargar detalles del match: ${e.toString()}',
        ),
      );
    }
  }
}
