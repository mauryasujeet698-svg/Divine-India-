import { withSupabase } from "npm:@supabase/server@1.9.2";

type AssignBody = {
  booking_id?: unknown;
  provider_user_id?: unknown;
};

function errorResponse(status: number, message: string): Response {
  return Response.json({ error: message }, { status });
}

export default {
  fetch: withSupabase({ auth: "user" }, async (request, context) => {
    if (request.method !== "POST") return errorResponse(405, "Method not allowed.");

    const userId = context.userClaims?.id;
    if (!userId) return errorResponse(401, "Authentication required.");

    let body: AssignBody;
    try {
      const value: unknown = await request.json();
      if (typeof value !== "object" || value === null || Array.isArray(value)) {
        return errorResponse(400, "Invalid request body.");
      }
      body = value as AssignBody;
    } catch {
      return errorResponse(400, "Invalid JSON body.");
    }

    const bookingId = typeof body.booking_id === "string" ? body.booking_id.trim() : "";
    const providerId = typeof body.provider_user_id === "string" ? body.provider_user_id.trim() : "";
    const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

    if (!uuidPattern.test(bookingId) || !uuidPattern.test(providerId)) {
      return errorResponse(400, "Enter valid booking and provider user IDs.");
    }

    const { data: actor, error: actorError } = await context.supabase
      .from("user_roles")
      .select("role")
      .eq("user_id", userId)
      .maybeSingle();

    if (actorError || !actor || !["admin", "operations"].includes(String(actor.role))) {
      return errorResponse(403, "Only administrators or operations staff can assign bookings.");
    }

    const { data: provider, error: providerError } = await context.supabaseAdmin
      .from("user_roles")
      .select("role")
      .eq("user_id", providerId)
      .maybeSingle();

    if (providerError) return errorResponse(500, "Could not validate provider account.");
    if (!provider || provider.role !== "provider") {
      return errorResponse(404, "The selected account is not an approved provider.");
    }

    const { data: updated, error: updateError } = await context.supabaseAdmin
      .from("bookings")
      .update({
        provider_id: providerId,
        status: "assigned",
        updated_at: new Date().toISOString(),
      })
      .eq("id", bookingId)
      .in("status", ["pending", "confirmed"])
      .select("id, booking_reference, provider_id, status")
      .maybeSingle();

    if (updateError) return errorResponse(500, "Could not assign the booking.");
    if (!updated) return errorResponse(409, "This booking is no longer available for assignment.");

    return Response.json({
      booking_id: updated.id,
      booking_reference: updated.booking_reference,
      provider_user_id: updated.provider_id,
      status: updated.status,
    }, { status: 200 });
  }),
};
