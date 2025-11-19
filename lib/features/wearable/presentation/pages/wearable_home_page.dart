import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/wearable_analysis_result.dart';
import '../widgets/wearable_result_card.dart';
import '../widgets/wearable_camera_button.dart';
import '../widgets/wearable_error_widget.dart';
import '../../../camera/presentation/pages/camera_page.dart';
import '../../../tea_analysis/presentation/pages/analysis_result_page.dart';
import '../../../tea_analysis/domain/usecases/tea_analysis_usecases.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/errors/failures.dart';

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
          if (kDebugMode) debugPrint('解析結果の読み込みエラー: $failure');
          if (kDebugMode) debugPrint('エラータイプ: ${failure.runtimeType}');
          if (kDebugMode) debugPrint('エラーメッセージ: ${failure.message}');
          if (kDebugMode && failure.code != null)
            debugPrint('エラーコード: ${failure.code}');

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
      if (kDebugMode) debugPrint('解析結果の読み込みエラー: $e');
      if (kDebugMode) debugPrint('スタックトレース: $stackTrace');

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
    final localization = LocalizationService.instance;

    if (failure is ServerFailure) {
      return localization.translate('error_server_detail',
          params: {'message': failure.message});
    } else if (failure is CacheFailure) {
      return localization.translate('error_cache_detail',
          params: {'message': failure.message});
    } else if (failure is NetworkFailure) {
      return localization.translate('error_network_detail',
          params: {'message': failure.message});
    } else if (failure is CameraFailure) {
      return localization.translate('error_camera_detail',
          params: {'message': failure.message});
    } else if (failure is TFLiteFailure) {
      return localization
          .translate('error_ai_detail', params: {'message': failure.message});
    } else {
      return localization.translate('error_unknown_detail',
          params: {'message': failure.message});
    }
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
          } catch (e) {
            if (kDebugMode) debugPrint('解析結果画面への遷移エラー: $e');
            if (mounted) {
              final localization = LocalizationService.instance;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    localization.translate('error_navigation'),
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        } else if (result['error'] != null && mounted) {
          // カメラ画面からエラーが返された場合
          final errorMessage = result['error'] as String;
          if (kDebugMode) debugPrint('カメラ画面からのエラー: $errorMessage');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) debugPrint('カメラ画面への遷移エラー: $e');
      if (kDebugMode) debugPrint('スタックトレース: $stackTrace');
      if (mounted) {
        final localization = LocalizationService.instance;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localization.translate('error_camera_navigation'),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService.instance;
    final isWearable = PlatformUtils.isWearable;

    return Scaffold(
      backgroundColor: Colors.green[50],
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                localization.translate('app_title'),
                style: TextStyle(
                  fontSize: isWearable ? 16 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // カメラボタン
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  localization.translate('no_results'),
                                  style: TextStyle(
                                    fontSize: isWearable ? 12 : 14,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(8.0),
                              itemCount: _recentResults.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
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
