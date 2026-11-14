-- Provider working availability, owned by the signed-in provider.
-- Apply after 202611140001_initial_divine_schema.sql.

create table if not exists public.provider_availability (
  user_id uuid not null references auth.users(id) on delete cascade,
  weekday smallint not null check (weekday between 1 and 7),
  start_time time not null default '09:00',
  end_time time not null default '17:00',
  is_available boolean not null default false,
  updated_at timestamptz not null default now(),
  primary key (user_id, weekday),
  constraint provider_availability_valid_time check (end_time > start_time)
);

alter table public.provider_availability enable row level security;

create policy "providers read own availability and admins read all"
  on public.provider_availability
  for select
  to authenticated
  using (
    user_id = (select auth.uid())
    or (select private.is_platform_operator())
  );

create policy "providers manage own availability"
  on public.provider_availability
  for insert
  to authenticated
  with check (
    user_id = (select auth.uid())
    and (
      (select private.current_user_has_role(array['provider', 'operations', 'admin']))
    )
  );

create policy "providers update own availability and admins update all"
  on public.provider_availability
  for update
  to authenticated
  using (
    (user_id = (select auth.uid())
      and (select private.current_user_has_role(array['provider', 'operations', 'admin'])))
    or (select private.is_platform_operator())
  )
  with check (
    (user_id = (select auth.uid())
      and (select private.current_user_has_role(array['provider', 'operations', 'admin'])))
    or (select private.is_platform_operator())
  );

create policy "providers delete own availability and admins delete all"
  on public.provider_availability
  for delete
  to authenticated
  using (
    (user_id = (select auth.uid())
      and (select private.current_user_has_role(array['provider', 'operations', 'admin'])))
    or (select private.is_platform_operator())
  );

grant select, insert, update, delete on public.provider_availability to authenticated;
