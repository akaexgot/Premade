import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:premade/application/providers/matching_providers.dart';
import 'package:premade/core/theme/app_colors.dart';
import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/core/widgets/safe_network_avatar.dart';

class FriendsPage extends ConsumerStatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends ConsumerState<FriendsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _pendingRequests = [];
  bool _isLoadingFriends = false;
  bool _isLoadingRequests = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      _loadFriends();
      _loadPendingRequests();
    });
  }

  Future<void> _loadFriends() async {
    if (!mounted) return;
    setState(() => _isLoadingFriends = true);
    try {
      final supabase = ref.read(supabaseServiceProvider);
      final friendsData = await supabase.getFriends();

      // Procesar para obtener el "otro" usuario
      final myProfileId = await supabase.getProfileId();
      final processedFriends = friendsData.map((f) {
        final u1 = f['user_1'];
        final u2 = f['user_2'];
        return u1['id'] == myProfileId ? u2 : u1;
      }).toList();

      if (mounted) {
        setState(() {
          _friends = List<Map<String, dynamic>>.from(processedFriends);
          _isLoadingFriends = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingFriends = false);
    }
  }

  Future<void> _loadPendingRequests() async {
    if (!mounted) return;
    setState(() => _isLoadingRequests = true);
    try {
      final supabase = ref.read(supabaseServiceProvider);
      final requests = await supabase.getPendingRequests();
      if (mounted) {
        setState(() {
          _pendingRequests = requests;
          _isLoadingRequests = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingRequests = false);
    }
  }

  Future<void> _respondToRequest(String requesterId, bool accept) async {
    try {
      final supabase = ref.read(supabaseServiceProvider);
      await supabase.respondToFriendRequest(requesterId, accept);
      if (accept) {
        _loadFriends();
      }
      _loadPendingRequests();
    } catch (_) {}
  }

  Future<void> _navigateToChat(String otherUserId) async {
    try {
      final supabase = ref.read(supabaseServiceProvider);
      final conversationId =
          await supabase.getOrCreateConversation(otherUserId);
      if (mounted) {
        context.push('/chat/$conversationId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir el chat: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.colorScheme.surface;
    final textPrimary = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text('Social',
                  style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.5)),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: theme.textTheme.bodySmall?.color,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                tabs: [
                  Tab(text: 'Amigos (${_friends.length})'),
                  Tab(text: 'Solicitudes (${_pendingRequests.length})'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFriendsList(theme, isDark, cardColor, textPrimary),
                  _buildRequestsList(theme, isDark, cardColor, textPrimary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsList(
      ThemeData theme, bool isDark, Color cardColor, Color textPrimary) {
    if (_isLoadingFriends) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.people_outline_rounded,
                  size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text('Aún no tienes amigos',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary)),
            const SizedBox(height: 8),
            Text('Haz match con jugadores para\nañadirlos a tu lista',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15,
                    color: theme.textTheme.bodyMedium?.color,
                    height: 1.4)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _friends.length,
      itemBuilder: (context, index) {
        final friend = _friends[index];
        return InkWell(
          onTap: () => _navigateToChat(friend['id'].toString()),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: cardColor, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                SafeNetworkAvatar(
                  radius: 25,
                  imageUrl: friend['avatar_url']?.toString(),
                  backgroundColor:
                      isDark ? const Color(0xFF2A2A45) : AppColors.grey200,
                  iconColor: theme.textTheme.bodySmall?.color ??
                      AppColors.textTertiary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(friend['nickname'] ?? 'Jugador',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textPrimary)),
                      const SizedBox(height: 2),
                      Text('Amigo',
                          style: TextStyle(
                              fontSize: 13,
                              color: theme.textTheme.bodySmall?.color)),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.chat_bubble_outline_rounded,
                      color: AppColors.primary, size: 20),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestsList(
      ThemeData theme, bool isDark, Color cardColor, Color textPrimary) {
    if (_isLoadingRequests) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pendingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_disabled_rounded,
                size: 60,
                color: isDark ? const Color(0xFF4A4A6A) : AppColors.grey300),
            const SizedBox(height: 16),
            Text(
              'No tienes solicitudes pendientes',
              style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _pendingRequests.length,
      itemBuilder: (context, index) {
        final req = _pendingRequests[index];
        final requester = req['requester'] ?? {};

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isDark ? const Color(0xFF2A2A45) : AppColors.grey200),
          ),
          child: Row(
            children: [
              SafeNetworkAvatar(
                radius: 25,
                imageUrl: requester['avatar_url']?.toString(),
                backgroundColor:
                    isDark ? const Color(0xFF2A2A45) : AppColors.grey200,
                iconColor:
                    theme.textTheme.bodySmall?.color ?? AppColors.textTertiary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      requester['nickname'] ?? 'Usuario',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textPrimary),
                    ),
                    Text(
                      'Quiere ser tu amigo',
                      style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle,
                    color: AppColors.success, size: 32),
                onPressed: () =>
                    _respondToRequest(requester['id'].toString(), true),
              ),
              IconButton(
                icon:
                    const Icon(Icons.cancel, color: AppColors.error, size: 32),
                onPressed: () =>
                    _respondToRequest(requester['id'].toString(), false),
              ),
            ],
          ),
        );
      },
    );
  }
}
