-- Category classification for customer Explore filters.
-- Apply after 202611140001_initial_divine_schema.sql.
alter table public.services
  add column if not exists category_slug text not null default 'local-experiences';

alter table public.services
  add constraint services_category_slug_valid
  check (category_slug in ('puja-rituals', 'pilgrimage', 'spiritual-stays', 'local-experiences'));

create index if not exists services_category_publication_idx
  on public.services (category_slug, is_published);
