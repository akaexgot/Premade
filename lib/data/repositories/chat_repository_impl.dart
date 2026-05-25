import 'package:fpdart/fpdart.dart';
import 'package:premade/core/errors/failures.dart';
import 'package:premade/data/datasources/chat_remote_data_source.dart';
import 'package:premade/domain/entities/chat_entity.dart';
import 'package:premade/domain/repositories/chat_repository.dart';

/// Implementación del repositorio de chat con error handling
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ConversationPreview>>> getConversations() async {
    try {
      final conversations = await remoteDataSource.getConversations();
      return Right(conversations);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error al cargar conversaciones: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(String conversationId) async {
    try {
      final messages = await remoteDataSource.getMessages(conversationId);
      return Right(messages);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error al cargar mensajes: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage(SendMessageParams params) async {
    try {
      final message = await remoteDataSource.sendMessage(params);
      return Right(message);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error al enviar mensaje: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Conversation>> getOrCreateConversation(
    CreateConversationParams params,
  ) async {
    try {
      final conversation = await remoteDataSource.getOrCreateConversation(params);
      return Right(conversation);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error al crear conversación: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead(String conversationId) async {
    try {
      await remoteDataSource.markMessagesAsRead(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error al marcar como leído: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Message>> getMessage(String messageId) async {
    try {
      final message = await remoteDataSource.getMessage(messageId);
      return Right(message);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error al obtener mensaje: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Conversation>> getConversationDetails(
    String conversationId,
  ) async {
    try {
      final conversation = await remoteDataSource.getConversationDetails(conversationId);
      return Right(conversation);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error al obtener detalles: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<Message> subscribeToMessages(String conversationId) {
    return remoteDataSource.subscribeToMessages(conversationId);
  }

  @override
  Stream<ConversationPreview> subscribeToConversations() {
    return remoteDataSource.subscribeToConversations();
  }
}
