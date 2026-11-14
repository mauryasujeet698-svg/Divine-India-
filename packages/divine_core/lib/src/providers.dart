import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';
import 'banner_model.dart';
import 'banner_repository.dart';
import 'booking_model.dart';
import 'booking_repository.dart';
import 'provider_availability_model.dart';
import 'provider_availability_repository.dart';
import 'service_model.dart';
import 'service_repository.dart';

final bannerRepositoryProvider = Provider<BannerRepository>(
  (ref) => BannerRepository(),
);

final activeBannersProvider = StreamProvider<List<BannerModel>>(
  (ref) => ref.watch(bannerRepositoryProvider).watchActiveBanners(),
);

final adminBannersProvider = StreamProvider<List<BannerModel>>(
  (ref) => ref.watch(bannerRepositoryProvider).watchAllBanners(),
);

final serviceRepositoryProvider = Provider<ServiceRepository>(
  (ref) => ServiceRepository(),
);

final publishedServicesProvider = StreamProvider<List<ServiceModel>>(
  (ref) => ref.watch(serviceRepositoryProvider).watchPublishedServices(),
);

final adminServicesProvider = StreamProvider<List<ServiceModel>>(
  (ref) => ref.watch(serviceRepositoryProvider).watchAllServices(),
);

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => BookingRepository(),
);

final authStateChangesProvider = StreamProvider<bool>((ref) {
  final client = divineSupabaseClient;
  if (client == null) return Stream<bool>.value(false);
  return client.auth.onAuthStateChange.map(
    (authState) => authState.session != null,
  );
});

final customerBookingsProvider = StreamProvider<List<BookingModel>>((ref) {
  ref.watch(authStateChangesProvider);
  return ref.watch(bookingRepositoryProvider).watchMyBookings();
});

final assignedBookingsProvider = StreamProvider<List<BookingModel>>((ref) {
  ref.watch(authStateChangesProvider);
  return ref.watch(bookingRepositoryProvider).watchAssignedBookings();
});

final adminBookingsProvider = StreamProvider<List<BookingModel>>(
  (ref) => ref.watch(bookingRepositoryProvider).watchAllBookings(),
);

final providerAvailabilityRepositoryProvider =
    Provider<ProviderAvailabilityRepository>(
  (ref) => ProviderAvailabilityRepository(),
);

final myAvailabilityProvider =
    StreamProvider<List<ProviderAvailabilityModel>>(
  (ref) => ref.watch(providerAvailabilityRepositoryProvider).watchMyAvailability(),
);

final divineAuthServiceProvider = Provider<DivineAuthService>(
  (ref) => DivineAuthService(),
);
