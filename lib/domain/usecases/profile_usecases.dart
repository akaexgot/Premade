import 'package:fpdart/fpdart.dart';
import 'package:premade/core/errors/failure.dart';
import 'package:premade/domain/entities/user_profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile(String userId);
  Future<Either<Failure, UserProfile>> updateProfile(UpdateProfileParams params);
  Future<Either<Failure, String>> uploadAvatar(UploadAvatarParams params);
  Future<Either<Failure, void>> addUserGame(AddUserGameParams params);
  Future<Either<Failure, List<UserGameSelection>>> getUserGames(String userId);
  Future<Either<Failure, void>> removeUserGame(String gameId);
  Future<Either<Failure, void>> updateUserGame(AddUserGameParams params);
  Future<Either<Failure, List<Map<String, dynamic>>>> getGamesList();
  Future<Either<Failure, List<Map<String, dynamic>>>> getGameRoles(String gameId);
  Future<Either<Failure, List<Map<String, dynamic>>>> getGameRanks(String gameId);
}

class GetUserProfileUseCase {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<Either<Failure, UserProfile>> call(String userId) {
    return repository.getUserProfile(userId);
  }
}

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, UserProfile>> call(UpdateProfileParams params) {
    return repository.updateProfile(params);
  }
}

class UploadAvatarUseCase {
  final ProfileRepository repository;

  UploadAvatarUseCase(this.repository);

  Future<Either<Failure, String>> call(UploadAvatarParams params) {
    return repository.uploadAvatar(params);
  }
}

class AddUserGameUseCase {
  final ProfileRepository repository;

  AddUserGameUseCase(this.repository);

  Future<Either<Failure, void>> call(AddUserGameParams params) {
    return repository.addUserGame(params);
  }
}

class GetUserGamesUseCase {
  final ProfileRepository repository;

  GetUserGamesUseCase(this.repository);

  Future<Either<Failure, List<UserGameSelection>>> call(String userId) {
    return repository.getUserGames(userId);
  }
}

class RemoveUserGameUseCase {
  final ProfileRepository repository;

  RemoveUserGameUseCase(this.repository);

  Future<Either<Failure, void>> call(String gameId) {
    return repository.removeUserGame(gameId);
  }
}

class UpdateUserGameUseCase {
  final ProfileRepository repository;

  UpdateUserGameUseCase(this.repository);

  Future<Either<Failure, void>> call(AddUserGameParams params) {
    return repository.updateUserGame(params);
  }
}

class GetGamesListUseCase {
  final ProfileRepository repository;

  GetGamesListUseCase(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call() {
    return repository.getGamesList();
  }
}

class GetGameRolesUseCase {
  final ProfileRepository repository;

  GetGameRolesUseCase(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(String gameId) {
    return repository.getGameRoles(gameId);
  }
}

class GetGameRanksUseCase {
  final ProfileRepository repository;

  GetGameRanksUseCase(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(String gameId) {
    return repository.getGameRanks(gameId);
  }
}
