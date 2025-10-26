// lib/core/extensions/color_extensions.dart
import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  // normalized (0.0 - 1.0) channel getters used by existing code
  double get r {
    final argb = getInt();
    return ((argb >> 16) & 0xff) / 255.0;
  }

  double get g {
    final argb = getInt();
    return ((argb >> 8) & 0xff) / 255.0;
  }

  double get b {
    final argb = getInt();
    return (argb & 0xff) / 255.0;
  }

  /// Get the ARGB integer representation of the color
  /// Using toARGB32() for non-deprecated access
  int getInt() {
    final argb = toARGB32();
    return argb;
  }

  /// Provide a withValues API that callers expect.
  /// Uses opacity instead of alpha for Flutter API compatibility
  Color withValues({
    double? red,
    double? green,
    double? blue,
    double? alpha,
  }) {
    // Get current color components using non-deprecated API
    final currentArgb = toARGB32();
    final currentRed = ((currentArgb >> 16) & 0xff);
    final currentGreen = ((currentArgb >> 8) & 0xff);
    final currentBlue = (currentArgb & 0xff);
    final currentAlpha = ((currentArgb >> 24) & 0xff);

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
