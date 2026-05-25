import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:premade/application/providers/profile_providers.dart';
import 'package:premade/domain/entities/user_profile_entity.dart';

class GameSelectionPage extends ConsumerStatefulWidget {
  const GameSelectionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<GameSelectionPage> createState() => _GameSelectionPageState();
}

class _GameSelectionPageState extends ConsumerState<GameSelectionPage> {
  String? _selectedGameId;
  String? _selectedPrimaryRank;
  String? _selectedSecondaryRank;
  String? _selectedMainRole;
  String? _selectedSecondaryRole;
  bool _isCasualOnly = false;
  int _playedHours = 0;

  final TextEditingController _skillNotesController = TextEditingController();
  final List<String> _selectedGames = [];

  @override
  void dispose() {
    _skillNotesController.dispose();
    super.dispose();
  }

  Future<void> _addGame() async {
    if (_selectedGameId == null) {
      _showError('Selecciona un juego');
      return;
    }

    ref.read(profileLoadingProvider.notifier).setLoading(true);

    try {
      final params = AddUserGameParams(
        gameId: _selectedGameId!,
        primaryRankId: _selectedPrimaryRank,
        secondaryRankId: _selectedSecondaryRank,
        mainRoleId: _selectedMainRole,
        secondaryRoleId: _selectedSecondaryRole,
        isCasualOnly: _isCasualOnly,
        playedHours: _playedHours,
        skillNotes: _skillNotesController.text.trim().isEmpty
            ? null
            : _skillNotesController.text.trim(),
      );

      await ref.read(userGamesProvider.notifier).addGame(params);

      setState(() {
        _selectedGames.add(_selectedGameId!);
        _selectedGameId = null;
        _selectedPrimaryRank = null;
        _selectedSecondaryRank = null;
        _selectedMainRole = null;
        _selectedSecondaryRole = null;
        _isCasualOnly = false;
        _playedHours = 0;
        _skillNotesController.clear();
      });

      if (mounted) {
        _showSuccess('Juego agregado');
      }
    } catch (e) {
      _showError('Error al agregar juego: ${e.toString()}');
    } finally {
      ref.read(profileLoadingProvider.notifier).setLoading(false);
    }
  }

  Future<void> _finishSetup() async {
    if (_selectedGames.isEmpty) {
      _showError('Agrega al menos un juego');
      return;
    }

    if (mounted) {
      context.go('/home');
    }
  }

  void _showError(String message) {
    ref.read(profileErrorProvider.notifier).setError(message);
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _gameTitle(Map<String, dynamic> game) {
    return game['title']?.toString() ?? 'Desconocido';
  }

  String? _gameId(Map<String, dynamic> game) {
    final id = game['id']?.toString();
    return id == null || id.isEmpty ? null : id;
  }

  String _roleName(Map<String, dynamic> role) {
    return role['role_name']?.toString() ??
        role['name']?.toString() ??
        'Desconocido';
  }

  String _rankName(Map<String, dynamic> rank) {
    return rank['rank_tier']?.toString() ??
        rank['tier']?.toString() ??
        rank['name']?.toString() ??
        'Desconocido';
  }

  Future<void> _showGamePicker(List<Map<String, dynamic>> games) async {
    final availableGames = games.where((game) {
      final id = _gameId(game);
      return id != null && !_selectedGames.contains(id);
    }).toList()
      ..sort((a, b) => _gameTitle(a).compareTo(_gameTitle(b)));

    if (availableGames.isEmpty) {
      _showError('Ya has agregado todos los juegos disponibles');
      return;
    }

    final selectedId = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: availableGames.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final game = availableGames[index];
              final id = _gameId(game);
              return ListTile(
                leading: const Icon(Icons.sports_esports),
                title: Text(_gameTitle(game)),
                onTap: id == null ? null : () => Navigator.pop(context, id),
              );
            },
          ),
        );
      },
    );

    if (selectedId == null || !mounted) return;

    setState(() {
      _selectedGameId = selectedId;
      _selectedPrimaryRank = null;
      _selectedSecondaryRank = null;
      _selectedMainRole = null;
      _selectedSecondaryRole = null;
    });
    ref.read(profileErrorProvider.notifier).clearError();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(profileLoadingProvider);
    final error = ref.watch(profileErrorProvider);
    final gamesAsyncValue = ref.watch(gamesListProvider);
    final rolesAsyncValue = _selectedGameId != null
        ? ref.watch(gameRolesProvider(_selectedGameId!))
        : const AsyncValue.data([]);
    final ranksAsyncValue = _selectedGameId != null
        ? ref.watch(gameRanksProvider(_selectedGameId!))
        : const AsyncValue.data([]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tus Juegos'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error message
              if (error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          error,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Juegos seleccionados
              if (_selectedGames.isNotEmpty) ...[
                Text(
                  'Tus Juegos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                ...gamesAsyncValue.when(
                  data: (games) => _selectedGames.map((gameId) {
                    final game = games.firstWhere(
                      (g) => _gameId(g) == gameId,
                      orElse: () => {'title': 'Desconocido'},
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        title: Text(game['title'] ?? 'Juego'),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() => _selectedGames.remove(gameId));
                          },
                        ),
                      ),
                    );
                  }).toList(),
                  loading: () => [
                    const Center(child: CircularProgressIndicator()),
                  ],
                  error: (_, __) => [
                    const Text('Error al cargar juegos'),
                  ],
                ),
                const SizedBox(height: 24),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 24),
              ],

              // Agregar nuevo juego
              Text(
                'Agregar Juego',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),

              // Seleccionar juego
              gamesAsyncValue.when(
                data: (games) {
                  final availableGames = games.where((g) {
                    final id = _gameId(g);
                    return id != null && !_selectedGames.contains(id);
                  }).toList();
                  if (games.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        border: Border.all(color: Colors.orange.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber,
                              color: Colors.orange.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No hay juegos disponibles. Verifica la conexión con la base de datos.',
                              style: TextStyle(color: Colors.orange.shade700),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  String? selectedGameTitle;
                  if (_selectedGameId != null) {
                    for (final game in games) {
                      if (_gameId(game) == _selectedGameId) {
                        selectedGameTitle = _gameTitle(game);
                        break;
                      }
                    }
                  }

                  return InkWell(
                    onTap: availableGames.isEmpty
                        ? null
                        : () => _showGamePicker(games),
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Juego',
                        prefixIcon: const Icon(Icons.sports_esports),
                        suffixIcon: const Icon(Icons.expand_more),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        selectedGameTitle ??
                            (availableGames.isEmpty
                                ? 'No quedan juegos disponibles'
                                : 'Selecciona un juego'),
                        style: TextStyle(
                          color: selectedGameTitle == null
                              ? Theme.of(context).hintColor
                              : null,
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Error al cargar juegos: $error',
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(gamesListProvider),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Rol principal
              if (_selectedGameId != null)
                rolesAsyncValue.when(
                  data: (roles) => DropdownButtonFormField<String>(
                    value: _selectedMainRole,
                    decoration: InputDecoration(
                      labelText: 'Rol Principal',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: roles
                        .map<DropdownMenuItem<String>>(
                            (role) => DropdownMenuItem<String>(
                                  value: role['id'].toString(),
                                  child: Text(_roleName(role)),
                                ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedMainRole = value);
                    },
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              if (_selectedGameId != null) const SizedBox(height: 16),

              // Rol secundario
              if (_selectedGameId != null)
                rolesAsyncValue.when(
                  data: (roles) => DropdownButtonFormField<String?>(
                    value: _selectedSecondaryRole,
                    decoration: InputDecoration(
                      labelText: 'Rol Secundario (Opcional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Ninguno'),
                      ),
                      ...roles
                          .where((r) => r['id'] != _selectedMainRole)
                          .map<DropdownMenuItem<String?>>(
                              (role) => DropdownMenuItem<String?>(
                                    value: role['id']?.toString(),
                                    child: Text(_roleName(role)),
                                  ))
                          .toList(),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedSecondaryRole = value);
                    },
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              if (_selectedGameId != null) const SizedBox(height: 16),

              // Rango principal
              if (_selectedGameId != null)
                ranksAsyncValue.when(
                  data: (ranks) => DropdownButtonFormField<String>(
                    value: _selectedPrimaryRank,
                    decoration: InputDecoration(
                      labelText: 'Rango Principal',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: ranks
                        .map<DropdownMenuItem<String>>(
                            (rank) => DropdownMenuItem<String>(
                                  value: rank['id'].toString(),
                                  child: Text(_rankName(rank)),
                                ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedPrimaryRank = value);
                    },
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              if (_selectedGameId != null) const SizedBox(height: 16),

              // Rango secundario
              if (_selectedGameId != null)
                ranksAsyncValue.when(
                  data: (ranks) => DropdownButtonFormField<String?>(
                    value: _selectedSecondaryRank,
                    decoration: InputDecoration(
                      labelText: 'Rango Secundario (Opcional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Ninguno'),
                      ),
                      ...ranks
                          .where((r) => r['id'] != _selectedPrimaryRank)
                          .map<DropdownMenuItem<String?>>(
                              (rank) => DropdownMenuItem<String?>(
                                    value: rank['id']?.toString(),
                                    child: Text(_rankName(rank)),
                                  ))
                          .toList(),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedSecondaryRank = value);
                    },
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              if (_selectedGameId != null) const SizedBox(height: 16),

              // Horas jugadas
              if (_selectedGameId != null)
                TextField(
                  enabled: !isLoading,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _playedHours = int.tryParse(value) ?? 0;
                  },
                  decoration: InputDecoration(
                    labelText: 'Horas Jugadas (Opcional)',
                    prefixIcon: const Icon(Icons.schedule),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              if (_selectedGameId != null) const SizedBox(height: 16),

              // ¿Solo casual?
              if (_selectedGameId != null)
                CheckboxListTile(
                  enabled: !isLoading,
                  value: _isCasualOnly,
                  onChanged: (value) {
                    setState(() => _isCasualOnly = value ?? false);
                  },
                  title: const Text('¿Solo juego casual?'),
                  contentPadding: EdgeInsets.zero,
                ),
              if (_selectedGameId != null) const SizedBox(height: 12),

              // Notas de skill
              if (_selectedGameId != null)
                TextField(
                  controller: _skillNotesController,
                  enabled: !isLoading,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notas sobre tu juego (Opcional)',
                    hintText: 'Ej: Buen comunicador, juego agresivo...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              if (_selectedGameId != null) const SizedBox(height: 20),

              // Botón agregar
              if (_selectedGameId != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _addGame,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Agregar Juego'),
                  ),
                ),

              const SizedBox(height: 32),

              // Botón finalizar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _finishSetup,
                  icon: const Icon(Icons.check),
                  label: const Text('Finalizar Setup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Puedes agregar más juegos luego',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
