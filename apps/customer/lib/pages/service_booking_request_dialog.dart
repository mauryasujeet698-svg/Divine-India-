import 'package:divine_core/divine_core.dart';
import 'package:divine_design_system/divine_design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ServiceBookingRequestDialog extends StatefulWidget {
  const ServiceBookingRequestDialog({super.key, required this.service});
  final ServiceModel service;

  @override
  State<ServiceBookingRequestDialog> createState() => _ServiceBookingRequestDialogState();
}

class _ServiceBookingRequestDialogState extends State<ServiceBookingRequestDialog> {
  final _note = TextEditingController();
  DateTime? _date;
  int _partySize = 1;
  bool _saving = false;
  String? _error;

  @override
  void dispose() { _note.dispose(); super.dispose(); }

  Future<void> _chooseDate() async {
    final now = DateTime.now();
    final value = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 1)),
      firstDate: DateTime(now.year, now.month, now.day + 1),
      lastDate: DateTime(now.year + 3),
    );
    if (value != null && mounted) setState(() => _date = value);
  }

  Future<void> _submit() async {
    if (_date == null) { setState(() => _error = 'Choose your preferred date.'); return; }
    setState(() { _saving = true; _error = null; });
    try {
      final date = DateTime(_date!.year, _date!.month, _date!.day, 9);
      final reference = await BookingRepository().requestBooking(
        serviceId: widget.service.id,
        bookingDate: date,
        partySize: _partySize,
        customerNote: _note.text,
      );
      if (mounted) Navigator.of(context).pop(reference);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not submit. Please check your connection and try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DivineColors.surface,
      title: const Text('Request this experience'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.service.title, style: const TextStyle(fontWeight: FontWeight.w800, color: DivineColors.maroon)),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month_rounded, color: DivineColors.maroon),
                title: const Text('Preferred date'),
                subtitle: Text(_date?.toLocal().toString().split(' ').first ?? 'Choose a date'),
                trailing: TextButton(onPressed: _saving ? null : _chooseDate, child: const Text('Select')),
              ),
              DropdownButtonFormField<int>(
                value: _partySize,
                decoration: const InputDecoration(labelText: 'Number of guests'),
                items: List.generate(20, (index) => DropdownMenuItem(value: index + 1, child: Text('${index + 1}'))),
                onChanged: _saving ? null : (value) { if (value != null) setState(() => _partySize = value); },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _note,
                maxLength: 500,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Special requests (optional)'),
              ),
              const SizedBox(height: 6),
              const Text('This submits a booking request for confirmation. No payment is taken in this step.', style: TextStyle(fontSize: 11, color: DivineColors.muted, height: 1.4)),
              if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12))),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Submit request'),
        ),
      ],
    );
  }
}

Future<void> showServiceBookingRequest(BuildContext context, ServiceModel service) async {
  if (divineSupabaseClient?.auth.currentUser == null) {
    context.push('/sign-in');
    return;
  }
  final reference = await showDialog<String>(
    context: context,
    builder: (_) => ServiceBookingRequestDialog(service: service),
  );
  if (reference != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request submitted: $reference')));
  }
}