import 'package:flutter/material.dart';
import '../../domain/entities/wearable_analysis_result.dart';
import '../widgets/wearable_result_card.dart';
import '../widgets/wearable_camera_button.dart';
import '../widgets/wearable_error_widget.dart';
import '../../../camera/presentation/pages/camera_page.dart';
import '../../../tea_analysis/presentation/pages/analysis_result_page.dart';
import '../../../tea_analysis/domain/usecases/tea_analysis_usecases.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/failure_message_mapper.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/errors/failures.dart';
import '../../../../core/widgets/snackbar_helper.dart';
import '../../../../core/theme/tea_garden_theme.dart';

/// ウェアラブルデバイス用のホームページ
/// 簡潔なUIで茶葉解析結果を表示
class WearableHomePage extends StatefulWidget {
  const WearableHomePage({super.key});

  @override
  State<WearableHomePage> createState() => _WearableHomePageState();
}

class _WearableHomePageState extends State<WearableHomePage> {
  List<WearableAnalysisResult> _recentResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  Failure? _failure;
  late final GetAllTeaAnalysisResults _getAllTeaAnalysisResults;

  @override
  void initState() {
    super.initState();
    _getAllTeaAnalysisResults = di.sl<GetAllTeaAnalysisResults>();
    _loadRecentResults();
  }

  /// 最近の解析結果を読み込む
  /// 実際のデータソースから最新の解析結果を取得し、
  /// ウェアラブル用の形式に変換して表示する
  Future<void> _loadRecentResults() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _failure = null;
    });

    try {
      final result = await _getAllTeaAnalysisResults();

      result.fold(
        (failure) {
          AppLogger.logFailure('解析結果の読み込みエラー', failure);

          final errorMessage = _mapFailureToMessage(failure);

          setState(() {
            _isLoading = false;
            _recentResults.clear();
            _errorMessage = errorMessage;
            _failure = failure;
          });
        },
        (teaResults) {
          // 最新の10件を取得（タイムスタンプでソート）
          final sortedResults = teaResults.toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          final recentTeaResults = sortedResults.take(10).toList();

          // TeaAnalysisResultをWearableAnalysisResultに変換
          final wearableResults = recentTeaResults
              .map((result) =>
                  WearableAnalysisResult.fromTeaAnalysisResult(result))
              .toList();

          setState(() {
            _recentResults = wearableResults;
            _isLoading = false;
            _errorMessage = null;
            _failure = null;
          });
        },
      );
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        '解析結果の読み込みエラー',
        e,
        stackTrace,
      );

      final localization = LocalizationService.instance;
      final errorMessage = localization.translate('error_loading_data');

      setState(() {
        _isLoading = false;
        _recentResults.clear();
        _errorMessage = '$errorMessage: ${e.toString()}';
        _failure = GenericFailure(e.toString());
      });
    }
  }

  /// エラーをユーザーフレンドリーなメッセージに変換
  String _mapFailureToMessage(Failure failure) {
    return FailureMessageMapper.mapToMessage(failure);
  }

  /// カメラ画面に遷移
  Future<void> _navigateToCamera() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CameraPage(),
        ),
      );

      if (result != null && mounted) {
        // 解析結果画面に遷移
        final imagePath = result['imagePath'] as String?;
        if (imagePath != null) {
          try {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AnalysisResultPage(
                  imagePath: imagePath,
                ),
              ),
            );
            // 解析結果画面から戻ったら、結果を再読み込み
            _loadRecentResults();
          } catch (e, stackTrace) {
            AppLogger.logErrorWithStackTrace(
              '解析結果画面への遷移エラー',
              e,
              stackTrace,
            );
            if (mounted) {
              SnackBarHelper.showError(
                context,
                LocalizationService.instance.translate('error_navigation'),
              );
            }
          }
        } else if (result['error'] != null && mounted) {
          // カメラ画面からエラーが返された場合
          final errorMessage = result['error'] as String;
          AppLogger.debugError('カメラ画面からのエラー', errorMessage);
          if (mounted) {
            SnackBarHelper.showError(context, errorMessage);
          }
        }
      }
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        'カメラ画面への遷移エラー',
        e,
        stackTrace,
      );
      if (mounted) {
        SnackBarHelper.showError(
          context,
          LocalizationService.instance.translate('error_camera_navigation'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService.instance;
    final isWearable = PlatformUtils.isWearable;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.all(TeaGardenTheme.spacingS),
              child: Text(
                localization.translate('app_title'),
                style: TextStyle(
                  fontSize: isWearable
                      ? TeaGardenTheme.titleFontSizeWearable
                      : TeaGardenTheme.titleFontSizeDefault,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // カメラボタン
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TeaGardenTheme.spacingM,
                vertical: TeaGardenTheme.spacingS,
              ),
              child: WearableCameraButton(
                onPressed: _navigateToCamera,
              ),
            ),

            // 最近の結果
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? WearableErrorWidget(
                          message: _errorMessage!,
                          failure: _failure,
                          onRetry: _loadRecentResults,
                        )
                      : _recentResults.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(
                                    TeaGardenTheme.spacingM),
                                child: Text(
                                  localization.translate('no_results'),
                                  style: TextStyle(
                                    fontSize: isWearable
                                        ? TeaGardenTheme.wearableFontSizeSmall
                                        : TeaGardenTheme.bodyMedium.fontSize,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.all(TeaGardenTheme.spacingS),
                              itemCount: _recentResults.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: TeaGardenTheme.spacingS,
                                  ),
                                  child: WearableResultCard(
                                    result: _recentResults[index],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
