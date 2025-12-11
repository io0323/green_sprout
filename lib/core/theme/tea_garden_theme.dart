import 'package:flutter/material.dart';

/// 茶園管理AI用のカスタムテーマ
/// モダンで美しいデザインシステム
class TeaGardenTheme {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color accentGreen = Color(0xFF66BB6A);

  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);

  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color infoColor = Color(0xFF2196F3);

  /// ライトテーマ
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: accentGreen,
        surface: surfaceLight,
        error: errorColor,
        onPrimary: textLight,
        onSecondary: textLight,
        onSurface: textPrimary,
        onError: textLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: textLight,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // cardTheme: const CardTheme(
      //   elevation: 4,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.all(Radius.circular(16)),
      //   ),
      // ).copyWith(color: surfaceLight),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  /// ダークテーマ
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: lightGreen,
        secondary: accentGreen,
        surface: surfaceDark,
        error: errorColor,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textLight,
        onError: textLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightGreen,
          foregroundColor: textPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // cardTheme: const CardTheme(
      //   elevation: 4,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.all(Radius.circular(16)),
      //   ),
      // ).copyWith(color: surfaceDark),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGreen, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  /// グラデーション
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, lightGreen],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundLight, Color(0xFFE8F5E8)],
  );

  /// シャドウ
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: primaryGreen.withOpacity(0.3),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  /// ボーダーラディウス
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  /// スペーシング
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingSM = 12.0; // Small-Medium
  static const double spacingM = 16.0;
  static const double spacingML = 20.0; // Medium-Large
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  /// タイポグラフィ
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  /// ウェアラブルデバイス用のフォントサイズ定数
  static const double wearableFontSizeLarge = 12.0;
  static const double wearableFontSizeMedium = 11.0;
  static const double wearableFontSizeSmall = 10.0;

  /// エラーウィジェット用のアイコンサイズ定数
  static const double errorIconSizeWearable = 40.0;
  static const double errorIconSizeDefault = 48.0;

  /// ボタン高さ定数
  static const double buttonHeightWearable = 40.0;
  static const double buttonHeightDefault = 48.0;

  /// タイトルフォントサイズ定数
  static const double titleFontSizeWearable = 16.0;
  static const double titleFontSizeDefault = 20.0;

  /// エレベーション定数
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  /// アイコンサイズ定数
  static const double iconSizeWearableSmall = 20.0;
  static const double iconSizeDefaultSmall = 24.0;
  static const double iconSizeWearableMedium = 24.0;
  static const double iconSizeDefaultMedium = 32.0;

  /// ボタン高さ定数（追加）
  static const double buttonHeightWearableLarge = 80.0;
  static const double buttonHeightDefaultLarge = 100.0;
  static const double buttonHeightWearableMedium = 60.0;

  /// ブラー半径定数
  static const double blurRadiusSmall = 4.0;
  static const double blurRadiusMedium = 8.0;
  static const double blurRadiusLarge = 16.0;

  /// オフセット定数
  static const Offset offsetSmall = Offset(0, 2);
  static const Offset offsetMedium = Offset(0, 4);
  static const Offset offsetLarge = Offset(0, 8);

  /// カメラ関連のサイズ定数
  static const double cameraFrameSize = 200.0;
  static const double cameraCornerSize = 20.0;
  static const double cameraOverlayHeight = 100.0;
  static const double cameraBorderWidth = 2.0;
  static const double cameraCornerBorderWidth = 3.0;

  /// キャプチャーボタン関連のサイズ定数
  static const double captureButtonSize = 80.0;
  static const double captureButtonBorderWidth = 4.0;
  static const double progressIndicatorSize = 30.0;

  /// グラフ関連のサイズ定数
  static const double chartBarWidth = 20.0;
  static const double chartHeight = 200.0;
  static const double chartBorderRadius = 4.0;

  /// アイコンサイズ定数（追加）
  static const double iconSizeDefaultLarge = 64.0;
  static const double iconSizeDefaultXLarge = 80.0;

  /// その他のサイズ定数
  static const double analysisResultImageSize = 200.0;
  static const double webHomeButtonSize = 60.0;
  static const double webHomeIconSize = 30.0;
  static const double webHomeChartHeight = 400.0;
  static const double strokeWidthMedium = 3.0;
}

/// アニメーション定数
class AnimationConstants {
  // 短いアニメーション（ミリ秒）
  static const Duration veryShortDuration = Duration(milliseconds: 50);
  static const Duration extraShortDuration = Duration(milliseconds: 100);
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);
  static const Duration extraLongDuration = Duration(milliseconds: 800);
  static const Duration veryLongDuration = Duration(milliseconds: 1000);

  // 長いアニメーション（秒）
  static const Duration twoSeconds = Duration(seconds: 2);
  static const Duration threeSeconds = Duration(seconds: 3);
  static const Duration fourSeconds = Duration(seconds: 4);
  static const Duration fiveSeconds = Duration(seconds: 5);
  static const Duration thirtySeconds = Duration(seconds: 30);

  // カーブ
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve slideCurve = Curves.easeOutCubic;
}

/// レスポンシブデザイン用のブレークポイント
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// レスポンシブヘルパー
class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < Breakpoints.mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= Breakpoints.mobile && width < Breakpoints.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= Breakpoints.tablet;
  }

  static double getResponsiveWidth(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  static int getResponsiveColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }
}
