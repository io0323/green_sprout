import 'package:flutter/material.dart';

void main() {
  runApp(const TeaGardenApp());
}

class TeaGardenApp extends StatelessWidget {
  const TeaGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '茶園管理AI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: false,
      ),
      home: const TeaGardenHomePage(),
      debugShowCheckedModeBanner: false,
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
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('茶園管理AI'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            _buildStatsCard(),
            const SizedBox(height: 20),
            _buildAnalysisCard(),
            const SizedBox(height: 20),
            _buildResultsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.green[400]!, Colors.green[600]!],
          ),
        ),
        child: const Column(
          children: [
            Icon(Icons.eco, size: 50, color: Colors.white),
            SizedBox(height: 10),
            Text(
              '茶園管理AI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'AI技術で茶葉の健康状態を分析',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem('解析回数', '$_analysisCount', Icons.analytics),
            ),
            Expanded(
              child: _buildStatItem('健康率', '${_getHealthRate()}%', Icons.favorite),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.green, size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '茶葉解析',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_isAnalyzing)
              const Column(
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text('AIが茶葉を解析中...'),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: _startAnalysis,
                icon: const Icon(Icons.camera_alt),
                label: const Text('茶葉を撮影・解析'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
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

  Widget _buildResultsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '最近の解析結果',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_results.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.photo_camera_outlined, size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    Text('まだ解析結果がありません'),
                  ],
                ),
              )
            else
              ...(_results.map((result) => _buildResultItem(result))),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(Map<String, dynamic> result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: result['healthStatus'] == '健康' ? Colors.green : Colors.orange,
            width: 4,
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
                  color: result['healthStatus'] == '健康' 
                      ? Colors.green[100] 
                      : Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  result['healthStatus'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: result['healthStatus'] == '健康' 
                        ? Colors.green[700] 
                        : Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${result['timestamp']} | 信頼度: ${result['confidence']}%',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            result['comment'],
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  int _getHealthRate() {
    if (_results.isEmpty) return 0;
    final healthyCount = _results.where((r) => r['healthStatus'] == '健康').length;
    return ((healthyCount / _results.length) * 100).round();
  }

  void _startAnalysis() async {
    setState(() {
      _isAnalyzing = true;
    });

    await Future.delayed(const Duration(seconds: 3));

    final result = {
      'growthStage': ['発芽期', '成長期', '成熟期', '収穫期'][DateTime.now().millisecondsSinceEpoch % 4],
      'healthStatus': DateTime.now().millisecondsSinceEpoch % 10 < 2 ? '注意' : '健康',
      'confidence': (75 + (DateTime.now().millisecondsSinceEpoch % 25)).toString(),
      'timestamp': DateTime.now().toString().substring(0, 19),
      'comment': '新しい解析が完了しました。茶葉の状態を確認しました。',
    };

    setState(() {
      _results.insert(0, result);
      _analysisCount++;
      _isAnalyzing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('解析が完了しました！'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
