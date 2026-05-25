import 'package:fpdart/fpdart.dart';
import 'package:premade/core/errors/failures.dart';
import 'package:premade/domain/entities/chat_entity.dart';
import 'package:premade/domain/repositories/chat_repository.dart';

/// Obtener conversaciones del usuario
class GetConversationsUseCase {
  final ChatRepository repository;

  GetConversationsUseCase(this.repository);

  Future<Either<Failure, List<ConversationPreview>>> call() {
    return repository.getConversations();
  }
}

/// Obtener mensajes de una conversación
class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  Future<Either<Failure, List<Message>>> call(String conversationId) {
    return repository.getMessages(conversationId);
  }
}

/// Enviar mensaje
class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, Message>> call(SendMessageParams params) {
    return repository.sendMessage(params);
  }
}

/// Crear conversación 1-a-1 o obtener si ya existe
class GetOrCreateConversationUseCase {
  final ChatRepository repository;

  GetOrCreateConversationUseCase(this.repository);

  Future<Either<Failure, Conversation>> call(CreateConversationParams params) {
    return repository.getOrCreateConversation(params);
  }
}

/// Marcar mensajes como leídos
class MarkMessagesAsReadUseCase {
  final ChatRepository repository;

  MarkMessagesAsReadUseCase(this.repository);

  Future<Either<Failure, void>> call(String conversationId) {
    return repository.markMessagesAsRead(conversationId);
  }
}

/// Obtener un mensaje específico
class GetMessageUseCase {
  final ChatRepository repository;

  GetMessageUseCase(this.repository);

  Future<Either<Failure, Message>> call(String messageId) {
    return repository.getMessage(messageId);
  }
}

/// Obtener detalles de una conversación
class GetConversationDetailsUseCase {
  final ChatRepository repository;

  GetConversationDetailsUseCase(this.repository);

  Future<Either<Failure, Conversation>> call(String conversationId) {
    return repository.getConversationDetails(conversationId);
  }
}
