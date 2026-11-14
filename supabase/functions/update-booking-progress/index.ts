import { withSupabase } from "npm:@supabase/server@1.9.2";

type ProgressBody = {
  booking_id?: unknown;
  status?: unknown;
};

function errorResponse(status: number, message: string): Response {
  return Response.json({ error: message }, { status });
}

export default {
  fetch: withSupabase({ auth: "user" }, async (request, context) => {
    if (request.method !== "POST") return errorResponse(405, "Method not allowed.");

    const userId = context.userClaims?.id;
    if (!userId) return errorResponse(401, "Authentication required.");

    let body: ProgressBody;
    try {
      const value: unknown = await request.json();
      if (typeof value !== "object" || value === null || Array.isArray(value)) {
        return errorResponse(400, "Invalid request body.");
      }
      body = value as ProgressBody;
    } catch {
      return errorResponse(400, "Invalid JSON body.");
    }

    const bookingId = typeof body.booking_id === "string" ? body.booking_id.trim() : "";
    const nextStatus = typeof body.status === "string" ? body.status : "";
    const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

    if (!uuidPattern.test(bookingId)) return errorResponse(400, "Invalid booking ID.");

    const { data: actor, error: actorError } = await context.supabase
      .from("user_roles")
      .select("role")
      .eq("user_id", userId)
      .maybeSingle();

    if (actorError || !actor || actor.role !== "provider") {
      return errorResponse(403, "Only an approved provider can update assigned work.");
    }

    const expectedStatus = nextStatus === "in_progress"
      ? "assigned"
      : nextStatus === "completed"
        ? "in_progress"
        : null;

    if (!expectedStatus) return errorResponse(400, "Unsupported progress transition.");

    const { data: updated, error: updateError } = await context.supabaseAdmin
      .from("bookings")
      .update({
        status: nextStatus,
        updated_at: new Date().toISOString(),
      })
      .eq("id", bookingId)
      .eq("provider_id", userId)
      .eq("status", expectedStatus)
      .select("id, booking_reference, status")
      .maybeSingle();

    if (updateError) return errorResponse(500, "Could not update booking progress.");
    if (!updated) return errorResponse(409, "This booking is not assigned to you or has changed already.");

    return Response.json({
      booking_id: updated.id,
      booking_reference: updated.booking_reference,
      status: updated.status,
    });
  }),
};
