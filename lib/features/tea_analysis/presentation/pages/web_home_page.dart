import 'package:flutter/material.dart';

/**
 * Web用の簡素化されたホームページ
 * 依存性注入を使わずに直接実装
 */
class WebHomePage extends StatefulWidget {
  const WebHomePage({super.key});

  @override
  State<WebHomePage> createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {
  bool _isLoading = false;
  final List<Map<String, dynamic>> _mockResults = [
    {
      'id': '1',
      'imagePath': '/assets/images/sample_tea_1.jpg',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'healthStatus': '健康',
      'growthStage': '成熟期',
      'confidence': 0.85,
      'comment': '健康な茶葉です。良好な成長状態を維持しています。',
    },
    {
      'id': '2',
      'imagePath': '/assets/images/sample_tea_2.jpg',
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      'healthStatus': '注意',
      'growthStage': '成長期',
      'confidence': 0.72,
      'comment': '軽度の葉枯れ病が検出されました。適切な対処が必要です。',
    },
    {
      'id': '3',
      'imagePath': '/assets/images/sample_tea_3.jpg',
      'timestamp': DateTime.now().subtract(const Duration(days: 5)),
      'healthStatus': '健康',
      'growthStage': '成熟期',
      'confidence': 0.90,
      'comment': '非常に健康な茶葉です。理想的な成長状態です。',
    },
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
            onPressed: () {
              _showLogsDialog();
            },
            tooltip: '日誌一覧',
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
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'データを読み込み中...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
            '今日の解析結果',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${todayResults.length}件の解析が完了しました',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _simulateAnalysis,
        icon: const Icon(Icons.camera_alt),
        label: const Text('茶葉を撮影・解析'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentResults() {
    if (_mockResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_camera_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'まだ解析結果がありません',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '写真を撮って茶葉を解析してみましょう',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.eco,
                  color: Colors.green,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${result['growthStage']} - ${result['healthStatus']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${timestamp.month}/${timestamp.day} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '信頼度: ${(confidence * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: healthStatus == '健康' ? Colors.green[100] : Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  healthStatus,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: healthStatus == '健康' ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
          if (result['comment'] != null) ...[
            const SizedBox(height: 8),
            Text(
              result['comment'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
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
    await Future.delayed(const Duration(seconds: 3));

    // 新しい結果を追加
    final newResult = {
      'id': (_mockResults.length + 1).toString(),
      'imagePath': '/assets/images/sample_tea_${DateTime.now().millisecondsSinceEpoch % 3 + 1}.jpg',
      'timestamp': DateTime.now(),
      'healthStatus': DateTime.now().millisecondsSinceEpoch % 10 < 2 ? '注意' : '健康',
      'growthStage': ['発芽期', '成長期', '成熟期', '収穫期'][DateTime.now().millisecondsSinceEpoch % 4],
      'confidence': 0.8 + (DateTime.now().millisecondsSinceEpoch % 20) / 100,
      'comment': '新しい解析結果です。茶葉の状態を確認しました。',
    };

    setState(() {
      _mockResults.insert(0, newResult);
      _isLoading = false;
    });

    // 成功メッセージを表示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('解析が完了しました！'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showLogsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('解析履歴'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _mockResults.length,
            itemBuilder: (context, index) {
              final result = _mockResults[index];
              final timestamp = result['timestamp'] as DateTime;
              return ListTile(
                leading: const Icon(Icons.eco, color: Colors.green),
                title: Text('${result['growthStage']} - ${result['healthStatus']}'),
                subtitle: Text('${timestamp.year}/${timestamp.month}/${timestamp.day}'),
                trailing: Text('${(result['confidence'] * 100).toInt()}%'),
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

