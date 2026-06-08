-- Run this in Supabase SQL Editor if chat creation/opening fails with RLS errors.

DROP POLICY IF EXISTS "Authenticated users can create conversations" ON public.conversations;
DROP POLICY IF EXISTS "Users can view their conversations" ON public.conversations;
DROP POLICY IF EXISTS "Users can view participants in their conversations" ON public.conversation_participants;
DROP POLICY IF EXISTS "Users can add participants to their conversations" ON public.conversation_participants;
DROP POLICY IF EXISTS "Users can update own conversation read state" ON public.conversation_participants;

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
