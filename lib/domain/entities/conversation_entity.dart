// Conversation Entity
class ConversationEntity {
  final String id;
  final String participantId;
  final String groupName;
  final bool isGroup;
  final DateTime lastMessageAt;
  final int unreadCount;

  ConversationEntity({
    required this.id,
    required this.participantId,
    required this.groupName,
    required this.isGroup,
    required this.lastMessageAt,
    required this.unreadCount,
  });
}
