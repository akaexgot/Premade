// User Entity
class UserEntity {
  final String id;
  final String email;
  final String nickname;
  final int age;
  final String country;
  final String? autonomousRegion;
  final String? province;
  final String? avatar;
  final String? bio;
  final String? discord;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserEntity({
    required this.id,
    required this.email,
    required this.nickname,
    required this.age,
    required this.country,
    this.autonomousRegion,
    this.province,
    this.avatar,
    this.bio,
    this.discord,
    required this.createdAt,
    required this.updatedAt,
  });
}
