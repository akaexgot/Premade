// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'matching_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Match {
  String get id => throw _privateConstructorUsedError;
  String get userId1 =>
      throw _privateConstructorUsedError; // Quien inició el match
  String get userId2 =>
      throw _privateConstructorUsedError; // Quien fue matcheado
  DateTime get matchedAt => throw _privateConstructorUsedError;
  String? get chatGroupId =>
      throw _privateConstructorUsedError; // ID del grupo de chat para ambos
  DateTime? get unlockedAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MatchCopyWith<Match> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchCopyWith<$Res> {
  factory $MatchCopyWith(Match value, $Res Function(Match) then) =
      _$MatchCopyWithImpl<$Res, Match>;
  @useResult
  $Res call(
      {String id,
      String userId1,
      String userId2,
      DateTime matchedAt,
      String? chatGroupId,
      DateTime? unlockedAt});
}

/// @nodoc
class _$MatchCopyWithImpl<$Res, $Val extends Match>
    implements $MatchCopyWith<$Res> {
  _$MatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId1 = null,
    Object? userId2 = null,
    Object? matchedAt = null,
    Object? chatGroupId = freezed,
    Object? unlockedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId1: null == userId1
          ? _value.userId1
          : userId1 // ignore: cast_nullable_to_non_nullable
              as String,
      userId2: null == userId2
          ? _value.userId2
          : userId2 // ignore: cast_nullable_to_non_nullable
              as String,
      matchedAt: null == matchedAt
          ? _value.matchedAt
          : matchedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      chatGroupId: freezed == chatGroupId
          ? _value.chatGroupId
          : chatGroupId // ignore: cast_nullable_to_non_nullable
              as String?,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MatchImplCopyWith<$Res> implements $MatchCopyWith<$Res> {
  factory _$$MatchImplCopyWith(
          _$MatchImpl value, $Res Function(_$MatchImpl) then) =
      __$$MatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId1,
      String userId2,
      DateTime matchedAt,
      String? chatGroupId,
      DateTime? unlockedAt});
}

/// @nodoc
class __$$MatchImplCopyWithImpl<$Res>
    extends _$MatchCopyWithImpl<$Res, _$MatchImpl>
    implements _$$MatchImplCopyWith<$Res> {
  __$$MatchImplCopyWithImpl(
      _$MatchImpl _value, $Res Function(_$MatchImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId1 = null,
    Object? userId2 = null,
    Object? matchedAt = null,
    Object? chatGroupId = freezed,
    Object? unlockedAt = freezed,
  }) {
    return _then(_$MatchImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId1: null == userId1
          ? _value.userId1
          : userId1 // ignore: cast_nullable_to_non_nullable
              as String,
      userId2: null == userId2
          ? _value.userId2
          : userId2 // ignore: cast_nullable_to_non_nullable
              as String,
      matchedAt: null == matchedAt
          ? _value.matchedAt
          : matchedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      chatGroupId: freezed == chatGroupId
          ? _value.chatGroupId
          : chatGroupId // ignore: cast_nullable_to_non_nullable
              as String?,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$MatchImpl implements _Match {
  const _$MatchImpl(
      {required this.id,
      required this.userId1,
      required this.userId2,
      required this.matchedAt,
      required this.chatGroupId,
      this.unlockedAt});

  @override
  final String id;
  @override
  final String userId1;
// Quien inició el match
  @override
  final String userId2;
// Quien fue matcheado
  @override
  final DateTime matchedAt;
  @override
  final String? chatGroupId;
// ID del grupo de chat para ambos
  @override
  final DateTime? unlockedAt;

  @override
  String toString() {
    return 'Match(id: $id, userId1: $userId1, userId2: $userId2, matchedAt: $matchedAt, chatGroupId: $chatGroupId, unlockedAt: $unlockedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId1, userId1) || other.userId1 == userId1) &&
            (identical(other.userId2, userId2) || other.userId2 == userId2) &&
            (identical(other.matchedAt, matchedAt) ||
                other.matchedAt == matchedAt) &&
            (identical(other.chatGroupId, chatGroupId) ||
                other.chatGroupId == chatGroupId) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, userId1, userId2, matchedAt, chatGroupId, unlockedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchImplCopyWith<_$MatchImpl> get copyWith =>
      __$$MatchImplCopyWithImpl<_$MatchImpl>(this, _$identity);
}

abstract class _Match implements Match {
  const factory _Match(
      {required final String id,
      required final String userId1,
      required final String userId2,
      required final DateTime matchedAt,
      required final String? chatGroupId,
      final DateTime? unlockedAt}) = _$MatchImpl;

  @override
  String get id;
  @override
  String get userId1;
  @override // Quien inició el match
  String get userId2;
  @override // Quien fue matcheado
  DateTime get matchedAt;
  @override
  String? get chatGroupId;
  @override // ID del grupo de chat para ambos
  DateTime? get unlockedAt;
  @override
  @JsonKey(ignore: true)
  _$$MatchImplCopyWith<_$MatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Swipe {
  String get id => throw _privateConstructorUsedError;
  String get fromUserId =>
      throw _privateConstructorUsedError; // Quién hace el swipe
  String get toUserId =>
      throw _privateConstructorUsedError; // A quién le hace el swipe
  SwipeAction get action => throw _privateConstructorUsedError; // like o pass
  DateTime get swipedAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SwipeCopyWith<Swipe> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SwipeCopyWith<$Res> {
  factory $SwipeCopyWith(Swipe value, $Res Function(Swipe) then) =
      _$SwipeCopyWithImpl<$Res, Swipe>;
  @useResult
  $Res call(
      {String id,
      String fromUserId,
      String toUserId,
      SwipeAction action,
      DateTime swipedAt});
}

/// @nodoc
class _$SwipeCopyWithImpl<$Res, $Val extends Swipe>
    implements $SwipeCopyWith<$Res> {
  _$SwipeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fromUserId = null,
    Object? toUserId = null,
    Object? action = null,
    Object? swipedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fromUserId: null == fromUserId
          ? _value.fromUserId
          : fromUserId // ignore: cast_nullable_to_non_nullable
              as String,
      toUserId: null == toUserId
          ? _value.toUserId
          : toUserId // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as SwipeAction,
      swipedAt: null == swipedAt
          ? _value.swipedAt
          : swipedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SwipeImplCopyWith<$Res> implements $SwipeCopyWith<$Res> {
  factory _$$SwipeImplCopyWith(
          _$SwipeImpl value, $Res Function(_$SwipeImpl) then) =
      __$$SwipeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String fromUserId,
      String toUserId,
      SwipeAction action,
      DateTime swipedAt});
}

/// @nodoc
class __$$SwipeImplCopyWithImpl<$Res>
    extends _$SwipeCopyWithImpl<$Res, _$SwipeImpl>
    implements _$$SwipeImplCopyWith<$Res> {
  __$$SwipeImplCopyWithImpl(
      _$SwipeImpl _value, $Res Function(_$SwipeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fromUserId = null,
    Object? toUserId = null,
    Object? action = null,
    Object? swipedAt = null,
  }) {
    return _then(_$SwipeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fromUserId: null == fromUserId
          ? _value.fromUserId
          : fromUserId // ignore: cast_nullable_to_non_nullable
              as String,
      toUserId: null == toUserId
          ? _value.toUserId
          : toUserId // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as SwipeAction,
      swipedAt: null == swipedAt
          ? _value.swipedAt
          : swipedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$SwipeImpl implements _Swipe {
  const _$SwipeImpl(
      {required this.id,
      required this.fromUserId,
      required this.toUserId,
      required this.action,
      required this.swipedAt});

  @override
  final String id;
  @override
  final String fromUserId;
// Quién hace el swipe
  @override
  final String toUserId;
// A quién le hace el swipe
  @override
  final SwipeAction action;
// like o pass
  @override
  final DateTime swipedAt;

  @override
  String toString() {
    return 'Swipe(id: $id, fromUserId: $fromUserId, toUserId: $toUserId, action: $action, swipedAt: $swipedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SwipeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fromUserId, fromUserId) ||
                other.fromUserId == fromUserId) &&
            (identical(other.toUserId, toUserId) ||
                other.toUserId == toUserId) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.swipedAt, swipedAt) ||
                other.swipedAt == swipedAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, fromUserId, toUserId, action, swipedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SwipeImplCopyWith<_$SwipeImpl> get copyWith =>
      __$$SwipeImplCopyWithImpl<_$SwipeImpl>(this, _$identity);
}

abstract class _Swipe implements Swipe {
  const factory _Swipe(
      {required final String id,
      required final String fromUserId,
      required final String toUserId,
      required final SwipeAction action,
      required final DateTime swipedAt}) = _$SwipeImpl;

  @override
  String get id;
  @override
  String get fromUserId;
  @override // Quién hace el swipe
  String get toUserId;
  @override // A quién le hace el swipe
  SwipeAction get action;
  @override // like o pass
  DateTime get swipedAt;
  @override
  @JsonKey(ignore: true)
  _$$SwipeImplCopyWith<_$SwipeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MatchCard {
  String get userId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  int get age => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  double? get compatibilityScore =>
      throw _privateConstructorUsedError; // Score calculado por BD
  List<String> get games =>
      throw _privateConstructorUsedError; // Lista de juegos
  String? get bio => throw _privateConstructorUsedError;
  bool get isOnline => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MatchCardCopyWith<MatchCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchCardCopyWith<$Res> {
  factory $MatchCardCopyWith(MatchCard value, $Res Function(MatchCard) then) =
      _$MatchCardCopyWithImpl<$Res, MatchCard>;
  @useResult
  $Res call(
      {String userId,
      String nickname,
      int age,
      String? avatarUrl,
      String country,
      double? compatibilityScore,
      List<String> games,
      String? bio,
      bool isOnline});
}

/// @nodoc
class _$MatchCardCopyWithImpl<$Res, $Val extends MatchCard>
    implements $MatchCardCopyWith<$Res> {
  _$MatchCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? age = null,
    Object? avatarUrl = freezed,
    Object? country = null,
    Object? compatibilityScore = freezed,
    Object? games = null,
    Object? bio = freezed,
    Object? isOnline = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      compatibilityScore: freezed == compatibilityScore
          ? _value.compatibilityScore
          : compatibilityScore // ignore: cast_nullable_to_non_nullable
              as double?,
      games: null == games
          ? _value.games
          : games // ignore: cast_nullable_to_non_nullable
              as List<String>,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MatchCardImplCopyWith<$Res>
    implements $MatchCardCopyWith<$Res> {
  factory _$$MatchCardImplCopyWith(
          _$MatchCardImpl value, $Res Function(_$MatchCardImpl) then) =
      __$$MatchCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String nickname,
      int age,
      String? avatarUrl,
      String country,
      double? compatibilityScore,
      List<String> games,
      String? bio,
      bool isOnline});
}

/// @nodoc
class __$$MatchCardImplCopyWithImpl<$Res>
    extends _$MatchCardCopyWithImpl<$Res, _$MatchCardImpl>
    implements _$$MatchCardImplCopyWith<$Res> {
  __$$MatchCardImplCopyWithImpl(
      _$MatchCardImpl _value, $Res Function(_$MatchCardImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? age = null,
    Object? avatarUrl = freezed,
    Object? country = null,
    Object? compatibilityScore = freezed,
    Object? games = null,
    Object? bio = freezed,
    Object? isOnline = null,
  }) {
    return _then(_$MatchCardImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      compatibilityScore: freezed == compatibilityScore
          ? _value.compatibilityScore
          : compatibilityScore // ignore: cast_nullable_to_non_nullable
              as double?,
      games: null == games
          ? _value._games
          : games // ignore: cast_nullable_to_non_nullable
              as List<String>,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$MatchCardImpl implements _MatchCard {
  const _$MatchCardImpl(
      {required this.userId,
      required this.nickname,
      required this.age,
      required this.avatarUrl,
      required this.country,
      required this.compatibilityScore,
      required final List<String> games,
      required this.bio,
      required this.isOnline})
      : _games = games;

  @override
  final String userId;
  @override
  final String nickname;
  @override
  final int age;
  @override
  final String? avatarUrl;
  @override
  final String country;
  @override
  final double? compatibilityScore;
// Score calculado por BD
  final List<String> _games;
// Score calculado por BD
  @override
  List<String> get games {
    if (_games is EqualUnmodifiableListView) return _games;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_games);
  }

// Lista de juegos
  @override
  final String? bio;
  @override
  final bool isOnline;

  @override
  String toString() {
    return 'MatchCard(userId: $userId, nickname: $nickname, age: $age, avatarUrl: $avatarUrl, country: $country, compatibilityScore: $compatibilityScore, games: $games, bio: $bio, isOnline: $isOnline)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchCardImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.compatibilityScore, compatibilityScore) ||
                other.compatibilityScore == compatibilityScore) &&
            const DeepCollectionEquality().equals(other._games, _games) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      nickname,
      age,
      avatarUrl,
      country,
      compatibilityScore,
      const DeepCollectionEquality().hash(_games),
      bio,
      isOnline);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchCardImplCopyWith<_$MatchCardImpl> get copyWith =>
      __$$MatchCardImplCopyWithImpl<_$MatchCardImpl>(this, _$identity);
}

abstract class _MatchCard implements MatchCard {
  const factory _MatchCard(
      {required final String userId,
      required final String nickname,
      required final int age,
      required final String? avatarUrl,
      required final String country,
      required final double? compatibilityScore,
      required final List<String> games,
      required final String? bio,
      required final bool isOnline}) = _$MatchCardImpl;

  @override
  String get userId;
  @override
  String get nickname;
  @override
  int get age;
  @override
  String? get avatarUrl;
  @override
  String get country;
  @override
  double? get compatibilityScore;
  @override // Score calculado por BD
  List<String> get games;
  @override // Lista de juegos
  String? get bio;
  @override
  bool get isOnline;
  @override
  @JsonKey(ignore: true)
  _$$MatchCardImplCopyWith<_$MatchCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CreateSwipeParams {
  String get toUserId => throw _privateConstructorUsedError;
  SwipeAction get action => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CreateSwipeParamsCopyWith<CreateSwipeParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateSwipeParamsCopyWith<$Res> {
  factory $CreateSwipeParamsCopyWith(
          CreateSwipeParams value, $Res Function(CreateSwipeParams) then) =
      _$CreateSwipeParamsCopyWithImpl<$Res, CreateSwipeParams>;
  @useResult
  $Res call({String toUserId, SwipeAction action});
}

/// @nodoc
class _$CreateSwipeParamsCopyWithImpl<$Res, $Val extends CreateSwipeParams>
    implements $CreateSwipeParamsCopyWith<$Res> {
  _$CreateSwipeParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? toUserId = null,
    Object? action = null,
  }) {
    return _then(_value.copyWith(
      toUserId: null == toUserId
          ? _value.toUserId
          : toUserId // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as SwipeAction,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateSwipeParamsImplCopyWith<$Res>
    implements $CreateSwipeParamsCopyWith<$Res> {
  factory _$$CreateSwipeParamsImplCopyWith(_$CreateSwipeParamsImpl value,
          $Res Function(_$CreateSwipeParamsImpl) then) =
      __$$CreateSwipeParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String toUserId, SwipeAction action});
}

/// @nodoc
class __$$CreateSwipeParamsImplCopyWithImpl<$Res>
    extends _$CreateSwipeParamsCopyWithImpl<$Res, _$CreateSwipeParamsImpl>
    implements _$$CreateSwipeParamsImplCopyWith<$Res> {
  __$$CreateSwipeParamsImplCopyWithImpl(_$CreateSwipeParamsImpl _value,
      $Res Function(_$CreateSwipeParamsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? toUserId = null,
    Object? action = null,
  }) {
    return _then(_$CreateSwipeParamsImpl(
      toUserId: null == toUserId
          ? _value.toUserId
          : toUserId // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as SwipeAction,
    ));
  }
}

/// @nodoc

class _$CreateSwipeParamsImpl implements _CreateSwipeParams {
  const _$CreateSwipeParamsImpl({required this.toUserId, required this.action});

  @override
  final String toUserId;
  @override
  final SwipeAction action;

  @override
  String toString() {
    return 'CreateSwipeParams(toUserId: $toUserId, action: $action)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateSwipeParamsImpl &&
            (identical(other.toUserId, toUserId) ||
                other.toUserId == toUserId) &&
            (identical(other.action, action) || other.action == action));
  }

  @override
  int get hashCode => Object.hash(runtimeType, toUserId, action);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateSwipeParamsImplCopyWith<_$CreateSwipeParamsImpl> get copyWith =>
      __$$CreateSwipeParamsImplCopyWithImpl<_$CreateSwipeParamsImpl>(
          this, _$identity);
}

abstract class _CreateSwipeParams implements CreateSwipeParams {
  const factory _CreateSwipeParams(
      {required final String toUserId,
      required final SwipeAction action}) = _$CreateSwipeParamsImpl;

  @override
  String get toUserId;
  @override
  SwipeAction get action;
  @override
  @JsonKey(ignore: true)
  _$$CreateSwipeParamsImplCopyWith<_$CreateSwipeParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SwipeResult {
  Swipe get swipe => throw _privateConstructorUsedError;
  Match? get matchCreated => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SwipeResultCopyWith<SwipeResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SwipeResultCopyWith<$Res> {
  factory $SwipeResultCopyWith(
          SwipeResult value, $Res Function(SwipeResult) then) =
      _$SwipeResultCopyWithImpl<$Res, SwipeResult>;
  @useResult
  $Res call({Swipe swipe, Match? matchCreated});

  $SwipeCopyWith<$Res> get swipe;
  $MatchCopyWith<$Res>? get matchCreated;
}

/// @nodoc
class _$SwipeResultCopyWithImpl<$Res, $Val extends SwipeResult>
    implements $SwipeResultCopyWith<$Res> {
  _$SwipeResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? swipe = null,
    Object? matchCreated = freezed,
  }) {
    return _then(_value.copyWith(
      swipe: null == swipe
          ? _value.swipe
          : swipe // ignore: cast_nullable_to_non_nullable
              as Swipe,
      matchCreated: freezed == matchCreated
          ? _value.matchCreated
          : matchCreated // ignore: cast_nullable_to_non_nullable
              as Match?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SwipeCopyWith<$Res> get swipe {
    return $SwipeCopyWith<$Res>(_value.swipe, (value) {
      return _then(_value.copyWith(swipe: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $MatchCopyWith<$Res>? get matchCreated {
    if (_value.matchCreated == null) {
      return null;
    }

    return $MatchCopyWith<$Res>(_value.matchCreated!, (value) {
      return _then(_value.copyWith(matchCreated: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SwipeResultImplCopyWith<$Res>
    implements $SwipeResultCopyWith<$Res> {
  factory _$$SwipeResultImplCopyWith(
          _$SwipeResultImpl value, $Res Function(_$SwipeResultImpl) then) =
      __$$SwipeResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Swipe swipe, Match? matchCreated});

  @override
  $SwipeCopyWith<$Res> get swipe;
  @override
  $MatchCopyWith<$Res>? get matchCreated;
}

/// @nodoc
class __$$SwipeResultImplCopyWithImpl<$Res>
    extends _$SwipeResultCopyWithImpl<$Res, _$SwipeResultImpl>
    implements _$$SwipeResultImplCopyWith<$Res> {
  __$$SwipeResultImplCopyWithImpl(
      _$SwipeResultImpl _value, $Res Function(_$SwipeResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? swipe = null,
    Object? matchCreated = freezed,
  }) {
    return _then(_$SwipeResultImpl(
      swipe: null == swipe
          ? _value.swipe
          : swipe // ignore: cast_nullable_to_non_nullable
              as Swipe,
      matchCreated: freezed == matchCreated
          ? _value.matchCreated
          : matchCreated // ignore: cast_nullable_to_non_nullable
              as Match?,
    ));
  }
}

/// @nodoc

class _$SwipeResultImpl implements _SwipeResult {
  const _$SwipeResultImpl({required this.swipe, required this.matchCreated});

  @override
  final Swipe swipe;
  @override
  final Match? matchCreated;

  @override
  String toString() {
    return 'SwipeResult(swipe: $swipe, matchCreated: $matchCreated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SwipeResultImpl &&
            (identical(other.swipe, swipe) || other.swipe == swipe) &&
            (identical(other.matchCreated, matchCreated) ||
                other.matchCreated == matchCreated));
  }

  @override
  int get hashCode => Object.hash(runtimeType, swipe, matchCreated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SwipeResultImplCopyWith<_$SwipeResultImpl> get copyWith =>
      __$$SwipeResultImplCopyWithImpl<_$SwipeResultImpl>(this, _$identity);
}

abstract class _SwipeResult implements SwipeResult {
  const factory _SwipeResult(
      {required final Swipe swipe,
      required final Match? matchCreated}) = _$SwipeResultImpl;

  @override
  Swipe get swipe;
  @override
  Match? get matchCreated;
  @override
  @JsonKey(ignore: true)
  _$$SwipeResultImplCopyWith<_$SwipeResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
