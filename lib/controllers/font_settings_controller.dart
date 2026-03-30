import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/font_settings.dart';

class FontSettingsController extends ChangeNotifier {
  FontSettings _settings = const FontSettings();

  FontSettings get settings => _settings;

  void updateFontFamily(String fontFamily) {
    if (_settings.fontFamily == fontFamily) return;
    _settings = _settings.copyWith(fontFamily: fontFamily);
    notifyListeners();
  }

  void updateFontWeight(FontWeight fontWeight) {
    if (_settings.fontWeight == fontWeight) return;
    _settings = _settings.copyWith(fontWeight: fontWeight);
    notifyListeners();
  }

  void updateFontSizeScale(double scale) {
    if (_settings.fontSizeScale == scale) return;
    _settings = _settings.copyWith(fontSizeScale: scale);
    notifyListeners();
  }
}

/// Provides [FontSettingsController] to the widget subtree via [InheritedNotifier].
/// Place this below [MaterialApp] using its `builder` parameter so all
/// navigated pages can call [FontSettingsScope.of(context)].
class FontSettingsScope extends InheritedNotifier<FontSettingsController> {
  const FontSettingsScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static FontSettingsController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<FontSettingsScope>();
    assert(scope != null, 'No FontSettingsScope found in the widget tree');
    return scope!.notifier!;
  }
}
