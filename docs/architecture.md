# Divine India architecture

## Monorepo

```text
apps/
  customer/       Public customer experience
  operations/     Provider and fulfilment workflows
  admin/          Restricted platform administration
packages/
  divine_core/    Supabase bootstrap, auth, models and repositories
  divine_design_system/ Shared Hindu-inspired visual language
supabase/
  migrations/     Database schema and Row Level Security
  seed.sql        Safe development seed data
.github/workflows/
  manual-android-apk.yml  Manually dispatched APK workflow only
```

## Dependency direction

- Apps depend on `divine_core` and `divine_design_system`.
- `divine_core` owns backend configuration, auth and data access.
- `divine_design_system` owns theme tokens and reusable presentational components.
- Shared packages must not import app-specific code.
- Do not duplicate Supabase initialization inside feature screens.

## App boundaries

### Customer
Discovery, published services, spiritual experiences, booking history and account settings. Public browsing is available without an account. Booking creation and personal history require authentication.

### Operations
An authenticated provider/operations workspace for assigned bookings, availability and schedules. Every write must be authorized by Supabase RLS and server-side business rules.

### Admin
An authenticated and role-gated control centre. Admin-only permissions are enforced by the `user_roles` table, RLS and storage policies. The UI gate is additional protection, not the security boundary.

## Dynamic homepage banners

1. Admin selects an image in the Admin app.
2. The image is uploaded to the public-read, admin-write `divine-banners` Storage bucket.
3. A row is inserted/updated in `public.banners` with title, subtitle, image URL, CTA, schedule, sort order and active state.
4. The customer app subscribes to the `banners` table through Supabase Realtime.
5. Published and currently scheduled banners are rendered without a new app release.

The app includes a visual fallback when the backend is not configured or no published banners exist. This fallback is not written into the database.

## Configuration

Use Dart compile-time values `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`. Only the publishable key is safe for a mobile client. Do not add a service-role key to app config or Git.

## Build policy

No build runs on push or pull request. The APK workflow is explicitly `workflow_dispatch` only. Do not dispatch it until a build is requested. Artifact retention is one day.
