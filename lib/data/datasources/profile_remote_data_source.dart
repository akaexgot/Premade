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
        id: profile['id'],
        email: profile['email'],
        nickname: profile['nickname'],
        age: profile['age'],
        country: profile['country'],
        autonomousRegion: profile['autonomous_region'],
        province: profile['province'],
        avatarUrl: profile['avatar_url'],
        bio: profile['bio'],
        discordUsername: profile['discord_username'],
        isOnline: profile['is_online'],
        lastSeenAt: DateTime.parse(profile['last_seen_at']),
        isVerified: profile['is_verified'],
        createdAt: DateTime.parse(profile['created_at']),
        updatedAt: profile['updated_at'] != null
            ? DateTime.parse(profile['updated_at'])
            : null,
      );
    } catch (e) {
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

      // Obtener el perfil actualizado
      final currentUserId = supabaseService.getCurrentUser()?.id;
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
      final games = await supabaseService.getUserGames(userId);
      return games
          .map((g) => UserGameSelection(
                gameId: g['game_id'],
                gameName: g['game']?['title'] ?? 'Unknown',
                primaryRankId: g['primary_rank_id'],
                primaryRankName: g['primary_rank']?['rank_tier'] ??
                    g['primary_rank']?['tier'] ??
                    g['primary_rank']?['name'],
                secondaryRankId: g['secondary_rank_id'],
                secondaryRankName: g['secondary_rank']?['rank_tier'] ??
                    g['secondary_rank']?['tier'] ??
                    g['secondary_rank']?['name'],
                mainRoleId: g['main_role_id'],
                mainRoleName:
                    g['main_role']?['role_name'] ?? g['main_role']?['name'],
                secondaryRoleId: g['secondary_role_id'],
                secondaryRoleName: g['secondary_role']?['role_name'] ??
                    g['secondary_role']?['name'],
                isCasualOnly: g['is_casual_only'],
                playedHours: g['played_hours'] ?? 0,
                skillNotes: g['skill_notes'],
              ))
          .toList();
    } catch (e) {
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
