-- Divine India starter schema.
-- Review with a project owner before applying to a hosted Supabase project.

create extension if not exists pgcrypto with schema extensions;

create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to authenticated;

create table if not exists public.user_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('customer', 'provider', 'operations', 'admin')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.user_roles enable row level security;

create policy "users can read their own role"
  on public.user_roles
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

grant select on public.user_roles to authenticated;

-- These role helpers intentionally run as the caller (SECURITY INVOKER).
-- The user_roles RLS policy restricts the lookup to the caller's own role.
create or replace function private.current_user_has_role(allowed_roles text[])
returns boolean
language sql
stable
security invoker
set search_path = ''
as $$
  select exists (
    select 1
    from public.user_roles ur
    where ur.user_id = (select auth.uid())
      and ur.role = any(allowed_roles)
  );
$$;

revoke all on function private.current_user_has_role(text[]) from public;
grant execute on function private.current_user_has_role(text[]) to authenticated;

create or replace function private.is_platform_admin()
returns boolean
language sql
stable
security invoker
set search_path = ''
as $$
  select private.current_user_has_role(array['admin']);
$$;

create or replace function private.is_platform_operator()
returns boolean
language sql
stable
security invoker
set search_path = ''
as $$
  select private.current_user_has_role(array['admin', 'operations']);
$$;

revoke all on function private.is_platform_admin() from public;
revoke all on function private.is_platform_operator() from public;
grant execute on function private.is_platform_admin() to authenticated;
grant execute on function private.is_platform_operator() to authenticated;

create table if not exists public.banners (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  subtitle text not null default '',
  image_url text not null,
  cta_label text not null default 'Explore',
  cta_route text not null default '/explore',
  sort_order integer not null default 0,
  is_active boolean not null default false,
  starts_at timestamptz,
  ends_at timestamptz,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint banners_schedule_valid check (
    starts_at is null or ends_at is null or ends_at > starts_at
  )
);

create index if not exists banners_publication_order_idx
  on public.banners (is_active, sort_order, starts_at, ends_at);

alter table public.banners enable row level security;

create policy "published banners are readable"
  on public.banners
  for select
  to anon, authenticated
  using (
    is_active = true
    and (starts_at is null or starts_at <= now())
    and (ends_at is null or ends_at > now())
  );

create policy "admins manage banners"
  on public.banners
  for all
  to authenticated
  using ((select private.is_platform_admin()))
  with check ((select private.is_platform_admin()));

grant select on public.banners to anon, authenticated;
grant insert, update, delete on public.banners to authenticated;

create table if not exists public.service_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  description text not null default '',
  icon_key text not null default 'temple_hindu',
  sort_order integer not null default 0,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.service_categories enable row level security;

create policy "published service categories are readable"
  on public.service_categories
  for select
  to anon, authenticated
  using (is_published = true);

create policy "admins manage service categories"
  on public.service_categories
  for all
  to authenticated
  using ((select private.is_platform_admin()))
  with check ((select private.is_platform_admin()));

grant select on public.service_categories to anon, authenticated;
grant insert, update, delete on public.service_categories to authenticated;

create table if not exists public.services (
  id uuid primary key default gen_random_uuid(),
  category_id uuid references public.service_categories(id) on delete set null,
  title text not null,
  slug text not null unique,
  short_description text not null default '',
  image_url text,
  location_name text,
  price_from numeric(12,2),
  currency text not null default 'INR',
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists services_publication_idx
  on public.services (is_published, category_id);

alter table public.services enable row level security;

create policy "published services are readable"
  on public.services
  for select
  to anon, authenticated
  using (is_published = true);

create policy "admins manage services"
  on public.services
  for all
  to authenticated
  using ((select private.is_platform_admin()))
  with check ((select private.is_platform_admin()));

grant select on public.services to anon, authenticated;
grant insert, update, delete on public.services to authenticated;

create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  booking_reference text not null unique,
  user_id uuid not null references auth.users(id) on delete restrict,
  service_id uuid references public.services(id) on delete set null,
  provider_id uuid references auth.users(id) on delete set null,
  booking_date timestamptz,
  party_size integer not null default 1 check (party_size > 0),
  status text not null default 'pending'
    check (status in ('pending', 'confirmed', 'assigned', 'in_progress', 'completed', 'cancelled')),
  total_amount numeric(12,2) not null default 0 check (total_amount >= 0),
  currency text not null default 'INR',
  customer_note text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists bookings_user_created_idx
  on public.bookings (user_id, created_at desc);
create index if not exists bookings_provider_status_idx
  on public.bookings (provider_id, status, booking_date);

alter table public.bookings enable row level security;

create policy "users and assigned providers can read bookings"
  on public.bookings
  for select
  to authenticated
  using (
    user_id = (select auth.uid())
    or provider_id = (select auth.uid())
    or (select private.is_platform_operator())
  );

create policy "admins and operations update bookings"
  on public.bookings
  for update
  to authenticated
  using ((select private.is_platform_operator()))
  with check ((select private.is_platform_operator()));

-- Direct client inserts are intentionally not granted. Checkout must be implemented
-- through a server-validated RPC/Edge Function that verifies service price and payment.

grant select on public.bookings to authenticated;
grant update on public.bookings to authenticated;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'divine-banners',
  'divine-banners',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

create policy "public can view Divine India banners"
  on storage.objects
  for select
  to anon, authenticated
  using (bucket_id = 'divine-banners');

create policy "admins upload Divine India banners"
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'divine-banners'
    and (select private.is_platform_admin())
  );

create policy "admins update Divine India banners"
  on storage.objects
  for update
  to authenticated
  using (
    bucket_id = 'divine-banners'
    and (select private.is_platform_admin())
  )
  with check (
    bucket_id = 'divine-banners'
    and (select private.is_platform_admin())
  );

create policy "admins delete Divine India banners"
  on storage.objects
  for delete
  to authenticated
  using (
    bucket_id = 'divine-banners'
    and (select private.is_platform_admin())
  );

do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime')
     and not exists (
       select 1 from pg_publication_tables
       where pubname = 'supabase_realtime'
         and schemaname = 'public'
         and tablename = 'banners'
     ) then
    alter publication supabase_realtime add table public.banners;
  end if;
end;
$$;
