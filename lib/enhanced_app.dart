import 'package:flutter/material.dart';
import 'dart:convert';
import 'src/web_storage.dart';
import 'core/services/localization_service.dart';

void main() {
  runApp(const EnhancedTeaGardenApp());
}

class EnhancedTeaGardenApp extends StatelessWidget {
  const EnhancedTeaGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: LocalizationService.instance.translate('enhanced_app_title'),
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: false,
      ),
      home: const EnhancedTeaGardenHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class EnhancedTeaGardenHomePage extends StatefulWidget {
  const EnhancedTeaGardenHomePage({super.key});

  @override
  State<EnhancedTeaGardenHomePage> createState() =>
      _EnhancedTeaGardenHomePageState();
}

class _EnhancedTeaGardenHomePageState extends State<EnhancedTeaGardenHomePage>
    with TickerProviderStateMixin {
  int _analysisCount = 0;
  bool _isAnalyzing = false;
  final List<Map<String, dynamic>> _results = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    // ローカルストレージからデータを読み込み
    final savedData = getLocalStorage('teaGardenData');
    if (savedData != null) {
      final data = jsonDecode(savedData);
      setState(() {
        _analysisCount = data['analysisCount'] ?? 0;
        _results.clear();
        _results.addAll(
            (data['analysisResults'] as List).cast<Map<String, dynamic>>());
      });
    }
  }

  void _saveData() {
    // データをローカルストレージに保存
    final data = {
      'analysisCount': _analysisCount,
      'analysisResults': _results,
    };
    setLocalStorage('teaGardenData', jsonEncode(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title:
            Text(LocalizationService.instance.translate('enhanced_app_title')),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          onTap: (index) {
            // Tab selection handled by TabController
          },
          tabs: [
            Tab(
                icon: const Icon(Icons.dashboard),
                text: LocalizationService.instance.translate('dashboard')),
            Tab(
                icon: const Icon(Icons.camera_alt),
                text: LocalizationService.instance.translate('analysis')),
            Tab(
                icon: const Icon(Icons.bar_chart),
                text: LocalizationService.instance.translate('charts')),
            Tab(
                icon: const Icon(Icons.download),
                text: LocalizationService.instance.translate('export')),
            Tab(
                icon: const Icon(Icons.settings),
                text: LocalizationService.instance.translate('settings')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildAnalysisTab(),
          _buildChartsTab(),
          _buildExportTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildStatsGrid(),
          const SizedBox(height: 20),
          _buildRecentResultsCard(),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAnalysisCard(),
          const SizedBox(height: 20),
          _buildAllResultsCard(),
        ],
      ),
    );
  }

  Widget _buildChartsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHealthChartCard(),
          const SizedBox(height: 20),
          _buildGrowthChartCard(),
        ],
      ),
    );
  }

  Widget _buildExportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildExportCard(),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSettingsCard(),
        ],
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
        child: Column(
          children: [
            const Icon(Icons.eco, size: 50, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              LocalizationService.instance.translate('enhanced_app_title'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              LocalizationService.instance.translate('welcome_message'),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final healthyCount =
        _results.where((r) => r['healthStatus'] == '健康').length;
    final healthRate = _results.isNotEmpty
        ? (healthyCount / _results.length * 100).round()
        : 0;
    final today = DateTime.now();
    final todayCount = _results.where((r) {
      final timestamp = DateTime.parse(r['timestamp']);
      return timestamp.year == today.year &&
          timestamp.month == today.month &&
          timestamp.day == today.day;
    }).length;
    final avgConfidence = _results.isNotEmpty
        ? (_results
                    .map((r) => r['confidence'] as double)
                    .reduce((a, b) => a + b) /
                _results.length *
                100)
            .round()
        : 0;

    return Row(
      children: [
        Expanded(
            child: _buildStatCard(
                LocalizationService.instance.translate('total_analysis_count'),
                '$_analysisCount',
                Icons.analytics)),
        Expanded(
            child: _buildStatCard(
                LocalizationService.instance.translate('health_rate'),
                '$healthRate%',
                Icons.favorite)),
        Expanded(
            child: _buildStatCard(
                LocalizationService.instance.translate('today_analysis'),
                '$todayCount',
                Icons.today)),
        Expanded(
            child: _buildStatCard(
                LocalizationService.instance.translate('avg_confidence'),
                '$avgConfidence%',
                Icons.trending_up)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
        ),
      ),
    );
  }

  Widget _buildAnalysisCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              LocalizationService.instance.translate('tea_analysis'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_isAnalyzing)
              Column(
                children: [
                  const CircularProgressIndicator(color: Colors.green),
                  const SizedBox(height: 16),
                  Text(LocalizationService.instance.translate('ai_analyzing')),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: _startAnalysis,
                icon: const Icon(Icons.camera_alt),
                label:
                    Text(LocalizationService.instance.translate('take_photo')),
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

  Widget _buildRecentResultsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.translate('recent_results'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_results.isEmpty)
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.photo_camera_outlined,
                        size: 50, color: Colors.grey),
                    const SizedBox(height: 10),
                    Text(LocalizationService.instance
                        .translate('no_results_yet')),
                  ],
                ),
              )
            else
              ...(_results.take(5).map((result) => _buildResultItem(result))),
          ],
        ),
      ),
    );
  }

  Widget _buildAllResultsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.translate('analysis_history'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_results.isEmpty)
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.photo_camera_outlined,
                        size: 50, color: Colors.grey),
                    const SizedBox(height: 10),
                    Text(LocalizationService.instance
                        .translate('no_results_yet')),
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
            color: result['healthStatus'] ==
                    LocalizationService.instance.translate('healthy')
                ? Colors.green
                : Colors.orange,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: result['healthStatus'] ==
                                LocalizationService.instance
                                    .translate('healthy')
                            ? Colors.green[100]
                            : Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        result['healthStatus'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: result['healthStatus'] ==
                                  LocalizationService.instance
                                      .translate('healthy')
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${result['timestamp']} | 信頼度: ${((result['confidence'] as double) * 100).round()}%',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  result['comment'],
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _editResult(result),
                color: Colors.blue,
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () => _deleteResult(result),
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthChartCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance
                  .translate('health_status_distribution'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildHealthChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthChartCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance
                  .translate('growth_stage_distribution'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildGrowthChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthChart() {
    if (_results.isEmpty) {
      return Center(
        child: Text(LocalizationService.instance.translate('no_data')),
      );
    }

    final last7Days = _results.take(7).toList().reversed.toList();
    return CustomPaint(
      painter: HealthChartPainter(last7Days),
      size: const Size(double.infinity, 200),
    );
  }

  Widget _buildGrowthChart() {
    if (_results.isEmpty) {
      return Center(
        child: Text(LocalizationService.instance.translate('no_data')),
      );
    }

    final stageCounts = <String, int>{};
    for (final result in _results) {
      final stage = result['growthStage'] as String;
      stageCounts[stage] = (stageCounts[stage] ?? 0) + 1;
    }

    return CustomPaint(
      painter: GrowthChartPainter(stageCounts),
      size: const Size(double.infinity, 200),
    );
  }

  Widget _buildExportCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.translate('export'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(LocalizationService.instance
                .translate('export_data_description')),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _exportToCSV,
                  icon: const Icon(Icons.table_chart),
                  label: Text(LocalizationService.instance.translate('csv')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _exportToJSON,
                  icon: const Icon(Icons.code),
                  label: Text(LocalizationService.instance.translate('json')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _exportToPDF,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(LocalizationService.instance.translate('pdf')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.translate('app_settings'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(LocalizationService.instance.translate('retention_period')),
            Slider(
              value: 30.0,
              min: 1,
              max: 365,
              divisions: 364,
              label: '30${LocalizationService.instance.translate('days')}',
              onChanged: (value) {
                // 設定保存処理
              },
            ),
            const SizedBox(height: 16),
            Text(LocalizationService.instance
                .translate('auto_analysis_interval')),
            Slider(
              value: 60.0,
              min: 5,
              max: 1440,
              divisions: 287,
              label: '60${LocalizationService.instance.translate('minutes')}',
              onChanged: (value) {
                // 設定保存処理
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child:
                  Text(LocalizationService.instance.translate('save_settings')),
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

    await Future.delayed(const Duration(seconds: 3));

    final growthStages = [
      LocalizationService.instance.translate('sprouting_period'),
      LocalizationService.instance.translate('growth_period'),
      LocalizationService.instance.translate('maturity_period'),
      LocalizationService.instance.translate('harvest_period')
    ];
    final result = {
      'growthStage': growthStages[DateTime.now().millisecondsSinceEpoch % 4],
      'healthStatus': DateTime.now().millisecondsSinceEpoch % 10 < 2
          ? LocalizationService.instance.translate('attention')
          : LocalizationService.instance.translate('healthy'),
      'confidence': (75 + (DateTime.now().millisecondsSinceEpoch % 25)) / 100.0,
      'timestamp': DateTime.now().toString().substring(0, 19),
      'comment':
          LocalizationService.instance.translate('new_analysis_completed'),
    };

    if (!mounted) {
      return; // <- important: avoid using context if widget disposed
    }

    setState(() {
      _results.insert(0, result);
      _analysisCount++;
      _isAnalyzing = false;
    });

    _saveData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(LocalizationService.instance.translate('analysis_complete')),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editResult(Map<String, dynamic> result) {
    // 編集ダイアログを表示
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationService.instance.translate('edit_result')),
        content: Text(
            LocalizationService.instance.translate('edit_feature_coming_soon')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalizationService.instance.translate('close')),
          ),
        ],
      ),
    );
  }

  void _deleteResult(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(LocalizationService.instance.translate('delete_confirmation')),
        content: Text(LocalizationService.instance
            .translate('delete_result_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalizationService.instance.translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _results.remove(result);
              });
              _saveData();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(LocalizationService.instance
                      .translate('analysis_result_deleted')),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text(LocalizationService.instance.translate('delete')),
          ),
        ],
      ),
    );
  }

  void _exportToCSV() {
    if (_results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(LocalizationService.instance.translate('no_export_data')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final csvContent = [
      '${LocalizationService.instance.translate('date_time')},${LocalizationService.instance.translate('growth_stage')},${LocalizationService.instance.translate('health_status')},${LocalizationService.instance.translate('confidence')},${LocalizationService.instance.translate('comment')}',
      ..._results.map((r) =>
          '${r['timestamp']},${r['growthStage']},${r['healthStatus']},${((r['confidence'] as double) * 100).round()}%,${r['comment']}')
    ].join('\n');

    _downloadFile(csvContent, 'tea_analysis_results.csv', 'text/csv');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocalizationService.instance.translate('csv_exported')),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportToJSON() {
    if (_results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(LocalizationService.instance.translate('no_export_data')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final jsonContent = jsonEncode(_results);
    _downloadFile(jsonContent, 'tea_analysis_results.json', 'application/json');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocalizationService.instance.translate('json_exported')),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportToPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(LocalizationService.instance.translate('pdf_coming_soon')),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocalizationService.instance.translate('settings_saved')),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _downloadFile(String content, String filename, String mimeType) {
    downloadFile(content, filename, mimeType);
  }
}

// チャート描画用のカスタムペインター
class HealthChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  HealthChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final isHealthy = data[i]['healthStatus'] ==
          LocalizationService.instance.translate('healthy');
      final y = size.height - (isHealthy ? 20.0 : size.height - 20);
      final x = i * stepX;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GrowthChartPainter extends CustomPainter {
  final Map<String, int> data;

  GrowthChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final total = data.values.reduce((a, b) => a + b);
    final colors = [Colors.green, Colors.blue, Colors.orange, Colors.red];

    double startAngle = 0;
    int colorIndex = 0;

    for (final entry in data.entries) {
      final sweepAngle = (entry.value / total) * 2 * 3.14159;

      final paint = Paint()
        ..color = colors[colorIndex % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: size.width * 0.8,
          height: size.height * 0.8,
        ),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
      colorIndex++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
