// Conversation Model
class ConversationModel {
  final String id;
  final String participantId;
  final String groupName;
  final bool isGroup;
  final DateTime lastMessageAt;
  final int unreadCount;

  ConversationModel({
    required this.id,
    required this.participantId,
    required this.groupName,
    required this.isGroup,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      participantId: json['participant_id'],
      groupName: json['group_name'],
      isGroup: json['is_group'],
      lastMessageAt: DateTime.parse(json['last_message_at']),
      unreadCount: json['unread_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_id': participantId,
      'group_name': groupName,
      'is_group': isGroup,
      'last_message_at': lastMessageAt.toIso8601String(),
      'unread_count': unreadCount,
    };
  }
}
