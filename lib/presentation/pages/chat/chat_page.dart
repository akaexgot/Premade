import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:premade/application/providers/auth_providers.dart';
import 'package:premade/application/providers/chat_providers.dart';
import 'package:premade/domain/entities/chat_entity.dart';
import 'package:premade/presentation/widgets/app_bar_widget.dart';

/// ChatPage: Lista de conversaciones
class ChatPage extends ConsumerStatefulWidget {
  final bool showAppBar;

  const ChatPage({super.key, this.showAppBar = true});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Cargar conversaciones al abrir
    Future.microtask(() async {
      await ref.read(conversationsProvider.notifier).loadConversations();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authUserProvider);
    final conversations = ref.watch(conversationsProvider);

    // Redirigir si no está autenticado
    if (authUser == null) {
      Future.microtask(() => context.go('/login'));
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBarWidget(
              title: 'Mensajes',
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Actualizar',
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    await ref
                        .read(conversationsProvider.notifier)
                        .loadConversations();
                    if (mounted) {
                      setState(() => _isLoading = false);
                    }
                  },
                ),
              ],
            )
          : null,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : conversations.isEmpty
              ? _buildEmptyState(context)
              : ListView.separated(
                  itemCount: conversations.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return _buildConversationTile(context, conversation);
                  },
                ),
    );
  }

  /// Construir tile de conversación
  Widget _buildConversationTile(
      BuildContext context, ConversationPreview conversation) {
    return Material(
      child: InkWell(
        onTap: () async {
          await context.push('/chat/${conversation.id}');
          if (mounted) {
            ref.read(conversationsProvider.notifier).loadConversations();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundImage: conversation.otherUserAvatar != null
                    ? NetworkImage(conversation.otherUserAvatar!)
                    : null,
                backgroundColor: Colors.grey[300],
                child: conversation.otherUserAvatar == null
                    ? Icon(Icons.person, color: Colors.grey[600])
                    : null,
              ),
              const SizedBox(width: 12),

              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre + online indicator
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.otherUserName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (conversation.otherUserIsOnline)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Último mensaje
                    Text(
                      conversation.lastMessage,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Hora + badge de no leídos
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(conversation.lastMessageTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (conversation.unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        conversation.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
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
            'No hay conversaciones',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Haz match y comienza a chatear',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  /// Formatear tiempo
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}
