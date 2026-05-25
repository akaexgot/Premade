import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_entity.freezed.dart';

@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String email,
    required String? nickname,
    required bool isEmailVerified,
    required DateTime createdAt,
  }) = _AuthUser;

  const AuthUser._();

  bool get isAuthenticated => id.isNotEmpty;
}

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required AuthUser user,
    required String? accessToken,
    required String? refreshToken,
  }) = _AuthResponse;
}

@freezed
class SignUpParams with _$SignUpParams {
  const factory SignUpParams({
    required String email,
    required String password,
    required String nickname,
    required int age,
    required String country,
  }) = _SignUpParams;
}

@freezed
class SignInParams with _$SignInParams {
  const factory SignInParams({
    required String email,
    required String password,
  }) = _SignInParams;
}

@freezed
class ResetPasswordParams with _$ResetPasswordParams {
  const factory ResetPasswordParams({
    required String email,
  }) = _ResetPasswordParams;
}
