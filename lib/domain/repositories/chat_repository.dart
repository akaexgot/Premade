import 'package:fpdart/fpdart.dart';
import 'package:premade/core/errors/failures.dart';
import 'package:premade/domain/entities/chat_entity.dart';

/// Interface abstracta para repositorio de chat
abstract class ChatRepository {
  /// Obtener conversaciones del usuario actual
  Future<Either<Failure, List<ConversationPreview>>> getConversations();

  /// Obtener mensajes de una conversación específica
  Future<Either<Failure, List<Message>>> getMessages(String conversationId);

  /// Enviar un mensaje
  Future<Either<Failure, Message>> sendMessage(SendMessageParams params);

  /// Obtener o crear conversación 1-a-1
  Future<Either<Failure, Conversation>> getOrCreateConversation(
    CreateConversationParams params,
  );

  /// Marcar mensajes como leídos
  Future<Either<Failure, void>> markMessagesAsRead(String conversationId);

  /// Obtener mensaje específico
  Future<Either<Failure, Message>> getMessage(String messageId);

  /// Obtener detalles de conversación
  Future<Either<Failure, Conversation>> getConversationDetails(
    String conversationId,
  );

  /// Suscribirse a actualizaciones de mensajes en tiempo real
  Stream<Message> subscribeToMessages(String conversationId);

  /// Suscribirse a cambios en conversaciones
  Stream<ConversationPreview> subscribeToConversations();
}
