-- Crea una funcion segura para abrir o crear chats 1-a-1.
-- Ejecutar completo en Supabase SQL Editor.

create or replace function public.get_or_create_conversation(
  p_other_profile_id uuid
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_my_profile_id uuid;
  v_conversation_id uuid;
begin
  select u.id
  into v_my_profile_id
  from public.users u
  where u.auth_id = auth.uid()
  limit 1;

  if v_my_profile_id is null then
    raise exception 'Usuario no autenticado';
  end if;

  if p_other_profile_id is null then
    raise exception 'Usuario destino invalido';
  end if;

  if p_other_profile_id = v_my_profile_id then
    raise exception 'No puedes abrir chat contigo mismo';
  end if;

  if not exists (
    select 1 from public.users u where u.id = p_other_profile_id
  ) then
    raise exception 'Usuario destino no encontrado';
  end if;

  select cp1.conversation_id
  into v_conversation_id
  from public.conversation_participants cp1
  join public.conversation_participants cp2
    on cp2.conversation_id = cp1.conversation_id
  join public.conversations c
    on c.id = cp1.conversation_id
  where c.is_group = false
    and cp1.user_id = v_my_profile_id
    and cp2.user_id = p_other_profile_id
  limit 1;

  if v_conversation_id is not null then
    return v_conversation_id;
  end if;

  insert into public.conversations (is_group)
  values (false)
  returning id into v_conversation_id;

  insert into public.conversation_participants (conversation_id, user_id)
  values
    (v_conversation_id, v_my_profile_id),
    (v_conversation_id, p_other_profile_id)
  on conflict (conversation_id, user_id) do nothing;

  return v_conversation_id;
end;
$$;

alter function public.get_or_create_conversation(uuid) owner to postgres;
grant execute on function public.get_or_create_conversation(uuid) to authenticated;
