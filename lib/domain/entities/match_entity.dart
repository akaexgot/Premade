// Match Entity
class MatchEntity {
  final String id;
  final String userId;
  final String targetUserId;
  final DateTime createdAt;

  MatchEntity({
    required this.id,
    required this.userId,
    required this.targetUserId,
    required this.createdAt,
  });
}
