import 'package:supabase_flutter/supabase_flutter.dart';

class DivineAppConfig {
  const DivineAppConfig._();

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL');
  static const String supabasePublishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  static const String bannerBucket = 'divine-banners';

  static bool get hasSupabaseCredentials =>
      supabaseUrl.startsWith('https://') &&
      supabasePublishableKey.isNotEmpty &&
      !supabasePublishableKey.contains('YOUR_');
}

bool _supabaseInitialized = false;

bool get isSupabaseInitialized => _supabaseInitialized;

Future<void> initializeDivineBackend() async {
  if (!DivineAppConfig.hasSupabaseCredentials) {
    _supabaseInitialized = false;
    return;
  }

  await Supabase.initialize(
    url: DivineAppConfig.supabaseUrl,
    publishableKey: DivineAppConfig.supabasePublishableKey,
  );
  _supabaseInitialized = true;
}

SupabaseClient? get divineSupabaseClient =>
    _supabaseInitialized ? Supabase.instance.client : null;
