import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_entity.freezed.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    required String nickname,
    required int age,
    required String country,
    required String? autonomousRegion,
    required String? province,
    required String? avatarUrl,
    required String? bio,
    required String? discordUsername,
    required bool isOnline,
    required DateTime lastSeenAt,
    required bool isVerified,
    required DateTime createdAt,
    required DateTime? updatedAt,
  }) = _UserProfile;

  const UserProfile._();

  bool get isProfileComplete =>
      nickname.isNotEmpty && 
      bio != null && 
      bio!.isNotEmpty && 
      avatarUrl != null;
}

@freezed
class UserGameSelection with _$UserGameSelection {
  const factory UserGameSelection({
    required String gameId,
    required String gameName,
    required String? primaryRankId,
    required String? primaryRankName,
    required String? secondaryRankId,
    required String? secondaryRankName,
    required String? mainRoleId,
    required String? mainRoleName,
    required String? secondaryRoleId,
    required String? secondaryRoleName,
    required bool isCasualOnly,
    required int playedHours,
    required String? skillNotes,
  }) = _UserGameSelection;
}

@freezed
class UpdateProfileParams with _$UpdateProfileParams {
  const factory UpdateProfileParams({
    required String? nickname,
    required String? bio,
    required String? avatarUrl,
    required String? discordUsername,
    required String? autonomousRegion,
    required String? province,
  }) = _UpdateProfileParams;
}

@freezed
class AddUserGameParams with _$AddUserGameParams {
  const factory AddUserGameParams({
    required String gameId,
    required String? primaryRankId,
    required String? secondaryRankId,
    required String? mainRoleId,
    required String? secondaryRoleId,
    required bool isCasualOnly,
    required int playedHours,
    required String? skillNotes,
  }) = _AddUserGameParams;
}

@freezed
class UploadAvatarParams with _$UploadAvatarParams {
  const factory UploadAvatarParams({
    required String filePath,
    required String fileName,
  }) = _UploadAvatarParams;
}
