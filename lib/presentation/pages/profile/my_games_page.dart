import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/core/theme/app_colors.dart';

class MyGamesPage extends ConsumerStatefulWidget {
  const MyGamesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MyGamesPage> createState() => _MyGamesPageState();
}

class _MyGamesPageState extends ConsumerState<MyGamesPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allGames = [];
  List<String> _userGameIds = [];

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);
    try {
      final supabase = ref.read(supabaseServiceProvider);
      // Usar getProfileId() — el PK real de la tabla users, no el auth_id
      final profileId = await supabase.getProfileId();
      if (profileId == null) return;

      // Cargar todos los juegos
      final gamesData = await supabase.client.from('games').select('*');

      // Cargar juegos del usuario usando el profile ID correcto
      final userGamesData = await supabase.client
          .from('user_games')
          .select('game_id')
          .eq('user_id', profileId);

      if (mounted) {
        setState(() {
          _allGames = List<Map<String, dynamic>>.from(gamesData);
          _userGameIds = (userGamesData as List)
              .map((g) => g['game_id'].toString())
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('DEBUG: Error en _loadGames: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleGame(String gameId, bool isSelected) async {
    final supabase = ref.read(supabaseServiceProvider);
    final profileId = await supabase.getProfileId();
    if (profileId == null) return;

    try {
      if (isSelected) {
        // Añadir
        await supabase.client.from('user_games').upsert(
          {
            'user_id': profileId,
            'game_id': gameId,
          },
          onConflict: 'user_id,game_id',
        );
        setState(() => _userGameIds.add(gameId));
      } else {
        // Quitar
        await supabase.client
            .from('user_games')
            .delete()
            .eq('user_id', profileId)
            .eq('game_id', gameId);
        setState(() => _userGameIds.remove(gameId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('Mis Juegos',
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allGames.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sports_esports_rounded,
                          size: 60, color: theme.textTheme.bodySmall?.color),
                      const SizedBox(height: 16),
                      Text('No hay juegos disponibles',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textPrimary)),
                      const SizedBox(height: 8),
                      Text('Verifica la conexión con la base de datos',
                          style: TextStyle(
                              color: theme.textTheme.bodySmall?.color)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _allGames.length,
                  itemBuilder: (context, index) {
                    final game = _allGames[index];
                    final gameId = game['id'].toString();
                    final isSelected = _userGameIds.contains(gameId);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        title: Text(game['title'] ?? 'Juego',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textPrimary)),
                        subtitle: Text(game['genre'] ?? 'Juego',
                            style: TextStyle(
                                color: theme.textTheme.bodySmall?.color)),
                        trailing: Switch(
                          value: isSelected,
                          activeColor: AppColors.primary,
                          onChanged: (val) => _toggleGame(gameId, val),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
