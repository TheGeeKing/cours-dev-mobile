import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todos/models/font_settings.dart';

class FontSettingsController extends ChangeNotifier {
  FontSettingsController({Future<SharedPreferences>? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance() {
    _loaded = _load();
  }

  static const _fontFamilyKey = 'font_settings_family';
  static const _fontWeightKey = 'font_settings_weight';
  static const _fontSizeScaleKey = 'font_settings_size_scale';

  final Future<SharedPreferences> _preferences;
  late final Future<void> _loaded;
  Future<void> _pendingSave = Future.value();
  FontSettings _settings = const FontSettings();
  bool _hasUserChanges = false;
  bool _isDisposed = false;

  FontSettings get settings => _settings;

  Future<void> get loaded => _loaded;

  Future<void> get pendingSave => _pendingSave;

  void updateFontFamily(String fontFamily) {
    if (_settings.fontFamily == fontFamily) return;
    _settings = _settings.copyWith(fontFamily: fontFamily);
    _hasUserChanges = true;
    _queueSave(_settings);
    notifyListeners();
  }

  void updateFontWeight(FontWeight fontWeight) {
    if (_settings.fontWeight == fontWeight) return;
    _settings = _settings.copyWith(fontWeight: fontWeight);
    _hasUserChanges = true;
    _queueSave(_settings);
    notifyListeners();
  }

  void updateFontSizeScale(double scale) {
    if (_settings.fontSizeScale == scale) return;
    _settings = _settings.copyWith(fontSizeScale: scale);
    _hasUserChanges = true;
    _queueSave(_settings);
    notifyListeners();
  }

  Future<void> _load() async {
    final prefs = await _preferences;
    if (_hasUserChanges) return;

    final restoredSettings = FontSettings(
      fontFamily: prefs.getString(_fontFamilyKey) ?? _settings.fontFamily,
      fontWeight:
          _fontWeightFromValue(prefs.getInt(_fontWeightKey)) ??
          _settings.fontWeight,
      fontSizeScale:
          prefs.getDouble(_fontSizeScaleKey) ?? _settings.fontSizeScale,
    );

    if (_settings == restoredSettings) return;
    _settings = restoredSettings;
    if (!_isDisposed) notifyListeners();
  }

  void _queueSave(FontSettings settings) {
    _pendingSave = _pendingSave.then((_) => _save(settings));
  }

  Future<void> _save(FontSettings settings) async {
    final prefs = await _preferences;
    await prefs.setString(_fontFamilyKey, settings.fontFamily);
    await prefs.setInt(_fontWeightKey, settings.fontWeight.value);
    await prefs.setDouble(_fontSizeScaleKey, settings.fontSizeScale);
  }

  FontWeight? _fontWeightFromValue(int? value) {
    if (value == null) return null;

    for (final weight in FontWeight.values) {
      if (weight.value == value) return weight;
    }

    return null;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
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
    final scope = context
        .dependOnInheritedWidgetOfExactType<FontSettingsScope>();
    assert(scope != null, 'No FontSettingsScope found in the widget tree');
    return scope!.notifier!;
  }
}
