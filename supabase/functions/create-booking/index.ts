import { withSupabase } from "npm:@supabase/server@1.9.2";

type BookingRequestBody = {
  service_id?: unknown;
  booking_date?: unknown;
  party_size?: unknown;
  customer_note?: unknown;
};

function jsonError(status: number, message: string): Response {
  return Response.json({ error: message }, { status });
}

export default {
  fetch: withSupabase({ auth: "user" }, async (request, context) => {
    if (request.method !== "POST") {
      return jsonError(405, "Method not allowed.");
    }

    let body: BookingRequestBody;
    try {
      const parsed: unknown = await request.json();
      if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) {
        return jsonError(400, "Invalid request body.");
      }
      body = parsed as BookingRequestBody;
    } catch {
      return jsonError(400, "Invalid JSON body.");
    }

    const serviceId =
      typeof body.service_id === "string" ? body.service_id.trim() : "";
    const bookingDate =
      typeof body.booking_date === "string"
        ? new Date(body.booking_date)
        : null;
    const partySize = Number(body.party_size);
    const customerNote =
      typeof body.customer_note === "string" ? body.customer_note.trim() : "";

    if (
      !serviceId ||
      !bookingDate ||
      Number.isNaN(bookingDate.getTime()) ||
      bookingDate.getTime() <= Date.now()
    ) {
      return jsonError(400, "Choose a valid future date and experience.");
    }

    if (!Number.isInteger(partySize) || partySize < 1 || partySize > 20) {
      return jsonError(400, "Party size must be between 1 and 20.");
    }

    if (customerNote.length > 500) {
      return jsonError(400, "The note must be 500 characters or fewer.");
    }

    // This client carries the verified caller's JWT and respects RLS.
    const { data: service, error: serviceError } = await context.supabase
      .from("services")
      .select("id, is_published")
      .eq("id", serviceId)
      .maybeSingle();

    if (serviceError) {
      return jsonError(500, "Could not validate the selected experience.");
    }

    if (!service || service.is_published !== true) {
      return jsonError(404, "This experience is not currently available.");
    }

    // Use the admin client only for the server-validated insert. The user ID
    // always comes from the verified JWT, never from the submitted request.
    const bookingReference =
      `DI-${crypto.randomUUID().replaceAll("-", "").slice(0, 12).toUpperCase()}`;

    const { error: insertError } = await context.supabaseAdmin
      .from("bookings")
      .insert({
        booking_reference: bookingReference,
        user_id: context.userClaims.id,
        service_id: service.id,
        booking_date: bookingDate.toISOString(),
        party_size: partySize,
        status: "pending",
        total_amount: 0,
        currency: "INR",
        customer_note: customerNote,
      });

    if (insertError) {
      return jsonError(500, "Could not create your booking request.");
    }

    return Response.json(
      {
        booking_reference: bookingReference,
        status: "pending",
        message: "Your booking request has been submitted for confirmation.",
      },
      { status: 201 },
    );
  }),
};
