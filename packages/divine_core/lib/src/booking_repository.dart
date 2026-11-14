import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_config.dart';
import 'booking_model.dart';

class BookingRepository {
  SupabaseClient get _client {
    final client = divineSupabaseClient;
    if (client == null) throw StateError('Supabase is not configured.');
    return client;
  }

  Stream<List<BookingModel>> watchMyBookings() {
    final user = _client.auth.currentUser;
    if (user == null) return Stream.value(const []);
    return _client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(BookingModel.fromMap).toList(growable: false));
  }

  Stream<List<BookingModel>> watchAssignedBookings() {
    final user = _client.auth.currentUser;
    if (user == null) return Stream.value(const []);
    return _client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('provider_id', user.id)
        .order('booking_date')
        .map((rows) => rows.map(BookingModel.fromMap).toList(growable: false));
  }

  Future<String> requestBooking({
    required String serviceId,
    required DateTime bookingDate,
    required int partySize,
    required String customerNote,
  }) async {
    if (partySize < 1 || partySize > 20) {
      throw ArgumentError.value(partySize, 'partySize', 'Choose between 1 and 20 guests.');
    }
    final response = await _client.functions.invoke(
      'create-booking',
      body: {
        'service_id': serviceId,
        'booking_date': bookingDate.toUtc().toIso8601String(),
        'party_size': partySize,
        'customer_note': customerNote.trim(),
      },
    );
    final data = response.data;
    if (response.status < 200 || response.status >= 300 || data is! Map) {
      throw StateError('The booking request could not be submitted.');
    }
    final reference = data['booking_reference']?.toString();
    if (reference == null || reference.isEmpty) {
      throw StateError('The booking service returned an invalid response.');
    }
    return reference;
  }

  Future<void> updateStatus(String id, String status) async {
    const allowed = {'confirmed', 'assigned', 'in_progress', 'completed', 'cancelled'};
    if (!allowed.contains(status)) {
      throw ArgumentError.value(status, 'status', 'Unsupported booking status.');
    }
    await _client.from('bookings').update({
      'status': status,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
  }

  Stream<List<BookingModel>> watchAllBookings() {
    return _client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows.map(BookingModel.fromMap).toList(growable: false));
  }
}
