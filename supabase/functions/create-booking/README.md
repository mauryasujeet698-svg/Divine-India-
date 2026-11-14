# create-booking

Deploy with Supabase Functions after linking the correct project.

Required Edge Function secrets:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`

The function requires a valid authenticated user, validates the requested published service and future booking date, bounds the party size and note length, and then creates a pending booking under the authenticated user's ID using server-side credentials.

It is a booking **request**, not a payment capture or confirmed reservation. Amount is stored as zero until a verified quote/payment workflow is implemented. Never expose the service-role key to mobile apps.
