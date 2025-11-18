import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/wearable_analysis_result.dart';
import '../widgets/wearable_result_card.dart';
import '../widgets/wearable_camera_button.dart';
import '../../../camera/presentation/pages/camera_page.dart';
import '../../../tea_analysis/presentation/pages/analysis_result_page.dart';
import '../../../../core/services/localization_service.dart';
import '../../../../core/utils/platform_utils.dart';

/// ウェアラブルデバイス用のホームページ
/// 簡潔なUIで茶葉解析結果を表示
class WearableHomePage extends StatefulWidget {
  const WearableHomePage({super.key});

  @override
  State<WearableHomePage> createState() => _WearableHomePageState();
}

class _WearableHomePageState extends State<WearableHomePage> {
  final List<WearableAnalysisResult> _recentResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRecentResults();
  }

  /// 最近の解析結果を読み込む
  Future<void> _loadRecentResults() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 実際のデータソースから読み込む
      // 現在はモックデータを使用
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) debugPrint('解析結果の読み込みエラー: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// カメラ画面に遷移
  Future<void> _navigateToCamera() async {
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
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultPage(
              imagePath: imagePath,
            ),
          ),
        );
        _loadRecentResults();
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
