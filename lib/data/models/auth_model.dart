// Auth Model
class AuthModel {
  final String token;
  final String refreshToken;
  final String userId;

  AuthModel({
    required this.token,
    required this.refreshToken,
    required this.userId,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'],
      refreshToken: json['refresh_token'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refresh_token': refreshToken,
      'user_id': userId,
    };
  }
}
