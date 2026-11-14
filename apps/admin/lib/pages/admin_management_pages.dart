import 'package:divine_core/divine_core.dart';
import 'package:divine_design_system/divine_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminBookingsPage extends ConsumerWidget {
  const AdminBookingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(adminBookingsProvider);
    final repository = ref.read(bookingRepositoryProvider);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('Bookings', style: TextStyle(color: DivineColors.maroon, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        const Text('Monitor customer reservations and update fulfilment status.', style: TextStyle(color: DivineColors.muted, fontSize: 12)),
        const SizedBox(height: 16),
        bookings.when(
          loading: () => const Center(child: CircularProgressIndicator(color: DivineColors.saffron)),
          error: (error, stack) => const DivineEmptyState(icon: Icons.cloud_off_rounded, title: 'Bookings unavailable', message: 'Check the Supabase migration and administrator permissions.'),
          data: (items) => items.isEmpty
              ? const DivineEmptyState(icon: Icons.event_busy_rounded, title: 'No bookings yet', message: 'Customer reservations will appear here when the booking workflow is enabled.')
              : Column(
                  children: items.map((booking) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                            const SizedBox(height: 7),
                            Text('Customer: ${booking.userId}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: DivineColors.muted, fontSize: 10)),
                            const SizedBox(height: 4),
                            Text(
                              booking.totalAmount <= 0 ? 'Quote/payment pending • ${booking.partySize} guest(s)' : '${booking.currency} ${booking.totalAmount.toStringAsFixed(2)} • ${booking.partySize} guest(s)',
                              style: const TextStyle(color: DivineColors.ink, fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                            if (booking.bookingDate != null) ...[
                              const SizedBox(height: 4),
                              Text(booking.bookingDate!.toLocal().toString().split('.').first, style: const TextStyle(color: DivineColors.muted, fontSize: 10)),
                            ],
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: booking.status,
                              decoration: const InputDecoration(labelText: 'Booking status', isDense: true),
                              items: const [
                                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                                DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                                DropdownMenuItem(value: 'assigned', child: Text('Assigned')),
                                DropdownMenuItem(value: 'in_progress', child: Text('In progress')),
                                DropdownMenuItem(value: 'completed', child: Text('Completed')),
                                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                                                              ],
                              onChanged: booking.status == 'refunded' ? null : (value) async {
                                if (value == null || value == booking.status || value == 'refunded') return;
                                try {
                                  await repository.updateStatus(booking.id, value);
                                } catch (_) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not update booking status.')));
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      )).toList(),
                ),
        ),
      ],
    );
  }
}

class AdminServicesPage extends ConsumerWidget {
  const AdminServicesPage({super.key});

  Future<void> _openEditor(BuildContext context, WidgetRef ref, {ServiceModel? service}) async {
    await showDialog<void>(
      context: context,
      builder: (context) => ServiceEditorDialog(
        repository: ref.read(serviceRepositoryProvider),
        service: service,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(adminServicesProvider);
    final repository = ref.read(serviceRepositoryProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        backgroundColor: DivineColors.saffron,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add service'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 90),
        children: [
          const Text('Services catalogue', style: TextStyle(color: DivineColors.maroon, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          const Text('Create and publish pujas, pilgrimage packages, stays and experiences.', style: TextStyle(color: DivineColors.muted, fontSize: 12)),
          const SizedBox(height: 16),
          services.when(
            loading: () => const Center(child: CircularProgressIndicator(color: DivineColors.saffron)),
            error: (error, stack) => const DivineEmptyState(icon: Icons.cloud_off_rounded, title: 'Catalogue unavailable', message: 'Check the Supabase migration and administrator permissions.'),
            data: (items) => items.isEmpty
                ? const DivineEmptyState(icon: Icons.storefront_outlined, title: 'No services added', message: 'Create your first listing to make it available for the customer app.')
                : Column(
                    children: items.map((service) => Container(
                          margin: const EdgeInsets.only(bottom: 11),
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(color: DivineColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: DivineColors.border)),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(color: DivineColors.sand, borderRadius: BorderRadius.circular(14)),
                                clipBehavior: Clip.antiAlias,
                                child: service.imageUrl == null || service.imageUrl!.isEmpty
                                    ? const Icon(Icons.temple_hindu_rounded, color: DivineColors.maroon)
                                    : Image.network(service.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, error, stack) => const Icon(Icons.temple_hindu_rounded)),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(service.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text(service.locationName ?? service.slug, style: const TextStyle(color: DivineColors.muted, fontSize: 10)),
                                    const SizedBox(height: 4),
                                    DivineStatusPill(label: service.isPublished ? 'PUBLISHED' : 'DRAFT', color: service.isPublished ? DivineColors.success : DivineColors.muted),
                                  ],
                                ),
                              ),
                              IconButton(tooltip: 'Edit service', onPressed: () => _openEditor(context, ref, service: service), icon: const Icon(Icons.edit_outlined)),
                              Switch(
                                value: service.isPublished,
                                activeColor: DivineColors.saffron,
                                onChanged: (value) async {
                                  try {
                                    await repository.setPublished(service.id, value);
                                  } catch (_) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not change publication status.')));
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        )).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class ServiceEditorDialog extends StatefulWidget {
  const ServiceEditorDialog({super.key, required this.repository, this.service});

  final ServiceRepository repository;
  final ServiceModel? service;

  @override
  State<ServiceEditorDialog> createState() => _ServiceEditorDialogState();
}

class _ServiceEditorDialogState extends State<ServiceEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _slug;
  String _categorySlug = 'local-experiences';
  late final TextEditingController _description;
  late final TextEditingController _location;
  late final TextEditingController _price;
  late final TextEditingController _imageUrl;
  late bool _published;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final item = widget.service;
    _title = TextEditingController(text: item?.title ?? '');
    _slug = TextEditingController(text: item?.slug ?? '');
    _categorySlug = item?.categorySlug ?? 'local-experiences';
    _description = TextEditingController(text: item?.shortDescription ?? '');
    _location = TextEditingController(text: item?.locationName ?? '');
    _price = TextEditingController(text: item?.priceFrom?.toString() ?? '');
    _imageUrl = TextEditingController(text: item?.imageUrl ?? '');
    _published = item?.isPublished ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _slug.dispose();
    _description.dispose();
    _location.dispose();
    _price.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() { _saving = true; _error = null; });
    try {
      await widget.repository.saveService(
        id: widget.service?.id,
        title: _title.text,
        slug: _slug.text,
        categorySlug: _categorySlug,
        shortDescription: _description.text,
        locationName: _location.text,
        imageUrl: _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
        priceFrom: _price.text.trim().isEmpty ? null : num.parse(_price.text.trim()),
        isPublished: _published,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not save. Check unique slug and administrator access.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DivineColors.surface,
      title: Text(widget.service == null ? 'Add service' : 'Edit service'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Service name'), validator: (v) => v == null || v.trim().isEmpty ? 'Enter a service name.' : null),
                const SizedBox(height: 9),
                TextFormField(
                  controller: _slug,
                  decoration: const InputDecoration(
                    labelText: 'Unique service slug (e.g. kashi-puja)',
                  ),
                  validator: (value) => value == null ||
                          !RegExp(r'^[a-z0-9-]+$').hasMatch(value.trim())
                      ? 'Use lowercase letters, numbers and hyphens.'
                      : null,
                ),
                const SizedBox(height: 9),
                DropdownButtonFormField<String>(
                  value: _categorySlug,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'puja-rituals', child: Text('Puja & rituals')),
                    DropdownMenuItem(value: 'pilgrimage', child: Text('Pilgrimage')),
                    DropdownMenuItem(value: 'spiritual-stays', child: Text('Spiritual stays')),
                    DropdownMenuItem(value: 'local-experiences', child: Text('Local experiences')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _categorySlug = value);
                  },
                ),
                const SizedBox(height: 9),
                TextFormField(controller: _description, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 9),
                TextFormField(controller: _location, decoration: const InputDecoration(labelText: 'Location')),
                const SizedBox(height: 9),
                TextFormField(controller: _price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Starting price (INR, optional)'), validator: (v) => v != null && v.trim().isNotEmpty && num.tryParse(v.trim()) == null ? 'Enter a valid amount.' : null),
                const SizedBox(height: 9),
                TextFormField(controller: _imageUrl, decoration: const InputDecoration(labelText: 'Image URL (optional)')),
                SwitchListTile(contentPadding: EdgeInsets.zero, value: _published, onChanged: (v) => setState(() => _published = v), title: const Text('Publish service')),
                if (_error != null) Align(alignment: Alignment.centerLeft, child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12))),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save service'),
        ),
      ],
    );
  }
}
).hasMatch(v.trim()) ? 'Use lowercase letters, numbers and hyphens.' : null),
                const SizedBox(height: 9),
                DropdownButtonFormField<String>(
                  value: _categorySlug,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'puja-rituals', child: Text('Puja & rituals')),
                    DropdownMenuItem(value: 'pilgrimage', child: Text('Pilgrimage')),
                    DropdownMenuItem(value: 'spiritual-stays', child: Text('Spiritual stays')),
                    DropdownMenuItem(value: 'local-experiences', child: Text('Local experiences')),
                  ],
                  onChanged: (value) { if (value != null) setState(() => _categorySlug = value); },
                ),
                const SizedBox(height: 9),
                TextFormField(controller: _description, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 9),
                TextFormField(controller: _location, decoration: const InputDecoration(labelText: 'Location')),
                const SizedBox(height: 9),
                TextFormField(controller: _price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Starting price (INR, optional)'), validator: (v) => v != null && v.trim().isNotEmpty && num.tryParse(v.trim()) == null ? 'Enter a valid amount.' : null),
                const SizedBox(height: 9),
                TextFormField(controller: _imageUrl, decoration: const InputDecoration(labelText: 'Image URL (optional)')),
                SwitchListTile(contentPadding: EdgeInsets.zero, value: _published, onChanged: (v) => setState(() => _published = v), title: const Text('Publish service')),
                if (_error != null) Align(alignment: Alignment.centerLeft, child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12))),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save service'),
        ),
      ],
    );
  }
}
