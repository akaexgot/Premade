import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/domain/entities/matching_entity.dart';

/// Interface abstracta para operaciones remotas de matching
abstract class MatchingRemoteDataSource {
  Future<List<MatchCard>> getMatchCandidates();
  Future<SwipeResult> createSwipe(CreateSwipeParams params);
  Future<List<Match>> getUserMatches();
  Future<List<Swipe>> getUserSwipes();
  Future<List<Swipe>> getReceivedSwipes();
  Future<Match> unlockMatch(String matchId);
  Future<Match> getMatchDetails(String matchId);
}

/// Implementación de operaciones remotas con Supabase
class MatchingRemoteDataSourceImpl implements MatchingRemoteDataSource {
  final SupabaseService supabaseService;

  MatchingRemoteDataSourceImpl(this.supabaseService);

  @override
  Future<List<MatchCard>> getMatchCandidates() async {
    print('DEBUG: MatchingRemoteDataSource.getMatchCandidates() llamado');
    print('DEBUG: currentUserId = ${supabaseService.currentUserId}');

    final candidates = await supabaseService.getMatchCandidates(
      authId: supabaseService.currentUserId ?? '',
    );

    print('DEBUG: Candidatos obtenidos de Supabase: ${candidates.length}');
    if (candidates.isNotEmpty) {
      print('DEBUG: Primer candidato: ${candidates.first}');
    }

    return candidates
        .map((candidate) => MatchCard(
              userId:
                  (candidate['user_id'] ?? candidate['id'])?.toString() ?? '',
              nickname: candidate['nickname']?.toString() ?? 'Sin nombre',
              age: (candidate['age'] as num?)?.toInt() ?? 0,
              avatarUrl: candidate['avatar_url']?.toString(),
              country: candidate['country']?.toString() ?? 'Unknown',
              compatibilityScore:
                  (candidate['compatibility_score'] as num?)?.toDouble(),
              games: _extractGames(candidate),
              bio: candidate['bio']?.toString(),
              isOnline: candidate['is_online'] == true,
            ))
        .toList();
  }

  @override
  Future<SwipeResult> createSwipe(CreateSwipeParams params) async {
    final myProfileId = await supabaseService.getProfileId();
    final isMatch = await supabaseService.swipeUser(
      targetUserId: params.toUserId,
      action: params.action.name,
    );

    final swipe = Swipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fromUserId: myProfileId ?? '',
      toUserId: params.toUserId,
      action: params.action,
      swipedAt: DateTime.now(),
    );

    Match? matchCreated;
    if (isMatch) {
      matchCreated = Match(
        id: '${myProfileId}_${params.toUserId}', // Dummy ID since we don't fetch the real one yet
        userId1: myProfileId ?? '',
        userId2: params.toUserId,
        matchedAt: DateTime.now(),
        chatGroupId: null, // Let the backend trigger create the chat group
      );
    }

    return SwipeResult(swipe: swipe, matchCreated: matchCreated);
  }

  @override
  Future<List<Match>> getUserMatches() async {
    final matches = await supabaseService.getMatches();

    return matches
        .map((match) => Match(
              id: match['id'],
              userId1: match['user_id_1'],
              userId2: match['user_id_2'],
              matchedAt: DateTime.parse(
                (match['matched_at'] ?? match['created_at']).toString(),
              ),
              chatGroupId: match['group_id'],
            ))
        .toList();
  }

  @override
  Future<List<Swipe>> getUserSwipes() async {
    // TODO: Implementar con función RPC o query específica
    return [];
  }

  @override
  Future<List<Swipe>> getReceivedSwipes() async {
    // TODO: Implementar con función RPC o query específica
    return [];
  }

  @override
  Future<Match> unlockMatch(String matchId) async {
    // TODO: Implementar desbloqueo de match
    throw UnimplementedError();
  }

  @override
  Future<Match> getMatchDetails(String matchId) async {
    // TODO: Implementar obtención de detalles
    throw UnimplementedError();
  }

  /// Extraer juegos desde candidate data
  List<String> _extractGames(Map<String, dynamic> candidate) {
    try {
      // Caso 1: Array simple de strings (desde el RPC)
      if (candidate['games'] is List) {
        return List<String>.from(candidate['games']);
      }

      // Caso 2: Desde el fallback (relación user_games)
      if (candidate['user_games'] is List) {
        return (candidate['user_games'] as List)
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
    } catch (e) {
      print('DEBUG: Error al extraer juegos: $e');
      return [];
    }
  }
}
