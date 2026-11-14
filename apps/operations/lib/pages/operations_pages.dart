import 'package:divine_core/divine_core.dart';
import 'package:divine_design_system/divine_design_system.dart';
import 'package:flutter/material.dart';

class OperationsSignInPage extends StatefulWidget {
  const OperationsSignInPage({
    super.key,
    required this.backendConfigured,
    required this.onSignedIn,
  });

  final bool backendConfigured;
  final Future<void> Function() onSignedIn;

  @override
  State<OperationsSignInPage> createState() => _OperationsSignInPageState();
}

class _OperationsSignInPageState extends State<OperationsSignInPage> {
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
    } catch (_) {
      if (mounted) setState(() => _error = 'Sign-in failed. Check your credentials.');
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
                  'Operations sign in',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: DivineColors.maroon, fontSize: 25, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Your workspace for assignments, schedules and service updates.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: DivineColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Work email', prefixIcon: Icon(Icons.mail_outline_rounded)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline_rounded)),
                  onSubmitted: (_) => _signIn(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: widget.backendConfigured && !_busy ? _signIn : null,
                  child: _busy
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Sign in'),
                ),
                if (!widget.backendConfigured) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: DivineColors.sand, borderRadius: BorderRadius.circular(16)),
                    child: const Text(
                      'Supabase is not configured. Add the SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY dart-defines before signing in.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: DivineColors.maroon, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OperationsAccessDeniedPage extends StatelessWidget {
  const OperationsAccessDeniedPage({super.key, required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_person_outlined, color: DivineColors.maroon, size: 48),
              const SizedBox(height: 14),
              const Text('Access restricted', style: TextStyle(color: DivineColors.maroon, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text(
                'This account is not assigned to the provider or operations workspace.',
                textAlign: TextAlign.center,
                style: TextStyle(color: DivineColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 18),
              OutlinedButton(onPressed: onSignOut, child: const Text('Sign out')),
            ],
          ),
        ),
      ),
    );
  }
}

class OperationsShell extends StatefulWidget {
  const OperationsShell({super.key});

  @override
  State<OperationsShell> createState() => _OperationsShellState();
}

class _OperationsShellState extends State<OperationsShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      OperationsOverviewPage(),
      OperationsAssignmentsPage(),
      OperationsSchedulePage(),
      OperationsProfilePage(),
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
          NavigationDestination(icon: Icon(Icons.space_dashboard_outlined), selectedIcon: Icon(Icons.space_dashboard_rounded), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment_rounded), label: 'Assignments'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Schedule'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class OperationsOverviewPage extends StatelessWidget {
  const OperationsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Namaste, team',
          style: TextStyle(color: DivineColors.maroon, fontSize: 25, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 5),
        const Text('Your daily service operations at a glance.', style: TextStyle(color: DivineColors.muted, fontSize: 13)),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(color: DivineColors.sand, borderRadius: BorderRadius.circular(16)),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: DivineColors.maroon),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Preview workspace. Live assignments will appear after booking and provider workflows are connected.',
                  style: TextStyle(color: DivineColors.maroon, fontSize: 11, height: 1.35),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Wrap(
          spacing: 11,
          runSpacing: 11,
          children: [
            SizedBox(width: 160, child: DivineMetricCard(label: 'Assigned', value: '—', icon: Icons.assignment_turned_in_outlined)),
            SizedBox(width: 160, child: DivineMetricCard(label: 'In progress', value: '—', icon: Icons.timelapse_rounded)),
            SizedBox(width: 160, child: DivineMetricCard(label: 'Completed', value: '—', icon: Icons.task_alt_rounded)),
          ],
        ),
        const SizedBox(height: 23),
        const DivineSectionHeading(title: 'Your workspace'),
        const SizedBox(height: 11),
        const _WorkspaceCard(icon: Icons.assignment_outlined, title: 'Assigned work', subtitle: 'Review new bookings and assigned service tasks.'),
        const _WorkspaceCard(icon: Icons.calendar_month_outlined, title: 'Availability', subtitle: 'Keep your schedule and working hours up to date.'),
        const _WorkspaceCard(icon: Icons.support_agent_rounded, title: 'Support', subtitle: 'Get help with service delivery and account access.'),
      ],
    );
  }
}

class OperationsAssignmentsPage extends ConsumerWidget {
  const OperationsAssignmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(assignedBookingsProvider);
    final repository = ref.read(bookingRepositoryProvider);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('Assignments', style: TextStyle(color: DivineColors.maroon, fontSize: 25, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        const Text('Bookings and service tasks assigned to your account.', style: TextStyle(color: DivineColors.muted, fontSize: 13)),
        const SizedBox(height: 18),
        bookings.when(
          loading: () => const Center(child: CircularProgressIndicator(color: DivineColors.saffron)),
          error: (error, stack) => const DivineEmptyState(icon: Icons.cloud_off_rounded, title: 'Assignments unavailable', message: 'Check your internet connection and assigned account permissions.'),
          data: (items) => items.isEmpty
              ? const DivineEmptyState(icon: Icons.assignment_outlined, title: 'No assignments to show', message: 'When a booking is assigned to you, its service details, customer instructions and timing will appear here.')
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
                            const SizedBox(height: 7),
                            Text(booking.bookingDate?.toLocal().toString().split('.').first ?? 'Date to be confirmed', style: const TextStyle(color: DivineColors.muted, fontSize: 11)),
                            const SizedBox(height: 5),
                            Text(booking.totalAmount <= 0 ? '${booking.partySize} guest(s) • Quote/payment pending' : '${booking.partySize} guest(s) • ${booking.currency} ${booking.totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: DivineColors.ink, fontSize: 12, fontWeight: FontWeight.w700)),
                            if (booking.customerNote.isNotEmpty) ...[
                              const SizedBox(height: 7),
                              Text(booking.customerNote, style: const TextStyle(color: DivineColors.muted, fontSize: 11)),
                            ],
                            if (booking.status == 'assigned' || booking.status == 'in_progress') ...[
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: FilledButton.icon(
                                  onPressed: () async {
                                    final nextStatus = booking.status == 'assigned'
                                        ? 'in_progress'
                                        : 'completed';
                                    try {
                                      await repository.updateAssignedProgress(
                                        bookingId: booking.id,
                                        status: nextStatus,
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(nextStatus == 'completed' ? 'Service marked completed.' : 'Service started.')),
                                        );
                                      }
                                    } catch (_) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Could not update this booking. Refresh and try again.')),
                                        );
                                      }
                                    }
                                  },
                                  icon: Icon(
                                    booking.status == 'assigned'
                                        ? Icons.play_arrow_rounded
                                        : Icons.task_alt_rounded,
                                  ),
                                  label: Text(
                                    booking.status == 'assigned'
                                        ? 'Start service'
                                        : 'Mark completed',
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )).toList(),
                ),
        ),
      ],
    );
  }
}

class OperationsSchedulePage extends ConsumerWidget {
  const OperationsSchedulePage({super.key});

  static const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  Future<void> _editDay(
    BuildContext context,
    WidgetRef ref,
    int weekday,
    ProviderAvailabilityModel? current,
  ) async {
    TimeOfDay parseTime(String? value, TimeOfDay fallback) {
      if (value == null) return fallback;
      final parts = value.split(':');
      if (parts.length < 2) return fallback;
      return TimeOfDay(hour: int.tryParse(parts[0]) ?? fallback.hour, minute: int.tryParse(parts[1]) ?? fallback.minute);
    }

    var start = parseTime(current?.startTime, const TimeOfDay(hour: 9, minute: 0));
    var end = parseTime(current?.endTime, const TimeOfDay(hour: 17, minute: 0));
    var available = current?.isAvailable ?? false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(_days[weekday - 1]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: available,
                onChanged: (value) => setDialogState(() => available = value),
                title: const Text('Available for bookings'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Start time'),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(context: context, initialTime: start);
                    if (picked != null) setDialogState(() => start = picked);
                  },
                  child: Text(start.format(context)),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('End time'),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(context: context, initialTime: end);
                    if (picked != null) setDialogState(() => end = picked);
                  },
                  child: Text(end.format(context)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (end.hour * 60 + end.minute <= start.hour * 60 + start.minute) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End time must be later than start time.')));
                  return;
                }
                try {
                  await ref.read(providerAvailabilityRepositoryProvider).saveDay(
                    weekday: weekday,
                    startTime: '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}:00',
                    endTime: '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}:00',
                    isAvailable: available,
                  );
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                } catch (_) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('Could not save availability. Check your provider role and database migration.')));
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availability = ref.watch(myAvailabilityProvider);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text('My schedule', style: TextStyle(color: DivineColors.maroon, fontSize: 25, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        const Text('Set the days and hours when you can accept services.', style: TextStyle(color: DivineColors.muted, fontSize: 13)),
        const SizedBox(height: 17),
        availability.when(
          loading: () => const Center(child: CircularProgressIndicator(color: DivineColors.saffron)),
          error: (error, stack) => const DivineEmptyState(icon: Icons.cloud_off_rounded, title: 'Availability unavailable', message: 'Apply the provider availability migration and check your role.'),
          data: (items) {
            return Column(
              children: List.generate(7, (index) {
                final day = index + 1;
                ProviderAvailabilityModel? current;
                for (final entry in items) {
                  if (entry.weekday == day) {
                    current = entry;
                    break;
                  }
                }
                final isAvailable = current?.isAvailable ?? false;
                final start = current?.startTime.substring(0, 5) ?? '09:00';
                final end = current?.endTime.substring(0, 5) ?? '17:00';
                return Container(
                  margin: const EdgeInsets.only(bottom: 9),
                  decoration: BoxDecoration(color: DivineColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: DivineColors.border)),
                  child: ListTile(
                    onTap: () => _editDay(context, ref, day, current),
                    title: Text(_days[index], style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(isAvailable ? '$start – $end' : 'Not available', style: const TextStyle(color: DivineColors.muted, fontSize: 11)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DivineStatusPill(label: isAvailable ? 'AVAILABLE' : 'OFF', color: isAvailable ? DivineColors.success : DivineColors.muted),
                        const SizedBox(width: 7),
                        const Icon(Icons.chevron_right_rounded, color: DivineColors.muted),
                      ],
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

class OperationsProfilePage extends StatelessWidget {
  const OperationsProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = divineSupabaseClient?.auth.currentUser;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [DivineColors.maroon, DivineColors.saffronDark]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: Color(0x33FFFFFF),
                child: Icon(Icons.person_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Operations account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(user?.email ?? 'Signed in user', style: const TextStyle(color: Color(0xFFFFEADB), fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _WorkspaceCard(icon: Icons.badge_outlined, title: 'Profile details', subtitle: 'Your verified provider and team information.'),
        const _WorkspaceCard(icon: Icons.notifications_none_rounded, title: 'Notifications', subtitle: 'Updates about assignments and schedule changes.'),
        const _WorkspaceCard(icon: Icons.help_outline_rounded, title: 'Help & support', subtitle: 'Contact platform operations.'),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async => DivineAuthService().signOut(),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Sign out'),
        ),
      ],
    );
  }
}

class _WorkspaceCard extends StatelessWidget {
  const _WorkspaceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: DivineColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DivineColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        leading: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(color: DivineColors.sand, borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: DivineColors.maroon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(color: DivineColors.muted, fontSize: 11)),
        trailing: const Icon(Icons.chevron_right_rounded, color: DivineColors.muted),
      ),
    );
  }
}
