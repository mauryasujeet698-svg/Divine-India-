# create-booking

Deploy with:

```bash
supabase functions deploy create-booking
```

The function uses the pinned `@supabase/server` package and requires an authenticated Supabase user. The wrapper verifies the caller's JWT and provides:

- `context.supabase`: user-scoped client that respects RLS when checking the published experience.
- `context.supabaseAdmin`: secret-backed server client used only for the validated insert.

Hosted Supabase Edge Functions automatically provide the required URL, publishable/secret key maps and JWKS environment variables. Never put the secret key in Flutter source, app build variables, or Git.

The function validates the service, future booking date, party size and note length. It creates a booking request owned by the authenticated user's verified ID. It returns a pending reference only; it does not collect payment, confirm capacity or perform refunds.

Keep `verify_jwt = true` for this user-authenticated function.
