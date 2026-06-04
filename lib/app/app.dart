import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

/// Root widget. Wires the role-based [routerProvider] into a
/// [MaterialApp.router] with the shared [buildAgriTheme].
class AgriApp extends ConsumerWidget {
  const AgriApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Agri Marketplace',
      debugShowCheckedModeBanner: false,
      theme: buildAgriTheme(),
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ml'), // Malayalam — UI labels to be localised later
      ],
    );
  }
}
