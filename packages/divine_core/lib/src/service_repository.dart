import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_config.dart';
import 'service_model.dart';

class ServiceRepository {
  SupabaseClient get _client {
    final client = divineSupabaseClient;
    if (client == null) throw StateError('Supabase is not configured.');
    return client;
  }

  Stream<List<ServiceModel>> watchPublishedServices() {
    if (!isSupabaseInitialized) return Stream.value(const []);
    return _client
        .from('services')
        .stream(primaryKey: ['id'])
        .eq('is_published', true)
        .order('title')
        .map((rows) => rows.map(ServiceModel.fromMap).toList(growable: false));
  }

  Stream<List<ServiceModel>> watchAllServices() {
    if (!isSupabaseInitialized) return Stream.value(const []);
    return _client
        .from('services')
        .stream(primaryKey: ['id'])
        .order('title')
        .map((rows) => rows.map(ServiceModel.fromMap).toList(growable: false));
  }

  Future<void> saveService({
    String? id,
    required String title,
    required String slug,
    required String categorySlug,
    required String shortDescription,
    String? locationName,
    String? imageUrl,
    num? priceFrom,
    required bool isPublished,
  }) async {
    final values = <String, dynamic>{
      'title': title.trim(),
      'slug': slug.trim().toLowerCase(),
      'category_slug': categorySlug,
      'short_description': shortDescription.trim(),
      'location_name': locationName?.trim(),
      'image_url': imageUrl,
      'price_from': priceFrom,
      'currency': 'INR',
      'is_published': isPublished,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (id == null) {
      await _client.from('services').insert(values);
    } else {
      await _client.from('services').update(values).eq('id', id);
    }
  }

  Future<void> setPublished(String id, bool published) async {
    await _client.from('services').update({
      'is_published': published,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
  }
}
