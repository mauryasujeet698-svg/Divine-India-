class ProviderAvailabilityModel {
  const ProviderAvailabilityModel({
    required this.weekday,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  final int weekday;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  factory ProviderAvailabilityModel.fromMap(Map<String, dynamic> map) =>
      ProviderAvailabilityModel(
        weekday: (map['weekday'] as num).toInt(),
        startTime: map['start_time']?.toString() ?? '09:00:00',
        endTime: map['end_time']?.toString() ?? '17:00:00',
        isAvailable: map['is_available'] as bool? ?? false,
      );
}
