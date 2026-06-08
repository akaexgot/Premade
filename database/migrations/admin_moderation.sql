-- ============================================================================
-- Admin moderation support
-- Ejecutar en Supabase SQL Editor despues de admin_panel.sql.
-- ============================================================================

alter table public.users
  add column if not exists banned_at timestamptz,
  add column if not exists ban_reason text,
  add column if not exists banned_by uuid references public.users(id) on delete set null;

alter table public.reports
  add column if not exists reporter_user_id uuid references public.users(id) on delete set null,
  add column if not exists reported_user_id uuid references public.users(id) on delete set null,
  add column if not exists description text,
  add column if not exists updated_at timestamptz default now();

do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'reports'
      and column_name = 'reporter_id'
  ) then
    alter table public.reports alter column reporter_id drop not null;
    update public.reports
    set reporter_user_id = coalesce(reporter_user_id, reporter_id);
  end if;

  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'reports'
      and column_name = 'reported_id'
  ) then
    alter table public.reports alter column reported_id drop not null;
    update public.reports
    set reported_user_id = coalesce(reported_user_id, reported_id);
  end if;

  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'reports'
      and column_name = 'details'
  ) then
    update public.reports
    set description = coalesce(description, details);
  end if;
end $$;

do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'reports'
      and column_name = 'reporter_id'
  ) and exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'reports'
      and column_name = 'reported_id'
  ) and exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'reports'
      and column_name = 'details'
  ) then
    execute $fn$
      create or replace function public.sync_report_columns()
      returns trigger
      language plpgsql
      set search_path = public
      as $body$
      begin
        new.reporter_user_id = coalesce(new.reporter_user_id, new.reporter_id);
        new.reported_user_id = coalesce(new.reported_user_id, new.reported_id);
        new.reporter_id = coalesce(new.reporter_id, new.reporter_user_id);
        new.reported_id = coalesce(new.reported_id, new.reported_user_id);
        new.description = coalesce(new.description, new.details);
        new.details = coalesce(new.details, new.description);
        return new;
      end;
      $body$;
    $fn$;

    drop trigger if exists sync_report_columns_before_insert on public.reports;
    create trigger sync_report_columns_before_insert
    before insert or update on public.reports
    for each row execute function public.sync_report_columns();
  end if;
end $$;

update public.reports
set status = 'under_review'
where status = 'reviewed';

alter table public.reports
  drop constraint if exists reports_status_check;

alter table public.reports
  add constraint reports_status_check
  check (status in ('pending', 'under_review', 'resolved', 'dismissed'));

alter table public.reports enable row level security;

create index if not exists idx_users_banned_at on public.users(banned_at);
create index if not exists idx_reports_status on public.reports(status);
create index if not exists idx_reports_reported_user_id on public.reports(reported_user_id);

create or replace function public.admin_get_stats()
returns jsonb
language sql
security definer
set search_path = public
stable
as $$
  select case
    when not public.is_app_admin() then '{}'::jsonb
    else jsonb_build_object(
      'total_users', (
        select count(*) from public.users where deleted_at is null
      ),
      'new_users_7d', (
        select count(*) from public.users
        where deleted_at is null
          and created_at >= now() - interval '7 days'
      ),
      'banned_users', (
        select count(*) from public.users
        where deleted_at is null
          and banned_at is not null
      ),
      'pending_reports', (
        select count(*) from public.reports
        where status in ('pending', 'under_review')
      ),
      'matches', (
        select count(*) from public.matches
      ),
      'conversations', (
        select count(*) from public.conversations
      )
    )
  end;
$$;

create or replace function public.admin_list_banned_users()
returns setof public.users
language sql
security definer
set search_path = public
stable
as $$
  select *
  from public.users
  where public.is_app_admin()
    and deleted_at is null
    and banned_at is not null
  order by banned_at desc;
$$;

create or replace function public.admin_list_reports()
returns table (
  id uuid,
  reporter_user_id uuid,
  reported_user_id uuid,
  reason text,
  description text,
  status text,
  created_at timestamptz,
  updated_at timestamptz,
  reporter_nickname text,
  reporter_email text,
  reported_nickname text,
  reported_email text,
  reported_banned_at timestamptz
)
language sql
security definer
set search_path = public
stable
as $$
  select
    r.id,
    r.reporter_user_id,
    r.reported_user_id,
    r.reason::text,
    r.description,
    r.status::text,
    r.created_at,
    r.updated_at,
    reporter.nickname::text as reporter_nickname,
    reporter.email::text as reporter_email,
    reported.nickname::text as reported_nickname,
    reported.email::text as reported_email,
    reported.banned_at as reported_banned_at
  from public.reports r
  left join public.users reporter on reporter.id = r.reporter_user_id
  left join public.users reported on reported.id = r.reported_user_id
  where public.is_app_admin()
  order by
    case r.status
      when 'pending' then 0
      when 'under_review' then 1
      else 2
    end,
    r.created_at desc;
$$;

create or replace function public.admin_ban_user(
  p_profile_id uuid,
  p_reason text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_admin_id uuid;
begin
  if not public.is_app_admin() then
    raise exception 'Admin privileges required';
  end if;

  select id into v_admin_id
  from public.users
  where auth_id = auth.uid()
  limit 1;

  update public.users
  set
    banned_at = now(),
    ban_reason = nullif(trim(coalesce(p_reason, '')), ''),
    banned_by = v_admin_id,
    updated_at = now()
  where id = p_profile_id;
end;
$$;

create or replace function public.admin_unban_user(p_profile_id uuid)
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
    banned_at = null,
    ban_reason = null,
    banned_by = null,
    updated_at = now()
  where id = p_profile_id;
end;
$$;

create or replace function public.admin_update_report_status(
  p_report_id uuid,
  p_status text
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

  if p_status not in ('pending', 'under_review', 'resolved', 'dismissed') then
    raise exception 'Invalid report status';
  end if;

  update public.reports
  set status = p_status, updated_at = now()
  where id = p_report_id;
end;
$$;

drop policy if exists "Admins can view reports" on public.reports;
drop policy if exists "Admins can update reports" on public.reports;
drop policy if exists "Users can create reports" on public.reports;
drop policy if exists "Users can view own reports" on public.reports;

create policy "Users can create reports"
  on public.reports for insert
  to authenticated
  with check (
    reporter_user_id = (
      select id from public.users where auth_id = auth.uid() limit 1
    )
    and reporter_user_id <> reported_user_id
  );

create policy "Users can view own reports"
  on public.reports for select
  to authenticated
  using (
    reporter_user_id = (
      select id from public.users where auth_id = auth.uid() limit 1
    )
  );

create policy "Admins can view reports"
  on public.reports for select
  using (public.is_app_admin());

create policy "Admins can update reports"
  on public.reports for update
  using (public.is_app_admin())
  with check (public.is_app_admin());

grant execute on function public.admin_get_stats() to authenticated;
grant execute on function public.admin_list_banned_users() to authenticated;
grant execute on function public.admin_list_reports() to authenticated;
grant execute on function public.admin_ban_user(uuid, text) to authenticated;
grant execute on function public.admin_unban_user(uuid) to authenticated;
grant execute on function public.admin_update_report_status(uuid, text) to authenticated;
