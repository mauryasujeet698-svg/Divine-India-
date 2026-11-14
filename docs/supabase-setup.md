# Supabase setup

This repository includes a starter migration. It has **not** been applied to a Supabase project.

## 1. Create and configure a project
Create a Supabase project, then run the SQL migration in `supabase/migrations` using the Supabase CLI or SQL editor. Review the migration before applying it to production.

## 2. Configure the Flutter apps

```bash
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

Never use the service-role/secret key in a Flutter app.

## 3. Roles
The migration creates `public.user_roles`. New users do not become admins automatically. Assign `admin`, `operations`, or `provider` roles only through a trusted server-side process or the Supabase SQL editor by an authorized project owner.

Example one-time role assignment (replace the UUID with the verified Auth user ID):

```sql
insert into public.user_roles (user_id, role)
values ('00000000-0000-0000-0000-000000000000', 'admin')
on conflict (user_id) do update set role = excluded.role;
```

Do not expose a role-editing feature to regular app users.

## 4. Homepage banners
The migration creates the `divine-banners` Storage bucket and the `public.banners` table. Public users can read active banners; only platform admins can write banner rows or upload/delete bucket objects. The migration attempts to add the table to `supabase_realtime`.

## 5. OAuth and redirects
Configure Google or other identity providers in Supabase Auth and register redirect URLs for each Android application before enabling OAuth. This starter currently provides email/password sign-in for restricted apps and keeps customer browsing available without authentication.

## 6. Deploy the booking-request function

Apply all four migrations in timestamp order, then deploy the Edge Function:

```bash
supabase functions deploy create-booking
```

The function uses the project secrets `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY`. Supabase provides these to Edge Functions in a standard project. Do not copy the service-role key into any Flutter app or client-side configuration.

This endpoint creates a **pending booking request** only. It does not collect payment, confirm inventory, or issue refunds. Add a verified payment-gateway integration before treating the booking as paid or confirmed.

## 7. Production checklist
- Configure Auth email templates, rate limits and allowed redirect URLs.
- Confirm RLS policies with anon, customer, provider, operations and admin test accounts.
- Configure backups, database monitoring and Storage lifecycle policies.
- Add a custom domain and production privacy/terms pages.
- Never commit project secrets, signing keys or service-role credentials.
