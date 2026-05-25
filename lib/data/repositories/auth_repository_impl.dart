import 'package:fpdart/fpdart.dart';
import 'package:premade/core/errors/failures.dart';
import 'package:premade/data/datasources/auth_remote_data_source.dart';
import 'package:premade/domain/entities/auth_entity.dart';
import 'package:premade/domain/usecases/auth_usecases.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, AuthResponse>> signUp(SignUpParams params) async {
    try {
      final response = await remoteDataSource.signUp(params);
      return Right(response);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al registrarse: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> signIn(SignInParams params) async {
    try {
      final response = await remoteDataSource.signIn(params);
      return Right(response);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al iniciar sesión: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> signInWithGoogle() async {
    try {
      final response = await remoteDataSource.signInWithGoogle();
      return Right(response);
    } on Exception catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al iniciar sesión con Google: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on Exception catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al cerrar sesión: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(
      ResetPasswordParams params) async {
    try {
      await remoteDataSource.resetPassword(params);
      return const Right(null);
    } on Exception catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al resetear contraseña: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AuthUser?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on Exception catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al obtener usuario actual: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isUserAuthenticated() async {
    try {
      final isAuthenticated = await remoteDataSource.isUserAuthenticated();
      return Right(isAuthenticated);
    } on Exception catch (e) {
      return Left(
        ServerFailure(
          message: 'Error al verificar autenticación: ${e.toString()}',
        ),
      );
    }
  }
}
