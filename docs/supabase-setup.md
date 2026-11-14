# Supabase setup

This repository includes starter migrations and a booking-request Edge Function. They have **not** been applied or deployed to a hosted Supabase project.

## 1. Create and configure a project
Create a Supabase project, then review and apply the migrations in `supabase/migrations` in timestamp order using the Supabase CLI or SQL editor. Do not apply them to a live project before reviewing the schema and access model.

## 2. Configure the Flutter apps

```bash
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

Use a Supabase publishable key in mobile applications. Never put a secret key, legacy service-role key or database password in Flutter code, dart-defines, or app bundles.

## 3. Assign roles securely
The migration creates `public.user_roles`. New users do not become admins automatically. Assign `admin`, `operations`, or `provider` roles only through a trusted server-side process or the Supabase SQL editor by an authorized project owner.

Example one-time role assignment (replace the UUID with the verified Auth user ID):

```sql
insert into public.user_roles (user_id, role)
values ('00000000-0000-0000-0000-000000000000', 'admin')
on conflict (user_id) do update set role = excluded.role;
```

Do not expose a role-editing feature to regular app users.

For a provider account, create and verify the Auth user through a trusted process, complete the platform's real-world provider checks outside this starter app, then assign the provider role from the SQL editor:

```sql
insert into public.user_roles (user_id, role)
values ('11111111-1111-4111-8111-111111111111', 'provider')
on conflict (user_id) do update set role = excluded.role;
```

The UUID is an example placeholder. The Admin app's booking assignment action requires the actual verified provider Auth user UUID. Provider onboarding, KYC collection and approval UI are not included in this first implementation pass.

## 4. Homepage banners
The migration creates the `divine-banners` Storage bucket and the `public.banners` table. Public users can read currently published banners; only platform admins can write banner rows or upload/delete bucket objects. The customer app listens to Supabase Realtime, so changes appear without an app release after the migrations are applied and Realtime is available for the table.

## 5. Authentication and redirects
Configure Supabase Auth email templates, allowed redirect URLs and any OAuth providers in the dashboard. The initial apps use email/password authentication. Register the matching Android application/deep-link redirects before enabling OAuth or password recovery.

## 6. Deploy the booking-request function

After applying all migrations, deploy the function:

```bash
supabase functions deploy create-booking
supabase functions deploy assign-booking
supabase functions deploy update-booking-progress
```

The function uses the current `@supabase/server` SDK. Supabase provisions `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEYS`, `SUPABASE_SECRET_KEYS` and `SUPABASE_JWKS` in hosted Edge Function environments. The SDK verifies the signed-in user's JWT and provides an RLS-scoped client; it uses the secret-backed admin client only for the validated booking insert. Do not copy a secret key into the repository or Flutter app.

This endpoint creates a **pending booking request** only. It does not collect payment, confirm inventory, or issue refunds. The amount remains zero until a trusted quote/payment workflow is implemented.

## 7. Production checklist
- Configure Auth email templates, rate limits and allowed redirect URLs.
- Confirm RLS policies with anon, customer, provider, operations and admin test accounts.
- Configure backups, database monitoring and Storage lifecycle policies.
- Add a custom domain and production privacy/terms pages.
- Never commit project secrets, signing keys or secret API keys.
