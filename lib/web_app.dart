import 'package:flutter/material.dart';
import 'core/theme/tea_garden_theme.dart';
import 'core/utils/app_initialization.dart';
import 'core/widgets/common_cards.dart';
import 'core/widgets/snackbar_helper.dart';
import 'core/utils/app_utils.dart';
import 'core/constants/app_constants.dart';

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

    runApp(const TeaGardenWebApp());
  });
}

/// 茶園管理AI - Web専用アプリ
/// 依存性注入やBLoCを使わないシンプルな実装
class TeaGardenWebApp extends StatelessWidget {
  const TeaGardenWebApp({super.key});

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

/// メインホームページ
/// 茶葉解析の機能を提供
class TeaGardenHomePage extends StatefulWidget {
  const TeaGardenHomePage({super.key});

  @override
  State<TeaGardenHomePage> createState() => _TeaGardenHomePageState();
}

class _TeaGardenHomePageState extends State<TeaGardenHomePage> {
  bool _isAnalyzing = false;
  final List<TeaAnalysisResult> _analysisResults = [
    TeaAnalysisResult(
      id: '1',
      imagePath: 'assets/sample_tea_1.jpg',
      timestamp:
          DateTime.now().subtract(const Duration(days: AppConstants.daysOne)),
      healthStatus: '健康',
      growthStage: '成熟期',
      confidence: 0.92,
      comment: '茶葉の状態は良好です。適切な成長を維持しています。',
    ),
    TeaAnalysisResult(
      id: '2',
      imagePath: 'assets/sample_tea_2.jpg',
      timestamp:
          DateTime.now().subtract(const Duration(days: AppConstants.daysThree)),
      healthStatus: '注意',
      growthStage: '成長期',
      confidence: 0.78,
      comment: '軽度の葉枯れ病の兆候が確認されました。',
    ),
    TeaAnalysisResult(
      id: '3',
      imagePath: 'assets/sample_tea_3.jpg',
      timestamp:
          DateTime.now().subtract(const Duration(days: AppConstants.daysFive)),
      healthStatus: '健康',
      growthStage: '成熟期',
      confidence: 0.88,
      comment: '非常に健康な茶葉です。理想的な状態を保っています。',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '茶園管理AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: colorScheme.onPrimary),
            onPressed: _showAnalysisHistory,
            tooltip: '解析履歴',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: TeaGardenTheme.backgroundGradient,
        ),
        child: _isAnalyzing ? _buildAnalyzingView() : _buildMainContent(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isAnalyzing ? null : _startAnalysis,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.camera_alt),
        label: const Text('茶葉を解析'),
      ),
    );
  }

  Widget _buildAnalyzingView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            '茶葉を解析中...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AIが茶葉の状態を分析しています',
            style: TextStyle(
              fontSize: 14,
              color:
                  colorScheme.onSurface.withOpacity(TeaGardenTheme.opacityHigh),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          _buildTodaySummary(),
          const SizedBox(height: 24),
          _buildRecentAnalysis(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: TeaGardenTheme.elevationHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TeaGardenTheme.borderRadiusLarge),
      ),
      child: Container(
        padding: const EdgeInsets.all(TeaGardenTheme.spacingL),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TeaGardenTheme.borderRadiusLarge),
          gradient: TeaGardenTheme.primaryGradient,
        ),
        child: Row(
          children: [
            Icon(
              Icons.eco,
              size: 48,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '茶園管理AIへようこそ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI技術で茶葉の健康状態を分析',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withOpacity(TeaGardenTheme.opacityAlmostOpaque),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummary() {
    final todayResults = _analysisResults.where((result) {
      final now = DateTime.now();
      return result.timestamp.year == now.year &&
          result.timestamp.month == now.month &&
          result.timestamp.day == now.day;
    }).toList();

    return Card(
      elevation: TeaGardenTheme.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TeaGardenTheme.borderRadiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TeaGardenTheme.spacingML),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.today,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '今日の解析結果',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    '解析回数',
                    '${todayResults.length}回',
                    Icons.analytics,
                    TeaGardenTheme.infoColor,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    '健康率',
                    todayResults.isNotEmpty
                        ? '${((todayResults.where((r) => r.healthStatus == '健康').length / todayResults.length) * 100).toInt()}%'
                        : '0%',
                    Icons.favorite,
                    TeaGardenTheme.successColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, IconData icon, Color color) {
    return StatItem(
      label: label,
      value: value,
      icon: icon,
      color: color,
    );
  }

  Widget _buildRecentAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最近の解析結果',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...(_analysisResults.isEmpty
            ? [_buildEmptyState()]
            : _analysisResults.map((result) => _buildAnalysisCard(result))),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Card(
      elevation: TeaGardenTheme.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
            Radius.circular(TeaGardenTheme.borderRadiusMedium)),
      ),
      child: Padding(
        padding: EdgeInsets.all(TeaGardenTheme.spacingXL),
        child: EmptyStateWidget(
          icon: Icons.photo_camera_outlined,
          iconSize: 64,
          subtitle: '茶葉を撮影してAI解析を開始しましょう',
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(TeaAnalysisResult result) {
    return Card(
      elevation: TeaGardenTheme.elevationLow,
      margin: const EdgeInsets.only(bottom: TeaGardenTheme.spacingSM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TeaGardenTheme.borderRadiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: result.healthStatus == '健康'
                    ? TeaGardenTheme.successColor.withOpacity(0.1)
                    : TeaGardenTheme.warningColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(TeaGardenTheme.borderRadiusSmall),
              ),
              child: Icon(
                Icons.eco,
                color: result.healthStatus == '健康'
                    ? TeaGardenTheme.successColor
                    : TeaGardenTheme.warningColor,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${result.growthStage} - ${result.healthStatus}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppUtils.formatAbsoluteTime(result.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(TeaGardenTheme.opacityHigh),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '信頼度: ${(result.confidence * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(TeaGardenTheme.opacityHigh),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: TeaGardenTheme.spacingSM,
                  vertical: TeaGardenTheme.spacingS),
              decoration: BoxDecoration(
                color: result.healthStatus == '健康'
                    ? TeaGardenTheme.successColor.withOpacity(0.1)
                    : TeaGardenTheme.warningColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(TeaGardenTheme.borderRadiusLarge),
              ),
              child: Text(
                result.healthStatus,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: result.healthStatus == '健康'
                      ? TeaGardenTheme.successColor
                      : TeaGardenTheme.warningColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startAnalysis() async {
    setState(() {
      _isAnalyzing = true;
    });

    // 解析処理をシミュレート
    await Future.delayed(AnimationConstants.threeSeconds);

    // 新しい解析結果を追加
    final newResult = TeaAnalysisResult(
      id: (_analysisResults.length + 1).toString(),
      imagePath:
          'assets/sample_tea_${DateTime.now().millisecondsSinceEpoch % 3 + 1}.jpg',
      timestamp: DateTime.now(),
      healthStatus:
          DateTime.now().millisecondsSinceEpoch % 10 < 2 ? '注意' : '健康',
      growthStage: [
        '発芽期',
        '成長期',
        '成熟期',
        '収穫期'
      ][DateTime.now().millisecondsSinceEpoch % 4],
      confidence: 0.8 + (DateTime.now().millisecondsSinceEpoch % 20) / 100,
      comment: '新しい解析が完了しました。茶葉の状態を確認しました。',
    );

    setState(() {
      _analysisResults.insert(0, newResult);
      _isAnalyzing = false;
    });

    // 成功メッセージを表示
    if (mounted) {
      SnackBarHelper.showSuccess(context, '解析が完了しました！');
    }
  }

  void _showAnalysisHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('解析履歴'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _analysisResults.length,
            itemBuilder: (context, index) {
              final result = _analysisResults[index];
              return ListTile(
                leading: Icon(
                  Icons.eco,
                  color: result.healthStatus == '健康'
                      ? TeaGardenTheme.successColor
                      : TeaGardenTheme.warningColor,
                ),
                title: Text('${result.growthStage} - ${result.healthStatus}'),
                subtitle: Text(
                    '${result.timestamp.year}/${result.timestamp.month}/${result.timestamp.day}'),
                trailing: Text('${(result.confidence * 100).toInt()}%'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}

/// 茶葉解析結果のデータクラス
class TeaAnalysisResult {
  final String id;
  final String imagePath;
  final DateTime timestamp;
  final String healthStatus;
  final String growthStage;
  final double confidence;
  final String comment;

  TeaAnalysisResult({
    required this.id,
    required this.imagePath,
    required this.timestamp,
    required this.healthStatus,
    required this.growthStage,
    required this.confidence,
    required this.comment,
  });
}
