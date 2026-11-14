import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_config.dart';
import 'provider_availability_model.dart';

class ProviderAvailabilityRepository {
  SupabaseClient get _client {
    final client = divineSupabaseClient;
    if (client == null) throw StateError('Supabase is not configured.');
    return client;
  }

  Stream<List<ProviderAvailabilityModel>> watchMyAvailability() {
    final user = _client.auth.currentUser;
    if (user == null) return Stream.value(const []);
    return _client
        .from('provider_availability')
        .stream(primaryKey: ['user_id', 'weekday'])
        .eq('user_id', user.id)
        .order('weekday')
        .map((rows) => rows.map(ProviderAvailabilityModel.fromMap).toList(growable: false));
  }

  Future<void> saveDay({
    required int weekday,
    required String startTime,
    required String endTime,
    required bool isAvailable,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Sign in to manage availability.');
    await _client.from('provider_availability').upsert({
      'user_id': user.id,
      'weekday': weekday,
      'start_time': startTime,
      'end_time': endTime,
      'is_available': isAvailable,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id,weekday');
  }
}
