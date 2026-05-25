import '../entities/user_entity.dart';

abstract class SocialRepository {
  Future<void> addFriend({
    required String userId,
    required String friendId,
  });

  Future<void> blockUser({
    required String userId,
    required String blockedUserId,
  });

  Future<List<UserEntity>> getFriends(String userId);
}
