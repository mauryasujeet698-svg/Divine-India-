class BookingModel {
  const BookingModel({
    required this.id,
    required this.reference,
    required this.userId,
    required this.serviceId,
    required this.providerId,
    required this.bookingDate,
    required this.partySize,
    required this.status,
    required this.totalAmount,
    required this.currency,
    required this.customerNote,
  });

  final String id;
  final String reference;
  final String userId;
  final String? serviceId;
  final String? providerId;
  final DateTime? bookingDate;
  final int partySize;
  final String status;
  final num totalAmount;
  final String currency;
  final String customerNote;

  factory BookingModel.fromMap(Map<String, dynamic> map) => BookingModel(
        id: map['id']?.toString() ?? '',
        reference: map['booking_reference']?.toString() ?? '',
        userId: map['user_id']?.toString() ?? '',
        serviceId: map['service_id']?.toString(),
        providerId: map['provider_id']?.toString(),
        bookingDate: DateTime.tryParse(map['booking_date']?.toString() ?? ''),
        partySize: (map['party_size'] as num?)?.toInt() ?? 1,
        status: map['status']?.toString() ?? 'pending',
        totalAmount: map['total_amount'] as num? ?? 0,
        currency: map['currency']?.toString() ?? 'INR',
        customerNote: map['customer_note']?.toString() ?? '',
      );
}
