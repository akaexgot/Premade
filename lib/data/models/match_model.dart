// Match Model
class MatchModel {
  final String id;
  final String userId;
  final String targetUserId;
  final DateTime createdAt;

  MatchModel({
    required this.id,
    required this.userId,
    required this.targetUserId,
    required this.createdAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'],
      userId: json['user_id'],
      targetUserId: json['target_user_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'target_user_id': targetUserId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
