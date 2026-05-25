import 'package:fpdart/fpdart.dart';
import 'package:premade/core/errors/failures.dart';
import 'package:premade/data/datasources/profile_remote_data_source.dart';
import 'package:premade/domain/entities/user_profile_entity.dart';
import 'package:premade/domain/usecases/profile_usecases.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String userId) async {
    try {
      final profile = await remoteDataSource.getUserProfile(userId);
      return Right(profile);
    } on Exception catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al obtener perfil: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile(
      UpdateProfileParams params) async {
    try {
      final profile = await remoteDataSource.updateProfile(params);
      return Right(profile);
    } on Exception catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al actualizar perfil: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(
      UploadAvatarParams params) async {
    try {
      final avatarUrl = await remoteDataSource.uploadAvatar(params);
      return Right(avatarUrl);
    } on Exception catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al subir avatar: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> addUserGame(AddUserGameParams params) async {
    try {
      await remoteDataSource.addUserGame(params);
      return const Right(null);
    } on Exception catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al agregar juego: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<UserGameSelection>>> getUserGames(
      String userId) async {
    try {
      final games = await remoteDataSource.getUserGames(userId);
      return Right(games);
    } on Exception catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al obtener juegos: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> removeUserGame(String gameId) async {
    try {
      await remoteDataSource.removeUserGame(gameId);
      return const Right(null);
    } on Exception catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al eliminar juego: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateUserGame(AddUserGameParams params) async {
    try {
      await remoteDataSource.updateUserGame(params);
      return const Right(null);
    } on Exception catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al actualizar juego: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getGamesList() async {
    try {
      final games = await remoteDataSource.getGamesList();
      return Right(games);
    } on Exception catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al obtener lista de juegos: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getGameRoles(
      String gameId) async {
    try {
      final roles = await remoteDataSource.getGameRoles(gameId);
      return Right(roles);
    } on Exception catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al obtener roles: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getGameRanks(
      String gameId) async {
    try {
      final ranks = await remoteDataSource.getGameRanks(gameId);
      return Right(ranks);
    } on Exception catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al obtener rangos: ${e.toString()}',
        ),
      );
    }
  }
}
