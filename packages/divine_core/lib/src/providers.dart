import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';
import 'banner_model.dart';
import 'banner_repository.dart';

final bannerRepositoryProvider = Provider<BannerRepository>(
  (ref) => BannerRepository(),
);

final activeBannersProvider = StreamProvider<List<BannerModel>>(
  (ref) => ref.watch(bannerRepositoryProvider).watchActiveBanners(),
);

final adminBannersProvider = StreamProvider<List<BannerModel>>(
  (ref) => ref.watch(bannerRepositoryProvider).watchAllBanners(),
);

final divineAuthServiceProvider = Provider<DivineAuthService>(
  (ref) => DivineAuthService(),
);
