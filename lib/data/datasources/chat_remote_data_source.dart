import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/domain/entities/chat_entity.dart';

/// Interface abstracta para datasource de chat
abstract class ChatRemoteDataSource {
  Future<List<ConversationPreview>> getConversations();
  Future<List<Message>> getMessages(String conversationId);
  Future<Message> sendMessage(SendMessageParams params);
  Future<Conversation> getOrCreateConversation(CreateConversationParams params);
  Future<void> markMessagesAsRead(String conversationId);
  Future<Message> getMessage(String messageId);
  Future<Conversation> getConversationDetails(String conversationId);
  Stream<Message> subscribeToMessages(String conversationId);
  Stream<ConversationPreview> subscribeToConversations();
}

/// Implementación con Supabase
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseService supabaseService;

  ChatRemoteDataSourceImpl(this.supabaseService);

  @override
  Future<List<ConversationPreview>> getConversations() async {
    try {
      final myProfileId = await supabaseService.getProfileId();
      if (myProfileId == null) return [];

      // getConversations devuelve conversation_participants con relaciones anidadas:
      // { id, conversation: { id, is_group, created_at, messages: [...], group: {...} } }
      final rawConversations =
          await supabaseService.getConversations(myProfileId);

      final List<ConversationPreview> previews = [];

      for (final cp in rawConversations) {
        try {
          final conv = cp['conversation'];
          if (conv == null) continue;

          final convId = conv['id']?.toString() ?? '';
          final isGroup = conv['is_group'] == true;
          final messages = conv['messages'] as List? ?? [];

          // Obtener último mensaje
          String lastMessage = '';
          DateTime lastMessageTime = DateTime.now();
          if (messages.isNotEmpty) {
            final sortedMessages = [...messages]..sort((a, b) {
                final aTime =
                    DateTime.tryParse(a['created_at']?.toString() ?? '') ??
                        DateTime.fromMillisecondsSinceEpoch(0);
                final bTime =
                    DateTime.tryParse(b['created_at']?.toString() ?? '') ??
                        DateTime.fromMillisecondsSinceEpoch(0);
                return aTime.compareTo(bTime);
              });
            final lastMsg = sortedMessages.last;
            lastMessage = lastMsg['content']?.toString() ?? '';
            lastMessageTime =
                DateTime.tryParse(lastMsg['created_at']?.toString() ?? '') ??
                    DateTime.now();
          }

          // Para conversación 1-a-1, buscar el otro participante
          String otherUserId = '';
          String otherUserName = 'Usuario';
          String? otherUserAvatar;
          bool otherUserIsOnline = false;

          if (!isGroup) {
            // Obtener los participantes de esta conversación para encontrar al otro
            try {
              final participants = await supabaseService.client
                  .from('conversation_participants')
                  .select(
                      'user_id, user:users(id, nickname, avatar_url, is_online)')
                  .eq('conversation_id', convId)
                  .neq('user_id', myProfileId);

              if (participants.isNotEmpty) {
                final otherUser = participants.first['user'];
                if (otherUser != null) {
                  otherUserId = otherUser['id']?.toString() ?? '';
                  otherUserName =
                      otherUser['nickname']?.toString() ?? 'Usuario';
                  otherUserAvatar = otherUser['avatar_url']?.toString();
                  otherUserIsOnline = otherUser['is_online'] == true;
                }
              }
            } catch (_) {}
          } else {
            // Grupo
            final group = conv['group'];
            if (group != null) {
              otherUserName = group['name']?.toString() ?? 'Grupo';
            }
          }

          previews.add(ConversationPreview(
            id: convId,
            otherUserId: otherUserId,
            otherUserName: otherUserName,
            otherUserAvatar: otherUserAvatar,
            otherUserIsOnline: otherUserIsOnline,
            lastMessage: lastMessage,
            lastMessageTime: lastMessageTime,
            unreadCount: 0, // TODO: calcular mensajes no leídos
            isGroup: isGroup,
          ));
        } catch (e) {
          print('DEBUG: Error procesando conversación: $e');
          continue;
        }
      }

      // Ordenar por último mensaje
      previews.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

      return previews;
    } catch (e) {
      print('DEBUG: Error getting conversations: $e');
      throw Exception('Error getting conversations: ${e.toString()}');
    }
  }

  @override
  Future<List<Message>> getMessages(String conversationId) async {
    try {
      // getMessages devuelve: { id, conversation_id, sender_id, content, created_at, sender: { id, nickname, avatar_url } }
      final messages = await supabaseService.getMessages(conversationId);

      return messages.map((msg) {
        final sender = msg['sender'];
        return Message(
          id: msg['id']?.toString() ?? '',
          conversationId: msg['conversation_id']?.toString() ?? '',
          senderId: msg['sender_id']?.toString() ?? '',
          content: msg['content']?.toString() ?? '',
          createdAt: DateTime.tryParse(msg['created_at']?.toString() ?? '') ??
              DateTime.now(),
          editedAt: msg['edited_at'] != null
              ? DateTime.tryParse(msg['edited_at'].toString())
              : null,
          isRead: msg['is_read'] ?? false,
          senderName: sender?['nickname']?.toString(),
          senderAvatar: sender?['avatar_url']?.toString(),
        );
      }).toList();
    } catch (e) {
      print('DEBUG: Error getting messages: $e');
      throw Exception('Error getting messages: ${e.toString()}');
    }
  }

  @override
  Future<Message> sendMessage(SendMessageParams params) async {
    try {
      // sendMessage inserta usando profileId como sender_id y devuelve la fila creada.
      final lastMsg = await supabaseService.sendMessage(
        conversationId: params.conversationId,
        content: params.content,
      );
      final sender = lastMsg['sender'];

      return Message(
        id: lastMsg['id']?.toString() ?? '',
        conversationId: lastMsg['conversation_id']?.toString() ?? '',
        senderId: lastMsg['sender_id']?.toString() ?? '',
        content: lastMsg['content']?.toString() ?? '',
        createdAt: DateTime.tryParse(lastMsg['created_at']?.toString() ?? '') ??
            DateTime.now(),
        editedAt: null,
        isRead: true,
        senderName: sender?['nickname']?.toString(),
        senderAvatar: sender?['avatar_url']?.toString(),
      );
    } catch (e) {
      print('DEBUG: Error sending message: $e');
      throw Exception('Error sending message: ${e.toString()}');
    }
  }

  @override
  Future<Conversation> getOrCreateConversation(
      CreateConversationParams params) async {
    try {
      final conversationId = await supabaseService.getOrCreateConversation(
        params.otherUserId,
      );

      return Conversation(
        id: conversationId,
        isGroup: false,
        groupId: null,
        createdAt: DateTime.now(),
        updatedAt: null,
        unreadCount: 0,
      );
    } catch (e) {
      print('DEBUG: Error creating conversation: $e');
      throw Exception('Error creating conversation: ${e.toString()}');
    }
  }

  @override
  Future<void> markMessagesAsRead(String conversationId) async {
    // Mark messages as read - update last_read_at en conversation_participants
    try {
      final myProfileId = await supabaseService.getProfileId();
      if (myProfileId == null) return;

      await supabaseService.client
          .from('conversation_participants')
          .update({'last_read_at': DateTime.now().toIso8601String()})
          .eq('conversation_id', conversationId)
          .eq('user_id', myProfileId);
    } catch (e) {
      print('DEBUG: Error marking messages as read: $e');
    }
  }

  @override
  Future<Message> getMessage(String messageId) async {
    try {
      final response = await supabaseService.client
          .from('messages')
          .select('*, sender:users(id, nickname, avatar_url)')
          .eq('id', messageId)
          .single();

      final sender = response['sender'];
      return Message(
        id: response['id']?.toString() ?? '',
        conversationId: response['conversation_id']?.toString() ?? '',
        senderId: response['sender_id']?.toString() ?? '',
        content: response['content']?.toString() ?? '',
        createdAt:
            DateTime.tryParse(response['created_at']?.toString() ?? '') ??
                DateTime.now(),
        editedAt: response['edited_at'] != null
            ? DateTime.tryParse(response['edited_at'].toString())
            : null,
        isRead: response['is_read'] ?? false,
        senderName: sender?['nickname']?.toString(),
        senderAvatar: sender?['avatar_url']?.toString(),
      );
    } catch (e) {
      throw Exception('Error getting message: ${e.toString()}');
    }
  }

  @override
  Future<Conversation> getConversationDetails(String conversationId) async {
    try {
      final response = await supabaseService.client
          .from('conversations')
          .select()
          .eq('id', conversationId)
          .single();

      return Conversation(
        id: response['id']?.toString() ?? '',
        isGroup: response['is_group'] == true,
        groupId: response['group_id']?.toString(),
        createdAt:
            DateTime.tryParse(response['created_at']?.toString() ?? '') ??
                DateTime.now(),
        updatedAt: response['updated_at'] != null
            ? DateTime.tryParse(response['updated_at'].toString())
            : null,
        unreadCount: 0,
      );
    } catch (e) {
      throw Exception('Error getting conversation details: ${e.toString()}');
    }
  }

  @override
  Stream<Message> subscribeToMessages(String conversationId) {
    try {
      return supabaseService.subscribeToMessages(conversationId).map((payload) {
        return Message(
          id: payload['id']?.toString() ?? '',
          conversationId: payload['conversation_id']?.toString() ?? '',
          senderId: payload['sender_id']?.toString() ?? '',
          content: payload['content']?.toString() ?? '',
          createdAt:
              DateTime.tryParse(payload['created_at']?.toString() ?? '') ??
                  DateTime.now(),
          editedAt: null,
          isRead: false,
          senderName: null, // Realtime payload doesn't include joined data
          senderAvatar: null,
        );
      });
    } catch (e) {
      throw Exception('Error subscribing to messages: ${e.toString()}');
    }
  }

  @override
  Stream<ConversationPreview> subscribeToConversations() {
    // Not strictly needed — the list refreshes on tab change
    throw UnimplementedError('subscribeToConversations not implemented');
  }
}
