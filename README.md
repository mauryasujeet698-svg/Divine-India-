# Divine India

A Flutter monorepo for the Divine India spiritual travel and services platform.

## Applications

| App | Purpose |
|---|---|
| `apps/customer` | Public discovery, spiritual experiences, pilgrimage, bookings and account |
| `apps/operations` | Provider and fulfilment operations, assignments and schedules |
| `apps/admin` | Restricted platform administration, content and dynamic homepage banners |

## Stack

- Flutter 3.50 / Dart 3.14
- Riverpod 3.5
- GoRouter 18.1
- Supabase Flutter 2.17 (Postgres, Auth, Storage and Realtime)
- Shared packages: `divine_core`, `divine_design_system`

## Visual direction

A contemporary Hindu spiritual identity: saffron, deep maroon, temple gold and warm ivory. The interface should feel devotional and premium without becoming visually crowded.

## Repository status

Frontend source and application configuration are being added in staged commits. This repository does not contain a generated APK or AAB. The Android artifact workflow is manual-dispatch only and its artifacts are configured to expire after one day.

## Local setup

1. Install Flutter 3.50 and Dart 3.14.
2. Configure a Supabase project using `supabase/migrations` and the setup notes in `docs/supabase-setup.md`.
3. From each app folder, run `flutter pub get`.
4. Run an app with the Supabase values supplied at launch:

```bash
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

The customer app can be explored in demo mode when Supabase values are not configured. Admin and operations sign-in require a configured Supabase project and authorized accounts. Customer booking requests require the deployed `create-booking` Edge Function.

## Build policy

Do not run an Android build automatically. The workflow at `.github/workflows/manual-android-apk.yml` runs only after an explicit manual dispatch. Uploaded APK artifacts have `retention-days: 1`.

## Important security notes

- Only the Supabase publishable key belongs in a mobile app. Never put a service-role/secret key in Flutter code or GitHub client-side configuration.
- Admin and operations access is role-gated and must be enforced by database RLS policies, not only by UI navigation.
- Configure Google/Apple OAuth, redirect URLs, app signing and production domains before launch.
- SQL migrations are committed but are not applied to any Supabase project by this repository setup.
