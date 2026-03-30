import 'package:flutter/material.dart';

class FontSettings {
  const FontSettings({
    this.fontFamily = 'Roboto',
    this.fontWeight = FontWeight.w400,
    this.fontSizeScale = 1.0,
  });

  final String fontFamily;
  final FontWeight fontWeight;

  /// Multiplier applied to every text style in the app's TextTheme.
  final double fontSizeScale;

  FontSettings copyWith({
    String? fontFamily,
    FontWeight? fontWeight,
    double? fontSizeScale,
  }) {
    return FontSettings(
      fontFamily: fontFamily ?? this.fontFamily,
      fontWeight: fontWeight ?? this.fontWeight,
      fontSizeScale: fontSizeScale ?? this.fontSizeScale,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FontSettings &&
          runtimeType == other.runtimeType &&
          fontFamily == other.fontFamily &&
          fontWeight == other.fontWeight &&
          fontSizeScale == other.fontSizeScale;

  @override
  int get hashCode =>
      fontFamily.hashCode ^ fontWeight.hashCode ^ fontSizeScale.hashCode;
}
