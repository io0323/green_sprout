import 'package:flutter/material.dart';
import '../theme/tea_garden_theme.dart';
import '../services/localization_service.dart';

/// 共通のWelcomeCardウィジェット
/// アプリケーション全体で一貫したウェルカムカードを提供
class WelcomeCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData icon;
  final double iconSize;

  const WelcomeCard({
    super.key,
    this.title,
    this.subtitle,
    this.icon = Icons.eco,
    this.iconSize = 50,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final finalTitle =
        title ?? LocalizationService.instance.translate('app_title');
    final finalSubtitle =
        subtitle ?? LocalizationService.instance.translate('welcome_message');

    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: TeaGardenTheme.primaryGradient,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: iconSize,
              color: colorScheme.onPrimary,
            ),
            const SizedBox(height: 10),
            Text(
              finalTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              finalSubtitle,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onPrimary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 共通のStatItemウィジェット
/// 統計情報を表示するための統一されたウィジェット
class StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const StatItem({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final finalColor = color ?? colorScheme.primary;

    return Column(
      children: [
        Icon(icon, color: finalColor, size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: finalColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

/// 共通のStatCardウィジェット
/// 統計情報をカード形式で表示
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final finalColor = color ?? colorScheme.primary;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StatItem(
          label: label,
          value: value,
          icon: icon,
          color: finalColor,
        ),
      ),
    );
  }
}

/// 共通のAnalysisCardウィジェット
/// 解析アクションを表示するための統一されたウィジェット
class AnalysisCard extends StatelessWidget {
  final bool isAnalyzing;
  final VoidCallback? onAnalyze;
  final String? analyzingText;
  final String? buttonText;
  final IconData buttonIcon;
  final Key? buttonKey;

  const AnalysisCard({
    super.key,
    required this.isAnalyzing,
    this.onAnalyze,
    this.analyzingText,
    this.buttonText,
    this.buttonIcon = Icons.camera_alt,
    this.buttonKey,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final finalAnalyzingText =
        analyzingText ?? LocalizationService.instance.translate('ai_analyzing');
    final finalButtonText =
        buttonText ?? LocalizationService.instance.translate('take_photo');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              LocalizationService.instance.translate('tea_analysis'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (isAnalyzing)
              Column(
                children: [
                  CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(finalAnalyzingText),
                ],
              )
            else
              ElevatedButton.icon(
                key: buttonKey,
                onPressed: onAnalyze,
                icon: Icon(buttonIcon),
                label: Text(finalButtonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 空の状態を表示するウィジェット
/// データが存在しない場合の統一された表示
class EmptyStateWidget extends StatelessWidget {
  final String? message;
  final String? subtitle;
  final IconData icon;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    this.message,
    this.subtitle,
    this.icon = Icons.photo_camera_outlined,
    this.iconSize = 50,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final finalMessage =
        message ?? LocalizationService.instance.translate('no_results_yet');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            finalMessage,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
