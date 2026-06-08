-- ============================================================================
-- Swipe RPC
-- Ejecutar en Supabase SQL Editor.
-- Evita errores RLS al insertar swipes desde el cliente.
-- ============================================================================

create or replace function public.perform_swipe(
  p_target_user_id uuid,
  p_action text,
  p_compatibility_score numeric default null
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
  v_user_1 uuid;
  v_user_2 uuid;
  v_has_reverse_like boolean := false;
begin
  select id into v_user_id
  from public.users
  where auth_id = auth.uid()
    and deleted_at is null
    and banned_at is null
  limit 1;

  if v_user_id is null then
    raise exception 'Perfil no encontrado o usuario baneado';
  end if;

  if p_target_user_id = v_user_id then
    raise exception 'No puedes hacer swipe sobre tu propio perfil';
  end if;

  if p_action not in ('like', 'dislike', 'superlike') then
    raise exception 'Accion de swipe invalida';
  end if;

  insert into public.swipes (
    user_id,
    target_user_id,
    action,
    compatibility_score
  ) values (
    v_user_id,
    p_target_user_id,
    p_action,
    p_compatibility_score
  )
  on conflict (user_id, target_user_id)
  do update set
    action = excluded.action,
    compatibility_score = excluded.compatibility_score,
    updated_at = now();

  if p_action in ('like', 'superlike') then
    select exists (
      select 1
      from public.swipes
      where user_id = p_target_user_id
        and target_user_id = v_user_id
        and action in ('like', 'superlike')
    ) into v_has_reverse_like;

    if v_has_reverse_like then
      v_user_1 := least(v_user_id, p_target_user_id);
      v_user_2 := greatest(v_user_id, p_target_user_id);

      insert into public.matches (user_id_1, user_id_2)
      values (v_user_1, v_user_2)
      on conflict (user_id_1, user_id_2)
      do update set is_active = true;

      return true;
    end if;
  end if;

  return false;
end;
$$;

grant execute on function public.perform_swipe(uuid, text, numeric) to authenticated;
