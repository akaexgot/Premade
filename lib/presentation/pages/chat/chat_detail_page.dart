import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:premade/application/providers/auth_providers.dart';
import 'package:premade/application/providers/chat_providers.dart';
import 'package:premade/core/theme/app_colors.dart';
import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/domain/entities/chat_entity.dart';

/// ChatDetailPage: Conversación individual con mensajes en tiempo real
class ChatDetailPage extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatDetailPage({
    Key? key,
    required this.conversationId,
  }) : super(key: key);

  @override
  ConsumerState<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage> {
  late TextEditingController _messageController;
  String? _myProfileId;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();

    Future.microtask(() async {
      // Obtener el profile ID real para comparar con sender_id de los mensajes
      final supabase = ref.read(supabaseServiceProvider);
      _myProfileId = await supabase.getProfileId();

      ref.read(messagesProvider(widget.conversationId).notifier)
          .loadMessages(widget.conversationId);
      ref.read(selectedConversationIdProvider.notifier).state =
          widget.conversationId;

      // Marcar como leídos al entrar
      try {
        final markAsRead = ref.read(markMessagesAsReadUseCaseProvider);
        await markAsRead(widget.conversationId);
      } catch (_) {}

      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authUserProvider);
    final messages = ref.watch(messagesProvider(widget.conversationId));
    final isSending = ref.watch(sendingMessageProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = theme.colorScheme.onSurface;

    // Suscribirse a mensajes en tiempo real
    ref.listen(
      messagesStreamProvider(widget.conversationId),
      (previous, next) {
        next.whenData((message) {
          // Solo añadir si no es nuestro propio mensaje
          if (message.senderId != _myProfileId) {
            ref.read(messagesProvider(widget.conversationId).notifier)
                .receiveMessage(message);
          }
        });
      },
    );

    if (authUser == null) {
      Future.microtask(() => context.go('/login'));
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Conversación',
            style: TextStyle(
                color: textPrimary, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message =
                          messages[messages.length - 1 - index];
                      // Comparar sender_id con profileId, NO con authUser.id
                      final isCurrentUser =
                          message.senderId == _myProfileId;

                      return Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: _buildMessageBubble(
                            message, isCurrentUser, theme, isDark),
                      );
                    },
                  ),
          ),

          // Input de mensaje
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                    color: isDark
                        ? const Color(0xFF2A2A45)
                        : AppColors.grey200),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                              color: isDark
                                  ? const Color(0xFF2A2A45)
                                  : AppColors.grey200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                              color: isDark
                                  ? const Color(0xFF2A2A45)
                                  : AppColors.grey200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1E1E36)
                            : AppColors.grey50,
                      ),
                      maxLines: null,
                      enabled: !isSending,
                      onSubmitted: (_) {
                        if (!isSending) _sendMessage();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white,
                          size: 20),
                      onPressed: isSending ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      Message message, bool isCurrentUser, ThemeData theme, bool isDark) {
    final bubbleColor = isCurrentUser
        ? AppColors.primary
        : (isDark ? const Color(0xFF222240) : AppColors.grey100);
    final textColor =
        isCurrentUser ? Colors.white : theme.colorScheme.onSurface;
    final timeColor =
        isCurrentUser ? Colors.white70 : theme.textTheme.bodySmall?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Nombre del remitente (solo para mensajes de otros)
          if (!isCurrentUser && message.senderName != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(
                message.senderName!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.content,
                  style: TextStyle(color: textColor, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatMessageTime(message.createdAt),
                  style: TextStyle(color: timeColor, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64,
              color: theme.textTheme.bodySmall?.color),
          const SizedBox(height: 16),
          Text('Comienza la conversación',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface)),
          const SizedBox(height: 8),
          Text('Sé el primero en escribir',
              style: TextStyle(
                  fontSize: 15,
                  color: theme.textTheme.bodyMedium?.color)),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    ref.read(sendingMessageProvider.notifier).state = true;

    try {
      final sendMessageUseCase = ref.read(sendMessageUseCaseProvider);
      final result = await sendMessageUseCase(
        SendMessageParams(
          conversationId: widget.conversationId,
          content: _messageController.text.trim(),
        ),
      );

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          }
        },
        (message) {
          ref.read(messagesProvider(widget.conversationId).notifier)
              .addMessage(message);
          _messageController.clear();
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar: $e')),
        );
      }
    } finally {
      ref.read(sendingMessageProvider.notifier).state = false;
    }
  }

  String _formatMessageTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
