-- Safe seed records for local development only.
-- No users, provider identities, payments or live banner campaigns are seeded.

insert into public.service_categories (name, slug, description, icon_key, sort_order, is_published)
values
  ('Puja & Rituals', 'puja-rituals', 'Explore ritual services and devotional experiences.', 'temple_hindu', 1, true),
  ('Pilgrimage', 'pilgrimage', 'Plan journeys to sacred destinations across Bharat.', 'account_balance', 2, true),
  ('Spiritual Stays', 'spiritual-stays', 'Discover stays near important temples and pilgrimage routes.', 'hotel', 3, true),
  ('Local Experiences', 'local-experiences', 'Explore culture, heritage walks and local experiences.', 'explore', 4, true)
on conflict (slug) do nothing;
