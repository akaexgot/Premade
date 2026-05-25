import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:premade/application/providers/auth_providers.dart';
import 'package:premade/application/providers/profile_providers.dart';
import 'package:premade/application/providers/matching_providers.dart';
import 'package:premade/core/theme/app_colors.dart';
import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/core/widgets/safe_network_avatar.dart';

class MyProfilePage extends ConsumerStatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends ConsumerState<MyProfilePage> {
  int _friendsCount = 0;
  List<Map<String, dynamic>> _userGames = [];
  String? _requestedProfileUserId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _loadProfileIfNeeded();
      _loadFriendsCount();
      _loadUserGames();
    });
  }

  void _loadProfileIfNeeded([String? userId]) {
    final profile = ref.read(userProfileProvider);
    final authUserId = userId ??
        ref.read(authUserProvider)?.id ??
        ref.read(supabaseServiceProvider).currentUserId;

    if (authUserId == null) return;
    if (profile != null || _requestedProfileUserId == authUserId) {
      return;
    }

    _requestedProfileUserId = authUserId;
    ref.read(userProfileProvider.notifier).loadProfile(authUserId);
  }

  Future<void> _loadFriendsCount() async {
    try {
      final supabase = ref.read(supabaseServiceProvider);
      final friends = await supabase.getFriends();
      if (mounted) setState(() => _friendsCount = friends.length);
    } catch (_) {}
  }

  Future<void> _loadUserGames() async {
    try {
      final supabase = ref.read(supabaseServiceProvider);
      final games = await supabase.getUserGames();
      if (mounted) {
        setState(() => _userGames = List<Map<String, dynamic>>.from(games));
      }
    } catch (_) {}
  }

  Future<void> _refreshProfile() async {
    final authUser = ref.read(authUserProvider);
    if (authUser != null) {
      await ref.read(userProfileProvider.notifier).loadProfile(authUser.id);
    }
    await _loadFriendsCount();
    await _loadUserGames();
  }

  String _roleName(Map<String, dynamic>? role) {
    return role?['role_name']?.toString() ?? role?['name']?.toString() ?? '';
  }

  String _rankName(Map<String, dynamic>? rank) {
    return rank?['rank_tier']?.toString() ??
        rank?['tier']?.toString() ??
        rank?['name']?.toString() ??
        '';
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authUserProvider);
    final userProfile = ref.watch(userProfileProvider);
    final matches = ref.watch(userMatchesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.colorScheme.surface;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary =
        theme.textTheme.bodySmall?.color ?? AppColors.textTertiary;

    if (userProfile == null) {
      Future.microtask(() => _loadProfileIfNeeded(authUser?.id));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // ── Header con gradiente ──
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16, bottom: 32),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    const Text('Mi Perfil',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 20),
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(51),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: ClipOval(
                        child: SafeNetworkAvatar(
                          radius: 50,
                          imageUrl: userProfile?.avatarUrl,
                          backgroundColor: Colors.white.withAlpha(51),
                          iconColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      userProfile?.nickname ?? 'Usuario',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (userProfile?.country != null &&
                            userProfile!.country.isNotEmpty) ...[
                          const Icon(Icons.location_on_rounded,
                              color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text(userProfile.country,
                              style: TextStyle(
                                  color: Colors.white.withAlpha(204),
                                  fontSize: 15)),
                        ],
                        if (userProfile?.age != null &&
                            userProfile!.age > 0) ...[
                          const SizedBox(width: 12),
                          Text('${userProfile.age} años',
                              style: TextStyle(
                                  color: Colors.white.withAlpha(204),
                                  fontSize: 15)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Stats row ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isDark ? null : AppColors.softShadow),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                          value: matches.length.toString(),
                          label: 'Matches',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary),
                      Container(
                          width: 1, height: 30, color: theme.dividerColor),
                      _StatItem(
                          value: '$_friendsCount',
                          label: 'Amigos',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary),
                      Container(
                          width: 1, height: 30, color: theme.dividerColor),
                      _StatItem(
                          value: '${_userGames.length}',
                          label: 'Juegos',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Bio section ──
              if (userProfile?.bio != null && userProfile!.bio!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 16, color: textSecondary),
                            const SizedBox(width: 6),
                            Text('Bio',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(userProfile.bio!,
                            style: TextStyle(
                                fontSize: 15, color: textPrimary, height: 1.4)),
                      ],
                    ),
                  ),
                ),

              // ── Discord ──
              if (userProfile?.discordUsername != null &&
                  userProfile!.discordUsername!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5865F2).withAlpha(20),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF5865F2).withAlpha(51)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.discord,
                            color: Color(0xFF5865F2), size: 22),
                        const SizedBox(width: 12),
                        Text(userProfile.discordUsername!,
                            style: const TextStyle(
                                color: Color(0xFF5865F2),
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ],

              // ── Juegos del usuario ──
              if (_userGames.isNotEmpty) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.sports_esports_rounded,
                              size: 18, color: textSecondary),
                          const SizedBox(width: 6),
                          Text('Mis Juegos',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._userGames.map((ug) {
                        final game = ug['game'];
                        final rank = ug['primary_rank'];
                        final role = ug['main_role'];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: isDark
                                    ? const Color(0xFF2A2A45)
                                    : AppColors.grey200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.sports_esports_rounded,
                                    color: AppColors.primary, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(game?['title'] ?? 'Juego',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: textPrimary)),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        if (role != null)
                                          Text(_roleName(role),
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w500)),
                                        if (role != null && rank != null)
                                          Text(' • ',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: textSecondary)),
                                        if (rank != null)
                                          Text(_rankName(rank),
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: textSecondary)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (ug['is_casual_only'] == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('Casual',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.accent)),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('Ranked',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary)),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // ── Menu items ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      _MenuItem(
                          icon: Icons.edit_rounded,
                          label: 'Editar perfil',
                          onTap: () async {
                            await context.push('/edit-profile');
                            _refreshProfile();
                          }),
                      Divider(height: 0, indent: 52, color: theme.dividerColor),
                      _MenuItem(
                          icon: Icons.sports_esports_rounded,
                          label: 'Mis juegos',
                          onTap: () async {
                            await context.push('/my-games');
                            _loadUserGames();
                          }),
                      Divider(height: 0, indent: 52, color: theme.dividerColor),
                      _MenuItem(
                          icon: Icons.settings_rounded,
                          label: 'Ajustes',
                          onTap: () => context.push('/settings')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Logout ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16)),
                  child: _MenuItem(
                    icon: Icons.logout_rounded,
                    label: 'Cerrar sesión',
                    color: AppColors.error,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('¿Cerrar sesión?'),
                          content: const Text('Se cerrará tu sesión actual'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancelar')),
                            TextButton(
                              onPressed: () {
                                ref.read(authUserProvider.notifier).signOut();
                                context.go('/login');
                              },
                              child: const Text('Salir',
                                  style: TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color textPrimary;
  final Color textSecondary;
  const _StatItem(
      {required this.value,
      required this.label,
      required this.textPrimary,
      required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: textSecondary,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MenuItem(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: c.withAlpha(20),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: c, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500, color: c))),
            Icon(Icons.chevron_right_rounded,
                color: theme.textTheme.bodySmall?.color, size: 22),
          ],
        ),
      ),
    );
  }
}
