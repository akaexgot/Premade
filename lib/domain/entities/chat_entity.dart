import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_entity.freezed.dart';

/// Conversación entre usuarios o grupo
@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required bool isGroup,
    required String? groupId, // Si es grupal
    required DateTime createdAt,
    required DateTime? updatedAt,
    required int unreadCount, // Mensajes no leídos
  }) = _Conversation;
}

/// Participante de una conversación
@freezed
class ConversationParticipant with _$ConversationParticipant {
  const factory ConversationParticipant({
    required String id,
    required String conversationId,
    required String userId,
    required DateTime joinedAt,
    required DateTime? lastReadAt, // Último mensaje leído
  }) = _ConversationParticipant;
}

/// Mensaje en una conversación
@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String conversationId,
    required String senderId,
    required String content,
    required DateTime createdAt,
    required DateTime? editedAt,
    required bool isRead,
    String? senderName, // Cached para UI
    String? senderAvatar, // Cached para UI
  }) = _Message;
}

/// Vista resumida de conversación para lista
@freezed
class ConversationPreview with _$ConversationPreview {
  const factory ConversationPreview({
    required String id,
    required String otherUserId, // Otro usuario (1-a-1)
    required String otherUserName,
    required String? otherUserAvatar,
    required bool otherUserIsOnline,
    required String lastMessage,
    required DateTime lastMessageTime,
    required int unreadCount,
    required bool isGroup, // Para diferenciar en UI
  }) = _ConversationPreview;
}

/// Parámetros para enviar mensaje
@freezed
class SendMessageParams with _$SendMessageParams {
  const factory SendMessageParams({
    required String conversationId,
    required String content,
  }) = _SendMessageParams;
}

/// Parámetros para crear conversación 1-a-1
@freezed
class CreateConversationParams with _$CreateConversationParams {
  const factory CreateConversationParams({
    required String otherUserId,
  }) = _CreateConversationParams;
}
