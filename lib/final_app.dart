import 'package:flutter/material.dart';
import 'core/theme/tea_garden_theme.dart';
import 'core/utils/app_initialization.dart';
import 'core/widgets/common_cards.dart';
import 'core/widgets/snackbar_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // グローバルエラーハンドラーの設定
  AppInitialization.setupGlobalErrorHandler();

  // 非同期エラーハンドラーの設定とアプリ実行
  await AppInitialization.runWithErrorHandling(() async {
    // 国際化サービスの初期化
    await AppInitialization.initializeLocalization();

    // エラーワジェットの設定（コンストラクタをconstにするためmainに移動）
    AppInitialization.setupErrorWidget();

    runApp(const TeaGardenApp());
  });
}

class TeaGardenApp extends StatelessWidget {
  const TeaGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appDefaults = AppInitialization.getMaterialAppDefaults();
    return MaterialApp(
      title: '茶園管理AI',
      theme: appDefaults.theme,
      darkTheme: appDefaults.darkTheme,
      themeMode: appDefaults.themeMode,
      localizationsDelegates: appDefaults.localizationsDelegates,
      supportedLocales: appDefaults.supportedLocales,
      debugShowCheckedModeBanner: appDefaults.debugShowCheckedModeBanner,
      onGenerateRoute: appDefaults.onGenerateRoute,
      home: const TeaGardenHomePage(),
    );
  }
}

class TeaGardenHomePage extends StatefulWidget {
  const TeaGardenHomePage({super.key});

  @override
  State<TeaGardenHomePage> createState() => _TeaGardenHomePageState();
}

class _TeaGardenHomePageState extends State<TeaGardenHomePage> {
  int _analysisCount = 0;
  bool _isAnalyzing = false;
  final List<Map<String, dynamic>> _results = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('茶園管理AI'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
        child: Column(
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: TeaGardenTheme.spacingML),
            _buildStatsCard(),
            const SizedBox(height: TeaGardenTheme.spacingML),
            _buildAnalysisCard(),
            const SizedBox(height: TeaGardenTheme.spacingML),
            _buildResultsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return const WelcomeCard();
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: TeaGardenTheme.elevationLow,
      child: Padding(
        padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
        child: Row(
          children: [
            Expanded(
              child: StatItem(
                label: '解析回数',
                value: '$_analysisCount',
                icon: Icons.analytics,
              ),
            ),
            Expanded(
              child: StatItem(
                label: '健康率',
                value: '${_getHealthRate()}%',
                icon: Icons.favorite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard() {
    return AnalysisCard(
      isAnalyzing: _isAnalyzing,
      onAnalyze: _startAnalysis,
      analyzingText: 'AIが茶葉を解析中...',
      buttonText: '茶葉を撮影・解析',
    );
  }

  Widget _buildResultsCard() {
    return Card(
      elevation: TeaGardenTheme.elevationLow,
      child: Padding(
        padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '最近の解析結果',
              style: TextStyle(
                fontSize: TeaGardenTheme.heading3.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: TeaGardenTheme.spacingM),
            if (_results.isEmpty)
              const EmptyStateWidget()
            else
              ...(_results.map((result) => _buildResultItem(result))),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(Map<String, dynamic> result) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isHealthy = result['healthStatus'] == '健康';
    return Container(
      margin: const EdgeInsets.only(bottom: TeaGardenTheme.spacingS),
      padding: const EdgeInsets.all(TeaGardenTheme.spacingSM),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(TeaGardenTheme.borderRadiusSmall),
        border: Border(
          left: BorderSide(
            color: isHealthy
                ? TeaGardenTheme.successColor
                : TeaGardenTheme.warningColor,
            width: TeaGardenTheme.borderWidthThick,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${result['growthStage']} - ${result['healthStatus']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isHealthy
                      ? TeaGardenTheme.successColor
                          .withOpacity(TeaGardenTheme.opacityVeryLow)
                      : TeaGardenTheme.warningColor
                          .withOpacity(TeaGardenTheme.opacityVeryLow),
                  borderRadius:
                      BorderRadius.circular(TeaGardenTheme.borderRadiusMedium),
                ),
                child: Text(
                  result['healthStatus'],
                  style: TextStyle(
                    fontSize: TeaGardenTheme.bodySmall.fontSize,
                    fontWeight: FontWeight.bold,
                    color: isHealthy
                        ? TeaGardenTheme.successColor
                        : TeaGardenTheme.warningColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TeaGardenTheme.spacingXS),
          Text(
            '${result['timestamp']} | 信頼度: ${result['confidence']}%',
            style: TextStyle(
              fontSize: TeaGardenTheme.bodySmall.fontSize,
              color:
                  colorScheme.onSurface.withOpacity(TeaGardenTheme.opacityHigh),
            ),
          ),
          const SizedBox(height: TeaGardenTheme.spacingXS),
          Text(
            result['comment'],
            style: TextStyle(fontSize: TeaGardenTheme.bodyMedium.fontSize),
          ),
        ],
      ),
    );
  }

  int _getHealthRate() {
    if (_results.isEmpty) return 0;
    final healthyCount =
        _results.where((r) => r['healthStatus'] == '健康').length;
    return ((healthyCount / _results.length) * 100).round();
  }

  void _startAnalysis() async {
    setState(() {
      _isAnalyzing = true;
    });

    await Future.delayed(AnimationConstants.threeSeconds);

    final result = {
      'growthStage': [
        '発芽期',
        '成長期',
        '成熟期',
        '収穫期'
      ][DateTime.now().millisecondsSinceEpoch % 4],
      'healthStatus':
          DateTime.now().millisecondsSinceEpoch % 10 < 2 ? '注意' : '健康',
      'confidence':
          (75 + (DateTime.now().millisecondsSinceEpoch % 25)).toString(),
      'timestamp': DateTime.now().toString().substring(0, 19),
      'comment': '新しい解析が完了しました。茶葉の状態を確認しました。',
    };

    setState(() {
      _results.insert(0, result);
      _analysisCount++;
      _isAnalyzing = false;
    });

    if (mounted) {
      SnackBarHelper.showSuccess(context, '解析が完了しました！');
    }
  }
}
