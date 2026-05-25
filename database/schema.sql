-- ============================================================================
-- PREMADE - Base de Datos Supabase
-- Gaming Duo/Squad Matching Platform
-- ============================================================================
-- Este archivo contiene toda la estructura necesaria para la plataforma
-- Incluye: Tablas, relaciones, índices, RLS (Row Level Security)
-- ============================================================================

-- ============================================================================
-- 1. EXTENSIONES Y SETUP INICIAL
-- ============================================================================

-- Habilitar UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Habilitar pgcrypto para funciones de seguridad
CREATE EXTENSION IF NOT EXISTS "pgcrypto";


-- ============================================================================
-- 2. TABLAS PRINCIPALES
-- ============================================================================

-- Tabla de Usuarios (vinculada a auth de Supabase)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL UNIQUE,
  nickname VARCHAR(20) NOT NULL UNIQUE,
  age INTEGER NOT NULL CHECK (age >= 13 AND age <= 120),
  country VARCHAR(100) NOT NULL,
  autonomous_region VARCHAR(100),
  province VARCHAR(100),
  avatar_url VARCHAR(500),
  bio TEXT CHECK (bio IS NULL OR (length(bio) >= 10 AND length(bio) <= 500)),
  discord_username VARCHAR(32),
  is_online BOOLEAN DEFAULT FALSE,
  last_seen_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  availability JSONB DEFAULT '{}', -- JSON con disponibilidad semanal
  gaming_style TEXT, -- Descripción del estilo de juego
  is_verified BOOLEAN DEFAULT FALSE,
  is_reported BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP WITH TIME ZONE
);

-- Tabla de Juegos Soportados
CREATE TABLE IF NOT EXISTS public.games (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  icon_url VARCHAR(500),
  has_competitive_mode BOOLEAN DEFAULT TRUE,
  api_type VARCHAR(50), -- 'riot', 'valorant', etc.
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Roles por Juego
CREATE TABLE IF NOT EXISTS public.game_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  game_id UUID NOT NULL REFERENCES public.games(id) ON DELETE CASCADE,
  role_name VARCHAR(50) NOT NULL,
  role_description TEXT,
  UNIQUE(game_id, role_name),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Rangos/Ranks
CREATE TABLE IF NOT EXISTS public.game_ranks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  game_id UUID NOT NULL REFERENCES public.games(id) ON DELETE CASCADE,
  rank_tier VARCHAR(50) NOT NULL, -- Iron, Bronze, Silver, Gold, Platinum, Diamond, Master, Grandmaster, Challenger
  rank_order INTEGER NOT NULL, -- Para ordenar
  icon_url VARCHAR(500),
  UNIQUE(game_id, rank_tier),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Juegos del Usuario
CREATE TABLE IF NOT EXISTS public.user_games (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  game_id UUID NOT NULL REFERENCES public.games(id) ON DELETE CASCADE,
  is_primary BOOLEAN DEFAULT FALSE,
  primary_rank_id UUID REFERENCES public.game_ranks(id) ON DELETE SET NULL,
  secondary_rank_id UUID REFERENCES public.game_ranks(id) ON DELETE SET NULL,
  main_role_id UUID REFERENCES public.game_roles(id) ON DELETE SET NULL,
  secondary_role_id UUID REFERENCES public.game_roles(id) ON DELETE SET NULL,
  is_casual_only BOOLEAN DEFAULT FALSE,
  played_hours INTEGER DEFAULT 0,
  skill_notes TEXT,
  UNIQUE(user_id, game_id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Swipes (Tipo Tinder)
CREATE TABLE IF NOT EXISTS public.swipes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  target_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  action VARCHAR(20) NOT NULL CHECK (action IN ('like', 'dislike', 'superlike')),
  compatibility_score DECIMAL(5, 2), -- Puntuación del matching
  check (user_id != target_user_id),
  UNIQUE(user_id, target_user_id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Matches (Matches confirmados)
CREATE TABLE IF NOT EXISTS public.matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id_1 UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  user_id_2 UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  matched_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE,
  ends_at TIMESTAMP WITH TIME ZONE,
  check (user_id_1 < user_id_2), -- Evitar duplicados
  UNIQUE(user_id_1, user_id_2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Amistades
CREATE TABLE IF NOT EXISTS public.friendships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id_1 UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  user_id_2 UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  requested_by UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  check (user_id_1 != user_id_2),
  UNIQUE(user_id_1, user_id_2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  accepted_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Bloqueos
CREATE TABLE IF NOT EXISTS public.blocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  blocker_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  blocked_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  reason TEXT,
  check (blocker_user_id != blocked_user_id),
  UNIQUE(blocker_user_id, blocked_user_id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Grupos/Squads
CREATE TABLE IF NOT EXISTS public.groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  description TEXT,
  creator_id UUID NOT NULL REFERENCES public.users(id) ON DELETE SET NULL,
  max_members INTEGER DEFAULT 5,
  is_public BOOLEAN DEFAULT FALSE,
  game_id UUID REFERENCES public.games(id) ON DELETE SET NULL,
  avatar_url VARCHAR(500),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Miembros del Grupo
CREATE TABLE IF NOT EXISTS public.group_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('admin', 'moderator', 'member')),
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(group_id, user_id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Conversaciones (1-a-1 o Grupal)
CREATE TABLE IF NOT EXISTS public.conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  is_group BOOLEAN DEFAULT FALSE,
  group_id UUID REFERENCES public.groups(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Participantes en Conversación
CREATE TABLE IF NOT EXISTS public.conversation_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  last_read_at TIMESTAMP WITH TIME ZONE,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(conversation_id, user_id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Mensajes
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_edited BOOLEAN DEFAULT FALSE,
  edited_at TIMESTAMP WITH TIME ZONE,
  is_deleted BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Notificaciones
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL CHECK (type IN ('match', 'message', 'friend_request', 'friend_accepted', 'group_invite')),
  title VARCHAR(200),
  description TEXT,
  related_user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  related_match_id UUID REFERENCES public.matches(id) ON DELETE SET NULL,
  related_conversation_id UUID REFERENCES public.conversations(id) ON DELETE SET NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  read_at TIMESTAMP WITH TIME ZONE
);

-- Tabla de Reports/Denuncias
CREATE TABLE IF NOT EXISTS public.reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE SET NULL,
  reported_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE SET NULL,
  reason VARCHAR(100) NOT NULL,
  description TEXT,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'under_review', 'resolved', 'dismissed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Solicitudes API (para auditoría)
CREATE TABLE IF NOT EXISTS public.api_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  endpoint VARCHAR(255),
  method VARCHAR(10),
  status_code INTEGER,
  response_time_ms INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- 3. ÍNDICES PARA OPTIMIZACIÓN
-- ============================================================================

-- Índices en users
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_nickname ON public.users(nickname);
CREATE INDEX idx_users_country ON public.users(country);
CREATE INDEX idx_users_is_online ON public.users(is_online);
CREATE INDEX idx_users_created_at ON public.users(created_at DESC);

-- Índices en swipes
CREATE INDEX idx_swipes_user_id ON public.swipes(user_id);
CREATE INDEX idx_swipes_target_user_id ON public.swipes(target_user_id);
CREATE INDEX idx_swipes_created_at ON public.swipes(created_at DESC);

-- Índices en matches
CREATE INDEX idx_matches_user_id_1 ON public.matches(user_id_1);
CREATE INDEX idx_matches_user_id_2 ON public.matches(user_id_2);
CREATE INDEX idx_matches_is_active ON public.matches(is_active);

-- Índices en friendships
CREATE INDEX idx_friendships_user_id_1 ON public.friendships(user_id_1);
CREATE INDEX idx_friendships_user_id_2 ON public.friendships(user_id_2);
CREATE INDEX idx_friendships_status ON public.friendships(status);

-- Índices en messages
CREATE INDEX idx_messages_conversation_id ON public.messages(conversation_id);
CREATE INDEX idx_messages_sender_id ON public.messages(sender_id);
CREATE INDEX idx_messages_created_at ON public.messages(created_at DESC);

-- Índices en notifications
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at DESC);

-- Índices en user_games
CREATE INDEX idx_user_games_user_id ON public.user_games(user_id);
CREATE INDEX idx_user_games_game_id ON public.user_games(game_id);

-- Índices en groups
CREATE INDEX idx_groups_creator_id ON public.groups(creator_id);
CREATE INDEX idx_groups_game_id ON public.groups(game_id);

-- Índices en group_members
CREATE INDEX idx_group_members_group_id ON public.group_members(group_id);
CREATE INDEX idx_group_members_user_id ON public.group_members(user_id);


-- ============================================================================
-- 4. TRIGGERS PARA ACTUALIZACIONES AUTOMÁTICAS
-- ============================================================================

-- Trigger para actualizar updated_at en users
CREATE OR REPLACE FUNCTION update_users_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_users_updated_at
BEFORE UPDATE ON public.users
FOR EACH ROW
EXECUTE FUNCTION update_users_updated_at();

-- Trigger para actualizar updated_at en user_games
CREATE OR REPLACE FUNCTION update_user_games_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_user_games_updated_at
BEFORE UPDATE ON public.user_games
FOR EACH ROW
EXECUTE FUNCTION update_user_games_updated_at();

-- Trigger para actualizar updated_at en swipes
CREATE OR REPLACE FUNCTION update_swipes_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_swipes_updated_at
BEFORE UPDATE ON public.swipes
FOR EACH ROW
EXECUTE FUNCTION update_swipes_updated_at();

-- Trigger para actualizar updated_at en messages
CREATE OR REPLACE FUNCTION update_messages_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_messages_updated_at
BEFORE UPDATE ON public.messages
FOR EACH ROW
EXECUTE FUNCTION update_messages_updated_at();


-- ============================================================================
-- 5. FUNCIONES ÚTILES
-- ============================================================================

-- Función para obtener compatibilidad entre dos usuarios
CREATE OR REPLACE FUNCTION calculate_match_compatibility(
  p_user_id_1 UUID,
  p_user_id_2 UUID
)
RETURNS DECIMAL AS $$
DECLARE
  v_score DECIMAL := 0;
  v_common_games INTEGER;
  v_rank_diff INTEGER;
  v_country_match BOOLEAN;
  v_availability_match BOOLEAN;
BEGIN
  -- 1. Juegos en común (peso alto: +40)
  SELECT COUNT(*) INTO v_common_games
  FROM public.user_games ug1
  WHERE ug1.user_id = p_user_id_1
    AND EXISTS (
      SELECT 1 FROM public.user_games ug2
      WHERE ug2.user_id = p_user_id_2
        AND ug2.game_id = ug1.game_id
    );
  
  v_score := v_score + (v_common_games * 20);

  -- 2. País igual (peso medio: +20)
  IF EXISTS (
    SELECT 1 FROM public.users u1, public.users u2
    WHERE u1.id = p_user_id_1
      AND u2.id = p_user_id_2
      AND u1.country = u2.country
  ) THEN
    v_score := v_score + 20;
  END IF;

  -- 3. Estado online (peso bajo: +10)
  IF EXISTS (
    SELECT 1 FROM public.users
    WHERE id = p_user_id_2 AND is_online = TRUE
  ) THEN
    v_score := v_score + 10;
  END IF;

  RETURN LEAST(v_score, 100);
END;
$$ LANGUAGE plpgsql;

-- Función para obtener usuarios con potencial de match
CREATE OR REPLACE FUNCTION get_match_candidates(
  p_user_id UUID,
  p_country VARCHAR DEFAULT NULL,
  p_game_id UUID DEFAULT NULL,
  p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
  user_id UUID,
  nickname VARCHAR,
  age INTEGER,
  avatar_url VARCHAR,
  country VARCHAR,
  compatibility_score DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    u.id,
    u.nickname,
    u.age,
    u.avatar_url,
    u.country,
    calculate_match_compatibility(p_user_id, u.id) as compatibility_score
  FROM public.users u
  WHERE u.id != p_user_id
    AND u.deleted_at IS NULL
    AND (p_country IS NULL OR u.country = p_country)
    AND NOT EXISTS (
      -- No mostrar si ya existe un swipe
      SELECT 1 FROM public.swipes
      WHERE user_id = p_user_id AND target_user_id = u.id
    )
    AND NOT EXISTS (
      -- No mostrar usuarios bloqueados
      SELECT 1 FROM public.blocks
      WHERE (blocker_user_id = p_user_id AND blocked_user_id = u.id)
         OR (blocker_user_id = u.id AND blocked_user_id = p_user_id)
    )
    AND (p_game_id IS NULL OR EXISTS (
      SELECT 1 FROM public.user_games
      WHERE user_id = u.id AND game_id = p_game_id
    ))
  ORDER BY compatibility_score DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;


-- ============================================================================
-- 6. ROW LEVEL SECURITY (RLS) - SEGURIDAD CRÍTICA
-- ============================================================================

-- Habilitar RLS en todas las tablas
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_games ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.swipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversation_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Política para users: Cada usuario puede ver su propio perfil y otros perfiles públicos
CREATE POLICY "Users can view own profile"
  ON public.users FOR SELECT
  USING (auth.uid() = auth_id);

CREATE POLICY "Users can view other profiles if not blocked"
  ON public.users FOR SELECT
  USING (
    auth.uid() != auth_id
    AND NOT EXISTS (
      SELECT 1 FROM public.blocks
      WHERE (blocker_user_id = auth.uid() AND blocked_user_id = id)
         OR (blocker_user_id = id AND blocked_user_id = auth.uid())
    )
  );

-- Política para users: Solo pueden editar su propio perfil
CREATE POLICY "Users can update own profile"
  ON public.users FOR UPDATE
  USING (auth.uid() = auth_id);

-- Política para user_games: Ver solo si es amigo o matching
CREATE POLICY "Users can view own games"
  ON public.user_games FOR SELECT
  USING (user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid()));

-- Política para messages: Solo participantes can ver
-- Política para conversations: usuarios autenticados pueden crear conversaciones
CREATE POLICY "Authenticated users can create conversations"
  ON public.conversations FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- Política para conversations: solo participantes pueden verlas
CREATE POLICY "Users can view their conversations"
  ON public.conversations FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.conversation_participants cp
      JOIN public.users u ON u.id = cp.user_id
      WHERE cp.conversation_id = conversations.id
        AND u.auth_id = auth.uid()
    )
  );

-- Política para conversation_participants: participantes pueden ver miembros de sus conversaciones
CREATE POLICY "Users can view participants in their conversations"
  ON public.conversation_participants FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.conversation_participants cp
      JOIN public.users u ON u.id = cp.user_id
      WHERE cp.conversation_id = conversation_participants.conversation_id
        AND u.auth_id = auth.uid()
    )
  );

-- Política para conversation_participants: crear la propia participación o invitar tras unirse
CREATE POLICY "Users can add participants to their conversations"
  ON public.conversation_participants FOR INSERT
  WITH CHECK (
    user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    OR EXISTS (
      SELECT 1 FROM public.conversation_participants cp
      JOIN public.users u ON u.id = cp.user_id
      WHERE cp.conversation_id = conversation_participants.conversation_id
        AND u.auth_id = auth.uid()
    )
  );

-- Política para conversation_participants: cada usuario actualiza su lectura
CREATE POLICY "Users can update own conversation read state"
  ON public.conversation_participants FOR UPDATE
  USING (
    user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  )
  WITH CHECK (
    user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  );

CREATE POLICY "Users can view messages in their conversations"
  ON public.messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.conversation_participants cp
      JOIN public.users u ON u.id = cp.user_id
      WHERE cp.conversation_id = messages.conversation_id
        AND u.auth_id = auth.uid()
    )
  );

-- Política para messages: Solo pueden enviar si son participantes
CREATE POLICY "Users can send messages to their conversations"
  ON public.messages FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.conversation_participants cp
      JOIN public.users u ON u.id = cp.user_id
      WHERE cp.conversation_id = conversation_id
        AND u.auth_id = auth.uid()
        AND sender_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    )
  );

-- Política para notifications: Solo pueden ver sus propias notificaciones
CREATE POLICY "Users can view own notifications"
  ON public.notifications FOR SELECT
  USING (
    user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  );


-- ============================================================================
-- 7. DATOS INICIALES - JUEGOS Y RANGOS
-- ============================================================================

-- Insertar juegos principales
INSERT INTO public.games (title, description, has_competitive_mode, api_type) VALUES
  ('League of Legends', 'Multiplayer Online Battle Arena competitivo', true, 'riot'),
  ('Valorant', 'Tactical Hero Shooter competitivo', true, 'riot')
ON CONFLICT (title) DO NOTHING;

-- Obtener IDs de juegos para inserción de roles
DO $$
DECLARE
  v_lol_id UUID;
  v_valorant_id UUID;
BEGIN
  -- Obtener IDs de juegos
  SELECT id INTO v_lol_id FROM public.games WHERE title = 'League of Legends' LIMIT 1;
  SELECT id INTO v_valorant_id FROM public.games WHERE title = 'Valorant' LIMIT 1;

  -- Insertar roles de League of Legends
  IF v_lol_id IS NOT NULL THEN
    INSERT INTO public.game_roles (game_id, role_name, role_description) VALUES
      (v_lol_id, 'Top', 'Carril superior'),
      (v_lol_id, 'Jungle', 'Jungla'),
      (v_lol_id, 'Mid', 'Carril central'),
      (v_lol_id, 'ADC', 'Carril inferior'),
      (v_lol_id, 'Support', 'Soporte')
    ON CONFLICT (game_id, role_name) DO NOTHING;
  END IF;

  -- Insertar roles de Valorant
  IF v_valorant_id IS NOT NULL THEN
    INSERT INTO public.game_roles (game_id, role_name, role_description) VALUES
      (v_valorant_id, 'Duelist', 'Agente ofensivo'),
      (v_valorant_id, 'Sentinel', 'Agente defensivo'),
      (v_valorant_id, 'Controller', 'Controlador de mapa'),
      (v_valorant_id, 'Initiator', 'Iniciador')
    ON CONFLICT (game_id, role_name) DO NOTHING;
  END IF;
END $$;

-- Insertar rangos de League of Legends
DO $$
DECLARE
  v_lol_id UUID;
BEGIN
  SELECT id INTO v_lol_id FROM public.games WHERE title = 'League of Legends' LIMIT 1;
  
  IF v_lol_id IS NOT NULL THEN
    INSERT INTO public.game_ranks (game_id, rank_tier, rank_order) VALUES
      (v_lol_id, 'Iron', 1),
      (v_lol_id, 'Bronze', 2),
      (v_lol_id, 'Silver', 3),
      (v_lol_id, 'Gold', 4),
      (v_lol_id, 'Platinum', 5),
      (v_lol_id, 'Diamond', 6),
      (v_lol_id, 'Master', 7),
      (v_lol_id, 'Grandmaster', 8),
      (v_lol_id, 'Challenger', 9)
    ON CONFLICT (game_id, rank_tier) DO NOTHING;
  END IF;
END $$;

-- Insertar rangos de Valorant
DO $$
DECLARE
  v_valorant_id UUID;
BEGIN
  SELECT id INTO v_valorant_id FROM public.games WHERE title = 'Valorant' LIMIT 1;
  
  IF v_valorant_id IS NOT NULL THEN
    INSERT INTO public.game_ranks (game_id, rank_tier, rank_order) VALUES
      (v_valorant_id, 'Iron', 1),
      (v_valorant_id, 'Bronze', 2),
      (v_valorant_id, 'Silver', 3),
      (v_valorant_id, 'Gold', 4),
      (v_valorant_id, 'Platinum', 5),
      (v_valorant_id, 'Diamond', 6),
      (v_valorant_id, 'Ascendant', 7),
      (v_valorant_id, 'Radiant', 8)
    ON CONFLICT (game_id, rank_tier) DO NOTHING;
  END IF;
END $$;


-- ============================================================================
-- 8. VISTAS ÚTILES PARA QUERIES
-- ============================================================================

-- Vista: Usuarios online
CREATE OR REPLACE VIEW public.vw_online_users AS
SELECT 
  id,
  nickname,
  avatar_url,
  country,
  last_seen_at
FROM public.users
WHERE is_online = TRUE AND deleted_at IS NULL;

-- Vista: Matches activos
CREATE OR REPLACE VIEW public.vw_active_matches AS
SELECT 
  m.id,
  u1.nickname as user_1_nickname,
  u2.nickname as user_2_nickname,
  u1.avatar_url as user_1_avatar,
  u2.avatar_url as user_2_avatar,
  m.matched_at,
  m.is_active
FROM public.matches m
JOIN public.users u1 ON m.user_id_1 = u1.id
JOIN public.users u2 ON m.user_id_2 = u2.id
WHERE m.is_active = TRUE;

-- Vista: Amigos de un usuario
CREATE OR REPLACE VIEW public.vw_user_friends AS
SELECT 
  CASE 
    WHEN user_id_1 = (SELECT id FROM public.users WHERE auth_id = auth.uid()) THEN user_id_2
    ELSE user_id_1
  END as friend_id,
  u.nickname,
  u.avatar_url,
  u.country,
  u.is_online
FROM public.friendships f
JOIN public.users u ON (
  (f.user_id_1 = u.id AND f.user_id_2 = (SELECT id FROM public.users WHERE auth_id = auth.uid()))
  OR
  (f.user_id_2 = u.id AND f.user_id_1 = (SELECT id FROM public.users WHERE auth_id = auth.uid()))
)
WHERE f.status = 'accepted';


-- ============================================================================
-- 9. COMENTARIOS Y DOCUMENTACIÓN
-- ============================================================================

COMMENT ON TABLE public.users IS 'Tabla principal de usuarios. Vinculada a auth.users de Supabase.';
COMMENT ON COLUMN public.users.auth_id IS 'Foreign key a auth.users(id) para autenticación.';

COMMENT ON TABLE public.swipes IS 'Acciones tipo Tinder: like, dislike, superlike.';
COMMENT ON COLUMN public.swipes.compatibility_score IS 'Puntuación de compatibilidad calculada entre usuarios.';
COMMENT ON TABLE public.matches IS 'Matches que ambos usuarios confirmaron.';
COMMENT ON TABLE public.messages IS 'Mensajes en tiempo real con Supabase Realtime.';

COMMENT ON FUNCTION calculate_match_compatibility IS 'Calcula la compatibilidad entre dos usuarios basado en juegos, rango, país y disponibilidad.';
COMMENT ON FUNCTION get_match_candidates IS 'Retorna candidatos de matching filtrados y ordenados por compatibilidad.';


-- ============================================================================
-- 10. LIMPIEZA Y VALIDACIONES
-- ============================================================================

-- Función para limpiar usuarios eliminados (soft delete)
CREATE OR REPLACE FUNCTION cleanup_deleted_users()
RETURNS void AS $$
BEGIN
  -- Puede ser llamado periódicamente para hacer hard delete
  -- DELETE FROM public.users WHERE deleted_at < NOW() - INTERVAL '30 days';
  RAISE NOTICE 'Cleanup function created. Use with caution!';
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- FIN DEL SCRIPT SQL
-- ============================================================================
