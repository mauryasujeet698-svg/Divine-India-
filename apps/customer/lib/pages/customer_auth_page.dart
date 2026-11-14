import 'package:divine_core/divine_core.dart';
import 'package:divine_design_system/divine_design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomerAuthPage extends StatefulWidget {
  const CustomerAuthPage({super.key});

  @override
  State<CustomerAuthPage> createState() => _CustomerAuthPageState();
}

class _CustomerAuthPageState extends State<CustomerAuthPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _createAccount = false;
  bool _busy = false;
  bool _obscurePassword = true;
  String? _error;
  String? _message;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final client = divineSupabaseClient;
    if (client == null || _busy) return;

    if (_email.text.trim().isEmpty || !_email.text.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (_password.text.length < 8) {
      setState(() => _error = 'Use a password with at least 8 characters.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });

    try {
      if (_createAccount) {
        final response = await client.auth.signUp(
          email: _email.text.trim(),
          password: _password.text,
        );
        if (response.session == null) {
          setState(() {
            _message = 'Your account was created. Check your email to verify it, then sign in.';
          });
        } else if (mounted) {
          context.go('/profile');
        }
      } else {
        await DivineAuthService().signInWithPassword(
          email: _email.text,
          password: _password.text,
        );
        if (mounted) context.go('/profile');
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = _createAccount
              ? 'Account creation failed. Check the details or try another email.'
              : 'Sign-in failed. Check your email and password.';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final configured = isSupabaseInitialized;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Your Divine India account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: DivineBrandMark()),
                const SizedBox(height: 28),
                Text(
                  _createAccount ? 'Begin your journey' : 'Welcome back',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: DivineColors.maroon,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign in to manage bookings and save meaningful experiences.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: DivineColors.muted, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    ),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(_message!, style: const TextStyle(color: DivineColors.success, fontSize: 12, height: 1.4)),
                ],
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: configured && !_busy ? _submit : null,
                  child: _busy
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_createAccount ? 'Create account' : 'Sign in'),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _createAccount = !_createAccount;
                    _error = null;
                    _message = null;
                  }),
                  child: Text(_createAccount ? 'Already have an account? Sign in' : 'New to Divine India? Create an account'),
                ),
                if (!configured) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: DivineColors.sand,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Browsing is available in demo mode. Account access will be enabled after the Supabase project is configured.',
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
