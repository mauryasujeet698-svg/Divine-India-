import 'dart:async';

import 'package:divine_core/divine_core.dart';
import 'package:divine_design_system/divine_design_system.dart';
import 'package:flutter/material.dart';

import 'pages/admin_pages.dart';

class DivineAdminApp extends StatelessWidget {
  const DivineAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Divine India Admin',
      debugShowCheckedModeBanner: false,
      theme: DivineTheme.light,
      home: const AdminAccessGate(),
    );
  }
}

class AdminAccessGate extends StatefulWidget {
  const AdminAccessGate({super.key});

  @override
  State<AdminAccessGate> createState() => _AdminAccessGateState();
}

class _AdminAccessGateState extends State<AdminAccessGate> {
  StreamSubscription<dynamic>? _authSubscription;
  bool _loading = true;
  bool _signedIn = false;
  String? _role;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (isSupabaseInitialized) {
      final client = divineSupabaseClient!;
      _authSubscription = client.auth.onAuthStateChange.listen((_) {
        _refreshAccess();
      });
      _refreshAccess();
    } else {
      _loading = false;
    }
  }

  Future<void> _refreshAccess() async {
    final client = divineSupabaseClient;
    if (client == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final session = client.auth.currentSession;
    if (session == null) {
      if (mounted) {
        setState(() {
          _signedIn = false;
          _role = null;
          _loading = false;
          _error = null;
        });
      }
      return;
    }

    if (mounted) setState(() => _loading = true);
    try {
      final role = await DivineAuthService().currentRole();
      if (!mounted) return;
      setState(() {
        _signedIn = true;
        _role = role;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _signedIn = true;
        _role = null;
        _loading = false;
        _error = 'Could not verify your administrator role. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: DivineColors.saffron)),
      );
    }

    if (!isSupabaseInitialized || !_signedIn) {
      return AdminSignInPage(
        backendConfigured: isSupabaseInitialized,
        onSignedIn: _refreshAccess,
      );
    }

    if (_role != 'admin') {
      return AdminAccessDeniedPage(
        message: _error ?? 'This account does not have the administrator role.',
        onSignOut: () async {
          await DivineAuthService().signOut();
          await _refreshAccess();
        },
      );
    }

    return const AdminShell();
  }
}
