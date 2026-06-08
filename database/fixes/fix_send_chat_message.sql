-- Crea una funcion segura para enviar mensajes de chat.
-- Ejecutar completo en Supabase SQL Editor.

create or replace function public.send_chat_message(
  p_conversation_id uuid,
  p_content text
)
returns public.messages
language plpgsql
security definer
set search_path = public
as $$
declare
  v_my_profile_id uuid;
  v_message public.messages;
begin
  select u.id
  into v_my_profile_id
  from public.users u
  where u.auth_id = auth.uid()
  limit 1;

  if v_my_profile_id is null then
    raise exception 'Usuario no autenticado';
  end if;

  if p_content is null or length(trim(p_content)) = 0 then
    raise exception 'El mensaje no puede estar vacio';
  end if;

  if not exists (
    select 1
    from public.conversation_participants cp
    where cp.conversation_id = p_conversation_id
      and cp.user_id = v_my_profile_id
  ) then
    raise exception 'No perteneces a esta conversacion';
  end if;

  insert into public.messages (conversation_id, sender_id, content)
  values (p_conversation_id, v_my_profile_id, trim(p_content))
  returning * into v_message;

  return v_message;
end;
$$;

alter function public.send_chat_message(uuid, text) owner to postgres;
grant execute on function public.send_chat_message(uuid, text) to authenticated;
