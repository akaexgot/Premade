import 'package:fpdart/fpdart.dart';
import 'package:premade/core/errors/failure.dart';
import 'package:premade/domain/entities/auth_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> signUp(SignUpParams params);
  Future<Either<Failure, AuthResponse>> signIn(SignInParams params);
  Future<Either<Failure, AuthResponse>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> resetPassword(ResetPasswordParams params);
  Future<Either<Failure, AuthUser?>> getCurrentUser();
  Future<Either<Failure, bool>> isUserAuthenticated();
}

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call(SignUpParams params) {
    return repository.signUp(params);
  }
}

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call(SignInParams params) {
    return repository.signIn(params);
  }
}

class SignInWithGoogleUseCase {
  final AuthRepository repository;

  SignInWithGoogleUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call() {
    return repository.signInWithGoogle();
  }
}

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.signOut();
  }
}

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(ResetPasswordParams params) {
    return repository.resetPassword(params);
  }
}

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, AuthUser?>> call() {
    return repository.getCurrentUser();
  }
}

class IsUserAuthenticatedUseCase {
  final AuthRepository repository;

  IsUserAuthenticatedUseCase(this.repository);

  Future<Either<Failure, bool>> call() {
    return repository.isUserAuthenticated();
  }
}
