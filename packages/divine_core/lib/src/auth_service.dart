import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_config.dart';

class DivineAuthService {
  SupabaseClient get _client {
    final client = divineSupabaseClient;
    if (client == null) {
      throw StateError('Sign-in is unavailable until Supabase is configured.');
    }
    return client;
  }

  User? get currentUser => divineSupabaseClient?.auth.currentUser;

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<String?> currentRole() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final row = await _client
        .from('user_roles')
        .select('role')
        .eq('user_id', user.id)
        .maybeSingle();

    return row?['role']?.toString();
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
