-- ================================================================
-- MIGRACIONES SQL - DuoQ App (Ejecutar en Supabase SQL Editor)
-- ================================================================

-- 1. TABLA REPORTS (recrear con esquema correcto)
-- ================================================================
DROP TABLE IF EXISTS public.reports CASCADE;

CREATE TABLE public.reports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    reporter_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    reported_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    details TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'dismissed')),
    created_at TIMESTAMPTZ DEFAULT now(),
    reviewed_at TIMESTAMPTZ,
    reviewed_by UUID,
    CONSTRAINT no_self_report CHECK (reporter_id != reported_id)
);

CREATE INDEX idx_reports_reported ON public.reports(reported_id);
CREATE INDEX idx_reports_status ON public.reports(status);

ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can create reports"
    ON public.reports FOR INSERT
    TO authenticated
    WITH CHECK (true);

CREATE POLICY "Users can view own reports"
    ON public.reports FOR SELECT
    TO authenticated
    USING (reporter_id = (SELECT id FROM public.users WHERE auth_id = auth.uid()));


-- 2. TABLA BLOCKS (verificar/recrear)
-- ================================================================
DROP TABLE IF EXISTS public.blocks CASCADE;

CREATE TABLE public.blocks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    blocker_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    blocked_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT no_self_block CHECK (blocker_user_id != blocked_user_id),
    CONSTRAINT unique_block UNIQUE (blocker_user_id, blocked_user_id)
);

CREATE INDEX idx_blocks_blocker ON public.blocks(blocker_user_id);
CREATE INDEX idx_blocks_blocked ON public.blocks(blocked_user_id);

ALTER TABLE public.blocks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own blocks"
    ON public.blocks FOR ALL
    TO authenticated
    USING (blocker_user_id = (SELECT id FROM public.users WHERE auth_id = auth.uid()));


-- 3. FIX: last_seen_at default para users
-- ================================================================
ALTER TABLE public.users 
    ALTER COLUMN last_seen_at SET DEFAULT now();

UPDATE public.users SET last_seen_at = created_at WHERE last_seen_at IS NULL;
