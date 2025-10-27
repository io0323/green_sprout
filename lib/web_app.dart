import 'package:flutter/material.dart';

void main() {
  runApp(const TeaGardenWebApp());
}

/// 茶園管理AI - Web専用アプリ
/// 依存性注入やBLoCを使わないシンプルな実装
class TeaGardenWebApp extends StatelessWidget {
  const TeaGardenWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '茶園管理AI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const TeaGardenHomePage(),
      debugShowCheckedModeBanner: false,
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
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      healthStatus: '健康',
      growthStage: '成熟期',
      confidence: 0.92,
      comment: '茶葉の状態は良好です。適切な成長を維持しています。',
    ),
    TeaAnalysisResult(
      id: '2',
      imagePath: 'assets/sample_tea_2.jpg',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      healthStatus: '注意',
      growthStage: '成長期',
      confidence: 0.78,
      comment: '軽度の葉枯れ病の兆候が確認されました。',
    ),
    TeaAnalysisResult(
      id: '3',
      imagePath: 'assets/sample_tea_3.jpg',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      healthStatus: '健康',
      growthStage: '成熟期',
      confidence: 0.88,
      comment: '非常に健康な茶葉です。理想的な状態を保っています。',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '茶園管理AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: _showAnalysisHistory,
            tooltip: '解析履歴',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.white,
            ],
          ),
        ),
        child: _isAnalyzing ? _buildAnalyzingView() : _buildMainContent(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isAnalyzing ? null : _startAnalysis,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.camera_alt),
        label: const Text('茶葉を解析'),
      ),
    );
  }

  Widget _buildAnalyzingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            strokeWidth: 3,
          ),
          SizedBox(height: 24),
          Text(
            '茶葉を解析中...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'AIが茶葉の状態を分析しています',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.green[400]!, Colors.green[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.eco,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '茶園管理AIへようこそ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI技術で茶葉の健康状態を分析',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.today,
                  color: Colors.green[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '今日の解析結果',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
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
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    '健康率',
                    todayResults.isNotEmpty
                        ? '${((todayResults.where((r) => r.healthStatus == '健康').length / todayResults.length) * 100).toInt()}%'
                        : '0%',
                    Icons.favorite,
                    Colors.red,
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
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
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
            color: Colors.grey[800],
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.photo_camera_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'まだ解析結果がありません',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '茶葉を撮影してAI解析を開始しましょう',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(TeaAnalysisResult result) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: result.healthStatus == '健康'
                    ? Colors.green[100]
                    : Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.eco,
                color: result.healthStatus == '健康'
                    ? Colors.green[600]
                    : Colors.orange[600],
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
                    '${result.timestamp.month}/${result.timestamp.day} ${result.timestamp.hour}:${result.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '信頼度: ${(result.confidence * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: result.healthStatus == '健康'
                    ? Colors.green[100]
                    : Colors.orange[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                result.healthStatus,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: result.healthStatus == '健康'
                      ? Colors.green[700]
                      : Colors.orange[700],
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
    await Future.delayed(const Duration(seconds: 3));

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('解析が完了しました！'),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
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
                      ? Colors.green
                      : Colors.orange,
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
