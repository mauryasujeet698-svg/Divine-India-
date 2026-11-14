import 'package:divine_core/divine_core.dart';
import 'package:divine_design_system/divine_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        Text(
          'Namaste 🙏',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: DivineColors.maroon,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Where would your spirit like to travel?',
          style: TextStyle(color: DivineColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 18),
        const _BannerCarousel(),
        const SizedBox(height: 25),
        const DivineSectionHeading(
          title: 'Explore by experience',
          subtitle: 'Meaningful ways to discover the sacred',
        ),
        const SizedBox(height: 13),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 11,
          crossAxisSpacing: 11,
          childAspectRatio: 1.28,
          children: [
            DivineFeatureCard(
              icon: Icons.temple_hindu_rounded,
              title: 'Puja & rituals',
              subtitle: 'Devotional services',
              onTap: () => context.go('/explore'),
            ),
            DivineFeatureCard(
              icon: Icons.account_balance_rounded,
              title: 'Pilgrimage',
              subtitle: 'Sacred journeys',
              accent: DivineColors.maroon,
              onTap: () => context.go('/explore'),
            ),
            DivineFeatureCard(
              icon: Icons.hotel_rounded,
              title: 'Spiritual stays',
              subtitle: 'Rest near the divine',
              accent: DivineColors.templeGold,
              onTap: () => context.go('/explore'),
            ),
            DivineFeatureCard(
              icon: Icons.directions_car_rounded,
              title: 'Local experiences',
              subtitle: 'Explore with ease',
              accent: DivineColors.success,
              onTap: () => context.go('/explore'),
            ),
          ],
        ),
        const SizedBox(height: 25),
        const DivineSectionHeading(
          title: 'Sacred destinations',
          subtitle: 'Places where faith meets heritage',
          actionLabel: 'View all',
        ),
        const SizedBox(height: 13),
        const _DestinationStrip(),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [DivineColors.maroon, DivineColors.maroonDark],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Row(
            children: [
              Icon(Icons.auto_awesome, color: DivineColors.templeGold, size: 30),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Travel with reverence',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Thoughtful journeys, clear information and trusted local experiences.',
                      style: TextStyle(
                        color: Color(0xFFF1DCCB),
                        height: 1.35,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BannerCarousel extends ConsumerWidget {
  const _BannerCarousel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banners = ref.watch(activeBannersProvider);
    return banners.when(
      loading: () => const _BannerLoading(),
      error: (error, stack) => const _BannerFallback(),
      data: (items) {
        if (items.isEmpty) return const _NoPublishedBanner();
        return _BannerPager(banners: items);
      },
    );
  }
}

class _BannerPager extends StatefulWidget {
  const _BannerPager({required this.banners});

  final List<BannerModel> banners;

  @override
  State<_BannerPager> createState() => _BannerPagerState();
}

class _BannerPagerState extends State<_BannerPager> {
  final PageController _controller = PageController(viewportFraction: 1);
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 198,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) =>
                _BannerSlide(banner: widget.banners[index]),
          ),
        ),
        const SizedBox(height: 11),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.banners.length, (index) {
            final selected = index == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: selected ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: selected ? DivineColors.maroon : DivineColors.templeGold,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BannerSlide extends StatelessWidget {
  const _BannerSlide({required this.banner});

  final BannerModel banner;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DivineColors.maroon,
                  Color(0xFF8E3C2D),
                  DivineColors.saffron,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          if (banner.imageUrl.isNotEmpty)
            Image.network(
              banner.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  const SizedBox.shrink(),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xCC35121B), Color(0x1A35121B)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          Positioned(
            right: -16,
            top: -26,
            child: Icon(
              Icons.temple_hindu_rounded,
              size: 150,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DIVINE INDIA • JOURNEYS OF THE SOUL',
                  style: TextStyle(
                    color: Color(0xFFF4D89B),
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                  ),
                ),
                const Spacer(),
                Text(
                  banner.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  banner.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFFEADB),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 11),
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      const routes = {'/explore', '/bookings', '/profile'};
                      context.go(routes.contains(banner.ctaRoute) ? banner.ctaRoute : '/explore');
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: DivineColors.templeGold,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: Text(
                        banner.ctaLabel,
                        style: const TextStyle(
                          color: DivineColors.maroonDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerLoading extends StatelessWidget {
  const _BannerLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 198,
      decoration: BoxDecoration(
        color: DivineColors.sand,
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(color: DivineColors.saffron),
    );
  }
}

class _BannerFallback extends StatelessWidget {
  const _BannerFallback();

  @override
  Widget build(BuildContext context) => const _NoPublishedBanner();
}

class _NoPublishedBanner extends StatelessWidget {
  const _NoPublishedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 198,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DivineColors.maroon, DivineColors.saffron],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('ॐ', style: TextStyle(color: Colors.white70, fontSize: 28)),
          SizedBox(height: 4),
          Text(
            'Your next sacred journey begins here',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'New stories and experiences will appear here.',
            style: TextStyle(color: Color(0xFFFFEADB), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _DestinationStrip extends StatelessWidget {
  const _DestinationStrip();

  static const _items = [
    ('Varanasi', 'The eternal city', Icons.waves_rounded),
    ('Ayodhya', 'Land of devotion', Icons.temple_hindu_rounded),
    ('Ujjain', 'City of Mahakal', Icons.account_balance_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 142,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, index) => const SizedBox(width: 11),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Container(
            width: 154,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: index == 1 ? DivineColors.maroon : DivineColors.sand,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: DivineColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  item.$3,
                  color: index == 1 ? DivineColors.templeGold : DivineColors.saffronDark,
                  size: 25,
                ),
                const Spacer(),
                Text(
                  item.$1,
                  style: TextStyle(
                    color: index == 1 ? Colors.white : DivineColors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                Text(
                  item.$2,
                  style: TextStyle(
                    color: index == 1 ? Colors.white70 : DivineColors.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  final _search = TextEditingController();
  String _category = 'All';
  static const _categories = ['All', 'Puja & rituals', 'Pilgrimage', 'Spiritual stays', 'Local experiences'];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listings = ref.watch(publishedServicesProvider);
    final query = _search.text.trim().toLowerCase();
    const categoryBySlug = {
      'puja-rituals': 'Puja & rituals',
      'pilgrimage': 'Pilgrimage',
      'spiritual-stays': 'Spiritual stays',
      'local-experiences': 'Local experiences',
    };
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        const Text('Discover Bharat', style: TextStyle(color: DivineColors.maroon, fontSize: 25, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        const Text('Find experiences for your next meaningful journey.', style: TextStyle(color: DivineColors.muted, fontSize: 13)),
        const SizedBox(height: 17),
        TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Search destinations or experiences'),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final value = _categories[index];
              final selected = _category == value;
              return ChoiceChip(
                label: Text(value),
                selected: selected,
                onSelected: (_) => setState(() => _category = value),
                selectedColor: DivineColors.sand,
                side: const BorderSide(color: DivineColors.border),
                labelStyle: TextStyle(color: selected ? DivineColors.maroon : DivineColors.muted, fontSize: 11, fontWeight: FontWeight.w700),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        listings.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(28), child: CircularProgressIndicator(color: DivineColors.saffron))),
          error: (error, stack) => const DivineEmptyState(icon: Icons.cloud_off_rounded, title: 'Catalogue unavailable', message: 'Please check your connection and try again.'),
          data: (items) {
            final visible = items.where((item) {
              final category = categoryBySlug[item.categorySlug] ?? 'All';
              final categoryMatches = _category == 'All' || category == _category;
              final queryMatches = query.isEmpty || item.title.toLowerCase().contains(query) || item.shortDescription.toLowerCase().contains(query) || (item.locationName ?? '').toLowerCase().contains(query);
              return categoryMatches && queryMatches;
            }).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DivineSectionHeading(title: 'Published experiences', subtitle: '${visible.length} available listings'),
                const SizedBox(height: 12),
                if (visible.isEmpty)
                  const DivineEmptyState(icon: Icons.travel_explore_rounded, title: 'No experiences published yet', message: 'Pujas, pilgrimage journeys and local experiences will appear here when the Divine India team publishes them.')
                else
                  ...visible.map((item) => Container(
                        margin: const EdgeInsets.only(bottom: 11),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: DivineColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: DivineColors.border)),
                        child: Row(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(color: DivineColors.sand, borderRadius: BorderRadius.circular(16)),
                              clipBehavior: Clip.antiAlias,
                              child: item.imageUrl == null || item.imageUrl!.isEmpty
                                  ? const Icon(Icons.temple_hindu_rounded, color: DivineColors.maroon, size: 28)
                                  : Image.network(item.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, error, stack) => const Icon(Icons.temple_hindu_rounded, color: DivineColors.maroon)),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.title, style: const TextStyle(color: DivineColors.ink, fontWeight: FontWeight.w800, fontSize: 14)),
                                  if (item.locationName?.isNotEmpty ?? false) ...[
                                    const SizedBox(height: 3),
                                    Text(item.locationName!, style: const TextStyle(color: DivineColors.muted, fontSize: 11)),
                                  ],
                                  if (item.shortDescription.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(item.shortDescription, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: DivineColors.muted, fontSize: 11)),
                                  ],
                                  const SizedBox(height: 5),
                                  Text(item.priceFrom == null ? 'Price on request' : 'From ${item.currency} ${item.priceFrom!.toStringAsFixed(0)}', style: const TextStyle(color: DivineColors.saffronDark, fontSize: 10, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
              ],
            );
          },
        ),
      ],
    );
  }
}

class CustomerBookingsPage extends ConsumerWidget {
  const CustomerBookingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = divineSupabaseClient?.auth.currentUser;
    if (user == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
        children: [
          const Text('My bookings', style: TextStyle(color: DivineColors.maroon, fontSize: 25, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Keep your journeys and experiences in one place.', style: TextStyle(color: DivineColors.muted, fontSize: 13)),
          const SizedBox(height: 22),
          const DivineEmptyState(icon: Icons.confirmation_number_outlined, title: 'Your journeys will appear here', message: 'Sign in when you are ready to make a booking and track its status.'),
          const SizedBox(height: 14),
          FilledButton.icon(onPressed: () => context.push('/sign-in'), icon: const Icon(Icons.login_rounded), label: const Text('Sign in to view bookings')),
        ],
      );
    }
    final bookings = ref.watch(customerBookingsProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
      children: [
        const Text('My bookings', style: TextStyle(color: DivineColors.maroon, fontSize: 25, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        const Text('Track your pujas, trips and experiences.', style: TextStyle(color: DivineColors.muted, fontSize: 13)),
        const SizedBox(height: 18),
        bookings.when(
          loading: () => const Center(child: CircularProgressIndicator(color: DivineColors.saffron)),
          error: (error, stack) => const DivineEmptyState(icon: Icons.cloud_off_rounded, title: 'Bookings unavailable', message: 'Please check your connection and try again.'),
          data: (items) => items.isEmpty
              ? const DivineEmptyState(icon: Icons.temple_hindu_rounded, title: 'No bookings yet', message: 'Your confirmed pujas, trips and experiences will appear here.')
              : Column(
                  children: items.map((booking) => Container(
                        margin: const EdgeInsets.only(bottom: 11),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(color: DivineColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: DivineColors.border)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(booking.reference, style: const TextStyle(color: DivineColors.maroon, fontWeight: FontWeight.w900))),
                                DivineStatusPill(label: booking.status.toUpperCase()),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(booking.bookingDate?.toLocal().toString().split('.').first ?? 'Date to be confirmed', style: const TextStyle(color: DivineColors.muted, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text('${booking.currency} ${booking.totalAmount.toStringAsFixed(2)} • ${booking.partySize} guest(s)', style: const TextStyle(color: DivineColors.ink, fontWeight: FontWeight.w700, fontSize: 12)),
                          ],
                        ),
                      )).toList(),
                ),
        ),
      ],
    );
  }
}

class CustomerProfilePage extends StatelessWidget {
  const CustomerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = divineSupabaseClient?.auth.currentUser;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [DivineColors.maroon, DivineColors.saffronDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0x33FFFFFF),
                child: Icon(Icons.person_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.email ?? 'Welcome, traveller',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user == null ? 'Explore as a guest' : 'Divine India member',
                      style: const TextStyle(color: Color(0xFFFFEADB), fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.auto_awesome, color: DivineColors.templeGold),
            ],
          ),
        ),
        if (user == null) ...[
          FilledButton.icon(
            onPressed: () => context.push('/sign-in'),
            icon: const Icon(Icons.login_rounded),
            label: const Text('Sign in or create an account'),
          ),
          const SizedBox(height: 18),
        ],
        const SizedBox(height: 22),
        const DivineSectionHeading(title: 'Your account'),
        const SizedBox(height: 9),
        _ProfileItem(icon: Icons.person_outline, title: 'Personal details', subtitle: 'Name, email and preferences'),
        _ProfileItem(icon: Icons.confirmation_number_outlined, title: 'My bookings', subtitle: 'View your journeys and reservations', onTap: () => context.go('/bookings')),
        _ProfileItem(icon: Icons.favorite_border_rounded, title: 'Saved experiences', subtitle: 'Places you want to visit'),
        const SizedBox(height: 19),
        const DivineSectionHeading(title: 'Preferences & support'),
        const SizedBox(height: 9),
        const _ProfileItem(icon: Icons.language_rounded, title: 'Language', subtitle: 'English'),
        const _ProfileItem(icon: Icons.palette_outlined, title: 'Appearance', subtitle: 'Light theme'),
        const _ProfileItem(icon: Icons.help_outline_rounded, title: 'Help & support', subtitle: 'We are here to help'),
        const _ProfileItem(icon: Icons.policy_outlined, title: 'Terms & privacy', subtitle: 'Policies and legal information'),
        if (user != null) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              await DivineAuthService().signOut();
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign out'),
          ),
        ],
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap ?? () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: DivineColors.sand,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: DivineColors.maroon, size: 21),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: DivineColors.muted, fontSize: 11),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: DivineColors.muted),
    );
  }
}
