// lib/core/extensions/color_extensions.dart
import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  // normalized (0.0 - 1.0) channel getters used by existing code
  double get r => red / 255.0;
  double get g => green / 255.0;
  double get b => blue / 255.0;

  /// Get the ARGB integer representation of the color
  int getInt() => value;

  /// Provide a withValues API that callers expect.
  /// Uses standard Color properties for compatibility
  Color withValues({
    double? red,
    double? green,
    double? blue,
    double? alpha,
  }) {
    final currentRed = this.red;
    final currentGreen = this.green;
    final currentBlue = this.blue;
    final currentAlpha = this.alpha;

    final nr =
        (red != null) ? ((red.clamp(0.0, 1.0) * 255).round()) : currentRed;
    final ng = (green != null)
        ? ((green.clamp(0.0, 1.0) * 255).round())
        : currentGreen;
    final nb =
        (blue != null) ? ((blue.clamp(0.0, 1.0) * 255).round()) : currentBlue;
    final na = (alpha != null)
        ? ((alpha.clamp(0.0, 1.0) * 255).round())
        : currentAlpha;

    return Color.fromARGB(na, nr, ng, nb);
  }
}

// Support MaterialColor usage where code calls withValues on MaterialColor.
// Convert to a representative Color (shade500) before applying withValues.
extension MaterialColorExtensions on MaterialColor {
  Color withValues({
    double? red,
    double? green,
    double? blue,
    double? alpha,
  }) =>
      this[500]!.withValues(
        red: red,
        green: green,
        blue: blue,
        alpha: alpha,
      );
}
