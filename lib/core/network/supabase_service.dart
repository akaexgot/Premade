import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para el servicio de Supabase
final supabaseServiceProvider =
    Provider<SupabaseService>((ref) => SupabaseService());

/// Servicio centralizado para todas las operaciones de Supabase
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  late SupabaseClient _client;

  SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  /// Inicializar Supabase (llamado en main.dart)
  Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: true,
      ),
    );
    _client = Supabase.instance.client;
    print(
        'DEBUG: Supabase inicializado. Usuario actual: ${_client.auth.currentUser?.id}');
  }

  /// Obtener instancia del cliente
  SupabaseClient get client => _client;

  /// Obtener usuario actual (getter)
  User? get currentUser => _client.auth.currentUser;

  /// Obtener usuario actual (método, alias del getter)
  User? getCurrentUser() => _client.auth.currentUser;

  /// Obtener session actual
  Session? get currentSession => _client.auth.currentSession;

  /// Verificar si está autenticado
  bool get isAuthenticated => currentUser != null;

  /// Obtener UUID del usuario actual (Auth ID)
  String? get currentUserId => currentUser?.id;

  /// Cache del ID de perfil real (public.users.id)
  String? _profileId;

  /// Limpiar cache al cerrar sesión o inicializar
  void _clearCache() {
    _profileId = null;
  }

  /// Limpiar datos cacheados cuando cambia la sesión activa.
  void clearProfileCache() {
    _clearCache();
  }

  /// Obtener el ID de perfil real (el PK de la tabla public.users)
  /// Se diferencia del Auth ID que devuelve currentUser.id
  Future<String?> getProfileId() async {
    if (_profileId != null) return _profileId;

    final authId = currentUserId;
    if (authId == null) return null;

    try {
      final response = await _client
          .from('users')
          .select('id')
          .eq('auth_id', authId)
          .maybeSingle();

      if (response != null) {
        _profileId = response['id'] as String;
      }
      return _profileId;
    } catch (e) {
      print('DEBUG: Error al obtener Profile ID: $e');
      return null;
    }
  }

  // ============================================================================
  // AUTENTICACIÓN
  // ============================================================================

  /// Registrar con email y password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Login con email y password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Login con Google
  Future<bool> signInWithGoogle() async {
    return await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutterquickstart://login-callback/',
    );
  }

  /// Logout
  Future<void> signOut() async {
    await _client.auth.signOut();
    _clearCache();
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // ============================================================================
  // DATABASE - USERS
  // ============================================================================

  /// Crear perfil de usuario después del registro
  Future<void> createUserProfile({
    String? userId,
    required String nickname,
    required int age,
    required String country,
    String? email,
    String? autonomousRegion,
    String? province,
    String? bio,
    String? discord,
  }) async {
    final uid = userId ?? currentUser?.id;
    if (uid == null) {
      print('DEBUG: SupabaseService.createUserProfile - ERROR: uid es null');
      throw Exception('Usuario no autenticado');
    }

    final userEmail = email ?? currentUser?.email ?? '';
    print(
        'DEBUG: SupabaseService.createUserProfile - Insertando en tabla "users" para el ID: $uid con email: $userEmail');

    try {
      await _client.from('users').insert({
        'auth_id': uid,
        'email': userEmail,
        'nickname': nickname,
        'age': age,
        'country': country,
        'autonomous_region': autonomousRegion,
        'province': province,
        'bio': bio,
        'discord_username': discord,
      });
      _clearCache();
      print('DEBUG: SupabaseService.createUserProfile - Inserción completada');
    } catch (e) {
      print('DEBUG: Error al insertar en tabla "users": $e');
      rethrow;
    }
  }

  /// Obtener perfil de usuario
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('auth_id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      print('DEBUG: Error al obtener perfil: $e');
      return null;
    }
  }

  /// Obtener un perfil publico por el ID real de public.users.
  Future<Map<String, dynamic>?> getPublicUserProfile(String profileId) async {
    try {
      const userGamesSelect =
          'user_games(*, game:games(*), main_role:game_roles!user_games_main_role_id_fkey(*), secondary_role:game_roles!user_games_secondary_role_id_fkey(*), primary_rank:game_ranks!user_games_primary_rank_id_fkey(*))';

      final response = await _client
          .from('users')
          .select('*, $userGamesSelect')
          .eq('id', profileId)
          .maybeSingle();
      return response;
    } catch (e) {
      print('DEBUG: Error al obtener perfil publico: $e');
      return null;
    }
  }

  /// Actualizar perfil de usuario
  Future<void> updateUserProfile({
    String? userId,
    String? nickname,
    int? age,
    String? bio,
    String? country,
    String? autonomousRegion,
    String? province,
    String? discord,
    String? discordUsername,
    String? avatarUrl,
  }) async {
    final uid = userId ?? currentUserId;
    if (uid == null) throw Exception('Usuario no autenticado');

    final updates = <String, dynamic>{};

    if (nickname != null) updates['nickname'] = nickname;
    if (age != null) updates['age'] = age;
    if (bio != null) updates['bio'] = bio;
    if (country != null) updates['country'] = country;
    if (autonomousRegion != null) {
      updates['autonomous_region'] = autonomousRegion;
    }
    if (province != null) updates['province'] = province;
    final discordValue = discordUsername ?? discord;
    if (discordValue != null) updates['discord_username'] = discordValue;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await _client.from('users').update(updates).eq('auth_id', uid);
  }

  /// Buscar usuarios con filtros avanzados
  Future<List<Map<String, dynamic>>> searchPlayers({
    String? nickname,
    String? gameTitle,
    bool? onlineOnly,
    int limit = 50,
  }) async {
    final currentId = currentUserId;

    // Si filtramos por juego, usamos !inner para asegurar que el usuario lo tenga
    // Incluimos roles y rangos para mostrarlos en el perfil
    const String ugSelect =
        'user_games(*, game:games(*), main_role:game_roles!user_games_main_role_id_fkey(*), secondary_role:game_roles!user_games_secondary_role_id_fkey(*), primary_rank:game_ranks!user_games_primary_rank_id_fkey(*))';

    String selectStr = '*, $ugSelect';
    if (gameTitle != null && gameTitle != 'Todos' && gameTitle != 'Online') {
      selectStr =
          '*, user_games!inner(*, game:games(*), main_role:game_roles!user_games_main_role_id_fkey(*), secondary_role:game_roles!user_games_secondary_role_id_fkey(*), primary_rank:game_ranks!user_games_primary_rank_id_fkey(*))';
    }

    var query = _client.from('users').select(selectStr);

    if (currentId != null) {
      query = query.neq('auth_id', currentId);
    }

    if (nickname != null && nickname.isNotEmpty) {
      query = query.ilike('nickname', '%$nickname%');
    }

    if (gameTitle != null && gameTitle != 'Todos' && gameTitle != 'Online') {
      query = query.eq('user_games.game.title', gameTitle);
    }

    if (onlineOnly == true || gameTitle == 'Online') {
      query = query.eq('is_online', true);
    }

    final response = await query.limit(limit);
    return List<Map<String, dynamic>>.from(response);
  }

  // ============================================================================
  // DATABASE - GAMES Y USER_GAMES
  // ============================================================================

  /// Obtener todos los juegos
  Future<List<Map<String, dynamic>>> getAllGames() async {
    return await _client.from('games').select();
  }

  /// Obtener juegos de un usuario
  Future<List<Map<String, dynamic>>> getUserGames([String? profileId]) async {
    final pid = profileId ?? await getProfileId();
    if (pid == null) return [];

    return await _client
        .from('user_games')
        .select(
            '*, game:games(*), primary_rank:game_ranks(*), main_role:game_roles(*)')
        .eq('user_id', pid);
  }

  /// Agregar juego a usuario
  Future<void> addUserGame({
    String? profileId,
    required String gameId,
    String? primaryRankId,
    String? secondaryRankId,
    String? mainRoleId,
    String? secondaryRoleId,
    bool isCasualOnly = false,
    bool isPrimary = false,
    int? playedHours,
    String? skillNotes,
  }) async {
    final pid = profileId ?? await getProfileId();
    if (pid == null) throw Exception('Usuario no autenticado');

    await _client.from('user_games').insert({
      'user_id': pid,
      'game_id': gameId,
      'primary_rank_id': primaryRankId,
      'secondary_rank_id': secondaryRankId,
      'main_role_id': mainRoleId,
      'secondary_role_id': secondaryRoleId,
      'is_casual_only': isCasualOnly,
      'is_primary': isPrimary,
      'played_hours': playedHours,
      'skill_notes': skillNotes,
    });
  }

  /// Eliminar juego de usuario
  Future<void> removeUserGame(String gameId) async {
    final pid = await getProfileId();
    if (pid == null) throw Exception('Usuario no autenticado');
    await _client
        .from('user_games')
        .delete()
        .eq('user_id', pid)
        .eq('game_id', gameId);
  }

  /// Actualizar juego de usuario
  Future<void> updateUserGame({
    required String gameId,
    String? primaryRankId,
    String? secondaryRankId,
    String? mainRoleId,
    String? secondaryRoleId,
    bool? isCasualOnly,
    int? playedHours,
    String? skillNotes,
  }) async {
    final pid = await getProfileId();
    if (pid == null) throw Exception('Usuario no autenticado');

    final updates = <String, dynamic>{};
    if (primaryRankId != null) updates['primary_rank_id'] = primaryRankId;
    if (secondaryRankId != null) updates['secondary_rank_id'] = secondaryRankId;
    if (mainRoleId != null) updates['main_role_id'] = mainRoleId;
    if (secondaryRoleId != null) updates['secondary_role_id'] = secondaryRoleId;
    if (isCasualOnly != null) updates['is_casual_only'] = isCasualOnly;
    if (playedHours != null) updates['played_hours'] = playedHours;
    if (skillNotes != null) updates['skill_notes'] = skillNotes;

    await _client
        .from('user_games')
        .update(updates)
        .eq('user_id', pid)
        .eq('game_id', gameId);
  }

  /// Obtener roles de un juego
  Future<List<Map<String, dynamic>>> getGameRoles(String gameId) async {
    return await _client.from('game_roles').select().eq('game_id', gameId);
  }

  /// Obtener rangos de un juego
  Future<List<Map<String, dynamic>>> getGameRanks(String gameId) async {
    return await _client
        .from('game_ranks')
        .select()
        .eq('game_id', gameId)
        .order('rank_order', ascending: true);
  }

  // ============================================================================
  // DATABASE - MATCHING (SWIPES Y MATCHES)
  // ============================================================================

  /// Obtener candidatos de matching
  Future<List<Map<String, dynamic>>> getMatchCandidates({
    required String authId,
    String? country,
    String? gameId,
    int limit = 10,
  }) async {
    final pid = await getProfileId();

    try {
      final params = {
        'p_user_id': pid,
        'p_country': country,
        'p_game_id': gameId,
        'p_limit': limit,
      };

      final response =
          await _client.rpc('get_match_candidates', params: params);
      if (response != null) {
        return List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      print(
          'DEBUG: Fallo al llamar a get_match_candidates RPC. Usando fallback... $e');
    }

    try {
      // Obtener IDs de usuarios ya evaluados (para excluirlos)
      final mySwipes = await _client
          .from('swipes')
          .select('target_user_id')
          .eq('user_id', pid ?? '');

      final List<String> swipedIds = (mySwipes as List)
          .map((s) => s['target_user_id'].toString())
          .toList();

      // Fallback manual
      // Si hay gameId, usamos !inner para filtrar usuarios que tengan ese juego
      String selectString = '*, user_games(game:games(*))';
      if (gameId != null) {
        selectString = '*, user_games!inner(game:games(*))';
      }

      var query =
          _client.from('users').select(selectString).neq('auth_id', authId);

      if (swipedIds.isNotEmpty) {
        query = query.not('id', 'in', swipedIds);
      }

      if (country != null) query = query.eq('country', country);
      if (gameId != null) query = query.eq('user_games.game_id', gameId);

      final result = await query.limit(limit);
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('DEBUG: Error en fallback getMatchCandidates: $e');
      return [];
    }
  }

  /// Registrar swipe (like/dislike/superlike) y devolver true si hay Match
  Future<bool> swipeUser({
    required String
        targetUserId, // Este ya es un Profile ID (viene de candidates)
    required String action, // 'like', 'dislike', 'superlike'
    double? compatibilityScore,
  }) async {
    final myProfileId = await getProfileId();
    if (myProfileId == null) throw Exception('Perfil no encontrado');
    final normalizedAction = action == 'pass' ? 'dislike' : action;

    // 1. Insertar el swipe actual
    await _client.from('swipes').upsert(
      {
        'user_id': myProfileId,
        'target_user_id': targetUserId,
        'action': normalizedAction,
        'compatibility_score': compatibilityScore,
      },
      onConflict: 'user_id,target_user_id',
    );

    // 2. Comprobar si es un like/superlike y el otro también nos dio like/superlike
    if (normalizedAction == 'like' || normalizedAction == 'superlike') {
      final reverseSwipe = await _client
          .from('swipes')
          .select()
          .eq('user_id', targetUserId)
          .eq('target_user_id', myProfileId)
          .inFilter('action', ['like', 'superlike']);

      if (reverseSwipe.isNotEmpty) {
        // ¡Match mutuo!
        await createMatch(userId1: myProfileId, userId2: targetUserId);
        return true;
      }
    }
    return false;
  }

  /// Obtener matches (conexiones bidireccionales)
  Future<List<Map<String, dynamic>>> getMatches([String? profileId]) async {
    final pid = profileId ?? await getProfileId();
    if (pid == null) return [];

    return await _client
        .from('matches')
        .select('*, user_1:users!user_id_1(*), user_2:users!user_id_2(*)')
        .or('user_id_1.eq.$pid,user_id_2.eq.$pid')
        .eq('is_active', true);
  }

  /// Crear match (después de swipes mutuos)
  Future<void> createMatch({
    required String userId1,
    required String userId2,
  }) async {
    final user1 = userId1.compareTo(userId2) < 0 ? userId1 : userId2;
    final user2 = userId1.compareTo(userId2) < 0 ? userId2 : userId1;

    await _client.from('matches').upsert(
      {
        'user_id_1': user1,
        'user_id_2': user2,
      },
      onConflict: 'user_id_1,user_id_2',
    );
  }

  // ============================================================================
  // DATABASE - CHAT Y MENSAJES
  // ============================================================================

  /// Obtener conversaciones de un usuario
  Future<List<Map<String, dynamic>>> getConversations(
      [String? profileId]) async {
    final pid = profileId ?? await getProfileId();
    if (pid == null) return [];

    return await _client
        .from('conversation_participants')
        .select(
          'id, conversation:conversations(id, is_group, created_at, messages(content, created_at, sender_id), group:groups(name))',
        )
        .eq('user_id', pid)
        .order('joined_at', ascending: false);
  }

  /// Obtener o crear una conversación 1-a-1 con otro usuario
  Future<String> getOrCreateConversation(String otherUserId) async {
    final myProfileId = await getProfileId();
    if (myProfileId == null) throw Exception('Usuario no autenticado');

    // 1. Buscar si ya existe una conversación 1-a-1 entre ambos
    final myConversations = await _client
        .from('conversation_participants')
        .select('conversation_id')
        .eq('user_id', myProfileId);

    final myConvIds = List<String>.from(
        myConversations.map((c) => c['conversation_id'].toString()));

    if (myConvIds.isNotEmpty) {
      final sharedConv = await _client
          .from('conversation_participants')
          .select('conversation_id')
          .eq('user_id', otherUserId)
          .filter('conversation_id', 'in', '(${myConvIds.join(',')})')
          .maybeSingle();

      if (sharedConv != null) {
        return sharedConv['conversation_id'].toString();
      }
    }

    // 2. Si no existe, crearla
    return await createConversation(
      isGroup: false,
      participantIds: [myProfileId, otherUserId],
    );
  }

  /// Obtener mensajes de una conversación
  Future<List<Map<String, dynamic>>> getMessages(
    String conversationId, {
    int limit = 50,
  }) async {
    return await _client
        .from('messages')
        .select('*, sender:users(id, nickname, avatar_url)')
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .limit(limit);
  }

  /// Enviar mensaje
  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final pid = await getProfileId();
    if (pid == null) throw Exception('Usuario no autenticado');

    return await _client
        .from('messages')
        .insert({
          'conversation_id': conversationId,
          'sender_id': pid,
          'content': content,
        })
        .select('*, sender:users(id, nickname, avatar_url)')
        .single();
  }

  /// Crear conversación 1-a-1 o grupal
  Future<String> createConversation({
    bool isGroup = false,
    String? groupId,
    List<String>? participantIds,
  }) async {
    final response = await _client
        .from('conversations')
        .insert({
          'is_group': isGroup,
          'group_id': groupId,
        })
        .select()
        .single();

    final conversationId = response['id'];

    // Agregar participantes
    if (participantIds != null && participantIds.isNotEmpty) {
      for (final uid in participantIds) {
        await _client.from('conversation_participants').upsert(
          {
            'conversation_id': conversationId,
            'user_id': uid,
          },
          onConflict: 'conversation_id,user_id',
        );
      }
    }

    return conversationId;
  }

  /// Suscribirse a mensajes en tiempo real
  Stream<Map<String, dynamic>> subscribeToMessages(String conversationId) {
    final controller = StreamController<Map<String, dynamic>>.broadcast();

    final channel = _client
        .channel('messages:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            if (payload.newRecord.isNotEmpty) {
              controller.add(payload.newRecord);
            }
          },
        )
        .subscribe();

    controller.onCancel = () {
      channel.unsubscribe();
      controller.close();
    };

    return controller.stream;
  }

  // ============================================================================
  // DATABASE - SOCIAL (AMIGOS, BLOQUES)
  // ============================================================================

  /// Obtener amigos de un usuario
  Future<List<Map<String, dynamic>>> getFriends([String? profileId]) async {
    final pid = profileId ?? await getProfileId();
    if (pid == null) return [];

    return await _client
        .from('friendships')
        .select(
          'user_1:user_id_1(id, nickname, avatar_url, is_online), user_2:user_id_2(id, nickname, avatar_url, is_online)',
        )
        .or('user_id_1.eq.$pid,user_id_2.eq.$pid')
        .eq('status', 'accepted');
  }

  /// Obtener el estado de amistad con un usuario específico
  Future<String?> getFriendshipStatus(String targetProfileId) async {
    final myProfileId = await getProfileId();
    if (myProfileId == null) return null;

    final user1 = myProfileId.compareTo(targetProfileId) < 0
        ? myProfileId
        : targetProfileId;
    final user2 = myProfileId.compareTo(targetProfileId) < 0
        ? targetProfileId
        : myProfileId;

    final response = await _client
        .from('friendships')
        .select('status')
        .eq('user_id_1', user1)
        .eq('user_id_2', user2)
        .maybeSingle();

    return response?['status'] as String?;
  }

  /// Enviar solicitud de amistad
  Future<void> sendFriendRequest(String targetProfileId) async {
    final myProfileId = await getProfileId();
    if (myProfileId == null) throw Exception('Usuario no autenticado');

    final user1 = myProfileId.compareTo(targetProfileId) < 0
        ? myProfileId
        : targetProfileId;
    final user2 = myProfileId.compareTo(targetProfileId) < 0
        ? targetProfileId
        : myProfileId;

    await _client.from('friendships').upsert(
      {
        'user_id_1': user1,
        'user_id_2': user2,
        'requested_by': myProfileId,
        'status': 'pending',
      },
      onConflict: 'user_id_1,user_id_2',
    );
  }

  /// Obtener solicitudes de amistad pendientes recibidas
  Future<List<Map<String, dynamic>>> getPendingRequests() async {
    final myProfileId = await getProfileId();
    if (myProfileId == null) return [];

    return await _client
        .from('friendships')
        .select('*, requester:requested_by(*)')
        .eq('status', 'pending')
        .neq('requested_by', myProfileId)
        .or('user_id_1.eq.$myProfileId,user_id_2.eq.$myProfileId');
  }

  /// Responder a una solicitud (aceptar o rechazar)
  Future<void> respondToFriendRequest(String requesterId, bool accept) async {
    final myProfileId = await getProfileId();
    if (myProfileId == null) return;

    if (accept) {
      await _client
          .from('friendships')
          .update({'status': 'accepted'})
          .eq('requested_by', requesterId)
          .or('user_id_1.eq.$myProfileId,user_id_2.eq.$myProfileId');
    } else {
      await _client
          .from('friendships')
          .delete()
          .eq('requested_by', requesterId)
          .or('user_id_1.eq.$myProfileId,user_id_2.eq.$myProfileId');
    }
  }

  /// Bloquear usuario
  Future<void> blockUser(String blockedProfileId) async {
    final myProfileId = await getProfileId();
    if (myProfileId == null) throw Exception('Usuario no autenticado');

    await _client.from('blocks').insert({
      'blocker_user_id': myProfileId,
      'blocked_user_id': blockedProfileId,
    });
  }

  /// Desbloquear usuario
  Future<void> unblockUser(String unblockedProfileId) async {
    final myProfileId = await getProfileId();
    if (myProfileId == null) throw Exception('Usuario no autenticado');

    await _client
        .from('blocks')
        .delete()
        .eq('blocker_user_id', myProfileId)
        .eq('blocked_user_id', unblockedProfileId);
  }

  /// Verificar si un usuario está bloqueado
  Future<bool> isUserBlocked(String profileId) async {
    final myProfileId = await getProfileId();
    if (myProfileId == null) return false;

    final result = await _client
        .from('blocks')
        .select('id')
        .eq('blocker_user_id', myProfileId)
        .eq('blocked_user_id', profileId)
        .maybeSingle();
    return result != null;
  }

  /// Reportar usuario
  Future<void> reportUser({
    required String reportedProfileId,
    required String reason,
    String? details,
  }) async {
    final myProfileId = await getProfileId();
    if (myProfileId == null) throw Exception('Usuario no autenticado');

    try {
      await _client.from('reports').insert({
        'reporter_user_id': myProfileId,
        'reported_user_id': reportedProfileId,
        'reason': reason,
        'description': details,
      });
    } catch (e) {
      if (!e.toString().contains('reporter_user_id') &&
          !e.toString().contains('reported_user_id') &&
          !e.toString().contains('description')) {
        rethrow;
      }

      await _client.from('reports').insert({
        'reporter_id': myProfileId,
        'reported_id': reportedProfileId,
        'reason': reason,
        'details': details,
      });
    }
  }

  // ============================================================================
  // DATABASE - NOTIFICACIONES
  // ============================================================================

  /// Obtener notificaciones
  Future<List<Map<String, dynamic>>> getNotifications({
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    final pid = await getProfileId();
    if (pid == null) return [];

    if (unreadOnly) {
      return await _client
          .from('notifications')
          .select()
          .eq('user_id', pid)
          .eq('is_read', false)
          .order('created_at', ascending: false)
          .limit(limit);
    }

    return await _client
        .from('notifications')
        .select()
        .eq('user_id', pid)
        .order('created_at', ascending: false)
        .limit(limit);
  }

  /// Marcar notificación como leída
  Future<void> markNotificationAsRead(String notificationId) async {
    await _client.from('notifications').update({
      'is_read': true,
      'read_at': DateTime.now().toIso8601String(),
    }).eq('id', notificationId);
  }

  // ============================================================================
  // STORAGE (AVATARES)
  // ============================================================================

  /// Subir avatar a Storage de Supabase
  Future<String> uploadAvatar({
    required String filePath,
    String? fileName,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    final file = File(filePath);
    final name = fileName ?? 'avatar_$userId.jpg';

    await _client.storage
        .from('avatars')
        .upload(name, file, fileOptions: const FileOptions(upsert: true));

    return _client.storage.from('avatars').getPublicUrl(name);
  }

  // ============================================================================
  // FUNCIONES AUXILIARES
  // ============================================================================

  /// Generar URL de imagen desde Supabase
  String getImageUrl(String bucketName, String filePath) {
    return _client.storage.from(bucketName).getPublicUrl(filePath);
  }

  /// Obtener RPC personalizado
  Future<dynamic> callRpc(String functionName,
      {Map<String, dynamic>? params}) async {
    return await _client.rpc(functionName, params: params);
  }
}
