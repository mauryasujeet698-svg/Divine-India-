class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.shortDescription,
    required this.categoryId,
    required this.categorySlug,
    required this.imageUrl,
    required this.locationName,
    required this.priceFrom,
    required this.currency,
    required this.isPublished,
  });

  final String id;
  final String title;
  final String slug;
  final String shortDescription;
  final String? categoryId;
  final String categorySlug;
  final String? imageUrl;
  final String? locationName;
  final num? priceFrom;
  final String currency;
  final bool isPublished;

  factory ServiceModel.fromMap(Map<String, dynamic> map) => ServiceModel(
        id: map['id']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        slug: map['slug']?.toString() ?? '',
        shortDescription: map['short_description']?.toString() ?? '',
        categoryId: map['category_id']?.toString(),
        categorySlug: map['category_slug']?.toString() ?? 'local-experiences',
        imageUrl: map['image_url']?.toString(),
        locationName: map['location_name']?.toString(),
        priceFrom: map['price_from'] as num?,
        currency: map['currency']?.toString() ?? 'INR',
        isPublished: map['is_published'] as bool? ?? false,
      );
}
