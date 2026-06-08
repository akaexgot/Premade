-- ============================================================================
-- Admin panel support
-- Ejecutar en Supabase SQL Editor.
-- ============================================================================

alter table public.users
  add column if not exists role varchar(20) default 'member'
  check (role in ('admin', 'moderator', 'member'));

create or replace function public.current_app_role()
returns text
language sql
security definer
set search_path = public
stable
as $$
  select coalesce(
    (select role from public.users where auth_id = auth.uid() limit 1),
    'member'
  );
$$;

create or replace function public.is_app_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select public.current_app_role() = 'admin';
$$;

grant execute on function public.current_app_role() to authenticated;
grant execute on function public.is_app_admin() to authenticated;

drop policy if exists "Admins can view all users" on public.users;
drop policy if exists "Admins can update users" on public.users;
drop policy if exists "Admins can delete users" on public.users;
drop policy if exists "Admins can insert app profiles" on public.users;

create policy "Admins can view all users"
  on public.users for select
  using (public.is_app_admin());

create policy "Admins can update users"
  on public.users for update
  using (public.is_app_admin())
  with check (public.is_app_admin());

create policy "Admins can delete users"
  on public.users for delete
  using (public.is_app_admin());

create policy "Admins can insert app profiles"
  on public.users for insert
  with check (public.is_app_admin());

create or replace function public.admin_list_users()
returns setof public.users
language sql
security definer
set search_path = public
stable
as $$
  select *
  from public.users
  where public.is_app_admin()
  order by created_at desc;
$$;

create or replace function public.admin_update_user_profile(
  p_profile_id uuid,
  p_email text,
  p_nickname text,
  p_age integer,
  p_country text,
  p_role text,
  p_bio text default null,
  p_discord_username text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_app_admin() then
    raise exception 'Admin privileges required';
  end if;

  update public.users
  set
    email = trim(p_email),
    nickname = trim(p_nickname),
    age = p_age,
    country = trim(p_country),
    role = p_role,
    bio = nullif(trim(coalesce(p_bio, '')), ''),
    discord_username = nullif(trim(coalesce(p_discord_username, '')), ''),
    updated_at = now()
  where id = p_profile_id;
end;
$$;

create or replace function public.admin_delete_user_profile(p_profile_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_app_admin() then
    raise exception 'Admin privileges required';
  end if;

  update public.users
  set deleted_at = now(), updated_at = now()
  where id = p_profile_id;
end;
$$;

create or replace function public.admin_create_user_profile(
  p_auth_id uuid,
  p_email text,
  p_nickname text,
  p_age integer,
  p_country text,
  p_role text default 'member'
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile_id uuid;
begin
  if not public.is_app_admin() then
    raise exception 'Admin privileges required';
  end if;

  insert into public.users (
    auth_id,
    email,
    nickname,
    age,
    country,
    role
  ) values (
    p_auth_id,
    trim(p_email),
    trim(p_nickname),
    p_age,
    trim(p_country),
    p_role
  )
  returning id into v_profile_id;

  return v_profile_id;
end;
$$;

grant execute on function public.admin_list_users() to authenticated;
grant execute on function public.admin_update_user_profile(uuid, text, text, integer, text, text, text, text) to authenticated;
grant execute on function public.admin_delete_user_profile(uuid) to authenticated;
grant execute on function public.admin_create_user_profile(uuid, text, text, integer, text, text) to authenticated;

-- Para convertir tu cuenta actual en admin, cambia el email:
-- update public.users set role = 'admin' where email = 'tu@email.com';
