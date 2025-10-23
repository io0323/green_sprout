import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../tea_analysis/presentation/bloc/tea_analysis_cubit.dart';
import '../../../tea_analysis/domain/entities/tea_analysis_result.dart';
import '../../../../core/services/localization_service.dart';

/**
 * 茶園分析ページ
 * 茶葉解析結果の統計とグラフを表示
 */
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
    return Scaffold(
      appBar: AppBar(
        title: Text(t('analytics')),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.timeline, color: Colors.white),
            tooltip: '期間選択',
            onSelected: (String period) {
              setState(() {
                _selectedPeriod = period;
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'week',
                  child: Text('過去1週間'),
                ),
                const PopupMenuItem(
                  value: 'month',
                  child: Text('過去1ヶ月'),
                ),
                const PopupMenuItem(
                  value: 'year',
                  child: Text('過去1年'),
                ),
              ];
            },
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
        child: BlocBuilder<TeaAnalysisCubit, TeaAnalysisState>(
          builder: (context, state) {
            if (state is TeaAnalysisLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              );
            }

            if (state is TeaAnalysisError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(t('error')),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TeaAnalysisCubit>().loadAllResults();
                      },
                      child: Text(t('retry')),
                    ),
                  ],
                ),
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

            return const Center(child: Text('Unknown state'));
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
          const Icon(Icons.calendar_today, color: Colors.green),
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
    final healthyCount = results.where((r) => r.healthStatus == '健康').length;
    final avgConfidence = results.isNotEmpty 
        ? results.map((r) => r.confidence).reduce((a, b) => a + b) / results.length 
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
            '統計サマリー',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '総解析数',
                  totalCount.toString(),
                  Icons.analytics_outlined,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '健康率',
                  totalCount > 0 ? '${((healthyCount / totalCount) * 100).toInt()}%' : '0%',
                  Icons.health_and_safety_outlined,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '平均信頼度',
                  '${(avgConfidence * 100).toInt()}%',
                  Icons.trending_up_outlined,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthStageChart(List<TeaAnalysisResult> results) {
    final growthStages = ['芽', '若葉', '成葉', '老葉'];
    final stageCounts = growthStages.map((stage) {
      return results.where((r) => r.growthStage == stage).length;
    }).toList();

    return _buildChartContainer(
      '成長状態分布',
      PieChart(
        PieChartData(
          sections: growthStages.asMap().entries.map((entry) {
            final index = entry.key;
            final stage = entry.value;
            final count = stageCounts[index];
            final colors = [Colors.lightGreen, Colors.green, Colors.teal, Colors.brown];
            
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
    final healthStatuses = ['健康', '軽微な損傷', '損傷', '病気'];
    final statusCounts = healthStatuses.map((status) {
      return results.where((r) => r.healthStatus == status).length;
    }).toList();

    return _buildChartContainer(
      '健康状態分布',
      BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: statusCounts.isEmpty ? 1 : statusCounts.reduce((a, b) => a > b ? a : b).toDouble(),
          barGroups: healthStatuses.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final count = statusCounts[index];
            final colors = [Colors.green, Colors.orange, Colors.red, Colors.red[800]!];
            
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  color: colors[index],
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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
      final dateKey = '${result.timestamp.year}-${result.timestamp.month.toString().padLeft(2, '0')}-${result.timestamp.day.toString().padLeft(2, '0')}';
      dailyCounts[dateKey] = (dailyCounts[dateKey] ?? 0) + 1;
    }

    final sortedDates = dailyCounts.keys.toList()..sort();
    final spots = sortedDates.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), dailyCounts[entry.value]!.toDouble());
    }).toList();

    return _buildChartContainer(
      '時系列解析数',
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
              color: Colors.green,
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
      return results.where((r) => r.confidence >= min && r.confidence <= max).length;
    }).toList();

    return _buildChartContainer(
      '信頼度分布',
      BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: rangeCounts.isEmpty ? 1 : rangeCounts.reduce((a, b) => a > b ? a : b).toDouble(),
          barGroups: confidenceRanges.asMap().entries.map((entry) {
            final index = entry.key;
            final range = entry.value;
            final count = rangeCounts[index];
            
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  color: Colors.blue,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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
              color: Colors.grey[800],
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

  List<TeaAnalysisResult> _filterResultsByPeriod(List<TeaAnalysisResult> results) {
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

    return results.where((result) => result.timestamp.isAfter(startDate)).toList();
  }

  String _getPeriodText() {
    switch (_selectedPeriod) {
      case 'week':
        return '過去1週間';
      case 'month':
        return '過去1ヶ月';
      case 'year':
        return '過去1年';
      default:
        return '過去1週間';
    }
  }
}
