-- ============================================================================
-- DUOQ - SQL de correccion para Supabase
-- Ejecutar entero en Supabase SQL Editor.
-- Es idempotente: elimina y recrea policies para evitar duplicados.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Asegurar RLS en tablas usadas por la app
-- ---------------------------------------------------------------------------

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_games ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.swipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversation_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

-- ---------------------------------------------------------------------------
-- 2. Normalizar acciones de swipe
-- ---------------------------------------------------------------------------

UPDATE public.swipes
SET action = 'dislike'
WHERE action = 'pass';

ALTER TABLE public.swipes
DROP CONSTRAINT IF EXISTS swipes_action_check;

ALTER TABLE public.swipes
ADD CONSTRAINT swipes_action_check
CHECK (action IN ('like', 'dislike', 'superlike'));

-- ---------------------------------------------------------------------------
-- 3. USERS
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can view public profiles" ON public.users;
DROP POLICY IF EXISTS "Users can view other profiles if not blocked" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;

CREATE POLICY "Users can insert own profile"
  ON public.users FOR INSERT
  WITH CHECK (auth.uid() = auth_id);

CREATE POLICY "Users can view own profile"
  ON public.users FOR SELECT
  USING (auth.uid() = auth_id);

CREATE POLICY "Users can view public profiles"
  ON public.users FOR SELECT
  USING (
    auth.uid() IS NOT NULL
    AND auth.uid() <> auth_id
    AND NOT EXISTS (
      SELECT 1
      FROM public.blocks b
      JOIN public.users me ON me.auth_id = auth.uid()
      WHERE (b.blocker_user_id = me.id AND b.blocked_user_id = users.id)
         OR (b.blocker_user_id = users.id AND b.blocked_user_id = me.id)
    )
  );

CREATE POLICY "Users can update own profile"
  ON public.users FOR UPDATE
  USING (auth.uid() = auth_id)
  WITH CHECK (auth.uid() = auth_id);

-- ---------------------------------------------------------------------------
-- 4. USER_GAMES
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "Users can view own games" ON public.user_games;
DROP POLICY IF EXISTS "Authenticated users can view games" ON public.user_games;
DROP POLICY IF EXISTS "Users can manage own games" ON public.user_games;
DROP POLICY IF EXISTS "Users can update own games" ON public.user_games;
DROP POLICY IF EXISTS "Users can delete own games" ON public.user_games;

CREATE POLICY "Authenticated users can view games"
  ON public.user_games FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "Users can manage own games"
  ON public.user_games FOR INSERT
  WITH CHECK (
    user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  );

CREATE POLICY "Users can update own games"
  ON public.user_games FOR UPDATE
  USING (
    user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  )
  WITH CHECK (
    user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  );

CREATE POLICY "Users can delete own games"
  ON public.user_games FOR DELETE
  USING (
    user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  );

-- ---------------------------------------------------------------------------
-- 5. SWIPES Y MATCHES
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "Users can view own swipes" ON public.swipes;
DROP POLICY IF EXISTS "Users can create own swipes" ON public.swipes;
DROP POLICY IF EXISTS "Users can update own swipes" ON public.swipes;
DROP POLICY IF EXISTS "Users can view own matches" ON public.matches;
DROP POLICY IF EXISTS "Users can create matches involving self" ON public.matches;
DROP POLICY IF EXISTS "Users can update own matches" ON public.matches;

CREATE POLICY "Users can view own swipes"
  ON public.swipes FOR SELECT
  USING (
    user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    OR target_user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  );

CREATE POLICY "Users can create own swipes"
  ON public.swipes FOR INSERT
  WITH CHECK (
    user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  );

CREATE POLICY "Users can update own swipes"
  ON public.swipes FOR UPDATE
  USING (
    user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  )
  WITH CHECK (
    user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  );

CREATE POLICY "Users can view own matches"
  ON public.matches FOR SELECT
  USING (
    user_id_1 = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    OR user_id_2 = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  );

CREATE POLICY "Users can create matches involving self"
  ON public.matches FOR INSERT
  WITH CHECK (
    user_id_1 = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    OR user_id_2 = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  );

CREATE POLICY "Users can update own matches"
  ON public.matches FOR UPDATE
  USING (
    user_id_1 = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    OR user_id_2 = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  )
  WITH CHECK (
    user_id_1 = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    OR user_id_2 = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  );

-- ---------------------------------------------------------------------------
-- 6. FRIENDSHIPS, BLOCKS Y REPORTS
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "Users can view own friendships" ON public.friendships;
DROP POLICY IF EXISTS "Users can create friend requests" ON public.friendships;
DROP POLICY IF EXISTS "Users can update own friendships" ON public.friendships;
DROP POLICY IF EXISTS "Users can delete own friendships" ON public.friendships;
DROP POLICY IF EXISTS "Users can view own blocks" ON public.blocks;
DROP POLICY IF EXISTS "Users can create own blocks" ON public.blocks;
DROP POLICY IF EXISTS "Users can delete own blocks" ON public.blocks;
DROP POLICY IF EXISTS "Users can create reports" ON public.reports;
DROP POLICY IF EXISTS "Users can create reports legacy" ON public.reports;

CREATE POLICY "Users can view own friendships"
  ON public.friendships FOR SELECT
  USING (
    user_id_1 = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    OR user_id_2 = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    OR requested_by = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  );

CREATE POLICY "Users can create friend requests"
  ON public.friendships FOR INSERT
  WITH CHECK (
    requested_by = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  );

CREATE POLICY "Users can update own friendships"
  ON public.friendships FOR UPDATE
  USING (
    user_id_1 = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    OR user_id_2 = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    OR requested_by = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  )
  WITH CHECK (
    user_id_1 = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    OR user_id_2 = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    OR requested_by = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  );

CREATE POLICY "Users can delete own friendships"
  ON public.friendships FOR DELETE
  USING (
    user_id_1 = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    OR user_id_2 = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    OR requested_by = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  );

CREATE POLICY "Users can view own blocks"
  ON public.blocks FOR SELECT
  USING (
    blocker_user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  );

CREATE POLICY "Users can create own blocks"
  ON public.blocks FOR INSERT
  WITH CHECK (
    blocker_user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  );

CREATE POLICY "Users can delete own blocks"
  ON public.blocks FOR DELETE
  USING (
    blocker_user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  );

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'reports'
      AND column_name = 'reporter_user_id'
  ) THEN
    EXECUTE '
      CREATE POLICY "Users can create reports"
        ON public.reports FOR INSERT
        WITH CHECK (
          reporter_user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
        )
    ';
  ELSIF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'reports'
      AND column_name = 'reporter_id'
  ) THEN
    EXECUTE '
      CREATE POLICY "Users can create reports legacy"
        ON public.reports FOR INSERT
        WITH CHECK (
          reporter_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
        )
    ';
  END IF;
END $$;

-- ---------------------------------------------------------------------------
-- 7. CONVERSATIONS Y CHAT
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "Authenticated users can create conversations" ON public.conversations;
DROP POLICY IF EXISTS "Users can view their conversations" ON public.conversations;
DROP POLICY IF EXISTS "Users can view participants in their conversations" ON public.conversation_participants;
DROP POLICY IF EXISTS "Users can add participants to their conversations" ON public.conversation_participants;
DROP POLICY IF EXISTS "Users can update own conversation read state" ON public.conversation_participants;
DROP POLICY IF EXISTS "Users can view messages in their conversations" ON public.messages;
DROP POLICY IF EXISTS "Users can send messages to their conversations" ON public.messages;

CREATE POLICY "Authenticated users can create conversations"
  ON public.conversations FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

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

CREATE POLICY "Users can send messages to their conversations"
  ON public.messages FOR INSERT
  WITH CHECK (
    sender_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
    AND EXISTS (
      SELECT 1 FROM public.conversation_participants cp
      JOIN public.users u ON u.id = cp.user_id
      WHERE cp.conversation_id = messages.conversation_id
        AND u.auth_id = auth.uid()
    )
  );

-- ---------------------------------------------------------------------------
-- 8. NOTIFICATIONS
-- ---------------------------------------------------------------------------

DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;

CREATE POLICY "Users can view own notifications"
  ON public.notifications FOR SELECT
  USING (
    user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  );

CREATE POLICY "Users can update own notifications"
  ON public.notifications FOR UPDATE
  USING (
    user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  )
  WITH CHECK (
    user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid())
  );

-- ============================================================================
-- FIN
-- ============================================================================
