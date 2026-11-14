import 'package:divine_core/divine_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'admin_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDivineBackend();
  runApp(const ProviderScope(child: DivineAdminApp()));
}
