import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:premade/application/providers/auth_providers.dart';
import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/core/errors/failures.dart';
import 'package:premade/data/datasources/chat_remote_data_source.dart';
import 'package:premade/data/repositories/chat_repository_impl.dart';
import 'package:premade/domain/entities/chat_entity.dart';
import 'package:premade/domain/repositories/chat_repository.dart';
import 'package:premade/domain/usecases/chat_usecases.dart';

// ============ DEPENDENCY INJECTION PROVIDERS ============

/// Data source para chat
final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return ChatRemoteDataSourceImpl(supabaseService);
});

/// Repository para chat
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dataSource = ref.watch(chatRemoteDataSourceProvider);
  return ChatRepositoryImpl(dataSource);
});

/// Use cases
final getConversationsUseCaseProvider = Provider<GetConversationsUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return GetConversationsUseCase(repository);
});

final getMessagesUseCaseProvider = Provider<GetMessagesUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return GetMessagesUseCase(repository);
});

final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return SendMessageUseCase(repository);
});

final getOrCreateConversationUseCaseProvider = Provider<GetOrCreateConversationUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return GetOrCreateConversationUseCase(repository);
});

final markMessagesAsReadUseCaseProvider = Provider<MarkMessagesAsReadUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return MarkMessagesAsReadUseCase(repository);
});

final getMessageUseCaseProvider = Provider<GetMessageUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return GetMessageUseCase(repository);
});

final getConversationDetailsUseCaseProvider = Provider<GetConversationDetailsUseCase>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return GetConversationDetailsUseCase(repository);
});

// ============ STATE NOTIFIERS ============

/// State notifier para lista de conversaciones
class ConversationsNotifier extends StateNotifier<List<ConversationPreview>> {
  final GetConversationsUseCase getConversationsUseCase;

  ConversationsNotifier(this.getConversationsUseCase) : super([]);

  /// Cargar conversaciones
  Future<void> loadConversations() async {
    final result = await getConversationsUseCase();
    result.fold(
      (failure) => state = [],
      (conversations) => state = conversations,
    );
  }

  /// Agregar conversación nueva
  void addConversation(ConversationPreview conversation) {
    state = [conversation, ...state];
  }
}

/// State notifier para mensajes de una conversación
class MessagesNotifier extends StateNotifier<List<Message>> {
  final GetMessagesUseCase getMessagesUseCase;
  late String currentConversationId;

  MessagesNotifier(this.getMessagesUseCase) : super([]);

  /// Cargar mensajes de una conversación
  Future<void> loadMessages(String conversationId) async {
    currentConversationId = conversationId;
    final result = await getMessagesUseCase(conversationId);
    result.fold(
      (failure) => state = [],
      (messages) => state = messages,
    );
  }

  /// Agregar mensaje recién enviado
  void addMessage(Message message) {
    state = [...state, message];
  }

  /// Agregar mensaje recibido (via realtime)
  void receiveMessage(Message message) {
    if (message.conversationId == currentConversationId) {
      state = [...state, message];
    }
  }

  /// Limpiar mensajes
  void clearMessages() {
    state = [];
  }
}

// ============ STATE PROVIDERS ============

/// Provider para conversaciones
final conversationsProvider = StateNotifierProvider<ConversationsNotifier, List<ConversationPreview>>((ref) {
  final useCase = ref.watch(getConversationsUseCaseProvider);
  return ConversationsNotifier(useCase);
});

/// Provider para mensajes de conversación actual
final messagesProvider = StateNotifierProvider.family<MessagesNotifier, List<Message>, String>((ref, conversationId) {
  final useCase = ref.watch(getMessagesUseCaseProvider);
  return MessagesNotifier(useCase);
});

/// Provider para conversaciones con FutureProvider
final conversationsFutureProvider = FutureProvider<List<ConversationPreview>>((ref) async {
  final useCase = ref.watch(getConversationsUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => [],
    (conversations) => conversations,
  );
});

/// Provider para mensajes con FutureProvider
final messagesFutureProvider = FutureProvider.family<List<Message>, String>((ref, conversationId) async {
  final useCase = ref.watch(getMessagesUseCaseProvider);
  final result = await useCase(conversationId);
  return result.fold(
    (failure) => [],
    (messages) => messages,
  );
});

/// Provider para stream de mensajes en tiempo real
final messagesStreamProvider = StreamProvider.family<Message, String>((ref, conversationId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.subscribeToMessages(conversationId);
});

// ============ LOADING & ERROR PROVIDERS ============

/// Provider para estado de carga del chat
final chatLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider para errores del chat
final chatErrorProvider = StateProvider<String?>((ref) => null);

/// Provider para estado de envío de mensaje
final sendingMessageProvider = StateProvider<bool>((ref) => false);

/// Provider para conversación seleccionada actualmente
final selectedConversationIdProvider = StateProvider<String?>((ref) => null);
