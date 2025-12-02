import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../tea_analysis/presentation/bloc/tea_analysis_cubit.dart';
import '../../../tea_analysis/presentation/widgets/tea_analysis_card.dart';
import '../../../../core/widgets/modern_ui_components.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/theme/tea_garden_theme.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          t('logs_list'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: colorScheme.onPrimary),
            onPressed: () {
              _showSearchDialog();
            },
            tooltip: t('search'),
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: colorScheme.onPrimary),
            onPressed: () {
              _showFilterDialog();
            },
            tooltip: t('filter'),
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
                message: LocalizationService.instance.translate('data_loading'),
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
              // フィルタリングと検索を適用
              var filteredResults = state.results.where((result) {
                // フィルター適用
                bool filterMatch = true;
                if (_selectedFilter != 'all') {
                  switch (_selectedFilter) {
                    case 'growth_stage':
                      filterMatch = result.growthStage == t('bud') ||
                          result.growthStage == t('young_leaf');
                      break;
                    case 'health_status':
                      filterMatch = result.healthStatus == t('healthy');
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
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _selectedFilter != 'all'
                              ? t('no_matching_records')
                              : t('no_records_yet'),
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty || _selectedFilter != 'all'
                              ? t('change_search_conditions')
                              : t('take_photo_to_analyze'),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
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
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: Text(t('reset_filter')),
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
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .shadow
                              .withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          t('total_records'),
                          state.results.length.toString(),
                          Icons.analytics_outlined,
                          TeaGardenTheme.infoColor,
                        ),
                        _buildStatItem(
                          t('displaying'),
                          filteredResults.length.toString(),
                          Icons.visibility_outlined,
                          TeaGardenTheme.successColor,
                        ),
                        _buildStatItem(
                          t('this_week'),
                          state.results
                              .where((r) {
                                final DateTime now = DateTime.now();
                                return now.difference(r.timestamp).inDays <= 7;
                              })
                              .length
                              .toString(),
                          Icons.calendar_today_outlined,
                          TeaGardenTheme.warningColor,
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
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.filter_alt,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _buildFilterText(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.primary,
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
                                size: 16,
                                color: Theme.of(context).colorScheme.primary),
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

            return Center(child: Text(t('unknown_state')));
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
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
          filterText = t('growth_stage_filter');
          break;
        case 'health_status':
          filterText = t('healthy_tea_filter');
          break;
        case 'recent':
          filterText = t('recent_week');
          break;
      }
    }
    if (_searchQuery.isNotEmpty) {
      filterText += filterText.isNotEmpty ? ' + ' : '';
      filterText += t('search_query', params: {'query': _searchQuery});
    }
    return filterText;
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('search')),
        content: TextField(
          decoration: InputDecoration(
            hintText: t('search_hint'),
            border: const OutlineInputBorder(),
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
            child: Text(t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('search')),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('filter')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(t('all')),
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
              title: Text(t('growth_stage_filter')),
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
              title: Text(t('healthy_tea_filter')),
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
              title: Text(t('recent_week')),
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
