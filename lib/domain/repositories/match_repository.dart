import '../entities/match_entity.dart';

abstract class MatchRepository {
  Future<List<MatchEntity>> getMatches(String userId);
  Future<void> swipeUser({
    required String userId,
    required String targetUserId,
    required bool isLike,
  });
}
