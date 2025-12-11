import 'package:flutter/material.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/widgets/language_selector.dart';
import '../../../../core/widgets/snackbar_helper.dart';
import '../../../../core/theme/tea_garden_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/constants/app_constants.dart';

/// Web用の簡素化されたホームページ
/// 依存性注入を使わずに直接実装
class WebHomePage extends StatefulWidget {
  final VoidCallback? onLanguageChanged;

  const WebHomePage({super.key, this.onLanguageChanged});

  @override
  State<WebHomePage> createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _mockResults = [];

  @override
  void initState() {
    super.initState();
    _initializeMockResults();
  }

  void _initializeMockResults() {
    final loc = LocalizationService.instance;
    _mockResults = [
      {
        'id': '1',
        'imagePath': '/assets/images/sample_tea_1.jpg',
        'timestamp':
            DateTime.now().subtract(const Duration(days: AppConstants.daysOne)),
        'healthStatus': loc.translate('healthy'),
        'growthStage': loc.translate('maturity_period'),
        'confidence': 0.85,
        'comment': '健康な茶葉です。良好な成長状態を維持しています。',
      },
      {
        'id': '2',
        'imagePath': '/assets/images/sample_tea_2.jpg',
        'timestamp': DateTime.now()
            .subtract(const Duration(days: AppConstants.daysThree)),
        'healthStatus': loc.translate('attention'),
        'growthStage': loc.translate('growth_period'),
        'confidence': 0.72,
        'comment': '軽度の葉枯れ病が検出されました。適切な対処が必要です。',
      },
      {
        'id': '3',
        'imagePath': '/assets/images/sample_tea_3.jpg',
        'timestamp': DateTime.now()
            .subtract(const Duration(days: AppConstants.daysFive)),
        'healthStatus': loc.translate('healthy'),
        'growthStage': loc.translate('maturity_period'),
        'confidence': 0.90,
        'comment': '非常に健康な茶葉です。理想的な成長状態です。',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationService.instance.translate('app_title'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          LanguageSelector(onLanguageChanged: widget.onLanguageChanged),
          IconButton(
            icon: Icon(Icons.history,
                color: Theme.of(context).colorScheme.onPrimary),
            onPressed: () {
              _showLogsDialog();
            },
            tooltip: LocalizationService.instance.translate('logs_list'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: TeaGardenTheme.backgroundGradient,
        ),
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: TeaGardenTheme.spacingM),
                    Text(
                      LocalizationService.instance.translate('data_loading'),
                      style: TextStyle(
                        fontSize: TeaGardenTheme.bodyMedium.fontSize,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // 今日のサマリー
                  _buildTodaySummary(),

                  // 写真撮影ボタン
                  _buildCameraButton(),

                  // 最近の解析結果
                  Expanded(
                    child: _buildRecentResults(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTodaySummary() {
    final todayResults = _mockResults.where((result) {
      final timestamp = result['timestamp'] as DateTime;
      final now = DateTime.now();
      return timestamp.year == now.year &&
          timestamp.month == now.month &&
          timestamp.day == now.day;
    }).toList();

    return Container(
      margin: const EdgeInsets.all(TeaGardenTheme.spacingM),
      padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(TeaGardenTheme.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalizationService.instance.translate('today_analysis_results'),
            style: TextStyle(
              fontSize: TeaGardenTheme.bodyLarge.fontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: TeaGardenTheme.spacingS),
          Text(
            LocalizationService.instance.translate('analysis_completed_count',
                params: {'count': todayResults.length.toString()}),
            style: TextStyle(
              fontSize: TeaGardenTheme.bodySmall.fontSize,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraButton() {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: TeaGardenTheme.spacingM,
          vertical: TeaGardenTheme.spacingS),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _simulateAnalysis,
        icon: const Icon(Icons.camera_alt),
        label: Text(LocalizationService.instance.translate('take_photo')),
        style: ElevatedButton.styleFrom(
          backgroundColor: TeaGardenTheme.successColor,
          foregroundColor: TeaGardenTheme.textLight,
          padding: const EdgeInsets.symmetric(
              horizontal: TeaGardenTheme.spacingL,
              vertical: TeaGardenTheme.spacingM),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(TeaGardenTheme.borderRadiusSmall),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentResults() {
    if (_mockResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_camera_outlined,
              size: TeaGardenTheme.iconSizeDefaultLarge,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: TeaGardenTheme.spacingM),
            Text(
              LocalizationService.instance.translate('no_results_yet'),
              style: TextStyle(
                fontSize: TeaGardenTheme.bodyLarge.fontSize,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: TeaGardenTheme.spacingS),
            Text(
              LocalizationService.instance.translate('take_photo_to_analyze'),
              style: TextStyle(
                fontSize: TeaGardenTheme.bodySmall.fontSize,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
      itemCount: _mockResults.length,
      itemBuilder: (context, index) {
        final result = _mockResults[index];
        return _buildResultCard(result);
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    final timestamp = result['timestamp'] as DateTime;
    final healthStatus = result['healthStatus'] as String;
    final confidence = result['confidence'] as double;

    return Container(
      margin: const EdgeInsets.only(bottom: TeaGardenTheme.spacingM),
      padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(TeaGardenTheme.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: TeaGardenTheme.webHomeButtonSize,
                height: TeaGardenTheme.webHomeButtonSize,
                decoration: BoxDecoration(
                  color: TeaGardenTheme.successColor.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(TeaGardenTheme.borderRadiusSmall),
                ),
                child: const Icon(
                  Icons.eco,
                  color: TeaGardenTheme.successColor,
                  size: TeaGardenTheme.webHomeIconSize,
                ),
              ),
              const SizedBox(width: TeaGardenTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${result['growthStage']} - ${result['healthStatus']}',
                      style: TextStyle(
                        fontSize: TeaGardenTheme.bodyMedium.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppUtils.formatShortDateTime(timestamp),
                      style: TextStyle(
                        fontSize: TeaGardenTheme.caption.fontSize,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '${LocalizationService.instance.translate('confidence_label')} ${(confidence * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: TeaGardenTheme.caption.fontSize,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: TeaGardenTheme.spacingS,
                    vertical: TeaGardenTheme.spacingXS),
                decoration: BoxDecoration(
                  color: healthStatus ==
                          LocalizationService.instance.translate('healthy')
                      ? TeaGardenTheme.successColor.withOpacity(0.1)
                      : TeaGardenTheme.warningColor.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(TeaGardenTheme.borderRadiusMedium),
                ),
                child: Text(
                  healthStatus,
                  style: TextStyle(
                    fontSize: TeaGardenTheme.caption.fontSize,
                    fontWeight: FontWeight.bold,
                    color: healthStatus ==
                            LocalizationService.instance.translate('healthy')
                        ? TeaGardenTheme.successColor
                        : TeaGardenTheme.warningColor,
                  ),
                ),
              ),
            ],
          ),
          if (result['comment'] != null) ...[
            const SizedBox(height: TeaGardenTheme.spacingS),
            Text(
              result['comment'],
              style: TextStyle(
                fontSize: TeaGardenTheme.bodySmall.fontSize,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _simulateAnalysis() async {
    setState(() {
      _isLoading = true;
    });

    // 解析処理をシミュレート
    await Future.delayed(AnimationConstants.threeSeconds);

    // 新しい結果を追加
    final loc = LocalizationService.instance;
    final newResult = {
      'id': (_mockResults.length + 1).toString(),
      'imagePath':
          '/assets/images/sample_tea_${DateTime.now().millisecondsSinceEpoch % 3 + 1}.jpg',
      'timestamp': DateTime.now(),
      'healthStatus': DateTime.now().millisecondsSinceEpoch % 10 < 2
          ? loc.translate('attention')
          : loc.translate('healthy'),
      'growthStage': [
        loc.translate('sprouting_period'),
        loc.translate('growth_period'),
        loc.translate('maturity_period'),
        loc.translate('harvest_period')
      ][DateTime.now().millisecondsSinceEpoch % 4],
      'confidence': 0.8 + (DateTime.now().millisecondsSinceEpoch % 20) / 100,
      'comment': loc.translate('new_analysis_completed'),
    };

    setState(() {
      _mockResults.insert(0, newResult);
      _isLoading = false;
    });

    // 成功メッセージを表示
    if (mounted) {
      SnackBarHelper.showSuccess(
        context,
        LocalizationService.instance.translate('analysis_complete'),
      );
    }
  }

  void _showLogsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationService.instance.translate('analysis_history')),
        content: SizedBox(
          width: double.maxFinite,
          height: TeaGardenTheme.webHomeChartHeight,
          child: ListView.builder(
            itemCount: _mockResults.length,
            itemBuilder: (context, index) {
              final result = _mockResults[index];
              final timestamp = result['timestamp'] as DateTime;
              return ListTile(
                leading:
                    const Icon(Icons.eco, color: TeaGardenTheme.successColor),
                title: Text(
                    '${result['growthStage']} - ${result['healthStatus']}'),
                subtitle: Text(
                    '${timestamp.year}/${timestamp.month}/${timestamp.day}'),
                trailing: Text('${(result['confidence'] * 100).toInt()}%'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalizationService.instance.translate('close')),
          ),
        ],
      ),
    );
  }
}
