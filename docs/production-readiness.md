# Divine India — implementation status

## Implemented in this repository

- Three Flutter app packages: Customer, Operations and Admin.
- Shared Hindu-inspired design system and Supabase core package.
- Customer browse experience, dynamically published services, account sign-in/sign-up and booking history.
- Admin dashboard navigation, role-gated sign-in, banner uploads/edits/activation/order/scheduling, service catalogue management and booking-status management.
- Operations sign-in, assigned-booking list and provider weekly availability.
- Supabase schema migrations for roles, services, bookings, banners and provider availability, with Row Level Security policies.
- Authenticated Edge Function for a customer to submit a pending booking request.
- Manual-only Android APK workflow with one-day artifact retention.

## Not yet production complete

- The Supabase migrations and Edge Function are committed but have **not** been applied/deployed to a hosted project.
- No Supabase project URL, publishable key, service-role secret or initial administrator account has been supplied/configured here.
- Payment collection, payment webhooks, refunds and financial reconciliation are not implemented. Booking requests currently enter as pending with amount zero.
- Provider onboarding, identity/KYC checks and admin approval workflows need to be designed and connected.
- Service categories are seeded, but content, temple/destination catalogues, provider records and operational data need verified real entries.
- Customer booking history and realtime streams require the migrations and Edge Function to be deployed.
- Android platform scaffolding is generated only inside the explicitly manual APK workflow; it is not committed in the starter frontend branch.
- Flutter static analysis and unit/widget tests have not been executed in this environment because the Flutter/Dart SDK is unavailable.

## Before first live test

1. Create/link a Supabase project and apply migrations 001–004 in order.
2. Deploy the `create-booking` function and verify its required secrets are present.
3. Assign an administrator role to a verified Auth user through a trusted project-owner process.
4. Create at least one published service and a provider/operations account with the correct role.
5. Test RLS separately as anon, customer, provider, operations and admin.
6. Configure production redirect URLs, privacy policy, terms, support contacts and app identifiers.
7. Add a verified payment gateway only after booking pricing, cancellation and refund policies are defined.
8. Run `flutter pub get`, `flutter analyze` and `flutter test` for each app/package before any APK build is requested.
