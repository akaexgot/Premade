-- Corrige la recursion infinita en policies de chat.
-- Ejecutar completo en Supabase SQL Editor.

create or replace function public.current_profile_id()
returns uuid
language sql
security definer
set search_path = public
as $$
  select id
  from public.users
  where auth_id = auth.uid()
  limit 1
$$;

create or replace function public.is_conversation_participant(p_conversation_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.conversation_participants cp
    where cp.conversation_id = p_conversation_id
      and cp.user_id = public.current_profile_id()
  )
$$;

alter function public.current_profile_id() owner to postgres;
alter function public.is_conversation_participant(uuid) owner to postgres;

grant execute on function public.current_profile_id() to authenticated;
grant execute on function public.is_conversation_participant(uuid) to authenticated;

alter table public.conversations enable row level security;
alter table public.conversation_participants enable row level security;
alter table public.messages enable row level security;

drop policy if exists "Authenticated users can create conversations" on public.conversations;
drop policy if exists "Users can view their conversations" on public.conversations;

drop policy if exists "Users can view participants in their conversations" on public.conversation_participants;
drop policy if exists "Users can add participants to their conversations" on public.conversation_participants;
drop policy if exists "Users can update own conversation read state" on public.conversation_participants;

drop policy if exists "Users can view messages in their conversations" on public.messages;
drop policy if exists "Users can send messages to their conversations" on public.messages;

create policy "Authenticated users can create conversations"
  on public.conversations
  for insert
  with check (auth.uid() is not null);

create policy "Users can view their conversations"
  on public.conversations
  for select
  using (public.is_conversation_participant(id));

create policy "Users can view conversation participants"
  on public.conversation_participants
  for select
  using (public.is_conversation_participant(conversation_id));

create policy "Users can add conversation participants"
  on public.conversation_participants
  for insert
  with check (
    user_id = public.current_profile_id()
    or public.is_conversation_participant(conversation_id)
  );

create policy "Users can update own conversation read state"
  on public.conversation_participants
  for update
  using (user_id = public.current_profile_id())
  with check (user_id = public.current_profile_id());

create policy "Users can view messages in their conversations"
  on public.messages
  for select
  using (public.is_conversation_participant(conversation_id));

create policy "Users can send messages to their conversations"
  on public.messages
  for insert
  with check (
    sender_id = public.current_profile_id()
    and public.is_conversation_participant(conversation_id)
  );
