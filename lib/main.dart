import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todos/controllers/font_settings_controller.dart';
import 'package:todos/models/font_settings.dart';
import 'package:todos/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _fontController = FontSettingsController();

  @override
  void dispose() {
    _fontController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _fontController,
      builder: (context, _) {
        final settings = _fontController.settings;
        return MaterialApp(
          title: 'Mes tâches',
          debugShowCheckedModeBanner: false,
          locale: const Locale('fr'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('fr')],
          theme: _buildTheme(settings),
          // Font size scaling is applied via MediaQuery so it works for every
          // widget regardless of how ThemeData merges the textTheme internally.
          // FontSettingsScope sits here so every pushed route can access it.
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(
              ctx,
            ).copyWith(textScaler: TextScaler.linear(settings.fontSizeScale)),
            child: FontSettingsScope(notifier: _fontController, child: child!),
          ),
          home: const HomePage(),
        );
      },
    );
  }

  ThemeData _buildTheme(FontSettings settings) {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.indigo);

    // Pass the Material 3 base theme so GoogleFonts preserves every font size.
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
    ).textTheme;
    var textTheme = GoogleFonts.getTextTheme(settings.fontFamily, baseTheme);
    textTheme = _withFontWeight(textTheme, settings.fontWeight);

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      textTheme: textTheme,
    );
  }

  /// Applies [weight] to the styles that represent readable content, leaving
  /// display / headline styles at their native weights.
  TextTheme _withFontWeight(TextTheme t, FontWeight weight) {
    TextStyle? w(TextStyle? s) => s?.copyWith(fontWeight: weight);
    return t.copyWith(
      bodyLarge: w(t.bodyLarge),
      bodyMedium: w(t.bodyMedium),
      bodySmall: w(t.bodySmall),
      labelLarge: w(t.labelLarge),
      labelMedium: w(t.labelMedium),
      labelSmall: w(t.labelSmall),
      titleMedium: w(t.titleMedium),
      titleSmall: w(t.titleSmall),
    );
  }
}
