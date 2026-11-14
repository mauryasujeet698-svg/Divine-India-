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

  Stream<List<BookingModel>> watchAllBookings() {
    return _client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows.map(BookingModel.fromMap).toList(growable: false));
  }
}
