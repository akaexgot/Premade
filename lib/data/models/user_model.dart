// User Model - JSON serializable version
class UserModel {
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

  UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      nickname: json['nickname'],
      age: json['age'],
      country: json['country'],
      autonomousRegion: json['autonomous_region'],
      province: json['province'],
      avatar: json['avatar'],
      bio: json['bio'],
      discord: json['discord'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'age': age,
      'country': country,
      'autonomous_region': autonomousRegion,
      'province': province,
      'avatar': avatar,
      'bio': bio,
      'discord': discord,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
