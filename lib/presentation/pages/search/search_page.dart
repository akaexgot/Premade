import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:premade/core/theme/app_colors.dart';
import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/core/widgets/safe_network_avatar.dart';
import 'package:go_router/go_router.dart';

/// SearchPage: Buscar jugadores por nombre o filtros
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _results = [];
  List<String> _gameFilters = ['Todos', 'Online'];
  bool _isLoading = true;
  String _selectedFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadGameFilters();
    _loadAllUsers();
  }

  /// Cargar filtros de juego dinámicamente de la BD
  Future<void> _loadGameFilters() async {
    try {
      final supabase = ref.read(supabaseServiceProvider);
      final gamesData = await supabase.client.from('games').select('title');
      final gameTitles = (gamesData as List)
          .map((g) => g['title']?.toString() ?? '')
          .where((t) => t.isNotEmpty)
          .toList();

      if (mounted) {
        setState(() {
          _gameFilters = ['Todos', 'Online', ...gameTitles];
        });
      }
    } catch (e) {
      print('DEBUG: Error cargando filtros de juego: $e');
    }
  }

  Future<void> _loadAllUsers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final supabase = ref.read(supabaseServiceProvider);

      final users = await supabase.searchPlayers(
        nickname: _searchController.text,
        gameTitle: _selectedFilter,
      );

      if (mounted) {
        setState(() {
          _allUsers = List<Map<String, dynamic>>.from(users);
          _results = _allUsers;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('DEBUG: Error cargando usuarios: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    if (_selectedFilter != 'Todos') {
      _loadAllUsers();
    } else {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _results = _allUsers.where((user) {
          final nickname = (user['nickname'] ?? '').toString().toLowerCase();
          return query.isEmpty || nickname.contains(query);
        }).toList();
      });
    }
  }

  List<String> _extractGameNames(Map<String, dynamic> user) {
    try {
      if (user['user_games'] is List) {
        return (user['user_games'] as List)
            .map((g) {
              final game = g['game'];
              if (game != null && game['title'] != null) {
                return game['title'].toString();
              }
              return '';
            })
            .where((name) => name.isNotEmpty)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.colorScheme.surface;
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary =
        theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final textTertiary =
        theme.textTheme.bodySmall?.color ?? AppColors.textTertiary;
    final searchBg = isDark ? const Color(0xFF1E1E36) : AppColors.grey100;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Buscar',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Search bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: searchBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  style: TextStyle(color: textPrimary),
                  onChanged: (value) => _applyFilters(),
                  decoration: InputDecoration(
                    hintText: 'Buscar jugadores por nombre...',
                    prefixIcon: Icon(Icons.search_rounded, color: textTertiary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close_rounded,
                                color: textTertiary, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Filter chips (dinámicos) ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: _gameFilters
                    .map((filter) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(
                              filter, isDark, textSecondary, cardColor),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),

            // ── Results ──
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                      ? _buildEmptyState(theme, textPrimary, textSecondary)
                      : _buildResults(theme, isDark, cardColor, textPrimary,
                          textSecondary, textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      String label, bool isDark, Color textSecondary, Color cardColor) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = label);
        _applyFilters();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? const Color(0xFF2A2A45) : AppColors.grey200),
          ),
          boxShadow: isSelected ? AppColors.primaryShadow : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      ThemeData theme, Color textPrimary, Color textSecondary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.person_search_rounded,
                size: 40, color: AppColors.accent),
          ),
          const SizedBox(height: 20),
          Text('No se encontraron jugadores',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textPrimary)),
          const SizedBox(height: 8),
          Text('Intenta con otro nombre o filtro',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 15, color: textSecondary, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildResults(ThemeData theme, bool isDark, Color cardColor,
      Color textPrimary, Color textSecondary, Color textTertiary) {
    return RefreshIndicator(
      onRefresh: _loadAllUsers,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final user = _results[index];
          final isOnline = user['is_online'] == true;
          final games = _extractGameNames(user);

          final profileId = user['id']?.toString();

          return InkWell(
            onTap: profileId == null || profileId.isEmpty
                ? null
                : () => context.push('/public-profile/$profileId', extra: user),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      SafeNetworkAvatar(
                        radius: 28,
                        imageUrl: user['avatar_url']?.toString(),
                        backgroundColor: isDark
                            ? const Color(0xFF2A2A45)
                            : AppColors.grey200,
                        iconColor: textTertiary,
                      ),
                      if (isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: cardColor, width: 2),
                            ),
                          ),
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
                                user['nickname'] ?? 'Usuario',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (user['age'] != null) ...[
                              const SizedBox(width: 6),
                              Text('${user['age']}',
                                  style: TextStyle(
                                      fontSize: 14, color: textTertiary)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user['bio'] ?? 'Jugador de Premade',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: textSecondary),
                        ),
                        if (games.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4,
                            children: games
                                .take(2)
                                .map((g) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primarySoft,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(g,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary)),
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: textTertiary, size: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
