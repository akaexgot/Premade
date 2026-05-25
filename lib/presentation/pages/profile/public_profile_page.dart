import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/core/theme/app_colors.dart';

class PublicProfilePage extends ConsumerStatefulWidget {
  final String profileId;
  final Map<String, dynamic>? user;

  const PublicProfilePage({
    Key? key,
    required this.profileId,
    this.user,
  }) : super(key: key);

  @override
  ConsumerState<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends ConsumerState<PublicProfilePage> {
  bool _isSendingRequest = false;
  bool _requestSent = false;
  String? _friendshipStatus;
  bool _isBlocked = false;
  bool _isLoadingProfile = false;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    if (_user == null) {
      _loadPublicProfile();
    }
    _checkFriendshipStatus();
    _checkBlockStatus();
  }

  Future<void> _loadPublicProfile() async {
    setState(() => _isLoadingProfile = true);
    try {
      final supabase = ref.read(supabaseServiceProvider);
      final user = await supabase.getPublicUserProfile(widget.profileId);
      if (mounted) {
        setState(() {
          _user = user;
          _isLoadingProfile = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _checkFriendshipStatus() async {
    try {
      final supabase = ref.read(supabaseServiceProvider);
      final status = await supabase.getFriendshipStatus(widget.profileId);
      if (status != null && mounted) {
        setState(() {
          _requestSent = true;
          _friendshipStatus = status;
        });
      }
    } catch (_) {}
  }

  Future<void> _checkBlockStatus() async {
    try {
      final supabase = ref.read(supabaseServiceProvider);
      final blocked = await supabase.isUserBlocked(widget.profileId);
      if (mounted) setState(() => _isBlocked = blocked);
    } catch (_) {}
  }

  Future<void> _sendFriendRequest() async {
    setState(() => _isSendingRequest = true);
    try {
      final supabase = ref.read(supabaseServiceProvider);
      await supabase.sendFriendRequest(widget.profileId);
      if (mounted) {
        setState(() {
          _isSendingRequest = false;
          _requestSent = true;
          _friendshipStatus = 'pending';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Solicitud de amistad enviada'),
              backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSendingRequest = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _navigateToChat() async {
    try {
      final supabase = ref.read(supabaseServiceProvider);
      final conversationId =
          await supabase.getOrCreateConversation(widget.profileId);
      if (mounted) context.push('/chat/$conversationId');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir chat: $e')),
        );
      }
    }
  }

  Future<void> _blockUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Bloquear usuario?'),
        content: Text(_isBlocked
            ? 'Se desbloqueará a ${_user?['nickname'] ?? 'este usuario'}.'
            : '${_user?['nickname'] ?? 'Este usuario'} no podrá contactarte ni verte en búsquedas.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(_isBlocked ? 'Desbloquear' : 'Bloquear',
                style: TextStyle(
                    color: _isBlocked ? AppColors.success : AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final supabase = ref.read(supabaseServiceProvider);
      final profileId = widget.profileId;
      if (_isBlocked) {
        await supabase.unblockUser(profileId);
        if (mounted) {
          setState(() => _isBlocked = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario desbloqueado')),
          );
        }
      } else {
        await supabase.blockUser(profileId);
        if (mounted) {
          setState(() => _isBlocked = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Usuario bloqueado'),
                backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showReportDialog() {
    String? selectedReason;
    final reasons = [
      'Comportamiento inapropiado',
      'Spam o publicidad',
      'Perfil falso',
      'Acoso',
      'Contenido ofensivo',
      'Otro',
    ];
    final detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            return AlertDialog(
              title: const Text('Reportar usuario'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('¿Cuál es el motivo del reporte?',
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.textTheme.bodySmall?.color)),
                    const SizedBox(height: 12),
                    ...reasons.map((reason) => RadioListTile<String>(
                          title: Text(reason,
                              style: const TextStyle(fontSize: 14)),
                          value: reason,
                          groupValue: selectedReason,
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          onChanged: (val) =>
                              setDialogState(() => selectedReason = val),
                        )),
                    const SizedBox(height: 12),
                    TextField(
                      controller: detailsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Detalles adicionales (opcional)...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar')),
                TextButton(
                  onPressed: selectedReason == null
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          await _submitReport(
                              selectedReason!, detailsController.text);
                        },
                  child: const Text('Enviar reporte',
                      style: TextStyle(color: AppColors.error)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitReport(String reason, String details) async {
    try {
      final supabase = ref.read(supabaseServiceProvider);
      await supabase.reportUser(
        reportedProfileId: widget.profileId,
        reason: reason,
        details: details.isNotEmpty ? details : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte enviado. Lo revisaremos pronto.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al enviar reporte: $e'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  List<Map<String, dynamic>> _extractUserGames(Map<String, dynamic> user) {
    try {
      if (user['user_games'] is List) {
        return List<Map<String, dynamic>>.from(user['user_games']);
      }
      return [];
    } catch (_) {
      return [];
    }
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

  bool _hasUsableImageUrl(String? value) {
    final url = value?.trim();
    final uri = url == null ? null : Uri.tryParse(url);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final theme = Theme.of(context);
    if (_isLoadingProfile) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(),
        body: const Center(child: Text('Perfil no encontrado')),
      );
    }

    final isOnline = user['is_online'] == true;
    final userGames = _extractUserGames(user);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.colorScheme.surface;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary =
        theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Header con imagen ──
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: theme.appBarTheme.backgroundColor,
            actions: [
              // ── Menú de 3 puntos ──
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(77),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.more_vert,
                      color: Colors.white, size: 20),
                ),
                onSelected: (value) {
                  if (value == 'block') _blockUser();
                  if (value == 'report') _showReportDialog();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'block',
                    child: Row(
                      children: [
                        Icon(
                            _isBlocked
                                ? Icons.lock_open_rounded
                                : Icons.block_rounded,
                            color: _isBlocked
                                ? AppColors.success
                                : AppColors.error,
                            size: 20),
                        const SizedBox(width: 10),
                        Text(_isBlocked ? 'Desbloquear' : 'Bloquear'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag_rounded,
                            color: AppColors.error, size: 20),
                        SizedBox(width: 10),
                        Text('Reportar'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _hasUsableImageUrl(user['avatar_url']?.toString())
                      ? Image.network(user['avatar_url'],
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder: (_, __, ___) => Container(
                              color: AppColors.primarySoft,
                              child: const Icon(Icons.person,
                                  size: 100, color: AppColors.primary)))
                      : Container(
                          decoration: const BoxDecoration(
                              gradient: AppColors.primaryGradient),
                          child: const Icon(Icons.person,
                              size: 100, color: Colors.white70)),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                  // Nombre sobre la imagen
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['nickname'] ?? 'Usuario',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                  '${user['age'] ?? '??'} años • ${user['country'] ?? ''}',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 15)),
                            ],
                          ),
                        ),
                        if (isOnline)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(51),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.success),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                    radius: 4,
                                    backgroundColor: AppColors.success),
                                SizedBox(width: 6),
                                Text('Online',
                                    style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Blocked banner ──
          if (_isBlocked)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withAlpha(51)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.block_rounded,
                        color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('Has bloqueado a este usuario',
                          style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600)),
                    ),
                    TextButton(
                      onPressed: _blockUser,
                      child: const Text('Desbloquear',
                          style:
                              TextStyle(color: AppColors.error, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),

          // ── Contenido ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bio
                  if (user['bio'] != null &&
                      user['bio'].toString().isNotEmpty) ...[
                    Text('Sobre mí',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary)),
                    const SizedBox(height: 8),
                    Text(user['bio'],
                        style: TextStyle(
                            fontSize: 15, color: textPrimary, height: 1.5)),
                    const SizedBox(height: 24),
                  ],

                  // Discord
                  if (user['discord_username'] != null &&
                      user['discord_username'].toString().isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5865F2).withAlpha(20),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFF5865F2).withAlpha(51)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.discord,
                              color: Color(0xFF5865F2), size: 22),
                          const SizedBox(width: 12),
                          Text(user['discord_username'],
                              style: const TextStyle(
                                  color: Color(0xFF5865F2),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Juegos y Roles
                  if (userGames.isNotEmpty) ...[
                    Text('Juegos y Roles',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary)),
                    const SizedBox(height: 12),
                    ...userGames.map((ug) {
                      final game = ug['game'] ?? ug['games'];
                      final mainRole = ug['main_role'];
                      final secondaryRole = ug['secondary_role'];
                      final rank = ug['primary_rank'];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: isDark
                                  ? const Color(0xFF2A2A45)
                                  : AppColors.grey200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                      color: AppColors.primarySoft,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(
                                      Icons.sports_esports_rounded,
                                      color: AppColors.primary,
                                      size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(game?['title'] ?? 'Juego',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: textPrimary)),
                                ),
                                if (rank != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: AppColors.accentLight,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Text(_rankName(rank),
                                        style: const TextStyle(
                                            color: AppColors.accent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  ),
                              ],
                            ),
                            if (mainRole != null || secondaryRole != null) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                children: [
                                  if (mainRole != null)
                                    _RoleChip(
                                        label: _roleName(mainRole),
                                        isPrimary: true,
                                        isDark: isDark),
                                  if (secondaryRole != null)
                                    _RoleChip(
                                        label: _roleName(secondaryRole),
                                        isPrimary: false,
                                        isDark: isDark),
                                ],
                              ),
                            ],
                            if (ug['played_hours'] != null ||
                                ug['is_casual_only'] != null) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  if (ug['played_hours'] != null)
                                    _InfoChip(
                                        icon: Icons.timer_outlined,
                                        label: '${ug['played_hours']}h',
                                        color: textSecondary),
                                  if (ug['played_hours'] != null)
                                    const SizedBox(width: 12),
                                  _InfoChip(
                                    icon: ug['is_casual_only'] == true
                                        ? Icons.sentiment_satisfied_alt_rounded
                                        : Icons.emoji_events_rounded,
                                    label: ug['is_casual_only'] == true
                                        ? 'Casual'
                                        : 'Competitivo',
                                    color: textSecondary,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom action buttons ──
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            children: [
              // Chat button (solo si son amigos)
              if (_friendshipStatus == 'accepted') ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _navigateToChat,
                    icon: const Icon(Icons.chat_bubble_rounded, size: 20),
                    label: const Text('Chatear',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              // Friend request / status button
              Expanded(
                flex: _friendshipStatus == 'accepted' ? 1 : 2,
                child: ElevatedButton.icon(
                  onPressed: (_isSendingRequest || _requestSent || _isBlocked)
                      ? null
                      : _sendFriendRequest,
                  icon: Icon(_getButtonIcon(), size: 20),
                  label: Text(_getButtonText(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getButtonColor(),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _getButtonColor().withAlpha(180),
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: _requestSent ? 0 : 4,
                    shadowColor: AppColors.primary.withAlpha(102),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getButtonIcon() {
    if (_isBlocked) return Icons.block_rounded;
    if (_friendshipStatus == 'accepted') return Icons.check_circle_rounded;
    if (_requestSent) return Icons.hourglass_top_rounded;
    return Icons.person_add_rounded;
  }

  String _getButtonText() {
    if (_isBlocked) return 'Bloqueado';
    if (_friendshipStatus == 'accepted') return 'Amigos';
    if (_requestSent) return 'Solicitud enviada';
    return 'Añadir amigo';
  }

  Color _getButtonColor() {
    if (_isBlocked) return AppColors.error;
    if (_friendshipStatus == 'accepted') return AppColors.success;
    if (_requestSent) return AppColors.textTertiary;
    return AppColors.primary;
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final bool isDark;
  const _RoleChip(
      {required this.label, required this.isPrimary, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppColors.primary.withAlpha(25)
            : (isDark ? const Color(0xFF2A2A45) : AppColors.grey100),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: isPrimary
                ? AppColors.primary.withAlpha(77)
                : (isDark ? const Color(0xFF3A3A55) : AppColors.grey200)),
      ),
      child: Text(label,
          style: TextStyle(
              color: isPrimary
                  ? AppColors.primary
                  : (isDark
                      ? const Color(0xFF9CA3AF)
                      : AppColors.textSecondary),
              fontSize: 12,
              fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
