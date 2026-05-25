import 'package:freezed_annotation/freezed_annotation.dart';

part 'matching_entity.freezed.dart';

/// Swipe action (like/dislike)
enum SwipeAction {
  like,
  dislike,
}

/// Match entre dos usuarios
@freezed
class Match with _$Match {
  const factory Match({
    required String id,
    required String userId1, // Quien inició el match
    required String userId2, // Quien fue matcheado
    required DateTime matchedAt,
    required String? chatGroupId, // ID del grupo de chat para ambos
    DateTime? unlockedAt, // Cuándo se revealó el match
  }) = _Match;
}

/// Swipe (like/dislike en un usuario)
@freezed
class Swipe with _$Swipe {
  const factory Swipe({
    required String id,
    required String fromUserId, // Quién hace el swipe
    required String toUserId, // A quién le hace el swipe
    required SwipeAction action, // like o dislike
    required DateTime swipedAt,
  }) = _Swipe;
}

/// Tarjeta de usuario para swiping
@freezed
class MatchCard with _$MatchCard {
  const factory MatchCard({
    required String userId,
    required String nickname,
    required int age,
    required String? avatarUrl,
    required String country,
    required double? compatibilityScore, // Score calculado por BD
    required List<String> games, // Lista de juegos
    required String? bio,
    required bool isOnline,
  }) = _MatchCard;
}

/// Parámetros para crear un swipe
@freezed
class CreateSwipeParams with _$CreateSwipeParams {
  const factory CreateSwipeParams({
    required String toUserId,
    required SwipeAction action,
  }) = _CreateSwipeParams;
}

/// Resultado de un swipe (puede resultar en match)
@freezed
class SwipeResult with _$SwipeResult {
  const factory SwipeResult({
    required Swipe swipe,
    required Match? matchCreated, // null si no hubo match
  }) = _SwipeResult;
}
