// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Conversation {
  String get id => throw _privateConstructorUsedError;
  bool get isGroup => throw _privateConstructorUsedError;
  String? get groupId => throw _privateConstructorUsedError; // Si es grupal
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ConversationCopyWith<Conversation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationCopyWith<$Res> {
  factory $ConversationCopyWith(
          Conversation value, $Res Function(Conversation) then) =
      _$ConversationCopyWithImpl<$Res, Conversation>;
  @useResult
  $Res call(
      {String id,
      bool isGroup,
      String? groupId,
      DateTime createdAt,
      DateTime? updatedAt,
      int unreadCount});
}

/// @nodoc
class _$ConversationCopyWithImpl<$Res, $Val extends Conversation>
    implements $ConversationCopyWith<$Res> {
  _$ConversationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? isGroup = null,
    Object? groupId = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? unreadCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      isGroup: null == isGroup
          ? _value.isGroup
          : isGroup // ignore: cast_nullable_to_non_nullable
              as bool,
      groupId: freezed == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConversationImplCopyWith<$Res>
    implements $ConversationCopyWith<$Res> {
  factory _$$ConversationImplCopyWith(
          _$ConversationImpl value, $Res Function(_$ConversationImpl) then) =
      __$$ConversationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      bool isGroup,
      String? groupId,
      DateTime createdAt,
      DateTime? updatedAt,
      int unreadCount});
}

/// @nodoc
class __$$ConversationImplCopyWithImpl<$Res>
    extends _$ConversationCopyWithImpl<$Res, _$ConversationImpl>
    implements _$$ConversationImplCopyWith<$Res> {
  __$$ConversationImplCopyWithImpl(
      _$ConversationImpl _value, $Res Function(_$ConversationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? isGroup = null,
    Object? groupId = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? unreadCount = null,
  }) {
    return _then(_$ConversationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      isGroup: null == isGroup
          ? _value.isGroup
          : isGroup // ignore: cast_nullable_to_non_nullable
              as bool,
      groupId: freezed == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ConversationImpl implements _Conversation {
  const _$ConversationImpl(
      {required this.id,
      required this.isGroup,
      required this.groupId,
      required this.createdAt,
      required this.updatedAt,
      required this.unreadCount});

  @override
  final String id;
  @override
  final bool isGroup;
  @override
  final String? groupId;
// Si es grupal
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final int unreadCount;

  @override
  String toString() {
    return 'Conversation(id: $id, isGroup: $isGroup, groupId: $groupId, createdAt: $createdAt, updatedAt: $updatedAt, unreadCount: $unreadCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.isGroup, isGroup) || other.isGroup == isGroup) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, isGroup, groupId, createdAt, updatedAt, unreadCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      __$$ConversationImplCopyWithImpl<_$ConversationImpl>(this, _$identity);
}

abstract class _Conversation implements Conversation {
  const factory _Conversation(
      {required final String id,
      required final bool isGroup,
      required final String? groupId,
      required final DateTime createdAt,
      required final DateTime? updatedAt,
      required final int unreadCount}) = _$ConversationImpl;

  @override
  String get id;
  @override
  bool get isGroup;
  @override
  String? get groupId;
  @override // Si es grupal
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  int get unreadCount;
  @override
  @JsonKey(ignore: true)
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ConversationParticipant {
  String get id => throw _privateConstructorUsedError;
  String get conversationId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;
  DateTime? get lastReadAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ConversationParticipantCopyWith<ConversationParticipant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationParticipantCopyWith<$Res> {
  factory $ConversationParticipantCopyWith(ConversationParticipant value,
          $Res Function(ConversationParticipant) then) =
      _$ConversationParticipantCopyWithImpl<$Res, ConversationParticipant>;
  @useResult
  $Res call(
      {String id,
      String conversationId,
      String userId,
      DateTime joinedAt,
      DateTime? lastReadAt});
}

/// @nodoc
class _$ConversationParticipantCopyWithImpl<$Res,
        $Val extends ConversationParticipant>
    implements $ConversationParticipantCopyWith<$Res> {
  _$ConversationParticipantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? userId = null,
    Object? joinedAt = null,
    Object? lastReadAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastReadAt: freezed == lastReadAt
          ? _value.lastReadAt
          : lastReadAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConversationParticipantImplCopyWith<$Res>
    implements $ConversationParticipantCopyWith<$Res> {
  factory _$$ConversationParticipantImplCopyWith(
          _$ConversationParticipantImpl value,
          $Res Function(_$ConversationParticipantImpl) then) =
      __$$ConversationParticipantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String conversationId,
      String userId,
      DateTime joinedAt,
      DateTime? lastReadAt});
}

/// @nodoc
class __$$ConversationParticipantImplCopyWithImpl<$Res>
    extends _$ConversationParticipantCopyWithImpl<$Res,
        _$ConversationParticipantImpl>
    implements _$$ConversationParticipantImplCopyWith<$Res> {
  __$$ConversationParticipantImplCopyWithImpl(
      _$ConversationParticipantImpl _value,
      $Res Function(_$ConversationParticipantImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? userId = null,
    Object? joinedAt = null,
    Object? lastReadAt = freezed,
  }) {
    return _then(_$ConversationParticipantImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastReadAt: freezed == lastReadAt
          ? _value.lastReadAt
          : lastReadAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$ConversationParticipantImpl implements _ConversationParticipant {
  const _$ConversationParticipantImpl(
      {required this.id,
      required this.conversationId,
      required this.userId,
      required this.joinedAt,
      required this.lastReadAt});

  @override
  final String id;
  @override
  final String conversationId;
  @override
  final String userId;
  @override
  final DateTime joinedAt;
  @override
  final DateTime? lastReadAt;

  @override
  String toString() {
    return 'ConversationParticipant(id: $id, conversationId: $conversationId, userId: $userId, joinedAt: $joinedAt, lastReadAt: $lastReadAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationParticipantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.lastReadAt, lastReadAt) ||
                other.lastReadAt == lastReadAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, conversationId, userId, joinedAt, lastReadAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationParticipantImplCopyWith<_$ConversationParticipantImpl>
      get copyWith => __$$ConversationParticipantImplCopyWithImpl<
          _$ConversationParticipantImpl>(this, _$identity);
}

abstract class _ConversationParticipant implements ConversationParticipant {
  const factory _ConversationParticipant(
      {required final String id,
      required final String conversationId,
      required final String userId,
      required final DateTime joinedAt,
      required final DateTime? lastReadAt}) = _$ConversationParticipantImpl;

  @override
  String get id;
  @override
  String get conversationId;
  @override
  String get userId;
  @override
  DateTime get joinedAt;
  @override
  DateTime? get lastReadAt;
  @override
  @JsonKey(ignore: true)
  _$$ConversationParticipantImplCopyWith<_$ConversationParticipantImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Message {
  String get id => throw _privateConstructorUsedError;
  String get conversationId => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get editedAt => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  String? get senderName =>
      throw _privateConstructorUsedError; // Cached para UI
  String? get senderAvatar => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MessageCopyWith<Message> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) then) =
      _$MessageCopyWithImpl<$Res, Message>;
  @useResult
  $Res call(
      {String id,
      String conversationId,
      String senderId,
      String content,
      DateTime createdAt,
      DateTime? editedAt,
      bool isRead,
      String? senderName,
      String? senderAvatar});
}

/// @nodoc
class _$MessageCopyWithImpl<$Res, $Val extends Message>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? senderId = null,
    Object? content = null,
    Object? createdAt = null,
    Object? editedAt = freezed,
    Object? isRead = null,
    Object? senderName = freezed,
    Object? senderAvatar = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      editedAt: freezed == editedAt
          ? _value.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      senderName: freezed == senderName
          ? _value.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String?,
      senderAvatar: freezed == senderAvatar
          ? _value.senderAvatar
          : senderAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageImplCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$$MessageImplCopyWith(
          _$MessageImpl value, $Res Function(_$MessageImpl) then) =
      __$$MessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String conversationId,
      String senderId,
      String content,
      DateTime createdAt,
      DateTime? editedAt,
      bool isRead,
      String? senderName,
      String? senderAvatar});
}

/// @nodoc
class __$$MessageImplCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$MessageImpl>
    implements _$$MessageImplCopyWith<$Res> {
  __$$MessageImplCopyWithImpl(
      _$MessageImpl _value, $Res Function(_$MessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? senderId = null,
    Object? content = null,
    Object? createdAt = null,
    Object? editedAt = freezed,
    Object? isRead = null,
    Object? senderName = freezed,
    Object? senderAvatar = freezed,
  }) {
    return _then(_$MessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      editedAt: freezed == editedAt
          ? _value.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      senderName: freezed == senderName
          ? _value.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String?,
      senderAvatar: freezed == senderAvatar
          ? _value.senderAvatar
          : senderAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$MessageImpl implements _Message {
  const _$MessageImpl(
      {required this.id,
      required this.conversationId,
      required this.senderId,
      required this.content,
      required this.createdAt,
      required this.editedAt,
      required this.isRead,
      this.senderName,
      this.senderAvatar});

  @override
  final String id;
  @override
  final String conversationId;
  @override
  final String senderId;
  @override
  final String content;
  @override
  final DateTime createdAt;
  @override
  final DateTime? editedAt;
  @override
  final bool isRead;
  @override
  final String? senderName;
// Cached para UI
  @override
  final String? senderAvatar;

  @override
  String toString() {
    return 'Message(id: $id, conversationId: $conversationId, senderId: $senderId, content: $content, createdAt: $createdAt, editedAt: $editedAt, isRead: $isRead, senderName: $senderName, senderAvatar: $senderAvatar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.editedAt, editedAt) ||
                other.editedAt == editedAt) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.senderAvatar, senderAvatar) ||
                other.senderAvatar == senderAvatar));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, conversationId, senderId,
      content, createdAt, editedAt, isRead, senderName, senderAvatar);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      __$$MessageImplCopyWithImpl<_$MessageImpl>(this, _$identity);
}

abstract class _Message implements Message {
  const factory _Message(
      {required final String id,
      required final String conversationId,
      required final String senderId,
      required final String content,
      required final DateTime createdAt,
      required final DateTime? editedAt,
      required final bool isRead,
      final String? senderName,
      final String? senderAvatar}) = _$MessageImpl;

  @override
  String get id;
  @override
  String get conversationId;
  @override
  String get senderId;
  @override
  String get content;
  @override
  DateTime get createdAt;
  @override
  DateTime? get editedAt;
  @override
  bool get isRead;
  @override
  String? get senderName;
  @override // Cached para UI
  String? get senderAvatar;
  @override
  @JsonKey(ignore: true)
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ConversationPreview {
  String get id => throw _privateConstructorUsedError;
  String get otherUserId =>
      throw _privateConstructorUsedError; // Otro usuario (1-a-1)
  String get otherUserName => throw _privateConstructorUsedError;
  String? get otherUserAvatar => throw _privateConstructorUsedError;
  bool get otherUserIsOnline => throw _privateConstructorUsedError;
  String get lastMessage => throw _privateConstructorUsedError;
  DateTime get lastMessageTime => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;
  bool get isGroup => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ConversationPreviewCopyWith<ConversationPreview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationPreviewCopyWith<$Res> {
  factory $ConversationPreviewCopyWith(
          ConversationPreview value, $Res Function(ConversationPreview) then) =
      _$ConversationPreviewCopyWithImpl<$Res, ConversationPreview>;
  @useResult
  $Res call(
      {String id,
      String otherUserId,
      String otherUserName,
      String? otherUserAvatar,
      bool otherUserIsOnline,
      String lastMessage,
      DateTime lastMessageTime,
      int unreadCount,
      bool isGroup});
}

/// @nodoc
class _$ConversationPreviewCopyWithImpl<$Res, $Val extends ConversationPreview>
    implements $ConversationPreviewCopyWith<$Res> {
  _$ConversationPreviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? otherUserId = null,
    Object? otherUserName = null,
    Object? otherUserAvatar = freezed,
    Object? otherUserIsOnline = null,
    Object? lastMessage = null,
    Object? lastMessageTime = null,
    Object? unreadCount = null,
    Object? isGroup = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      otherUserId: null == otherUserId
          ? _value.otherUserId
          : otherUserId // ignore: cast_nullable_to_non_nullable
              as String,
      otherUserName: null == otherUserName
          ? _value.otherUserName
          : otherUserName // ignore: cast_nullable_to_non_nullable
              as String,
      otherUserAvatar: freezed == otherUserAvatar
          ? _value.otherUserAvatar
          : otherUserAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
      otherUserIsOnline: null == otherUserIsOnline
          ? _value.otherUserIsOnline
          : otherUserIsOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      lastMessage: null == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String,
      lastMessageTime: null == lastMessageTime
          ? _value.lastMessageTime
          : lastMessageTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      isGroup: null == isGroup
          ? _value.isGroup
          : isGroup // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConversationPreviewImplCopyWith<$Res>
    implements $ConversationPreviewCopyWith<$Res> {
  factory _$$ConversationPreviewImplCopyWith(_$ConversationPreviewImpl value,
          $Res Function(_$ConversationPreviewImpl) then) =
      __$$ConversationPreviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String otherUserId,
      String otherUserName,
      String? otherUserAvatar,
      bool otherUserIsOnline,
      String lastMessage,
      DateTime lastMessageTime,
      int unreadCount,
      bool isGroup});
}

/// @nodoc
class __$$ConversationPreviewImplCopyWithImpl<$Res>
    extends _$ConversationPreviewCopyWithImpl<$Res, _$ConversationPreviewImpl>
    implements _$$ConversationPreviewImplCopyWith<$Res> {
  __$$ConversationPreviewImplCopyWithImpl(_$ConversationPreviewImpl _value,
      $Res Function(_$ConversationPreviewImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? otherUserId = null,
    Object? otherUserName = null,
    Object? otherUserAvatar = freezed,
    Object? otherUserIsOnline = null,
    Object? lastMessage = null,
    Object? lastMessageTime = null,
    Object? unreadCount = null,
    Object? isGroup = null,
  }) {
    return _then(_$ConversationPreviewImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      otherUserId: null == otherUserId
          ? _value.otherUserId
          : otherUserId // ignore: cast_nullable_to_non_nullable
              as String,
      otherUserName: null == otherUserName
          ? _value.otherUserName
          : otherUserName // ignore: cast_nullable_to_non_nullable
              as String,
      otherUserAvatar: freezed == otherUserAvatar
          ? _value.otherUserAvatar
          : otherUserAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
      otherUserIsOnline: null == otherUserIsOnline
          ? _value.otherUserIsOnline
          : otherUserIsOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      lastMessage: null == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String,
      lastMessageTime: null == lastMessageTime
          ? _value.lastMessageTime
          : lastMessageTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      isGroup: null == isGroup
          ? _value.isGroup
          : isGroup // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ConversationPreviewImpl implements _ConversationPreview {
  const _$ConversationPreviewImpl(
      {required this.id,
      required this.otherUserId,
      required this.otherUserName,
      required this.otherUserAvatar,
      required this.otherUserIsOnline,
      required this.lastMessage,
      required this.lastMessageTime,
      required this.unreadCount,
      required this.isGroup});

  @override
  final String id;
  @override
  final String otherUserId;
// Otro usuario (1-a-1)
  @override
  final String otherUserName;
  @override
  final String? otherUserAvatar;
  @override
  final bool otherUserIsOnline;
  @override
  final String lastMessage;
  @override
  final DateTime lastMessageTime;
  @override
  final int unreadCount;
  @override
  final bool isGroup;

  @override
  String toString() {
    return 'ConversationPreview(id: $id, otherUserId: $otherUserId, otherUserName: $otherUserName, otherUserAvatar: $otherUserAvatar, otherUserIsOnline: $otherUserIsOnline, lastMessage: $lastMessage, lastMessageTime: $lastMessageTime, unreadCount: $unreadCount, isGroup: $isGroup)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationPreviewImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.otherUserId, otherUserId) ||
                other.otherUserId == otherUserId) &&
            (identical(other.otherUserName, otherUserName) ||
                other.otherUserName == otherUserName) &&
            (identical(other.otherUserAvatar, otherUserAvatar) ||
                other.otherUserAvatar == otherUserAvatar) &&
            (identical(other.otherUserIsOnline, otherUserIsOnline) ||
                other.otherUserIsOnline == otherUserIsOnline) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.lastMessageTime, lastMessageTime) ||
                other.lastMessageTime == lastMessageTime) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.isGroup, isGroup) || other.isGroup == isGroup));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      otherUserId,
      otherUserName,
      otherUserAvatar,
      otherUserIsOnline,
      lastMessage,
      lastMessageTime,
      unreadCount,
      isGroup);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationPreviewImplCopyWith<_$ConversationPreviewImpl> get copyWith =>
      __$$ConversationPreviewImplCopyWithImpl<_$ConversationPreviewImpl>(
          this, _$identity);
}

abstract class _ConversationPreview implements ConversationPreview {
  const factory _ConversationPreview(
      {required final String id,
      required final String otherUserId,
      required final String otherUserName,
      required final String? otherUserAvatar,
      required final bool otherUserIsOnline,
      required final String lastMessage,
      required final DateTime lastMessageTime,
      required final int unreadCount,
      required final bool isGroup}) = _$ConversationPreviewImpl;

  @override
  String get id;
  @override
  String get otherUserId;
  @override // Otro usuario (1-a-1)
  String get otherUserName;
  @override
  String? get otherUserAvatar;
  @override
  bool get otherUserIsOnline;
  @override
  String get lastMessage;
  @override
  DateTime get lastMessageTime;
  @override
  int get unreadCount;
  @override
  bool get isGroup;
  @override
  @JsonKey(ignore: true)
  _$$ConversationPreviewImplCopyWith<_$ConversationPreviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SendMessageParams {
  String get conversationId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SendMessageParamsCopyWith<SendMessageParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SendMessageParamsCopyWith<$Res> {
  factory $SendMessageParamsCopyWith(
          SendMessageParams value, $Res Function(SendMessageParams) then) =
      _$SendMessageParamsCopyWithImpl<$Res, SendMessageParams>;
  @useResult
  $Res call({String conversationId, String content});
}

/// @nodoc
class _$SendMessageParamsCopyWithImpl<$Res, $Val extends SendMessageParams>
    implements $SendMessageParamsCopyWith<$Res> {
  _$SendMessageParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversationId = null,
    Object? content = null,
  }) {
    return _then(_value.copyWith(
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SendMessageParamsImplCopyWith<$Res>
    implements $SendMessageParamsCopyWith<$Res> {
  factory _$$SendMessageParamsImplCopyWith(_$SendMessageParamsImpl value,
          $Res Function(_$SendMessageParamsImpl) then) =
      __$$SendMessageParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String conversationId, String content});
}

/// @nodoc
class __$$SendMessageParamsImplCopyWithImpl<$Res>
    extends _$SendMessageParamsCopyWithImpl<$Res, _$SendMessageParamsImpl>
    implements _$$SendMessageParamsImplCopyWith<$Res> {
  __$$SendMessageParamsImplCopyWithImpl(_$SendMessageParamsImpl _value,
      $Res Function(_$SendMessageParamsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversationId = null,
    Object? content = null,
  }) {
    return _then(_$SendMessageParamsImpl(
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SendMessageParamsImpl implements _SendMessageParams {
  const _$SendMessageParamsImpl(
      {required this.conversationId, required this.content});

  @override
  final String conversationId;
  @override
  final String content;

  @override
  String toString() {
    return 'SendMessageParams(conversationId: $conversationId, content: $content)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SendMessageParamsImpl &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.content, content) || other.content == content));
  }

  @override
  int get hashCode => Object.hash(runtimeType, conversationId, content);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SendMessageParamsImplCopyWith<_$SendMessageParamsImpl> get copyWith =>
      __$$SendMessageParamsImplCopyWithImpl<_$SendMessageParamsImpl>(
          this, _$identity);
}

abstract class _SendMessageParams implements SendMessageParams {
  const factory _SendMessageParams(
      {required final String conversationId,
      required final String content}) = _$SendMessageParamsImpl;

  @override
  String get conversationId;
  @override
  String get content;
  @override
  @JsonKey(ignore: true)
  _$$SendMessageParamsImplCopyWith<_$SendMessageParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CreateConversationParams {
  String get otherUserId => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CreateConversationParamsCopyWith<CreateConversationParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateConversationParamsCopyWith<$Res> {
  factory $CreateConversationParamsCopyWith(CreateConversationParams value,
          $Res Function(CreateConversationParams) then) =
      _$CreateConversationParamsCopyWithImpl<$Res, CreateConversationParams>;
  @useResult
  $Res call({String otherUserId});
}

/// @nodoc
class _$CreateConversationParamsCopyWithImpl<$Res,
        $Val extends CreateConversationParams>
    implements $CreateConversationParamsCopyWith<$Res> {
  _$CreateConversationParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? otherUserId = null,
  }) {
    return _then(_value.copyWith(
      otherUserId: null == otherUserId
          ? _value.otherUserId
          : otherUserId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateConversationParamsImplCopyWith<$Res>
    implements $CreateConversationParamsCopyWith<$Res> {
  factory _$$CreateConversationParamsImplCopyWith(
          _$CreateConversationParamsImpl value,
          $Res Function(_$CreateConversationParamsImpl) then) =
      __$$CreateConversationParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String otherUserId});
}

/// @nodoc
class __$$CreateConversationParamsImplCopyWithImpl<$Res>
    extends _$CreateConversationParamsCopyWithImpl<$Res,
        _$CreateConversationParamsImpl>
    implements _$$CreateConversationParamsImplCopyWith<$Res> {
  __$$CreateConversationParamsImplCopyWithImpl(
      _$CreateConversationParamsImpl _value,
      $Res Function(_$CreateConversationParamsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? otherUserId = null,
  }) {
    return _then(_$CreateConversationParamsImpl(
      otherUserId: null == otherUserId
          ? _value.otherUserId
          : otherUserId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CreateConversationParamsImpl implements _CreateConversationParams {
  const _$CreateConversationParamsImpl({required this.otherUserId});

  @override
  final String otherUserId;

  @override
  String toString() {
    return 'CreateConversationParams(otherUserId: $otherUserId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateConversationParamsImpl &&
            (identical(other.otherUserId, otherUserId) ||
                other.otherUserId == otherUserId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, otherUserId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateConversationParamsImplCopyWith<_$CreateConversationParamsImpl>
      get copyWith => __$$CreateConversationParamsImplCopyWithImpl<
          _$CreateConversationParamsImpl>(this, _$identity);
}

abstract class _CreateConversationParams implements CreateConversationParams {
  const factory _CreateConversationParams({required final String otherUserId}) =
      _$CreateConversationParamsImpl;

  @override
  String get otherUserId;
  @override
  @JsonKey(ignore: true)
  _$$CreateConversationParamsImplCopyWith<_$CreateConversationParamsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
