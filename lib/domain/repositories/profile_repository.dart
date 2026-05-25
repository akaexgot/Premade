import '../entities/user_entity.dart';

abstract class ProfileRepository {
  Future<UserEntity> getUserProfile(String userId);
  Future<void> updateUserProfile(UserEntity user);
  Future<void> updateAvatar(String userId, String imagePath);
}
