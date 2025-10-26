import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../tea_analysis/presentation/bloc/tea_analysis_cubit.dart';
import '../../../tea_analysis/presentation/widgets/tea_analysis_card.dart';

/// 日誌一覧ページ
/// 過去の茶葉解析結果を表示
class LogListPage extends StatefulWidget {
  const LogListPage({super.key});

  @override
  State<LogListPage> createState() => _LogListPageState();
}

class _LogListPageState extends State<LogListPage> {
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // 初期化処理
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeaAnalysisCubit>().loadAllResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '日誌一覧',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              _showSearchDialog();
            },
            tooltip: '検索',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _showFilterDialog();
            },
            tooltip: 'フィルター',
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
              );
            }

            if (state is TeaAnalysisError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'エラーが発生しました',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<TeaAnalysisCubit>().loadAllResults();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('再試行'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is TeaAnalysisLoaded) {
              // フィルタリングと検索を適用
              var filteredResults = state.results.where((result) {
                // フィルター適用
                bool filterMatch = true;
                if (_selectedFilter != 'all') {
                  switch (_selectedFilter) {
                    case 'growth_stage':
                      filterMatch = result.growthStage == '芽' ||
                          result.growthStage == '若葉';
                      break;
                    case 'health_status':
                      filterMatch = result.healthStatus == '健康';
                      break;
                    case 'recent':
                      final DateTime now = DateTime.now();
                      filterMatch =
                          now.difference(result.timestamp).inDays <= 7;
                      break;
                  }
                }

                // 検索適用
                bool searchMatch = true;
                if (_searchQuery.isNotEmpty) {
                  searchMatch = result.growthStage.contains(_searchQuery) ||
                      result.healthStatus.contains(_searchQuery) ||
                      (result.comment?.contains(_searchQuery) ?? false);
                }

                return filterMatch && searchMatch;
              }).toList();

              if (filteredResults.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 80,
                          color: Colors.green[200],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _selectedFilter != 'all'
                              ? '条件に一致する記録がありません'
                              : 'まだ記録がありません',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty || _selectedFilter != 'all'
                              ? '検索条件を変更してみてください'
                              : '写真を撮って茶葉を解析してみましょう',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty ||
                            _selectedFilter != 'all') ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _selectedFilter = 'all';
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('フィルターをリセット'),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  // 統計情報
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          '総記録数',
                          state.results.length.toString(),
                          Icons.analytics_outlined,
                          Colors.blue,
                        ),
                        _buildStatItem(
                          '表示中',
                          filteredResults.length.toString(),
                          Icons.visibility_outlined,
                          Colors.green,
                        ),
                        _buildStatItem(
                          '今週',
                          state.results
                              .where((r) {
                                final DateTime now = DateTime.now();
                                return now.difference(r.timestamp).inDays <= 7;
                              })
                              .length
                              .toString(),
                          Icons.calendar_today_outlined,
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),

                  // フィルター表示
                  if (_selectedFilter != 'all' || _searchQuery.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.filter_alt,
                              size: 16, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _buildFilterText(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _searchQuery = '';
                                _selectedFilter = 'all';
                              });
                            },
                            child: Icon(Icons.close,
                                size: 16, color: Colors.green[700]),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),

                  // 結果リスト
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredResults.length,
                      itemBuilder: (context, index) {
                        final result = filteredResults[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TeaAnalysisCard(result: result),
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return const Center(child: Text('Unknown state'));
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
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

  String _buildFilterText() {
    String filterText = '';
    if (_selectedFilter != 'all') {
      switch (_selectedFilter) {
        case 'growth_stage':
          filterText = '成長期（芽・若葉）';
          break;
        case 'health_status':
          filterText = '健康な茶葉';
          break;
        case 'recent':
          filterText = '最近1週間';
          break;
      }
    }
    if (_searchQuery.isNotEmpty) {
      filterText += filterText.isNotEmpty ? ' + ' : '';
      filterText += '"$_searchQuery"で検索';
    }
    return filterText;
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('検索'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: '成長状態、健康状態、コメントで検索',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('検索'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('フィルター'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('すべて'),
              value: 'all',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('成長期（芽・若葉）'),
              value: 'growth_stage',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('健康な茶葉'),
              value: 'health_status',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('最近1週間'),
              value: 'recent',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
