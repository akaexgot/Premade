-- ============================================================================
-- Fix swipes RLS
-- Ejecutar en Supabase SQL Editor si aparece:
-- "new row violates row-level security policy for table swipes"
-- ============================================================================

alter table public.swipes enable row level security;

drop policy if exists "Users can view own swipes" on public.swipes;
drop policy if exists "Users can create own swipes" on public.swipes;
drop policy if exists "Users can update own swipes" on public.swipes;

create policy "Users can view own swipes"
  on public.swipes for select
  to authenticated
  using (
    user_id = (select id from public.users where auth_id = auth.uid() limit 1)
    or target_user_id = (
      select id from public.users where auth_id = auth.uid() limit 1
    )
  );

create policy "Users can create own swipes"
  on public.swipes for insert
  to authenticated
  with check (
    user_id = (select id from public.users where auth_id = auth.uid() limit 1)
  );

create policy "Users can update own swipes"
  on public.swipes for update
  to authenticated
  using (
    user_id = (select id from public.users where auth_id = auth.uid() limit 1)
  )
  with check (
    user_id = (select id from public.users where auth_id = auth.uid() limit 1)
  );
