import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../tea_analysis/presentation/bloc/tea_analysis_cubit.dart';
import '../../../tea_analysis/domain/entities/tea_analysis_result.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/widgets/modern_ui_components.dart';
import '../../../../core/theme/tea_garden_theme.dart';

/// 茶園分析ページ
/// 茶葉解析結果の統計とグラフを表示
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _selectedPeriod = 'week'; // week, month, year

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeaAnalysisCubit>().loadAllResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(t('analytics')),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.timeline, color: colorScheme.onPrimary),
            tooltip: t('period_selection'),
            onSelected: (String period) {
              setState(() {
                _selectedPeriod = period;
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'week',
                  child: Text(t('past_week')),
                ),
                PopupMenuItem(
                  value: 'month',
                  child: Text(t('past_month')),
                ),
                PopupMenuItem(
                  value: 'year',
                  child: Text(t('past_year')),
                ),
              ];
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: TeaGardenTheme.backgroundGradient,
        ),
        child: BlocBuilder<TeaAnalysisCubit, TeaAnalysisState>(
          builder: (context, state) {
            if (state is TeaAnalysisLoading) {
              return BeautifulLoadingIndicator(
                message: t('data_loading'),
              );
            }

            if (state is TeaAnalysisError) {
              return BeautifulErrorMessage(
                message: state.message,
                onRetry: () {
                  context.read<TeaAnalysisCubit>().loadAllResults();
                },
              );
            }

            if (state is TeaAnalysisLoaded) {
              final filteredResults = _filterResultsByPeriod(state.results);
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 期間選択表示
                    _buildPeriodSelector(),
                    const SizedBox(height: 16),

                    // 統計サマリー
                    _buildStatsSummary(filteredResults),
                    const SizedBox(height: 24),

                    // 成長状態分布グラフ
                    _buildGrowthStageChart(filteredResults),
                    const SizedBox(height: 24),

                    // 健康状態分布グラフ
                    _buildHealthStatusChart(filteredResults),
                    const SizedBox(height: 24),

                    // 時系列グラフ
                    _buildTimeSeriesChart(filteredResults),
                    const SizedBox(height: 24),

                    // 信頼度分布
                    _buildConfidenceChart(filteredResults),
                  ],
                ),
              );
            }

            return Center(child: Text(t('unknown_state')));
          },
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            _getPeriodText(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(List<TeaAnalysisResult> results) {
    final totalCount = results.length;
    final healthyCount =
        results.where((r) => r.healthStatus == t('healthy')).length;
    final avgConfidence = results.isNotEmpty
        ? results.map((r) => r.confidence).reduce((a, b) => a + b) /
            results.length
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('stats_summary'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  t('total_analysis_count'),
                  totalCount.toString(),
                  Icons.analytics_outlined,
                  TeaGardenTheme.infoColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  t('health_rate'),
                  totalCount > 0
                      ? '${((healthyCount / totalCount) * 100).toInt()}%'
                      : '0%',
                  Icons.health_and_safety_outlined,
                  TeaGardenTheme.successColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  t('avg_confidence'),
                  '${(avgConfidence * 100).toInt()}%',
                  Icons.trending_up_outlined,
                  TeaGardenTheme.warningColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthStageChart(List<TeaAnalysisResult> results) {
    final growthStages = [
      t('bud'),
      t('young_leaf'),
      t('mature_leaf'),
      t('old_leaf')
    ];
    final stageCounts = growthStages.map((stage) {
      return results.where((r) => r.growthStage == stage).length;
    }).toList();

    return _buildChartContainer(
      t('growth_stage_distribution'),
      PieChart(
        PieChartData(
          sections: growthStages.asMap().entries.map((entry) {
            final index = entry.key;
            final stage = entry.value;
            final count = stageCounts[index];
            final colors = [
              TeaGardenTheme.lightGreen,
              TeaGardenTheme.successColor,
              TeaGardenTheme.primaryGreen,
              TeaGardenTheme.darkGreen
            ];

            return PieChartSectionData(
              color: colors[index],
              value: count.toDouble(),
              title: '$stage\n$count',
              radius: 80,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildHealthStatusChart(List<TeaAnalysisResult> results) {
    final healthStatuses = [
      t('healthy'),
      t('minor_damage'),
      t('damaged'),
      t('diseased')
    ];
    final statusCounts = healthStatuses.map((status) {
      return results.where((r) => r.healthStatus == status).length;
    }).toList();

    return _buildChartContainer(
      t('health_status_distribution'),
      BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: statusCounts.isEmpty
              ? 1
              : statusCounts.reduce((a, b) => a > b ? a : b).toDouble(),
          barGroups: healthStatuses.asMap().entries.map((entry) {
            final index = entry.key;
            final count = statusCounts[index];
            final colors = [
              TeaGardenTheme.successColor,
              TeaGardenTheme.warningColor,
              TeaGardenTheme.errorColor,
              TeaGardenTheme.errorColor
            ];

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  color: colors[index],
                  width: 20,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    healthStatuses[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSeriesChart(List<TeaAnalysisResult> results) {
    // 日付ごとの解析数を計算
    final Map<String, int> dailyCounts = {};
    for (final result in results) {
      final dateKey =
          '${result.timestamp.year}-${result.timestamp.month.toString().padLeft(2, '0')}-${result.timestamp.day.toString().padLeft(2, '0')}';
      dailyCounts[dateKey] = (dailyCounts[dateKey] ?? 0) + 1;
    }

    final sortedDates = dailyCounts.keys.toList()..sort();
    final spots = sortedDates.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), dailyCounts[entry.value]!.toDouble());
    }).toList();

    return _buildChartContainer(
      t('time_series_analysis_count'),
      LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < sortedDates.length) {
                    final date = sortedDates[value.toInt()];
                    return Text(
                      date.split('-')[2], // 日のみ表示
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceChart(List<TeaAnalysisResult> results) {
    final confidenceRanges = ['0-20%', '21-40%', '41-60%', '61-80%', '81-100%'];
    final rangeCounts = confidenceRanges.map((range) {
      final parts = range.split('-');
      final min = int.parse(parts[0]) / 100.0;
      final max = int.parse(parts[1].replaceAll('%', '')) / 100.0;
      return results
          .where((r) => r.confidence >= min && r.confidence <= max)
          .length;
    }).toList();

    return _buildChartContainer(
      t('confidence_distribution'),
      BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: rangeCounts.isEmpty
              ? 1
              : rangeCounts.reduce((a, b) => a > b ? a : b).toDouble(),
          barGroups: confidenceRanges.asMap().entries.map((entry) {
            final index = entry.key;
            final count = rangeCounts[index];

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  color: TeaGardenTheme.infoColor,
                  width: 20,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    confidenceRanges[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartContainer(String title, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: chart,
          ),
        ],
      ),
    );
  }

  List<TeaAnalysisResult> _filterResultsByPeriod(
      List<TeaAnalysisResult> results) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case 'year':
        startDate = now.subtract(const Duration(days: 365));
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }

    return results
        .where((result) => result.timestamp.isAfter(startDate))
        .toList();
  }

  String _getPeriodText() {
    switch (_selectedPeriod) {
      case 'week':
        return t('past_week');
      case 'month':
        return t('past_month');
      case 'year':
        return t('past_year');
      default:
        return t('past_week');
    }
  }
}
