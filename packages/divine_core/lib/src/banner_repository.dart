import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_config.dart';
import 'banner_model.dart';

class BannerRepository {
  SupabaseClient get _client {
    final client = divineSupabaseClient;
    if (client == null) {
      throw StateError('Supabase is not configured for this app.');
    }
    return client;
  }

  Stream<List<BannerModel>> watchActiveBanners() {
    if (!isSupabaseInitialized) {
      return Stream<List<BannerModel>>.value(BannerModel.demoBanners);
    }

    return _client
        .from('banners')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('sort_order')
        .map((rows) => rows
            .map(BannerModel.fromMap)
            .where((banner) => banner.isVisibleNow)
            .toList(growable: false));
  }

  Stream<List<BannerModel>> watchAllBanners() {
    if (!isSupabaseInitialized) {
      return Stream<List<BannerModel>>.value(BannerModel.demoBanners);
    }

    return _client
        .from('banners')
        .stream(primaryKey: ['id'])
        .order('sort_order')
        .map((rows) => rows.map(BannerModel.fromMap).toList(growable: false));
  }

  Future<String> uploadBannerImage({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    final safeName = fileName
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '-')
        .replaceAll(RegExp(r'-+'), '-');
    final path =
        'banners/${DateTime.now().toUtc().microsecondsSinceEpoch}_$safeName';

    await _client.storage.from(DivineAppConfig.bannerBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType.isEmpty ? 'image/jpeg' : contentType,
            upsert: false,
          ),
        );

    return _client.storage
        .from(DivineAppConfig.bannerBucket)
        .getPublicUrl(path);
  }

  Future<void> saveBanner({
    String? id,
    required String title,
    required String subtitle,
    required String imageUrl,
    required String ctaLabel,
    required String ctaRoute,
    required int sortOrder,
    required bool isActive,
  }) async {
    final values = {
      'title': title.trim(),
      'subtitle': subtitle.trim(),
      'image_url': imageUrl,
      'cta_label': ctaLabel.trim().isEmpty ? 'Explore' : ctaLabel.trim(),
      'cta_route': ctaRoute.trim().isEmpty ? '/explore' : ctaRoute.trim(),
      'sort_order': sortOrder,
      'is_active': isActive,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    if (id == null) {
      await _client.from('banners').insert(values);
    } else {
      await _client.from('banners').update(values).eq('id', id);
    }
  }

  Future<void> setBannerActive(String id, bool isActive) async {
    await _client.from('banners').update({
      'is_active': isActive,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> setSortOrder(String id, int sortOrder) async {
    await _client.from('banners').update({
      'sort_order': sortOrder,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
  }
}
