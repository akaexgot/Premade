import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/domain/entities/user_profile_entity.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfile> getUserProfile(String userId);
  Future<UserProfile> updateProfile(UpdateProfileParams params);
  Future<String> uploadAvatar(UploadAvatarParams params);
  Future<void> addUserGame(AddUserGameParams params);
  Future<List<UserGameSelection>> getUserGames(String userId);
  Future<void> removeUserGame(String gameId);
  Future<void> updateUserGame(AddUserGameParams params);
  Future<List<Map<String, dynamic>>> getGamesList();
  Future<List<Map<String, dynamic>>> getGameRoles(String gameId);
  Future<List<Map<String, dynamic>>> getGameRanks(String gameId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseService supabaseService;

  ProfileRemoteDataSourceImpl(this.supabaseService);

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final profile = await supabaseService.getUserProfile(userId);
      if (profile == null) {
        throw Exception('Perfil no encontrado');
      }

      return UserProfile(
        id: profile['id']?.toString() ?? '',
        email: profile['email']?.toString() ?? '',
        nickname: profile['nickname']?.toString() ?? 'Usuario',
        age: profile['age'] ?? 0,
        country: profile['country']?.toString() ?? '',
        autonomousRegion: profile['autonomous_region']?.toString(),
        province: profile['province']?.toString(),
        avatarUrl: profile['avatar_url']?.toString(),
        bio: profile['bio']?.toString(),
        discordUsername: profile['discord_username']?.toString(),
        isOnline: profile['is_online'] ?? false,
        // Handle null last_seen_at gracefully
        lastSeenAt: profile['last_seen_at'] != null
            ? DateTime.tryParse(profile['last_seen_at'].toString()) ??
                DateTime.now()
            : DateTime.now(),
        isVerified: profile['is_verified'] ?? false,
        createdAt: profile['created_at'] != null
            ? DateTime.tryParse(profile['created_at'].toString()) ??
                DateTime.now()
            : DateTime.now(),
        updatedAt: profile['updated_at'] != null
            ? DateTime.tryParse(profile['updated_at'].toString())
            : null,
      );
    } catch (e) {
      print('DEBUG ProfileRemoteDataSource.getUserProfile error: $e');
      rethrow;
    }
  }

  @override
  Future<UserProfile> updateProfile(UpdateProfileParams params) async {
    try {
      await supabaseService.updateUserProfile(
        nickname: params.nickname,
        bio: params.bio,
        avatarUrl: params.avatarUrl,
        discordUsername: params.discordUsername,
        autonomousRegion: params.autonomousRegion,
        province: params.province,
      );

      // Obtener el perfil actualizado usando currentUserId (auth UUID)
      final currentUserId = supabaseService.currentUserId;
      if (currentUserId == null) throw Exception('Usuario no autenticado');

      return await getUserProfile(currentUserId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> uploadAvatar(UploadAvatarParams params) async {
    try {
      final avatarUrl = await supabaseService.uploadAvatar(
        filePath: params.filePath,
        fileName: params.fileName,
      );
      await supabaseService.updateUserProfile(avatarUrl: avatarUrl);
      return avatarUrl;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addUserGame(AddUserGameParams params) async {
    try {
      await supabaseService.addUserGame(
        gameId: params.gameId,
        primaryRankId: params.primaryRankId,
        secondaryRankId: params.secondaryRankId,
        mainRoleId: params.mainRoleId,
        secondaryRoleId: params.secondaryRoleId,
        isCasualOnly: params.isCasualOnly,
        playedHours: params.playedHours,
        skillNotes: params.skillNotes,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<UserGameSelection>> getUserGames(String userId) async {
    try {
      final games = await supabaseService.getUserGames();
      return games.map((g) {
        final game = g['game'];
        final primaryRank = g['primary_rank'];
        final mainRole = g['main_role'];

        return UserGameSelection(
          gameId: g['game_id']?.toString() ?? '',
          gameName: game?['title']?.toString() ?? 'Juego',
          primaryRankId: g['primary_rank_id']?.toString(),
          primaryRankName: primaryRank?['rank_tier']?.toString() ??
              primaryRank?['tier']?.toString() ??
              primaryRank?['name']?.toString(),
          secondaryRankId: g['secondary_rank_id']?.toString(),
          secondaryRankName: null,
          mainRoleId: g['main_role_id']?.toString(),
          mainRoleName: mainRole?['role_name']?.toString() ??
              mainRole?['name']?.toString(),
          secondaryRoleId: g['secondary_role_id']?.toString(),
          secondaryRoleName: null,
          isCasualOnly: g['is_casual_only'] ?? false,
          playedHours: g['played_hours'] ?? 0,
          skillNotes: g['skill_notes']?.toString(),
        );
      }).toList();
    } catch (e) {
      print('DEBUG ProfileRemoteDataSource.getUserGames error: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeUserGame(String gameId) async {
    try {
      await supabaseService.removeUserGame(gameId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateUserGame(AddUserGameParams params) async {
    try {
      await supabaseService.updateUserGame(
        gameId: params.gameId,
        primaryRankId: params.primaryRankId,
        secondaryRankId: params.secondaryRankId,
        mainRoleId: params.mainRoleId,
        secondaryRoleId: params.secondaryRoleId,
        isCasualOnly: params.isCasualOnly,
        playedHours: params.playedHours,
        skillNotes: params.skillNotes,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getGamesList() async {
    try {
      return await supabaseService.getAllGames();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getGameRoles(String gameId) async {
    try {
      return await supabaseService.getGameRoles(gameId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getGameRanks(String gameId) async {
    try {
      return await supabaseService.getGameRanks(gameId);
    } catch (e) {
      rethrow;
    }
  }
}
