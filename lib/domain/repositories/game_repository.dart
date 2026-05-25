import '../entities/game_entity.dart';

abstract class GameRepository {
  Future<List<GameEntity>> getAllGames();
  Future<void> addUserGame({
    required String userId,
    required String gameId,
    required String primaryRank,
  });
}
