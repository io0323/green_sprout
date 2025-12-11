import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'src/web_storage.dart';
import 'core/services/localization_service.dart';
import 'core/widgets/language_selector.dart';
import 'core/utils/app_initialization.dart';
import 'core/di/injection_container.dart' as di;
import 'features/cloud_sync/presentation/bloc/cloud_sync_cubit.dart';
import 'core/theme/tea_garden_theme.dart';
import 'core/widgets/common_cards.dart';
import 'core/widgets/snackbar_helper.dart';
import 'core/utils/app_logger.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/app_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // グローバルエラーハンドラーの設定
  AppInitialization.setupGlobalErrorHandler();

  // 非同期エラーハンドラーの設定とアプリ実行
  await AppInitialization.runWithErrorHandling(() async {
    // 国際化サービスの初期化
    await AppInitialization.initializeLocalization();

    // DIコンテナの初期化
    await AppInitialization.initializeDependencyInjection();

    // エラーワジェットの設定（コンストラクタをconstにするためmainに移動）
    AppInitialization.setupErrorWidget();

    runApp(const EnhancedTeaGardenApp());
  });
}

class EnhancedTeaGardenApp extends StatefulWidget {
  const EnhancedTeaGardenApp({super.key});

  @override
  State<EnhancedTeaGardenApp> createState() => _EnhancedTeaGardenAppState();
}

class _EnhancedTeaGardenAppState extends State<EnhancedTeaGardenApp> {
  void _updateLanguage() {
    setState(() {
      // 言語変更時にアプリを再構築
    });
  }

  @override
  Widget build(BuildContext context) {
    final appDefaults = AppInitialization.getMaterialAppDefaults();
    return MaterialApp(
      title: LocalizationService.instance.translate('enhanced_app_title'),
      theme: appDefaults.theme,
      darkTheme: appDefaults.darkTheme,
      themeMode: appDefaults.themeMode,
      localizationsDelegates: appDefaults.localizationsDelegates,
      supportedLocales: appDefaults.supportedLocales,
      debugShowCheckedModeBanner: appDefaults.debugShowCheckedModeBanner,
      home: FutureBuilder(
        future: di.sl.getAsync<CloudSyncCubit>(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return BlocProvider<CloudSyncCubit>.value(
              value: snapshot.data!,
              child: EnhancedTeaGardenHomePage(
                onLanguageChanged: _updateLanguage,
              ),
            );
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}

class EnhancedTeaGardenHomePage extends StatefulWidget {
  final VoidCallback? onLanguageChanged;

  const EnhancedTeaGardenHomePage({super.key, this.onLanguageChanged});

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

  // 設定値
  double _retentionPeriod = 30.0; // データ保持期間（日数）
  double _autoAnalysisInterval = 60.0; // 自動解析間隔（分）

  // 検索・フィルター
  final TextEditingController _searchController = TextEditingController();
  String? _selectedGrowthStageFilter;
  String? _selectedHealthStatusFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
    // CloudSyncCubitの初期化はBlocProvider経由で行われるため、
    // ここでは何もしない（Cubitの初期化時に自動的に接続確認と自動同期状態の読み込みが行われる）
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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

    // 設定値を読み込み
    _loadSettings();
  }

  /// 設定値を読み込み
  void _loadSettings() {
    final settingsData = getLocalStorage('teaGardenSettings');
    if (settingsData != null) {
      final settings = jsonDecode(settingsData);
      setState(() {
        _retentionPeriod = (settings['retentionPeriod'] ?? 30.0).toDouble();
        _autoAnalysisInterval =
            (settings['autoAnalysisInterval'] ?? 60.0).toDouble();
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title:
            Text(LocalizationService.instance.translate('enhanced_app_title')),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          LanguageSelector(onLanguageChanged: widget.onLanguageChanged),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.onPrimary,
          labelColor: colorScheme.onPrimary,
          unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.7),
          onTap: (index) {
            // Tab selection handled by TabController
          },
          tabs: [
            Tab(
                icon:
                    const Icon(Icons.dashboard, key: Key('tab_dashboard_icon')),
                text: LocalizationService.instance.translate('dashboard')),
            Tab(
                icon: const Icon(Icons.camera_alt, key: Key('tab_camera_icon')),
                text: LocalizationService.instance.translate('analysis')),
            Tab(
                icon: const Icon(Icons.bar_chart, key: Key('tab_charts_icon')),
                text: LocalizationService.instance.translate('charts')),
            Tab(
                icon: const Icon(Icons.download, key: Key('tab_export_icon')),
                text: LocalizationService.instance.translate('export')),
            Tab(
                icon: const Icon(Icons.settings, key: Key('tab_settings_icon')),
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
      padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
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
      padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
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
      padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
      child: Column(
        children: [
          _buildTimeSeriesChartCard(),
          const SizedBox(height: 20),
          _buildHealthChartCard(),
          const SizedBox(height: 20),
          _buildGrowthChartCard(),
          const SizedBox(height: 20),
          _buildConfidenceChartCard(),
        ],
      ),
    );
  }

  Widget _buildExportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
      child: Column(
        children: [
          _buildExportCard(),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
      child: Column(
        children: [
          _buildLanguageSettingsCard(),
          const SizedBox(height: 16),
          _buildSettingsCard(),
          const SizedBox(height: 16),
          _buildCloudSyncCard(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return WelcomeCard(
      title: LocalizationService.instance.translate('enhanced_app_title'),
      subtitle: LocalizationService.instance.translate('welcome_message'),
    );
  }

  Widget _buildStatsGrid() {
    final healthyStatus = LocalizationService.instance.translate('healthy');
    final healthyCount =
        _results.where((r) => r['healthStatus'] == healthyStatus).length;
    final healthRate = _results.isNotEmpty
        ? (healthyCount / _results.length * 100).round()
        : 0;
    final today = DateTime.now();
    final todayCount = _results.where((r) {
      final timestampStr = r['timestamp'] as String?;
      if (timestampStr == null) return false;
      try {
        final timestamp = DateTime.parse(timestampStr);
        return timestamp.year == today.year &&
            timestamp.month == today.month &&
            timestamp.day == today.day;
      } catch (e, stackTrace) {
        AppLogger.logErrorWithStackTrace(
          '日付パースエラー（今日の解析数計算）',
          e,
          stackTrace,
        );
        return false;
      }
    }).length;
    final avgConfidence = _results.isNotEmpty
        ? (_results
                    .map((r) => (r['confidence'] as double?) ?? 0.0)
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
    return StatCard(
      label: label,
      value: value,
      icon: icon,
    );
  }

  Widget _buildAnalysisCard() {
    return AnalysisCard(
      isAnalyzing: _isAnalyzing,
      onAnalyze: _startAnalysis,
      buttonKey: const Key('btn_take_photo'),
    );
  }

  Widget _buildRecentResultsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.translate('recent_results'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_results.isEmpty)
              const EmptyStateWidget()
            else
              ...(_results.take(5).map((result) => _buildResultItem(result))),
          ],
        ),
      ),
    );
  }

  Widget _buildAllResultsCard() {
    final filteredResults = _getFilteredResults();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocalizationService.instance.translate('analysis_history'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_hasActiveFilters())
                  TextButton.icon(
                    onPressed: _resetFilters,
                    icon: const Icon(Icons.clear, size: 16),
                    label: Text(
                        LocalizationService.instance.translate('reset_filter')),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // 検索バー
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: LocalizationService.instance.translate('search_hint'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            // フィルター
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGrowthStageFilter,
                    decoration: InputDecoration(
                      labelText: LocalizationService.instance
                          .translate('growth_stage'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child:
                            Text(LocalizationService.instance.translate('all')),
                      ),
                      ...[
                        LocalizationService.instance
                            .translate('sprouting_period'),
                        LocalizationService.instance.translate('growth_period'),
                        LocalizationService.instance
                            .translate('maturity_period'),
                        LocalizationService.instance
                            .translate('harvest_period'),
                      ].map((stage) => DropdownMenuItem<String>(
                            value: stage,
                            child: Text(stage),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGrowthStageFilter = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedHealthStatusFilter,
                    decoration: InputDecoration(
                      labelText: LocalizationService.instance
                          .translate('health_status'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child:
                            Text(LocalizationService.instance.translate('all')),
                      ),
                      DropdownMenuItem<String>(
                        value:
                            LocalizationService.instance.translate('healthy'),
                        child: Text(
                            LocalizationService.instance.translate('healthy')),
                      ),
                      DropdownMenuItem<String>(
                        value:
                            LocalizationService.instance.translate('attention'),
                        child: Text(LocalizationService.instance
                            .translate('attention')),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedHealthStatusFilter = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_results.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      size: 50,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                    const SizedBox(height: 10),
                    Text(LocalizationService.instance
                        .translate('no_results_yet')),
                    const SizedBox(height: 5),
                    Text(
                      LocalizationService.instance
                          .translate('take_photo_to_analyze'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              )
            else if (filteredResults.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 50,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                    const SizedBox(height: 10),
                    Text(LocalizationService.instance
                        .translate('no_matching_records')),
                    const SizedBox(height: 5),
                    Text(
                      LocalizationService.instance
                          .translate('change_search_conditions'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...filteredResults.map((result) => _buildResultItem(result)),
          ],
        ),
      ),
    );
  }

  /// フィルターされた結果を取得
  List<Map<String, dynamic>> _getFilteredResults() {
    var results = List<Map<String, dynamic>>.from(_results);

    // 検索クエリでフィルター
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      results = results.where((result) {
        final growthStage =
            (result['growthStage'] ?? '').toString().toLowerCase();
        final healthStatus =
            (result['healthStatus'] ?? '').toString().toLowerCase();
        final comment = (result['comment'] ?? '').toString().toLowerCase();
        return growthStage.contains(searchQuery) ||
            healthStatus.contains(searchQuery) ||
            comment.contains(searchQuery);
      }).toList();
    }

    // 成長状態でフィルター
    if (_selectedGrowthStageFilter != null) {
      results = results.where((result) {
        return result['growthStage'] == _selectedGrowthStageFilter;
      }).toList();
    }

    // 健康状態でフィルター
    if (_selectedHealthStatusFilter != null) {
      results = results.where((result) {
        return result['healthStatus'] == _selectedHealthStatusFilter;
      }).toList();
    }

    return results;
  }

  /// アクティブなフィルターがあるかチェック
  bool _hasActiveFilters() {
    return _searchController.text.isNotEmpty ||
        _selectedGrowthStageFilter != null ||
        _selectedHealthStatusFilter != null;
  }

  /// フィルターをリセット
  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedGrowthStageFilter = null;
      _selectedHealthStatusFilter = null;
    });
  }

  Widget _buildResultItem(Map<String, dynamic> result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(TeaGardenTheme.spacingSM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: result['healthStatus'] ==
                    LocalizationService.instance.translate('healthy')
                ? TeaGardenTheme.successColor
                : TeaGardenTheme.warningColor,
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
                            ? TeaGardenTheme.successColor.withOpacity(0.1)
                            : TeaGardenTheme.warningColor.withOpacity(0.1),
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
                              ? TeaGardenTheme.successColor
                              : TeaGardenTheme.warningColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${result['timestamp']} | 信頼度: ${((result['confidence'] as double) * 100).round()}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
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
                color: TeaGardenTheme.infoColor,
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () => _deleteResult(result),
                color: TeaGardenTheme.errorColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSeriesChartCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance
                  .translate('time_series_analysis_count'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildTimeSeriesChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSeriesChart() {
    if (_results.isEmpty) {
      return Center(
        child: Text(LocalizationService.instance.translate('no_data')),
      );
    }

    // 過去7日間のデータを集計
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dailyCounts = <DateTime, int>{};

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      dailyCounts[date] = 0;
    }

    for (final result in _results) {
      final timestampStr = result['timestamp'] as String?;
      if (timestampStr != null) {
        try {
          final timestamp = DateTime.parse(timestampStr);
          final date = DateTime(timestamp.year, timestamp.month, timestamp.day);
          if (dailyCounts.containsKey(date)) {
            dailyCounts[date] = (dailyCounts[date] ?? 0) + 1;
          }
        } catch (e, stackTrace) {
          AppLogger.logErrorWithStackTrace(
            '日付パースエラー（日次集計）',
            e,
            stackTrace,
          );
          // パースエラーは無視
        }
      }
    }

    final maxCount = dailyCounts.values.isEmpty
        ? 1
        : dailyCounts.values.reduce((a, b) => a > b ? a : b);

    final sortedEntries = dailyCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final spots = sortedEntries
        .asMap()
        .entries
        .map((entry) =>
            FlSpot(entry.key.toDouble(), entry.value.value.toDouble()))
        .toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= sortedEntries.length) {
                  return const Text('');
                }
                final date = sortedEntries[index].key;
                final daysDiff = date.difference(today).inDays;
                if (daysDiff == 0) {
                  return Text(
                    LocalizationService.instance.translate('today'),
                    style: const TextStyle(fontSize: 10),
                  );
                } else if (daysDiff == -1) {
                  return Text(
                    LocalizationService.instance.translate('yesterday'),
                    style: const TextStyle(fontSize: 10),
                  );
                } else {
                  return Text(
                    LocalizationService.instance.translate('days_ago',
                        params: {'days': (-daysDiff).toString()}),
                    style: const TextStyle(fontSize: 10),
                  );
                }
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        minY: 0,
        maxY: maxCount > 0 ? maxCount.toDouble() : 5.0, // const不可（計算値のため）
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthChartCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance
                  .translate('health_status_distribution'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildHealthChart(),
            ),
            const SizedBox(height: 16),
            _buildHealthChartLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceChartCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.translate('confidence_distribution'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildConfidenceChart(),
            ),
            const SizedBox(height: 16),
            _buildConfidenceChartLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceChart() {
    if (_results.isEmpty) {
      return Center(
        child: Text(LocalizationService.instance.translate('no_data')),
      );
    }

    // 信頼度を範囲別に集計
    final highLabel = LocalizationService.instance.translate('high_confidence');
    final mediumLabel =
        LocalizationService.instance.translate('medium_confidence');
    final lowLabel = LocalizationService.instance.translate('low_confidence');

    final ranges = <String, int>{
      highLabel: 0, // 80-100%
      mediumLabel: 0, // 60-79%
      lowLabel: 0, // 0-59%
    };

    for (final result in _results) {
      final confidence = ((result['confidence'] as double?) ?? 0.0) * 100;
      if (confidence >= 80) {
        ranges[highLabel] = (ranges[highLabel] ?? 0) + 1;
      } else if (confidence >= 60) {
        ranges[mediumLabel] = (ranges[mediumLabel] ?? 0) + 1;
      } else {
        ranges[lowLabel] = (ranges[lowLabel] ?? 0) + 1;
      }
    }

    final colors = [
      TeaGardenTheme.successColor,
      TeaGardenTheme.warningColor,
      TeaGardenTheme.errorColor,
    ];
    int colorIndex = 0;

    return PieChart(
      PieChartData(
        sections: ranges.entries.map((entry) {
          final color = colors[colorIndex % colors.length];
          colorIndex++;
          return PieChartSectionData(
            value: entry.value.toDouble(),
            title: '${entry.value}',
            color: color,
            radius: 80,
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildGrowthChartCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance
                  .translate('growth_stage_distribution'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildGrowthChart(),
            ),
            const SizedBox(height: 16),
            _buildGrowthChartLegend(),
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

    final healthyStatus = LocalizationService.instance.translate('healthy');
    final attentionStatus = LocalizationService.instance.translate('attention');

    final healthyCount =
        _results.where((r) => r['healthStatus'] == healthyStatus).length;
    final attentionCount =
        _results.where((r) => r['healthStatus'] == attentionStatus).length;

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: healthyCount.toDouble(),
            title: '$healthyCount',
            color: TeaGardenTheme.successColor,
            radius: 80,
          ),
          PieChartSectionData(
            value: attentionCount.toDouble(),
            title: '$attentionCount',
            color: TeaGardenTheme.warningColor,
            radius: 80,
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
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

    final colors = [
      TeaGardenTheme.infoColor,
      TeaGardenTheme.successColor,
      TeaGardenTheme.warningColor,
      TeaGardenTheme.primaryGreen,
    ];
    int colorIndex = 0;

    return PieChart(
      PieChartData(
        sections: stageCounts.entries.map((entry) {
          final color = colors[colorIndex % colors.length];
          colorIndex++;
          return PieChartSectionData(
            value: entry.value.toDouble(),
            title: '${entry.value}',
            color: color,
            radius: 80,
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  /// 健康状態チャートの凡例
  Widget _buildHealthChartLegend() {
    final healthyStatus = LocalizationService.instance.translate('healthy');
    final attentionStatus = LocalizationService.instance.translate('attention');

    final healthyCount =
        _results.where((r) => r['healthStatus'] == healthyStatus).length;
    final attentionCount =
        _results.where((r) => r['healthStatus'] == attentionStatus).length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
            TeaGardenTheme.successColor, healthyStatus, healthyCount),
        const SizedBox(width: 20),
        _buildLegendItem(
            TeaGardenTheme.warningColor, attentionStatus, attentionCount),
      ],
    );
  }

  /// 成長段階チャートの凡例
  Widget _buildGrowthChartLegend() {
    final stageCounts = <String, int>{};
    for (final result in _results) {
      final stage = result['growthStage'] as String;
      stageCounts[stage] = (stageCounts[stage] ?? 0) + 1;
    }

    final colors = [
      TeaGardenTheme.infoColor,
      TeaGardenTheme.successColor,
      TeaGardenTheme.warningColor,
      TeaGardenTheme.primaryGreen,
    ];
    int colorIndex = 0;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: stageCounts.entries.map((entry) {
        final color = colors[colorIndex % colors.length];
        colorIndex++;
        return _buildLegendItem(color, entry.key, entry.value);
      }).toList(),
    );
  }

  /// 信頼度チャートの凡例
  Widget _buildConfidenceChartLegend() {
    final highLabel = LocalizationService.instance.translate('high_confidence');
    final mediumLabel =
        LocalizationService.instance.translate('medium_confidence');
    final lowLabel = LocalizationService.instance.translate('low_confidence');

    final highCount = _results
        .where((r) => ((r['confidence'] as double?) ?? 0.0) * 100 >= 80)
        .length;
    final mediumCount = _results.where((r) {
      final conf = ((r['confidence'] as double?) ?? 0.0) * 100;
      return conf >= 60 && conf < 80;
    }).length;
    final lowCount = _results
        .where((r) => ((r['confidence'] as double?) ?? 0.0) * 100 < 60)
        .length;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem(TeaGardenTheme.successColor, highLabel, highCount),
        _buildLegendItem(TeaGardenTheme.warningColor, mediumLabel, mediumCount),
        _buildLegendItem(TeaGardenTheme.errorColor, lowLabel, lowCount),
      ],
    );
  }

  /// 凡例アイテム
  Widget _buildLegendItem(Color color, String label, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $count',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildExportCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.translate('export'),
              style: const TextStyle(
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
                    backgroundColor: TeaGardenTheme.warningColor,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _exportToJSON,
                  icon: const Icon(Icons.code),
                  label: Text(LocalizationService.instance.translate('json')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TeaGardenTheme.infoColor,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _exportToPDF,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(LocalizationService.instance.translate('pdf')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TeaGardenTheme.errorColor,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSettingsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.translate('language_settings'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...LocalizationService.instance.availableLanguages.map(
              (String languageCode) {
                return RadioListTile<String>(
                  title: Text(LocalizationService.instance
                      .getLanguageName(languageCode)),
                  value: languageCode,
                  groupValue: LocalizationService.instance.currentLanguage,
                  onChanged: (String? value) {
                    if (value != null) {
                      LocalizationService.instance.setLanguage(value);
                      setState(() {});
                      widget.onLanguageChanged?.call();
                      SnackBarHelper.showSuccess(
                        context,
                        LocalizationService.instance
                            .translate('settings_saved'),
                      );
                    }
                  },
                );
              },
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
        padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.translate('app_settings'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(LocalizationService.instance.translate('retention_period')),
            Slider(
              value: _retentionPeriod,
              min: AppConstants.retentionPeriodMin.toDouble(),
              max: AppConstants.retentionPeriodMax.toDouble(),
              divisions: AppConstants.retentionPeriodMax -
                  AppConstants.retentionPeriodMin,
              label:
                  '${_retentionPeriod.toInt()}${LocalizationService.instance.translate('days')}',
              onChanged: (value) {
                setState(() {
                  _retentionPeriod = value;
                });
              },
            ),
            Text(
              '${_retentionPeriod.toInt()}${LocalizationService.instance.translate('days')}',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Text(LocalizationService.instance
                .translate('auto_analysis_interval')),
            Slider(
              value: _autoAnalysisInterval,
              min: AppConstants.autoAnalysisIntervalMin.toDouble(),
              max: AppConstants.autoAnalysisIntervalMax.toDouble(),
              divisions: AppConstants.autoAnalysisIntervalMax -
                  AppConstants.autoAnalysisIntervalMin,
              label:
                  '${_autoAnalysisInterval.toInt()}${LocalizationService.instance.translate('minutes')}',
              onChanged: (value) {
                setState(() {
                  _autoAnalysisInterval = value;
                });
              },
            ),
            Text(
              '${_autoAnalysisInterval.toInt()}${LocalizationService.instance.translate('minutes')}',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child:
                  Text(LocalizationService.instance.translate('save_settings')),
            ),
          ],
        ),
      ),
    );
  }

  /// クラウド同期カード
  Widget _buildCloudSyncCard() {
    return BlocBuilder<CloudSyncCubit, CloudSyncState>(
      builder: (context, state) {
        final cubit = context.read<CloudSyncCubit>();
        bool isAutoSyncEnabled = false;
        bool isSyncing = false;
        String statusMessage = '';
        Color statusColor = TeaGardenTheme.infoColor;

        // 自動同期状態を確認
        if (state is CloudSyncAutoSyncState) {
          isAutoSyncEnabled = state.enabled;
        }

        // 同期状態を確認
        if (state is CloudSyncSyncing) {
          isSyncing = true;
          statusMessage = state.message;
          statusColor = TeaGardenTheme.infoColor;
        } else if (state is CloudSyncSuccess) {
          statusMessage = state.message;
          statusColor = TeaGardenTheme.successColor;
        } else if (state is CloudSyncError) {
          statusMessage = state.message;
          statusColor = TeaGardenTheme.errorColor;
        } else if (state is CloudSyncConnected) {
          statusMessage = 'クラウドに接続済み';
          statusColor = TeaGardenTheme.successColor;
        } else if (state is CloudSyncOffline) {
          statusMessage = 'オフライン';
          statusColor = TeaGardenTheme.warningColor;
        } else if (state is CloudSyncCheckingConnection) {
          statusMessage = '接続確認中...';
          statusColor = TeaGardenTheme.infoColor;
        } else if (state is CloudSyncInitial) {
          statusMessage = '初期化中...';
          statusColor = TeaGardenTheme.infoColor;
        }

        // 自動同期状態の取得
        // CloudSyncAutoSyncStateは他の状態と同時に存在しないため、
        // 初期化時以外は自動同期状態を別途取得する必要がある
        // ただし、毎回呼び出すと無限ループになる可能性があるため、
        // 初期化時にのみ呼び出されるようにCubit側で実装されている

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(TeaGardenTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.cloud, color: statusColor),
                    const SizedBox(width: 8),
                    const Text(
                      'クラウド同期',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (statusMessage.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSyncing)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        else
                          Icon(
                            state is CloudSyncSuccess
                                ? Icons.check_circle
                                : state is CloudSyncError
                                    ? Icons.error
                                    : state is CloudSyncOffline
                                        ? Icons.cloud_off
                                        : Icons.info,
                            size: 16,
                            color: statusColor,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          statusMessage,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'データをクラウドにバックアップして、複数のデバイス間で同期できます。',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: isSyncing
                          ? null
                          : () async {
                              await cubit.syncToCloud();
                              if (context.mounted) {
                                final currentState = cubit.state;
                                if (currentState is CloudSyncSuccess) {
                                  SnackBarHelper.showSuccess(
                                    context,
                                    currentState.message,
                                  );
                                } else if (currentState is CloudSyncError) {
                                  SnackBarHelper.showError(
                                    context,
                                    currentState.message,
                                  );
                                }
                              }
                            },
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('クラウドにアップロード'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TeaGardenTheme.infoColor,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: isSyncing
                          ? null
                          : () async {
                              await cubit.syncFromCloud();
                              if (context.mounted) {
                                final currentState = cubit.state;
                                if (currentState is CloudSyncSuccess) {
                                  SnackBarHelper.showSuccess(
                                    context,
                                    currentState.message,
                                  );
                                } else if (currentState is CloudSyncError) {
                                  SnackBarHelper.showError(
                                    context,
                                    currentState.message,
                                  );
                                }
                              }
                            },
                      icon: const Icon(Icons.cloud_download),
                      label: const Text('クラウドからダウンロード'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: isSyncing
                          ? null
                          : () async {
                              await cubit.syncBothWays();
                              if (context.mounted) {
                                final currentState = cubit.state;
                                if (currentState is CloudSyncSuccess) {
                                  SnackBarHelper.showSuccess(
                                    context,
                                    currentState.message,
                                  );
                                } else if (currentState is CloudSyncError) {
                                  SnackBarHelper.showError(
                                    context,
                                    currentState.message,
                                  );
                                }
                              }
                            },
                      icon: const Icon(Icons.sync),
                      label: const Text('双方向同期'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TeaGardenTheme.primaryGreen,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: isSyncing
                      ? null
                      : () async {
                          await cubit.checkConnection();
                        },
                  icon: const Icon(Icons.refresh),
                  label: const Text('接続状態を確認'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TeaGardenTheme.infoColor,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('自動同期を有効にする'),
                  subtitle: const Text('定期的にクラウドと同期します'),
                  value: isAutoSyncEnabled,
                  onChanged: isSyncing
                      ? null
                      : (value) async {
                          await cubit.toggleAutoSync(value);
                          if (context.mounted) {
                            SnackBarHelper.showCustom(
                              context,
                              value ? '自動同期を有効にしました' : '自動同期を無効にしました',
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              duration: AnimationConstants.twoSeconds,
                            );
                          }
                        },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startAnalysis() async {
    // Prevent multiple concurrent analyses
    if (_isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Simulate a short network delay (CI-friendly)
      await Future.delayed(AnimationConstants.shortDuration);

      final now = DateTime.now().toIso8601String();
      final growthStages = [
        LocalizationService.instance.translate('sprouting_period'),
        LocalizationService.instance.translate('growth_period'),
        LocalizationService.instance.translate('maturity_period'),
        LocalizationService.instance.translate('harvest_period')
      ];

      final Map<String, dynamic> resultMap = {
        'timestamp': now,
        'growthStage': growthStages[DateTime.now().millisecondsSinceEpoch % 4],
        'healthStatus': DateTime.now().millisecondsSinceEpoch % 10 < 2
            ? LocalizationService.instance.translate('attention')
            : LocalizationService.instance.translate('healthy'),
        'confidence':
            (75 + (DateTime.now().millisecondsSinceEpoch % 25)) / 100.0,
        'comment':
            LocalizationService.instance.translate('new_analysis_completed'),
      };

      // Update results and counters
      if (mounted) {
        setState(() {
          _results.insert(0, resultMap);
          _analysisCount++;
          _isAnalyzing = false;
        });

        // Persist data
        _saveData();

        // Show localized SnackBar confirming completion
        final text =
            LocalizationService.instance.translate('analysis_complete');
        SnackBarHelper.showSuccess(context, text);
      }
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        '解析エラー（enhanced_app）',
        e,
        stackTrace,
      );
      // End analyzing state on error and optionally show an error SnackBar
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        final errText =
            LocalizationService.instance.translate('analysis_failed');
        SnackBarHelper.showError(context, errText);
      }
    }
  }

  void _editResult(Map<String, dynamic> result) {
    // 編集用のコントローラーを初期化
    final commentController =
        TextEditingController(text: result['comment'] ?? '');

    // 成長状態の選択肢
    final growthStages = [
      LocalizationService.instance.translate('sprouting_period'),
      LocalizationService.instance.translate('growth_period'),
      LocalizationService.instance.translate('maturity_period'),
      LocalizationService.instance.translate('harvest_period'),
    ];

    // 健康状態の選択肢
    final healthStatuses = [
      LocalizationService.instance.translate('healthy'),
      LocalizationService.instance.translate('attention'),
    ];

    // 編集ダイアログを表示
    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder内で状態を管理
        String selectedGrowthStage = result['growthStage'] ?? '';
        String selectedHealthStatus = result['healthStatus'] ?? '';

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title:
                  Text(LocalizationService.instance.translate('edit_result')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 成長状態の選択
                    Text(
                      LocalizationService.instance.translate('growth_stage'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedGrowthStage.isEmpty
                          ? null
                          : selectedGrowthStage,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: growthStages.map((String stage) {
                        return DropdownMenuItem<String>(
                          value: stage,
                          child: Text(stage),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedGrowthStage = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // 健康状態の選択
                    Text(
                      LocalizationService.instance.translate('health_status'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedHealthStatus.isEmpty
                          ? null
                          : selectedHealthStatus,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: healthStatuses.map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedHealthStatus = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // コメント入力
                    Text(
                      LocalizationService.instance.translate('comment'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText:
                            LocalizationService.instance.translate('comment'),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    commentController.dispose();
                    Navigator.of(context).pop();
                  },
                  child: Text(LocalizationService.instance.translate('cancel')),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 結果を更新
                    final index = _results.indexOf(result);
                    if (index != -1) {
                      setState(() {
                        _results[index] = {
                          ...result,
                          'growthStage': selectedGrowthStage,
                          'healthStatus': selectedHealthStatus,
                          'comment': commentController.text,
                        };
                      });
                      _saveData();
                      commentController.dispose();
                      Navigator.of(context).pop();
                      SnackBarHelper.showSuccess(
                        context,
                        LocalizationService.instance
                            .translate('settings_saved'),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Text(LocalizationService.instance.translate('save')),
                ),
              ],
            );
          },
        );
      },
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
              SnackBarHelper.showError(
                context,
                LocalizationService.instance
                    .translate('analysis_result_deleted'),
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
      SnackBarHelper.showError(
        context,
        LocalizationService.instance.translate('no_export_data'),
      );
      return;
    }

    final csvContent = [
      '${LocalizationService.instance.translate('date_time')},${LocalizationService.instance.translate('growth_stage')},${LocalizationService.instance.translate('health_status')},${LocalizationService.instance.translate('confidence')},${LocalizationService.instance.translate('comment')}',
      ..._results.map((r) =>
          '${r['timestamp']},${r['growthStage']},${r['healthStatus']},${((r['confidence'] as double) * 100).round()}%,${r['comment']}')
    ].join('\n');

    _downloadFile(csvContent, 'tea_analysis_results.csv', 'text/csv');
    SnackBarHelper.showSuccess(
      context,
      LocalizationService.instance.translate('csv_exported'),
    );
  }

  void _exportToJSON() {
    if (_results.isEmpty) {
      SnackBarHelper.showError(
        context,
        LocalizationService.instance.translate('no_export_data'),
      );
      return;
    }

    final jsonContent = jsonEncode(_results);
    _downloadFile(jsonContent, 'tea_analysis_results.json', 'application/json');
    SnackBarHelper.showSuccess(
      context,
      LocalizationService.instance.translate('json_exported'),
    );
  }

  void _exportToPDF() {
    if (_results.isEmpty) {
      SnackBarHelper.showError(
        context,
        LocalizationService.instance.translate('no_export_data'),
      );
      return;
    }

    // HTMLテーブルを生成
    final htmlContent = _generatePDFHTML();
    _downloadFile(htmlContent, 'tea_analysis_report.html', 'text/html');

    SnackBarHelper.showCustom(
      context,
      '${LocalizationService.instance.translate('pdf')}レポートを生成しました。ブラウザで印刷してPDFとして保存できます。',
      backgroundColor: Theme.of(context).colorScheme.primary,
      duration: AnimationConstants.fourSeconds,
    );
  }

  /// PDF用のHTMLテーブルを生成
  String _generatePDFHTML() {
    final appTitle =
        LocalizationService.instance.translate('enhanced_app_title');
    final dateTimeLabel = LocalizationService.instance.translate('date_time');
    final growthStageLabel =
        LocalizationService.instance.translate('growth_stage');
    final healthStatusLabel =
        LocalizationService.instance.translate('health_status');
    final confidenceLabel =
        LocalizationService.instance.translate('confidence');
    final commentLabel = LocalizationService.instance.translate('comment');
    final totalRecordsLabel =
        LocalizationService.instance.translate('total_records');
    final healthyStatus = LocalizationService.instance.translate('healthy');
    final attentionStatus = LocalizationService.instance.translate('attention');

    final now = DateTime.now();
    final dateStr = AppUtils.formatAbsoluteTime(now);

    final healthyCount =
        _results.where((r) => r['healthStatus'] == healthyStatus).length;
    final attentionCount =
        _results.where((r) => r['healthStatus'] == attentionStatus).length;

    final html = '''
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>茶園管理AI - 解析結果レポート</title>
  <style>
    @media print {
      body { margin: 0; }
      .no-print { display: none; }
    }
    body {
      font-family: 'Helvetica Neue', Arial, sans-serif;
      padding: 20px;
      color: #333;
    }
    .header {
      text-align: center;
      margin-bottom: 30px;
      border-bottom: 3px solid #4CAF50;
      padding-bottom: 20px;
    }
    .header h1 {
      color: #4CAF50;
      margin: 0;
      font-size: 28px;
    }
    .header p {
      color: #666;
      margin: 5px 0;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 20px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    th {
      background-color: #4CAF50;
      color: white;
      padding: 12px;
      text-align: left;
      font-weight: bold;
    }
    td {
      padding: 10px;
      border-bottom: 1px solid #ddd;
    }
    tr:nth-child(even) {
      background-color: #f9f9f9;
    }
    tr:hover {
      background-color: #f5f5f5;
    }
    .summary {
      margin-top: 30px;
      padding: 15px;
      background-color: #f0f8f0;
      border-left: 4px solid #4CAF50;
    }
    .summary h2 {
      color: #4CAF50;
      margin-top: 0;
    }
    .no-print {
      text-align: center;
      margin-top: 20px;
      padding: 15px;
      background-color: #fff3cd;
      border: 1px solid #ffc107;
      border-radius: 5px;
    }
    .no-print button {
      background-color: #4CAF50;
      color: white;
      border: none;
      padding: 10px 20px;
      font-size: 16px;
      border-radius: 5px;
      cursor: pointer;
      margin-top: 10px;
    }
    .no-print button:hover {
      background-color: #45a049;
    }
  </style>
</head>
<body>
  <div class="header">
    <h1>$appTitle</h1>
    <p>解析結果レポート</p>
    <p>生成日時: $dateStr</p>
  </div>

  <table>
    <thead>
      <tr>
        <th>$dateTimeLabel</th>
        <th>$growthStageLabel</th>
        <th>$healthStatusLabel</th>
        <th>$confidenceLabel</th>
        <th>$commentLabel</th>
      </tr>
    </thead>
    <tbody>
${_results.map((r) {
      final timestamp = r['timestamp'] ?? '';
      final growthStage = r['growthStage'] ?? '';
      final healthStatus = r['healthStatus'] ?? '';
      final confidence = ((r['confidence'] as double?) ?? 0.0) * 100;
      final comment = (r['comment'] ?? '')
          .toString()
          .replaceAll('<', '&lt;')
          .replaceAll('>', '&gt;');
      return '      <tr>\n        <td>$timestamp</td>\n        <td>$growthStage</td>\n        <td>$healthStatus</td>\n        <td>${confidence.toStringAsFixed(1)}%</td>\n        <td>$comment</td>\n      </tr>';
    }).join('\n')}
    </tbody>
  </table>

  <div class="summary">
    <h2>サマリー</h2>
    <p><strong>$totalRecordsLabel:</strong> ${_results.length}件</p>
    <p><strong>健康な茶葉:</strong> $healthyCount件</p>
    <p><strong>注意が必要な茶葉:</strong> $attentionCount件</p>
  </div>

  <div class="no-print">
    <p><strong>PDFとして保存する方法:</strong></p>
    <p>このページを印刷してPDFとして保存できます。</p>
    <button onclick="window.${'print'}()">印刷してPDF保存</button>
  </div>

  <script>
    // ページ読み込み時に自動で印刷ダイアログを開く（オプション）
    // window.onload = function() { window.${'print'}(); };
  </script>
</body>
</html>
''';

    return html;
  }

  void _saveSettings() {
    // 設定値をローカルストレージに保存
    final settings = {
      'retentionPeriod': _retentionPeriod,
      'autoAnalysisInterval': _autoAnalysisInterval,
    };
    setLocalStorage('teaGardenSettings', jsonEncode(settings));

    // データ保持期間に基づいて古いデータを削除
    _cleanupOldData();

    SnackBarHelper.showSuccess(
      context,
      LocalizationService.instance.translate('settings_saved'),
    );
  }

  /// データ保持期間に基づいて古いデータを削除
  void _cleanupOldData() {
    final cutoffDate = DateTime.now().subtract(
      Duration(days: _retentionPeriod.toInt()),
    );

    setState(() {
      _results.removeWhere((result) {
        final timestampStr = result['timestamp'] as String?;
        if (timestampStr == null) return false;

        try {
          final timestamp = DateTime.parse(timestampStr);
          return timestamp.isBefore(cutoffDate);
        } catch (e, stackTrace) {
          AppLogger.logErrorWithStackTrace(
            '日付パースエラー（古いデータ削除）',
            e,
            stackTrace,
          );
          return false;
        }
      });
    });

    _saveData();
  }

  void _downloadFile(String content, String filename, String mimeType) {
    downloadFile(content, filename, mimeType);
  }
}
