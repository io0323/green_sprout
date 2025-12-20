import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_constants.dart';
import '../di/injection_container.dart';
import '../services/localization_service.dart';
import '../utils/platform_utils.dart';
import '../../features/camera/presentation/bloc/camera_cubit.dart';
import '../../features/camera/presentation/pages/camera_page.dart';
import '../../features/logs/presentation/pages/log_list_page.dart';
import '../../features/tea_analysis/presentation/bloc/analysis_cubit.dart';
import '../../features/tea_analysis/presentation/bloc/tea_analysis_cubit.dart';
import '../../features/tea_analysis/presentation/pages/analysis_result_page.dart';

/*
 * アプリ内ルーティング（Navigator.pushNamed）を一元管理する
 * - named route の未定義による実行時クラッシュを防ぐ
 * - RouteNames の変更をここに集約する
 */
class AppRouter {
  /*
   * named route の解決
   * - 必要な BLoC をここで提供して、画面側の前提を満たす
   */
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name;

    /*
     * Web では native カメラ等が未サポートなケースがあるため、
     * まずはルート解決だけを保証し、機能は案内画面へフォールバックする。
     */
    if (PlatformUtils.isWeb) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => _unsupportedOnWebPage(routeName: name),
      );
    }

    switch (name) {
      case RouteNames.camera:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider<CameraCubit>(
            create: (_) => sl<CameraCubit>(),
            child: const CameraPage(),
          ),
        );

      case RouteNames.analysis:
        final args = settings.arguments;
        final imagePath = args is String ? args : null;
        if (imagePath == null || imagePath.isEmpty) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => _invalidArgumentsPage(
              routeName: name,
              expected: 'String (imagePath)',
            ),
          );
        }

        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider<AnalysisCubit>(
                create: (_) => sl<AnalysisCubit>(),
              ),
              BlocProvider<TeaAnalysisCubit>(
                create: (_) => sl<TeaAnalysisCubit>(),
              ),
            ],
            child: AnalysisResultPage(imagePath: imagePath),
          ),
        );

      case RouteNames.logs:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider<TeaAnalysisCubit>(
            create: (_) => sl<TeaAnalysisCubit>(),
            child: const LogListPage(),
          ),
        );

      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => _unknownRoutePage(routeName: name),
        );
    }
  }

  /*
   * ルートが見つからない場合のフォールバック画面
   */
  static Widget _unknownRoutePage({required String? routeName}) {
    final loc = LocalizationService.instance;
    final routeText = routeName ?? '(null)';
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('router_unknown_route_title')),
      ),
      body: Center(
        child: Text(
          loc.translate(
            'router_unknown_route_message',
            params: {'route': routeText},
          ),
        ),
      ),
    );
  }

  /*
   * 引数不正時のフォールバック画面
   */
  static Widget _invalidArgumentsPage({
    required String? routeName,
    required String expected,
  }) {
    final loc = LocalizationService.instance;
    final routeText = routeName ?? '(null)';
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('router_invalid_navigation_title')),
      ),
      body: Center(
        child: Text(
          loc.translate(
            'router_invalid_arguments_message',
            params: {
              'route': routeText,
              'expected': expected,
            },
          ),
        ),
      ),
    );
  }

  /*
   * Web で未サポート機能へ遷移した場合の案内画面
   */
  static Widget _unsupportedOnWebPage({required String? routeName}) {
    final loc = LocalizationService.instance;
    final routeText = routeName ?? '(null)';
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('router_web_unsupported_title')),
      ),
      body: Center(
        child: Text(
          loc.translate(
            'router_web_unsupported_message',
            params: {'route': routeText},
          ),
        ),
      ),
    );
  }
}
