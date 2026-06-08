import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/core/theme/app_colors.dart';

class MyGamesPage extends ConsumerStatefulWidget {
  const MyGamesPage({super.key});

  @override
  ConsumerState<MyGamesPage> createState() => _MyGamesPageState();
}

class _MyGamesPageState extends ConsumerState<MyGamesPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allGames = [];
  List<Map<String, dynamic>> _userGames = [];

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);
    try {
      final supabase = ref.read(supabaseServiceProvider);
      final games = await supabase.getAllGames();
      final userGames = await supabase.getUserGames();
      if (mounted) {
        setState(() {
          _allGames = List<Map<String, dynamic>>.from(games);
          _userGames = List<Map<String, dynamic>>.from(userGames);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar juegos: $e')),
        );
      }
    }
  }

  bool _hasGame(String gameId) {
    return _userGames.any((item) => item['game_id']?.toString() == gameId);
  }

  Map<String, dynamic>? _userGameFor(String gameId) {
    for (final item in _userGames) {
      if (item['game_id']?.toString() == gameId) return item;
    }
    return null;
  }

  Future<void> _addGame(Map<String, dynamic> game) async {
    try {
      final supabase = ref.read(supabaseServiceProvider);
      await supabase.addUserGame(gameId: game['id'].toString());
      await _loadGames();
      if (mounted) {
        final userGame = _userGameFor(game['id'].toString());
        if (userGame != null) _openEditor(userGame);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar juego: $e')),
        );
      }
    }
  }

  Future<void> _removeGame(String gameId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitar juego'),
        content: const Text('Se eliminara este juego de tu perfil.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Quitar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ref.read(supabaseServiceProvider).removeUserGame(gameId);
      await _loadGames();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al quitar juego: $e')),
        );
      }
    }
  }

  Future<void> _openEditor(Map<String, dynamic> userGame) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _EditUserGameSheet(userGame: userGame),
    );

    if (updated == true) {
      await _loadGames();
    }
  }

  String _roleName(Map<String, dynamic>? role) {
    return role?['role_name']?.toString() ?? role?['name']?.toString() ?? '';
  }

  String _rankName(Map<String, dynamic>? rank) {
    return rank?['rank_tier']?.toString() ?? rank?['name']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onSurface;
    final textSecondary =
        theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Mis juegos',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadGames,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  Text(
                    'Seleccionados',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_userGames.isEmpty)
                    _EmptyBox(textSecondary: textSecondary)
                  else
                    ..._userGames.map((item) {
                      final game = item['game'] as Map<String, dynamic>?;
                      final gameId = item['game_id']?.toString() ?? '';
                      final role = _roleName(item['main_role']);
                      final rank = _rankName(item['primary_rank']);
                      return _UserGameTile(
                        title: game?['title']?.toString() ?? 'Juego',
                        subtitle: [
                          if (role.isNotEmpty) role,
                          if (rank.isNotEmpty) rank,
                          item['is_casual_only'] == true ? 'Casual' : 'Ranked',
                        ].join(' - '),
                        onTap: () => _openEditor(item),
                        onDelete: () => _removeGame(gameId),
                      );
                    }),
                  const SizedBox(height: 24),
                  Text(
                    'Disponibles',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._allGames
                      .where((game) => !_hasGame(game['id'].toString()))
                      .map(
                        (game) => _AvailableGameTile(
                          title: game['title']?.toString() ?? 'Juego',
                          subtitle:
                              game['genre']?.toString() ?? 'Anadir a perfil',
                          onTap: () => _addGame(game),
                        ),
                      ),
                ],
              ),
            ),
    );
  }
}

class _EditUserGameSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> userGame;

  const _EditUserGameSheet({required this.userGame});

  @override
  ConsumerState<_EditUserGameSheet> createState() => _EditUserGameSheetState();
}

class _EditUserGameSheetState extends ConsumerState<_EditUserGameSheet> {
  String? _primaryRankId;
  String? _secondaryRankId;
  String? _mainRoleId;
  String? _secondaryRoleId;
  late bool _isCasualOnly;
  late TextEditingController _hoursController;
  late TextEditingController _notesController;
  bool _isSaving = false;
  List<Map<String, dynamic>> _roles = [];
  List<Map<String, dynamic>> _ranks = [];

  String get _gameId => widget.userGame['game_id'].toString();

  @override
  void initState() {
    super.initState();
    _primaryRankId = widget.userGame['primary_rank_id']?.toString();
    _secondaryRankId = widget.userGame['secondary_rank_id']?.toString();
    _mainRoleId = widget.userGame['main_role_id']?.toString();
    _secondaryRoleId = widget.userGame['secondary_role_id']?.toString();
    _isCasualOnly = widget.userGame['is_casual_only'] == true;
    _hoursController = TextEditingController(
      text: (widget.userGame['played_hours'] ?? 0).toString(),
    );
    _notesController = TextEditingController(
      text: widget.userGame['skill_notes']?.toString() ?? '',
    );
    _loadOptions();
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    final supabase = ref.read(supabaseServiceProvider);
    final roles = await supabase.getGameRoles(_gameId);
    final ranks = await supabase.getGameRanks(_gameId);
    if (mounted) {
      setState(() {
        _roles = roles;
        _ranks = ranks;
      });
    }
  }

  Future<void> _save() async {
    final hours = int.tryParse(_hoursController.text.trim());
    if (hours == null || hours < 0 || hours > 100000) {
      _showError('Las horas deben estar entre 0 y 100000');
      return;
    }
    if (_notesController.text.trim().length > 500) {
      _showError('Las notas no pueden superar 500 caracteres');
      return;
    }
    if (!_isCasualOnly && _primaryRankId == null) {
      _showError('Selecciona rango principal o marca casual');
      return;
    }
    if (!_isCasualOnly && _mainRoleId == null) {
      _showError('Selecciona rol principal o marca casual');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(supabaseServiceProvider).client.from('user_games').update({
        'primary_rank_id': _isCasualOnly ? null : _primaryRankId,
        'secondary_rank_id': _isCasualOnly ? null : _secondaryRankId,
        'main_role_id': _isCasualOnly ? null : _mainRoleId,
        'secondary_role_id': _isCasualOnly ? null : _secondaryRoleId,
        'is_casual_only': _isCasualOnly,
        'played_hours': hours,
        'skill_notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      }).eq('id', widget.userGame['id']);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showError('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.userGame['game'] as Map<String, dynamic>?;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              game?['title']?.toString() ?? 'Editar juego',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isCasualOnly,
              onChanged: _isSaving
                  ? null
                  : (value) => setState(() {
                        _isCasualOnly = value;
                      }),
              title: const Text('Solo juego casual'),
            ),
            const SizedBox(height: 12),
            if (!_isCasualOnly) ...[
              _Dropdown(
                label: 'Rol principal',
                value: _mainRoleId,
                items: _roles,
                labelKey: 'role_name',
                onChanged: (value) => setState(() => _mainRoleId = value),
              ),
              const SizedBox(height: 12),
              _Dropdown(
                label: 'Rol secundario',
                value: _secondaryRoleId,
                items: _roles.where((r) => r['id'] != _mainRoleId).toList(),
                labelKey: 'role_name',
                allowNone: true,
                onChanged: (value) => setState(() => _secondaryRoleId = value),
              ),
              const SizedBox(height: 12),
              _Dropdown(
                label: 'Rango principal',
                value: _primaryRankId,
                items: _ranks,
                labelKey: 'rank_tier',
                onChanged: (value) => setState(() => _primaryRankId = value),
              ),
              const SizedBox(height: 12),
              _Dropdown(
                label: 'Rango secundario',
                value: _secondaryRankId,
                items: _ranks.where((r) => r['id'] != _primaryRankId).toList(),
                labelKey: 'rank_tier',
                allowNone: true,
                onChanged: (value) => setState(() => _secondaryRankId = value),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _hoursController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Horas jugadas',
                prefixIcon: Icon(Icons.schedule_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notas de skill',
                hintText: 'Ej: buen comunicador, juego agresivo...',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_isSaving ? 'Guardando...' : 'Guardar cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<Map<String, dynamic>> items;
  final String labelKey;
  final bool allowNone;
  final ValueChanged<String?> onChanged;

  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.labelKey,
    required this.onChanged,
    this.allowNone = false,
  });

  @override
  Widget build(BuildContext context) {
    final values = items.map((item) => item['id'].toString()).toSet();
    final safeValue = value != null && values.contains(value) ? value : null;

    return DropdownButtonFormField<String?>(
      initialValue: safeValue,
      decoration: InputDecoration(labelText: label),
      items: [
        if (allowNone)
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('Ninguno'),
          ),
        ...items.map(
          (item) => DropdownMenuItem<String?>(
            value: item['id'].toString(),
            child: Text(item[labelKey]?.toString() ?? 'Desconocido'),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _UserGameTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _UserGameTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          backgroundColor: AppColors.primarySoft,
          child: Icon(Icons.sports_esports_rounded, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle.isEmpty ? 'Toca para editar datos' : subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Editar',
              onPressed: onTap,
              icon: const Icon(Icons.edit_rounded),
            ),
            IconButton(
              tooltip: 'Quitar',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailableGameTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AvailableGameTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: IconButton.filledTonal(
        tooltip: 'Agregar',
        onPressed: onTap,
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final Color textSecondary;

  const _EmptyBox({required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Aun no tienes juegos seleccionados.',
        style: TextStyle(color: textSecondary),
      ),
    );
  }
}
