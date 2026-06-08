import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:premade/application/providers/auth_providers.dart';
import 'package:premade/application/providers/chat_providers.dart';
import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/core/widgets/safe_network_avatar.dart';
import 'package:premade/domain/entities/chat_entity.dart';

/// ChatDetailPage: Conversación individual con mensajes en tiempo real
class ChatDetailPage extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatDetailPage({
    super.key,
    required this.conversationId,
  });

  @override
  ConsumerState<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage> {
  late TextEditingController _messageController;
  String? _myProfileId;
  Map<String, dynamic>? _conversationPeer;
  String _conversationTitle = 'Conversacion';
  String? _conversationAvatarUrl;
  bool _conversationIsOnline = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();

    // Cargar mensajes
    Future.microtask(() async {
      final supabase = ref.read(supabaseServiceProvider);
      final profileId = await supabase.getProfileId();
      if (mounted) {
        setState(() => _myProfileId = profileId);
      }
      await _loadConversationHeader();
      ref
          .read(messagesProvider(widget.conversationId).notifier)
          .loadMessages(widget.conversationId);
      await ref
          .read(markMessagesAsReadUseCaseProvider)
          .call(widget.conversationId);
      ref.read(selectedConversationIdProvider.notifier).state =
          widget.conversationId;
    });
  }

  Future<void> _loadConversationHeader() async {
    try {
      final supabase = ref.read(supabaseServiceProvider);
      final peer = await supabase.getConversationPeer(widget.conversationId);
      if (!mounted || peer == null) return;

      setState(() {
        _conversationPeer = peer;
        _conversationTitle = peer['nickname']?.toString() ?? 'Usuario';
        _conversationAvatarUrl = peer['avatar_url']?.toString();
        _conversationIsOnline = peer['is_online'] == true;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    ref.read(selectedConversationIdProvider.notifier).state = null;
    _messageController.dispose();
    super.dispose();
  }

  void _openPeerProfile() {
    final peerId = _conversationPeer?['id']?.toString();
    if (peerId == null || peerId.isEmpty) return;
    context.push('/public-profile/$peerId', extra: _conversationPeer);
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authUserProvider);
    final messages = ref.watch(messagesProvider(widget.conversationId));
    final isSending = ref.watch(sendingMessageProvider);

    // Suscribirse a mensajes en tiempo real
    ref.listen(
      messagesStreamProvider(widget.conversationId),
      (previous, next) {
        next.whenData((message) {
          if (message.senderId != _myProfileId) {
            ref
                .read(messagesProvider(widget.conversationId).notifier)
                .receiveMessage(message);
            ref
                .read(markMessagesAsReadUseCaseProvider)
                .call(widget.conversationId);
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: InkWell(
          onTap: _openPeerProfile,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Stack(
                children: [
                  SafeNetworkAvatar(
                    radius: 18,
                    imageUrl: _conversationAvatarUrl,
                    backgroundColor: Colors.grey.shade200,
                    iconColor: Colors.grey.shade500,
                  ),
                  if (_conversationIsOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _conversationTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      final isCurrentUser = message.senderId == _myProfileId;

                      return Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: _buildMessageBubble(
                          message,
                          isCurrentUser,
                          context,
                        ),
                      );
                    },
                  ),
          ),

          // Input de mensaje
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    enabled: !isSending,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: isSending ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construir burbuja de mensaje
  Widget _buildMessageBubble(
    Message message,
    bool isCurrentUser,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isCurrentUser ? Theme.of(context).primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser && message.senderName != null) ...[
              Text(
                message.senderName!,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
            ],
            Text(
              message.content,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatMessageTime(message.createdAt),
              style: TextStyle(
                color: isCurrentUser ? Colors.white70 : Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Comienza la conversación',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Sé el primero en escribir',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  /// Enviar mensaje
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        },
        (message) {
          // Agregar mensaje a la lista
          ref
              .read(messagesProvider(widget.conversationId).notifier)
              .addMessage(message);
          _messageController.clear();
        },
      );
    } finally {
      ref.read(sendingMessageProvider.notifier).state = false;
    }
  }

  /// Formatear hora del mensaje
  String _formatMessageTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
