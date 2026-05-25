-- ============================================================================
-- QUERIES SQL ÚTILES PARA PREMADE
-- ============================================================================
-- Este archivo contiene consultas SQL comunes para diferentes funcionalidades
-- Copiá y pegá en Supabase SQL Editor según sea necesario
-- ============================================================================

-- ============================================================================
-- 1. QUERIES DE USUARIOS
-- ============================================================================

-- Obtener usuario con sus juegos
SELECT 
  u.id,
  u.nickname,
  u.email,
  u.age,
  u.country,
  u.avatar_url,
  u.is_online,
  json_agg(json_build_object(
    'game_id', ug.game_id,
    'game_title', g.title,
    'primary_rank', gr.rank_tier,
    'main_role', gr2.role_name
  )) as games
FROM users u
LEFT JOIN user_games ug ON u.id = ug.user_id
LEFT JOIN games g ON ug.game_id = g.id
LEFT JOIN game_ranks gr ON ug.primary_rank_id = gr.id
LEFT JOIN game_roles gr2 ON ug.main_role_id = gr2.id
WHERE u.id = 'user-uuid-here'
GROUP BY u.id, u.nickname, u.email, u.age, u.country, u.avatar_url, u.is_online;

-- Obtener usuarios online
SELECT 
  id,
  nickname,
  avatar_url,
  country,
  is_online,
  last_seen_at
FROM users
WHERE is_online = TRUE
  AND deleted_at IS NULL
ORDER BY last_seen_at DESC;

-- Contar usuarios totales
SELECT COUNT(*) as total_users FROM users WHERE deleted_at IS NULL;

-- Buscar usuarios potenciales de match
SELECT 
  u.id,
  u.nickname,
  u.avatar_url,
  u.age,
  u.country,
  COUNT(DISTINCT ug.game_id) as common_games
FROM users u
LEFT JOIN user_games ug ON u.id = ug.user_id
WHERE u.id != 'current-user-uuid'
  AND NOT EXISTS (
    SELECT 1 FROM blocks
    WHERE (blocker_user_id = 'current-user-uuid' AND blocked_user_id = u.id)
       OR (blocker_user_id = u.id AND blocked_user_id = 'current-user-uuid')
  )
GROUP BY u.id, u.nickname, u.avatar_url, u.age, u.country
ORDER BY common_games DESC;

-- ============================================================================
-- 2. QUERIES DE MATCHING
-- ============================================================================

-- Ver matches activos de un usuario
SELECT 
  m.id,
  CASE 
    WHEN m.user_id_1 = 'user-uuid' THEN u2.nickname
    ELSE u1.nickname
  END as matched_user_nickname,
  CASE 
    WHEN m.user_id_1 = 'user-uuid' THEN u2.avatar_url
    ELSE u1.avatar_url
  END as matched_user_avatar,
  m.matched_at
FROM matches m
JOIN users u1 ON m.user_id_1 = u1.id
JOIN users u2 ON m.user_id_2 = u2.id
WHERE (m.user_id_1 = 'user-uuid' OR m.user_id_2 = 'user-uuid')
  AND m.is_active = TRUE
ORDER BY m.matched_at DESC;

-- Ver swipes que ha dado un usuario
SELECT 
  s.target_user_id,
  u.nickname,
  u.avatar_url,
  s.action,
  s.compatibility_score,
  s.created_at
FROM swipes s
JOIN users u ON s.target_user_id = u.id
WHERE s.user_id = 'user-uuid'
ORDER BY s.created_at DESC;

-- Ver matches mutuos (ambos hicieron like)
SELECT 
  u2.id,
  u2.nickname,
  u2.avatar_url,
  u2.country,
  s1.compatibility_score
FROM swipes s1
JOIN swipes s2 ON (
  s1.user_id = s2.target_user_id 
  AND s1.target_user_id = s2.user_id
)
JOIN users u2 ON s1.target_user_id = u2.id
WHERE s1.user_id = 'user-uuid'
  AND s1.action = 'like'
  AND s2.action IN ('like', 'superlike')
  AND NOT EXISTS (
    SELECT 1 FROM matches
    WHERE (user_id_1 = 'user-uuid' AND user_id_2 = u2.id)
       OR (user_id_1 = u2.id AND user_id_2 = 'user-uuid')
  );

-- ============================================================================
-- 3. QUERIES DE CHAT
-- ============================================================================

-- Obtener conversaciones de un usuario con último mensaje
SELECT 
  cp.conversation_id,
  CASE 
    WHEN c.is_group THEN g.name
    ELSE COALESCE(u.nickname, 'Usuario desconocido')
  END as conversation_name,
  m.content as last_message,
  m.created_at as last_message_at,
  COUNT(CASE WHEN m.sender_id != 'user-uuid' AND m.created_at > cp.last_read_at THEN 1 END) as unread_count
FROM conversation_participants cp
JOIN conversations c ON cp.conversation_id = c.id
LEFT JOIN groups g ON c.group_id = g.id
LEFT JOIN users u ON c.is_group = FALSE AND u.id NOT IN (
  SELECT user_id FROM conversation_participants WHERE conversation_id = cp.conversation_id AND user_id = 'user-uuid'
)
LEFT JOIN messages m ON c.id = m.conversation_id
WHERE cp.user_id = 'user-uuid'
GROUP BY cp.conversation_id, c.is_group, g.name, u.nickname, m.content, m.created_at, cp.last_read_at
ORDER BY m.created_at DESC;

-- Obtener mensajes de una conversación (últimos 50)
SELECT 
  m.id,
  m.content,
  m.sender_id,
  u.nickname as sender_nickname,
  u.avatar_url as sender_avatar,
  m.created_at,
  m.is_edited,
  m.edited_at
FROM messages m
JOIN users u ON m.sender_id = u.id
WHERE m.conversation_id = 'conversation-uuid'
ORDER BY m.created_at DESC
LIMIT 50;

-- Contar mensajes no leídos
SELECT 
  cp.conversation_id,
  COUNT(m.id) as unread_messages
FROM conversation_participants cp
LEFT JOIN messages m ON (
  m.conversation_id = cp.conversation_id 
  AND m.created_at > cp.last_read_at
  AND m.sender_id != 'user-uuid'
)
WHERE cp.user_id = 'user-uuid'
GROUP BY cp.conversation_id
HAVING COUNT(m.id) > 0;

-- ============================================================================
-- 4. QUERIES DE AMIGOS
-- ============================================================================

-- Ver amigos de un usuario
SELECT 
  CASE 
    WHEN f.user_id_1 = 'user-uuid' THEN f.user_id_2
    ELSE f.user_id_1
  END as friend_id,
  CASE 
    WHEN f.user_id_1 = 'user-uuid' THEN u2.nickname
    ELSE u1.nickname
  END as friend_nickname,
  CASE 
    WHEN f.user_id_1 = 'user-uuid' THEN u2.avatar_url
    ELSE u1.avatar_url
  END as friend_avatar,
  CASE 
    WHEN f.user_id_1 = 'user-uuid' THEN u2.is_online
    ELSE u1.is_online
  END as is_online,
  f.accepted_at
FROM friendships f
JOIN users u1 ON f.user_id_1 = u1.id
JOIN users u2 ON f.user_id_2 = u2.id
WHERE (f.user_id_1 = 'user-uuid' OR f.user_id_2 = 'user-uuid')
  AND f.status = 'accepted'
ORDER BY f.accepted_at DESC;

-- Ver solicitudes de amistad pendientes
SELECT 
  CASE 
    WHEN f.user_id_1 = 'user-uuid' THEN f.user_id_2
    ELSE f.user_id_1
  END as requester_id,
  CASE 
    WHEN f.user_id_1 = 'user-uuid' THEN u2.nickname
    ELSE u1.nickname
  END as requester_nickname,
  CASE 
    WHEN f.user_id_1 = 'user-uuid' THEN u2.avatar_url
    ELSE u1.avatar_url
  END as requester_avatar,
  f.created_at
FROM friendships f
JOIN users u1 ON f.user_id_1 = u1.id
JOIN users u2 ON f.user_id_2 = u2.id
WHERE (f.user_id_1 = 'user-uuid' OR f.user_id_2 = 'user-uuid')
  AND f.status = 'pending'
  AND f.requested_by != 'user-uuid'
ORDER BY f.created_at DESC;

-- Ver usuarios bloqueados
SELECT 
  b.blocked_user_id,
  u.nickname,
  u.avatar_url,
  b.created_at
FROM blocks b
JOIN users u ON b.blocked_user_id = u.id
WHERE b.blocker_user_id = 'user-uuid'
ORDER BY b.created_at DESC;

-- ============================================================================
-- 5. QUERIES DE GRUPOS
-- ============================================================================

-- Ver grupos de un usuario
SELECT 
  g.id,
  g.name,
  g.description,
  g.avatar_url,
  g.is_public,
  COUNT(gm.id) as member_count,
  gm.role as current_user_role
FROM groups g
JOIN group_members gm ON g.id = gm.group_id
WHERE gm.user_id = 'user-uuid'
GROUP BY g.id, g.name, g.description, g.avatar_url, g.is_public, gm.role
ORDER BY g.created_at DESC;

-- Ver miembros de un grupo
SELECT 
  u.id,
  u.nickname,
  u.avatar_url,
  u.is_online,
  gm.role,
  gm.joined_at
FROM group_members gm
JOIN users u ON gm.user_id = u.id
WHERE gm.group_id = 'group-uuid'
ORDER BY gm.role DESC, gm.joined_at ASC;

-- ============================================================================
-- 6. QUERIES DE SINCRONIZACIÓN Y STATISTICAS
-- ============================================================================

-- Estadísticas generales
SELECT 
  (SELECT COUNT(*) FROM users WHERE deleted_at IS NULL) as total_users,
  (SELECT COUNT(*) FROM users WHERE is_online = TRUE) as online_now,
  (SELECT COUNT(*) FROM matches WHERE is_active = TRUE) as active_matches,
  (SELECT COUNT(*) FROM messages WHERE created_at > NOW() - INTERVAL '24 hours') as messages_24h,
  (SELECT COUNT(*) FROM friendships WHERE status = 'accepted') as total_friendships;

-- Usuarios más activos (por mensajes)
SELECT 
  u.id,
  u.nickname,
  COUNT(m.id) as message_count
FROM users u
LEFT JOIN messages m ON u.id = m.sender_id
WHERE u.deleted_at IS NULL
GROUP BY u.id, u.nickname
ORDER BY message_count DESC
LIMIT 10;

-- Actividad por hora
SELECT 
  DATE_TRUNC('hour', created_at) as hour,
  COUNT(*) as message_count
FROM messages
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY DATE_TRUNC('hour', created_at)
ORDER BY hour DESC;

-- ============================================================================
-- 7. QUERIES DE MANTENIMIENTO Y LIMPIEZA
-- ============================================================================

-- Ver usuarios no verificados hace más de 7 días
SELECT 
  id,
  nickname,
  email,
  created_at
FROM users
WHERE is_verified = FALSE
  AND created_at < NOW() - INTERVAL '7 days'
  AND deleted_at IS NULL;

-- Ver conversaciones sin actividad hace más de 30 días
SELECT 
  c.id,
  MAX(m.created_at) as last_activity
FROM conversations c
LEFT JOIN messages m ON c.id = m.conversation_id
GROUP BY c.id
HAVING MAX(m.created_at) < NOW() - INTERVAL '30 days' OR MAX(m.created_at) IS NULL;

-- Ver denuncias pendientes
SELECT 
  r.id,
  r.reporter_user_id,
  r.reported_user_id,
  r.reason,
  r.status,
  r.created_at
FROM reports r
WHERE status = 'pending'
ORDER BY r.created_at ASC;

-- ============================================================================
-- 8. UPDATES Y OPERACIONES MASIVAS (USAR CON CUIDADO)
-- ============================================================================

-- Actualizar estado online de usuarios (run cada 5 min con trigger)
UPDATE users
SET is_online = FALSE, last_seen_at = CURRENT_TIMESTAMP
WHERE is_online = TRUE
  AND last_seen_at < NOW() - INTERVAL '5 minutes'
  AND deleted_at IS NULL;

-- Soft delete de usuario (no borrar datos)
UPDATE users
SET deleted_at = CURRENT_TIMESTAMP
WHERE id = 'user-uuid';

-- Marcar todas las notificaciones como leídas
UPDATE notifications
SET is_read = TRUE, read_at = CURRENT_TIMESTAMP
WHERE user_id = 'user-uuid' AND is_read = FALSE;

-- Limpiar matches expirados
UPDATE matches
SET is_active = FALSE
WHERE ends_at < NOW() OR is_active = FALSE;

-- ============================================================================
-- FIN DE QUERIES
-- ============================================================================
