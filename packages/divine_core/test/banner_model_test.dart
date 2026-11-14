import 'package:divine_core/divine_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BannerModel', () {
    test('parses content and schedule fields', () {
      final banner = BannerModel.fromMap({
        'id': 'banner-1',
        'title': 'Sacred journeys',
        'subtitle': 'Discover Bharat',
        'image_url': 'https://example.test/banner.webp',
        'cta_label': 'Explore',
        'cta_route': '/explore',
        'sort_order': 3,
        'is_active': true,
        'starts_at': '2026-11-01T00:00:00Z',
        'ends_at': '2026-12-01T00:00:00Z',
      });

      expect(banner.id, 'banner-1');
      expect(banner.title, 'Sacred journeys');
      expect(banner.sortOrder, 3);
      expect(banner.isActive, isTrue);
      expect(banner.startsAt, isNotNull);
      expect(banner.endsAt, isNotNull);
    });

    test('demo banners are available for offline preview', () {
      expect(BannerModel.demoBanners, isNotEmpty);
      expect(BannerModel.demoBanners.every((banner) => banner.isActive), isTrue);
    });

    test('future scheduled banner is not visible yet', () {
      final banner = BannerModel(
        id: 'future',
        title: 'Future',
        subtitle: '',
        imageUrl: '',
        ctaLabel: 'Explore',
        ctaRoute: '/explore',
        sortOrder: 0,
        isActive: true,
        startsAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
      );

      expect(banner.isVisibleNow, isFalse);
    });
  });

  test('ServiceModel parses listing and category fields', () {
    final service = ServiceModel.fromMap({
      'id': 'service-1',
      'title': 'Kashi heritage walk',
      'slug': 'kashi-heritage-walk',
      'category_slug': 'local-experiences',
      'short_description': 'Walk the old city',
      'location_name': 'Varanasi',
      'price_from': 500,
      'currency': 'INR',
      'is_published': true,
    });

    expect(service.title, 'Kashi heritage walk');
    expect(service.categorySlug, 'local-experiences');
    expect(service.priceFrom, 500);
    expect(service.isPublished, isTrue);
  });

  test('BookingModel parses pending requests', () {
    final booking = BookingModel.fromMap({
      'id': 'booking-1',
      'booking_reference': 'DI-ABC12345',
      'user_id': 'user-1',
      'service_id': 'service-1',
      'provider_id': null,
      'booking_date': '2026-12-01T09:00:00Z',
      'party_size': 2,
      'status': 'pending',
      'total_amount': 0,
      'currency': 'INR',
      'customer_note': 'Near the main entrance',
    });

    expect(booking.reference, 'DI-ABC12345');
    expect(booking.partySize, 2);
    expect(booking.status, 'pending');
    expect(booking.totalAmount, 0);
  });
}
