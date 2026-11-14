import 'dart:typed_data';

import 'package:divine_core/divine_core.dart';
import 'package:divine_design_system/divine_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'admin_management_pages.dart';

class AdminSignInPage extends StatefulWidget {
  const AdminSignInPage({
    super.key,
    required this.backendConfigured,
    required this.onSignedIn,
  });

  final bool backendConfigured;
  final Future<void> Function() onSignedIn;

  @override
  State<AdminSignInPage> createState() => _AdminSignInPageState();
}

class _AdminSignInPageState extends State<AdminSignInPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!widget.backendConfigured || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await DivineAuthService().signInWithPassword(
        email: _email.text,
        password: _password.text,
      );
      await widget.onSignedIn();
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = 'Sign-in failed. Check the credentials and try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: DivineBrandMark()),
                const SizedBox(height: 35),
                const Text(
                  'Administrator sign in',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: DivineColors.maroon,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'A secure workspace for the Divine India platform.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: DivineColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Admin email',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                  onSubmitted: (_) => _signIn(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: widget.backendConfigured && !_busy ? _signIn : null,
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Sign in securely'),
                ),
                if (!widget.backendConfigured) ...[
                  const SizedBox(height: 15),
                  const _ConfigurationNotice(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfigurationNotice extends StatelessWidget {
  const _ConfigurationNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: DivineColors.sand,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Supabase is not configured yet. Add SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY at launch, then assign the admin role to an authorized Auth user.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: DivineColors.maroon,
          fontSize: 12,
          height: 1.4,
        ),
      ),
    );
  }
}

class AdminAccessDeniedPage extends StatelessWidget {
  const AdminAccessDeniedPage({
    super.key,
    required this.message,
    required this.onSignOut,
  });

  final String message;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.admin_panel_settings_outlined,
                    color: DivineColors.maroon, size: 48),
                const SizedBox(height: 15),
                const Text(
                  'Access restricted',
                  style: TextStyle(
                    color: DivineColors.maroon,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 18),
                OutlinedButton(
                  onPressed: onSignOut,
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      AdminDashboardPage(onManageBanners: () => setState(() => _index = 1)),
      const BannerManagementPage(),
      const AdminBookingsPage(),
      const AdminServicesPage(),
      const AdminSectionPage(
        title: 'Platform settings',
        subtitle: 'Keep the platform identity and operating policies current.',
        icon: Icons.settings_outlined,
        items: ['General settings', 'Support details', 'Roles and access', 'Audit history'],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const DivineBrandMark(),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async => DivineAuthService().signOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.photo_library_outlined), selectedIcon: Icon(Icons.photo_library_rounded), label: 'Banners'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note_rounded), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront_rounded), label: 'Services'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key, required this.onManageBanners});

  final VoidCallback onManageBanners;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Platform overview',
          style: TextStyle(
            color: DivineColors.maroon,
            fontWeight: FontWeight.w900,
            fontSize: 25,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Your central command centre for Divine India.',
          style: TextStyle(color: DivineColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 20),
        const Wrap(
          spacing: 11,
          runSpacing: 11,
          children: [
            SizedBox(width: 160, child: DivineMetricCard(label: 'Bookings today', value: '—', icon: Icons.event_available_rounded, footnote: 'Live data after schema setup')),
            SizedBox(width: 160, child: DivineMetricCard(label: 'Active providers', value: '—', icon: Icons.groups_rounded, footnote: 'Live data after schema setup')),
            SizedBox(width: 160, child: DivineMetricCard(label: 'Gross revenue', value: '—', icon: Icons.currency_rupee_rounded, footnote: 'Live data after schema setup')),
            SizedBox(width: 160, child: DivineMetricCard(label: 'Published banners', value: '—', icon: Icons.photo_library_rounded, footnote: 'Managed below')),
          ],
        ),
        const SizedBox(height: 23),
        const DivineSectionHeading(title: 'Quick management'),
        const SizedBox(height: 12),
        _AdminActionCard(
          icon: Icons.photo_library_rounded,
          title: 'Homepage banners',
          subtitle: 'Upload, edit, schedule and reorder customer-facing campaigns.',
          onTap: onManageBanners,
        ),
        const _AdminActionCard(
          icon: Icons.confirmation_number_outlined,
          title: 'Booking operations',
          subtitle: 'Review reservations and keep service fulfilment on track.',
        ),
        const _AdminActionCard(
          icon: Icons.storefront_outlined,
          title: 'Services and providers',
          subtitle: 'Manage published experiences and provider approvals.',
        ),
        const SizedBox(height: 14),
        const Text(
          'Live metrics will populate after the Supabase project is configured and production data is available.',
          style: TextStyle(color: DivineColors.muted, fontSize: 11, height: 1.4),
        ),
      ],
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  const _AdminActionCard({
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: DivineColors.surface,
        border: Border.all(color: DivineColors.border),
        borderRadius: BorderRadius.circular(19),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: DivineColors.sand,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: DivineColors.maroon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: DivineColors.muted)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ),
    );
  }
}

class BannerManagementPage extends ConsumerWidget {
  const BannerManagementPage({super.key});

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    BannerModel? initial,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => BannerEditorDialog(
        initial: initial,
        repository: ref.read(bannerRepositoryProvider),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banners = ref.watch(adminBannersProvider);
    final repository = ref.read(bannerRepositoryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        backgroundColor: DivineColors.saffron,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Add banner'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 90),
        children: [
          const Text(
            'Homepage banners',
            style: TextStyle(color: DivineColors.maroon, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          const Text(
            'Changes are delivered to the customer homepage through Supabase Realtime—no app update required.',
            style: TextStyle(color: DivineColors.muted, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: DivineColors.sand,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: DivineColors.maroon),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Recommended: landscape images, concise headings and a single call to action. Maximum upload size: 5 MB.',
                    style: TextStyle(color: DivineColors.maroon, fontSize: 11, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          banners.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(35),
              child: Center(child: CircularProgressIndicator(color: DivineColors.saffron)),
            ),
            error: (error, stack) => const DivineEmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Could not load banners',
              message: 'Check the Supabase connection, migration and administrator permissions.',
            ),
            data: (items) {
              if (items.isEmpty) {
                return const DivineEmptyState(
                  icon: Icons.photo_library_outlined,
                  title: 'No banners yet',
                  message: 'Add a banner to publish it on the customer homepage.',
                );
              }
              return Column(
                children: items.map((banner) {
                  return _BannerAdminCard(
                    banner: banner,
                    onEdit: () => _openEditor(context, ref, initial: banner),
                    onToggle: () async {
                      try {
                        await repository.setBannerActive(banner.id, !banner.isActive);
                      } catch (_) {
                        _showMessage(context, 'Could not update banner status.');
                      }
                    },
                    onMoveUp: () async {
                      try {
                        await repository.setSortOrder(banner.id, banner.sortOrder - 1);
                      } catch (_) {
                        _showMessage(context, 'Could not reorder banner.');
                      }
                    },
                    onMoveDown: () async {
                      try {
                        await repository.setSortOrder(banner.id, banner.sortOrder + 1);
                      } catch (_) {
                        _showMessage(context, 'Could not reorder banner.');
                      }
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _BannerAdminCard extends StatelessWidget {
  const _BannerAdminCard({
    required this.banner,
    required this.onEdit,
    required this.onToggle,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final BannerModel banner;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: DivineColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DivineColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 130,
            width: double.infinity,
            child: banner.imageUrl.isEmpty
                ? const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [DivineColors.maroon, DivineColors.saffron],
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.temple_hindu_rounded, color: Colors.white, size: 42),
                    ),
                  )
                : Image.network(
                    banner.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => const ColoredBox(
                      color: DivineColors.sand,
                      child: Center(child: Icon(Icons.broken_image_outlined)),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        banner.title,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                    ),
                    DivineStatusPill(
                      label: banner.isActive ? 'ACTIVE' : 'INACTIVE',
                      color: banner.isActive ? DivineColors.success : DivineColors.muted,
                    ),
                  ],
                ),
                if (banner.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(banner.subtitle, style: const TextStyle(color: DivineColors.muted, fontSize: 11)),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Order ${banner.sortOrder}', style: const TextStyle(color: DivineColors.muted, fontSize: 10)),
                    const Spacer(),
                    IconButton(tooltip: 'Move earlier', onPressed: onMoveUp, icon: const Icon(Icons.arrow_upward_rounded, size: 18)),
                    IconButton(tooltip: 'Move later', onPressed: onMoveDown, icon: const Icon(Icons.arrow_downward_rounded, size: 18)),
                    IconButton(tooltip: 'Edit', onPressed: onEdit, icon: const Icon(Icons.edit_outlined, size: 18)),
                    IconButton(
                      tooltip: banner.isActive ? 'Deactivate' : 'Activate',
                      onPressed: onToggle,
                      icon: Icon(banner.isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BannerEditorDialog extends StatefulWidget {
  const BannerEditorDialog({
    super.key,
    required this.repository,
    this.initial,
  });

  final BannerRepository repository;
  final BannerModel? initial;

  @override
  State<BannerEditorDialog> createState() => _BannerEditorDialogState();
}

class _BannerEditorDialogState extends State<BannerEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _subtitle;
  late final TextEditingController _ctaLabel;
  late final TextEditingController _ctaRoute;
  late final TextEditingController _sortOrder;
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  bool _active = true;
  DateTime? _startsAt;
  DateTime? _endsAt;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final banner = widget.initial;
    _title = TextEditingController(text: banner?.title ?? '');
    _subtitle = TextEditingController(text: banner?.subtitle ?? '');
    _ctaLabel = TextEditingController(text: banner?.ctaLabel ?? 'Explore');
    _ctaRoute = TextEditingController(text: banner?.ctaRoute ?? '/explore');
    _sortOrder = TextEditingController(text: (banner?.sortOrder ?? 0).toString());
    _active = banner?.isActive ?? true;
    _startsAt = banner?.startsAt?.toLocal();
    _endsAt = banner?.endsAt?.toLocal();
  }

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    _ctaLabel.dispose();
    _ctaRoute.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 86,
    );
    if (image != null && mounted) setState(() => _pickedImage = image);
  }

  Future<void> _chooseSchedule(bool isStart) async {
    final current = isStart ? _startsAt : _endsAt;
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: current == null
          ? TimeOfDay.fromDateTime(now)
          : TimeOfDay.fromDateTime(current),
    );
    if (time == null || !mounted) return;
    final scheduled = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) {
        _startsAt = scheduled;
      } else {
        _endsAt = scheduled;
      }
    });
  }

  String _scheduleLabel(DateTime? value) {
    if (value == null) return 'Not scheduled';
    final date = MaterialLocalizations.of(context).formatMediumDate(value);
    final time = TimeOfDay.fromDateTime(value).format(context);
    return '$date • $time';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    if (_startsAt != null && _endsAt != null && !_endsAt!.isAfter(_startsAt!)) {
      setState(() => _error = 'The end time must be later than the start time.');
      return;
    }
    if ((_startsAt == null) != (_endsAt == null)) {
      setState(() => _error = 'Set both schedule start and end, or leave both empty.');
      return;
    }
    if (_pickedImage == null && (widget.initial?.imageUrl.isEmpty ?? true)) {
      setState(() => _error = 'Choose a banner image before publishing.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      var imageUrl = widget.initial?.imageUrl ?? '';
      if (_pickedImage != null) {
        final bytes = await _pickedImage!.readAsBytes();
        if (bytes.lengthInBytes > 5 * 1024 * 1024) {
          throw StateError('Image is larger than 5 MB. Choose a smaller image.');
        }
        imageUrl = await widget.repository.uploadBannerImage(
          bytes: bytes,
          fileName: _pickedImage!.name,
          contentType: _pickedImage!.mimeType ?? 'image/jpeg',
        );
      }

      await widget.repository.saveBanner(
        id: widget.initial?.id,
        title: _title.text,
        subtitle: _subtitle.text,
        imageUrl: imageUrl,
        ctaLabel: _ctaLabel.text,
        ctaRoute: _ctaRoute.text,
        sortOrder: int.tryParse(_sortOrder.text) ?? 0,
        isActive: _active,
        startsAt: _startsAt,
        endsAt: _endsAt,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DivineColors.surface,
      title: Text(widget.initial == null ? 'Create banner' : 'Edit banner'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_pickedImage != null)
                  FutureBuilder<Uint8List>(
                    future: _pickedImage!.readAsBytes(),
                    builder: (context, snapshot) => snapshot.hasData
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.memory(snapshot.data!, height: 120, width: double.infinity, fit: BoxFit.cover),
                          )
                        : const SizedBox(height: 90, child: Center(child: CircularProgressIndicator())),
                  )
                else if (widget.initial?.imageUrl.isNotEmpty ?? false)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      widget.initial!.imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => const SizedBox(height: 90, child: Icon(Icons.image_not_supported_outlined)),
                    ),
                  )
                else
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(color: DivineColors.sand, borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.add_photo_alternate_outlined, color: DivineColors.maroon, size: 30),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(_pickedImage == null ? 'Choose banner image' : 'Change selected image'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Headline'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Add a headline.' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _subtitle,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Supporting text'),
                ),
                const SizedBox(height: 10),
                TextFormField(controller: _ctaLabel, decoration: const InputDecoration(labelText: 'Button label')),
                const SizedBox(height: 10),
                TextFormField(controller: _ctaRoute, decoration: const InputDecoration(labelText: 'App route (example: /explore)')),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _sortOrder,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Display order'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Publish from'),
                  subtitle: Text(_scheduleLabel(_startsAt)),
                  trailing: IconButton(
                    onPressed: _saving ? null : () => _chooseSchedule(true),
                    icon: const Icon(Icons.calendar_month_rounded),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Unpublish at'),
                  subtitle: Text(_scheduleLabel(_endsAt)),
                  trailing: IconButton(
                    onPressed: _saving ? null : () => _chooseSchedule(false),
                    icon: const Icon(Icons.event_busy_rounded),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _active,
                  activeColor: DivineColors.saffron,
                  onChanged: _saving ? null : (value) => setState(() => _active = value),
                  title: const Text('Publish this banner'),
                ),
                if (_error != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Save banner'),
        ),
      ],
    );
  }
}

class AdminSectionPage extends StatelessWidget {
  const AdminSectionPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.items,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(title, style: const TextStyle(color: DivineColors.maroon, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: DivineColors.muted, fontSize: 12)),
        const SizedBox(height: 18),
        ...items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: DivineColors.surface,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: DivineColors.border),
              ),
              child: ListTile(
                leading: Icon(icon, color: DivineColors.maroon),
                title: Text(item, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showMessage(context, 'This section is prepared for the next integration stage.'),
              ),
            )),
      ],
    );
  }
}
