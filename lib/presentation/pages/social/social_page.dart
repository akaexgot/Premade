import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/core/theme/app_colors.dart';
import 'package:premade/presentation/pages/chat/chat_page.dart';
import 'package:premade/presentation/pages/friends/friends_page.dart';
import 'package:premade/presentation/pages/search/search_page.dart';

class SocialPage extends ConsumerStatefulWidget {
  final ValueChanged<int>? onPendingRequestsChanged;
  final ValueChanged<int>? onUnreadChatsChanged;

  const SocialPage({
    super.key,
    this.onPendingRequestsChanged,
    this.onUnreadChatsChanged,
  });

  @override
  ConsumerState<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends ConsumerState<SocialPage> {
  int _pendingRequestsCount = 0;
  int _unreadChatsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPendingRequestsCount();
    _loadUnreadChatsCount();
  }

  Future<void> _loadPendingRequestsCount() async {
    try {
      final requests =
          await ref.read(supabaseServiceProvider).getPendingRequests();
      if (mounted) {
        setState(() => _pendingRequestsCount = requests.length);
        widget.onPendingRequestsChanged?.call(requests.length);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _pendingRequestsCount = 0);
      }
    }
  }

  Future<void> _loadUnreadChatsCount() async {
    try {
      final count =
          await ref.read(supabaseServiceProvider).getUnreadConversationsCount();
      if (mounted) {
        setState(() => _unreadChatsCount = count);
        widget.onUnreadChatsChanged?.call(count);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _unreadChatsCount = 0);
        widget.onUnreadChatsChanged?.call(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary =
        theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 112),
          children: [
            Text(
              'Social',
              style: TextStyle(
                color: textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Jugadores, conversaciones y solicitudes.',
              style: TextStyle(
                color: textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 22),
            _PrimaryAction(
              title: 'Descubrir jugadores',
              subtitle: 'Busca por nombre, estado o juego',
              icon: Icons.person_search_rounded,
              onTap: () => _open(
                context,
                const _SocialDetailPage(
                  title: 'Descubrir',
                  child: SearchPage(showHeader: false),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel(text: 'Actividad'),
            const SizedBox(height: 10),
            _ActionList(
              isDark: isDark,
              children: [
                _ActionRow(
                  title: 'Chats',
                  subtitle: _unreadChatsCount == 0
                      ? 'Mensajes con tus matches'
                      : '$_unreadChatsCount sin leer',
                  icon: Icons.chat_bubble_rounded,
                  badgeCount: _unreadChatsCount,
                  onTap: () async {
                    await _open(
                      context,
                      const _SocialDetailPage(
                        title: 'Chats',
                        child: ChatPage(showAppBar: false),
                      ),
                    );
                    _loadUnreadChatsCount();
                  },
                ),
                _ActionRow(
                  title: 'Amigos',
                  subtitle: 'Jugadores conectados contigo',
                  icon: Icons.people_rounded,
                  onTap: () => _open(
                    context,
                    const _SocialDetailPage(
                      title: 'Amigos',
                      child: FriendsPage(showHeader: false, showTabs: false),
                    ),
                  ),
                ),
                _ActionRow(
                  title: 'Peticiones',
                  subtitle: _pendingRequestsCount == 0
                      ? 'Solicitudes pendientes'
                      : '$_pendingRequestsCount sin responder',
                  icon: Icons.person_add_rounded,
                  badgeCount: _pendingRequestsCount,
                  onTap: () async {
                    await _open(
                      context,
                      const _SocialDetailPage(
                        title: 'Peticiones',
                        child: FriendsPage(
                          showHeader: false,
                          showTabs: false,
                          initialTab: 1,
                        ),
                      ),
                    );
                    _loadPendingRequestsCount();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _open(BuildContext context, Widget page) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }
}

class _SocialDetailPage extends StatelessWidget {
  final String title;
  final Widget child;

  const _SocialDetailPage({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white.withAlpha(16) : AppColors.grey200;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: borderColor),
        ),
      ),
      body: child,
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(28),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 25),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withAlpha(210),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodySmall?.color,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _ActionList extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _ActionList({
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A45) : AppColors.grey200,
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(
                height: 1,
                indent: 68,
                color: isDark ? const Color(0xFF2A2A45) : AppColors.grey200,
              ),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  const _ActionRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary =
        theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 21),
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: _Badge(count: badgeCount),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;

  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? '99+' : count.toString();
    return Container(
      constraints: BoxConstraints(
        minWidth: 22,
        minHeight: 22,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}
