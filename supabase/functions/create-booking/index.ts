import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(status: number, payload: Record<string, unknown>) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (request.method !== "POST") {
    return jsonResponse(405, { error: "Method not allowed." });
  }

  const authorization = request.headers.get("Authorization");
  if (!authorization?.startsWith("Bearer ")) {
    return jsonResponse(401, { error: "Authentication required." });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    return jsonResponse(500, { error: "Booking service is not configured." });
  }

  const token = authorization.slice("Bearer ".length);
  const authClient = createClient(supabaseUrl, anonKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: userData, error: authError } = await authClient.auth.getUser(token);
  if (authError || !userData.user) {
    return jsonResponse(401, { error: "Your session is invalid or expired." });
  }

  let body: Record<string, unknown>;
  try {
    const parsed: unknown = await request.json();
    if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) {
      return jsonResponse(400, { error: "Invalid request body." });
    }
    body = parsed as Record<string, unknown>;
  } catch {
    return jsonResponse(400, { error: "Invalid JSON body." });
  }

  const serviceId = typeof body.service_id === "string" ? body.service_id : "";
  const bookingDate = typeof body.booking_date === "string" ? new Date(body.booking_date) : null;
  const partySize = Number(body.party_size);
  const customerNote = typeof body.customer_note === "string" ? body.customer_note.trim() : "";

  if (!serviceId || !bookingDate || Number.isNaN(bookingDate.getTime()) || bookingDate.getTime() < Date.now()) {
    return jsonResponse(400, { error: "Choose a valid future date and experience." });
  }
  if (!Number.isInteger(partySize) || partySize < 1 || partySize > 20) {
    return jsonResponse(400, { error: "Party size must be between 1 and 20." });
  }
  if (customerNote.length > 500) {
    return jsonResponse(400, { error: "The note must be 500 characters or fewer." });
  }

  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data: service, error: serviceError } = await adminClient
    .from("services")
    .select("id, is_published")
    .eq("id", serviceId)
    .maybeSingle();

  if (serviceError) {
    return jsonResponse(500, { error: "Could not validate the selected experience." });
  }
  if (!service || service.is_published !== true) {
    return jsonResponse(404, { error: "This experience is not currently available." });
  }

  const bookingReference = `DI-${crypto.randomUUID().slice(0, 8).toUpperCase()}`;
  const { error: insertError } = await adminClient
    .from("bookings")
    .insert({
      booking_reference: bookingReference,
      user_id: userData.user.id,
      service_id: service.id,
      booking_date: bookingDate.toISOString(),
      party_size: partySize,
      status: "pending",
      total_amount: 0,
      currency: "INR",
      customer_note: customerNote,
    });

  if (insertError) {
    return jsonResponse(500, { error: "Could not create your booking request." });
  }

  return jsonResponse(201, {
    booking_reference: bookingReference,
    status: "pending",
    message: "Your booking request has been submitted for confirmation.",
  });
});
