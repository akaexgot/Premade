-- ============================================================================
-- Match candidates exclusions
-- Ejecutar en Supabase SQL Editor.
-- Excluye usuarios ya swiped, con match, amigos o con solicitud pendiente.
-- ============================================================================

drop function if exists public.get_match_candidates(uuid, varchar, uuid, integer);

create or replace function public.get_match_candidates(
  p_auth_id uuid,
  p_country varchar default null,
  p_game_id uuid default null,
  p_limit integer default 10
)
returns table (
  user_id uuid,
  nickname varchar,
  age integer,
  avatar_url varchar,
  country varchar,
  compatibility_score numeric,
  games text[],
  bio text,
  is_online boolean
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile_id uuid;
begin
  select u.id
  into v_profile_id
  from public.users u
  where u.auth_id = p_auth_id
  limit 1;

  if v_profile_id is null then
    return;
  end if;

  return query
  select
    u.id as user_id,
    u.nickname,
    u.age,
    u.avatar_url,
    u.country,
    public.calculate_match_compatibility(v_profile_id, u.id) as compatibility_score,
    coalesce(array_remove(array_agg(distinct g.title), null), array[]::text[]) as games,
    u.bio,
    u.is_online
  from public.users u
  left join public.user_games ug on ug.user_id = u.id
  left join public.games g on g.id = ug.game_id
  where u.id <> v_profile_id
    and u.deleted_at is null
    and u.banned_at is null
    and (p_country is null or u.country = p_country)
    and (p_game_id is null or exists (
      select 1
      from public.user_games ug_filter
      where ug_filter.user_id = u.id
        and ug_filter.game_id = p_game_id
    ))
    and not exists (
      select 1
      from public.swipes s
      where s.user_id = v_profile_id
        and s.target_user_id = u.id
    )
    and not exists (
      select 1
      from public.matches m
      where m.is_active = true
        and (
          (m.user_id_1 = v_profile_id and m.user_id_2 = u.id)
          or (m.user_id_1 = u.id and m.user_id_2 = v_profile_id)
        )
    )
    and not exists (
      select 1
      from public.friendships f
      where f.status in ('pending', 'accepted')
        and (
          (f.user_id_1 = v_profile_id and f.user_id_2 = u.id)
          or (f.user_id_1 = u.id and f.user_id_2 = v_profile_id)
        )
    )
    and not exists (
      select 1
      from public.blocks b
      where (b.blocker_user_id = v_profile_id and b.blocked_user_id = u.id)
         or (b.blocker_user_id = u.id and b.blocked_user_id = v_profile_id)
    )
  group by u.id, u.nickname, u.age, u.avatar_url, u.country, u.bio, u.is_online
  order by public.calculate_match_compatibility(v_profile_id, u.id) desc
  limit p_limit;
end;
$$;

grant execute on function public.get_match_candidates(uuid, varchar, uuid, integer)
  to authenticated;
