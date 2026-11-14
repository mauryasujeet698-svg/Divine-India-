class BannerModel {
  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.ctaLabel,
    required this.ctaRoute,
    required this.sortOrder,
    required this.isActive,
    this.startsAt,
    this.endsAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String ctaLabel;
  final String ctaRoute;
  final int sortOrder;
  final bool isActive;
  final DateTime? startsAt;
  final DateTime? endsAt;

  bool get isVisibleNow {
    final now = DateTime.now().toUtc();
    return isActive &&
        (startsAt == null || !startsAt!.isAfter(now)) &&
        (endsAt == null || endsAt!.isAfter(now));
  }

  factory BannerModel.fromMap(Map<String, dynamic> map) {
    return BannerModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      subtitle: map['subtitle']?.toString() ?? '',
      imageUrl: map['image_url']?.toString() ?? '',
      ctaLabel: map['cta_label']?.toString() ?? 'Explore',
      ctaRoute: map['cta_route']?.toString() ?? '/explore',
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
      isActive: map['is_active'] as bool? ?? false,
      startsAt: DateTime.tryParse(map['starts_at']?.toString() ?? '')?.toUtc(),
      endsAt: DateTime.tryParse(map['ends_at']?.toString() ?? '')?.toUtc(),
    );
  }

  static List<BannerModel> get demoBanners => const [
        BannerModel(
          id: 'demo-kashi',
          title: 'Find your way to the sacred',
          subtitle: 'Discover timeless journeys across Bharat.',
          imageUrl: '',
          ctaLabel: 'Explore journeys',
          ctaRoute: '/explore',
          sortOrder: 0,
          isActive: true,
        ),
        BannerModel(
          id: 'demo-puja',
          title: 'Moments of devotion',
          subtitle: 'Plan meaningful rituals with care and clarity.',
          imageUrl: '',
          ctaLabel: 'Discover pujas',
          ctaRoute: '/explore',
          sortOrder: 1,
          isActive: true,
        ),
      ];
}
