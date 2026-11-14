import 'dart:async';

import 'package:divine_core/divine_core.dart';
import 'package:divine_design_system/divine_design_system.dart';
import 'package:flutter/material.dart';

import 'pages/operations_pages.dart';

class DivineOperationsApp extends StatelessWidget {
  const DivineOperationsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Divine India Operations',
      debugShowCheckedModeBanner: false,
      theme: DivineTheme.light,
      home: const OperationsAccessGate(),
    );
  }
}

class OperationsAccessGate extends StatefulWidget {
  const OperationsAccessGate({super.key});

  @override
  State<OperationsAccessGate> createState() => _OperationsAccessGateState();
}

class _OperationsAccessGateState extends State<OperationsAccessGate> {
  StreamSubscription<dynamic>? _authSubscription;
  bool _loading = true;
  bool _signedIn = false;
  String? _role;

  @override
  void initState() {
    super.initState();
    if (isSupabaseInitialized) {
      final client = divineSupabaseClient!;
      _authSubscription = client.auth.onAuthStateChange.listen((_) {
        unawaited(_refreshAccess());
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
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _signedIn = true;
        _role = null;
        _loading = false;
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
      return OperationsSignInPage(
        backendConfigured: isSupabaseInitialized,
        onSignedIn: _refreshAccess,
      );
    }

    if (_role != 'provider' && _role != 'operations') {
      return OperationsAccessDeniedPage(
        onSignOut: () async {
          await DivineAuthService().signOut();
          await _refreshAccess();
        },
      );
    }

    return const OperationsShell();
  }
}
