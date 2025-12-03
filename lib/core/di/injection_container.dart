import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../utils/platform_utils.dart';
import '../../features/tea_analysis/data/datasources/analysis_local_datasource.dart';
import '../../features/tea_analysis/data/datasources/analysis_local_datasource_impl.dart';
import '../../features/tea_analysis/data/datasources/web_mock_analysis_datasource.dart';
import '../../features/tea_analysis/data/datasources/tea_analysis_local_datasource.dart';
import '../../features/tea_analysis/data/datasources/tea_analysis_local_datasource_impl.dart';
import '../../features/tea_analysis/data/datasources/web_mock_tea_analysis_datasource.dart';
import '../../features/tea_analysis/data/repositories/analysis_repository_impl.dart';
import '../../features/tea_analysis/data/repositories/tea_analysis_repository_impl.dart';
import '../../features/tea_analysis/domain/repositories/analysis_repository.dart';
import '../../features/tea_analysis/domain/repositories/tea_analysis_repository.dart';
import '../../features/tea_analysis/domain/usecases/analysis_usecases.dart';
import '../../features/tea_analysis/domain/usecases/tea_analysis_usecases.dart';
import '../../features/tea_analysis/domain/usecases/advanced_analysis_usecases.dart';
import '../../core/engines/advanced_analysis_engine.dart';
import '../../features/camera/data/datasources/camera_local_datasource.dart';
import '../../features/camera/data/datasources/camera_local_datasource_impl.dart';
import '../../features/camera/data/datasources/web_mock_camera_datasource.dart';
import '../../features/camera/data/datasources/fake_camera_datasource.dart';
import '../../features/camera/data/repositories/camera_repository_impl.dart';
import '../../features/camera/domain/repositories/camera_repository.dart';
import '../../features/camera/domain/usecases/camera_usecases.dart';
import '../../features/tea_analysis/presentation/bloc/tea_analysis_cubit.dart';
import '../../features/tea_analysis/presentation/bloc/analysis_cubit.dart';
import '../../features/camera/presentation/bloc/camera_cubit.dart';
import '../services/cloud_sync_service.dart';
import '../../features/cloud_sync/presentation/bloc/cloud_sync_cubit.dart';

/// 依存性注入コンテナ
/// GetItを使用してDIを管理
final GetIt sl = GetIt.instance;

/// 依存性注入の初期化
/// アプリ起動時に呼び出される
/// [testing] が true の場合、テスト用の設定で初期化する
Future<void> init({bool testing = false}) async {
  // データソース - プラットフォームに応じて実装を切り替え
  if (testing) {
    // テストモードではFake実装を使用
    sl.registerLazySingleton<TeaAnalysisLocalDataSource>(
      () => WebMockTeaAnalysisDataSource(),
    );

    sl.registerLazySingleton<AnalysisLocalDataSource>(
      () => WebMockAnalysisDataSource(),
    );

    sl.registerLazySingleton<CameraLocalDataSource>(
      () => FakeCameraDataSource(),
    );
  } else if (PlatformUtils.isWeb) {
    // Webプラットフォーム用のモック実装
    sl.registerLazySingleton<TeaAnalysisLocalDataSource>(
      () => WebMockTeaAnalysisDataSource(),
    );

    sl.registerLazySingleton<AnalysisLocalDataSource>(
      () => WebMockAnalysisDataSource(),
    );

    sl.registerLazySingleton<CameraLocalDataSource>(
      () => WebMockCameraDataSource(),
    );
  } else {
    // モバイルプラットフォーム用の実装
    sl.registerLazySingleton<TeaAnalysisLocalDataSource>(
      () => TeaAnalysisLocalDataSourceImpl(),
    );

    sl.registerLazySingleton<AnalysisLocalDataSource>(
      () => AnalysisLocalDataSourceImpl(),
    );

    sl.registerLazySingleton<CameraLocalDataSource>(
      () => CameraLocalDataSourceImpl(),
    );
  }

  // リポジトリ
  sl.registerLazySingleton<TeaAnalysisRepository>(
    () => TeaAnalysisRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<AnalysisRepository>(
    () => AnalysisRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<CameraRepository>(
    () => CameraRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  // ユースケース - Tea Analysis
  sl.registerLazySingleton(() => GetAllTeaAnalysisResults(sl()));
  sl.registerLazySingleton(() => GetTeaAnalysisResultsForDate(sl()));
  sl.registerLazySingleton(() => SaveTeaAnalysisResult(sl()));
  sl.registerLazySingleton(() => UpdateTeaAnalysisResult(sl()));
  sl.registerLazySingleton(() => DeleteTeaAnalysisResult(sl()));

  // ユースケース - Analysis
  sl.registerLazySingleton(() => LoadAnalysisModel(sl()));
  sl.registerLazySingleton(() => AnalyzeImage(sl()));
  sl.registerLazySingleton(() => CheckModelLoaded(sl()));

  // 高度な解析エンジン
  sl.registerLazySingleton<AdvancedAnalysisEngine>(
    () => AdvancedAnalysisEngine(),
  );

  // ユースケース - Advanced Analysis
  sl.registerLazySingleton(
    () => AdvancedAnalyzeImage(sl<AdvancedAnalysisEngine>()),
  );
  sl.registerLazySingleton(
    () => InitializeAdvancedAnalysisEngine(sl<AdvancedAnalysisEngine>()),
  );

  // ユースケース - Camera
  sl.registerLazySingleton(() => InitializeCamera(sl()));
  sl.registerLazySingleton(() => CaptureImage(sl()));
  sl.registerLazySingleton(() => DisposeCamera(sl()));
  sl.registerLazySingleton(() => CheckCameraInitialized(sl()));

  // BLoC
  sl.registerFactory(() => TeaAnalysisCubit(
        getAllTeaAnalysisResults: sl(),
        getTeaAnalysisResultsForDate: sl(),
        saveTeaAnalysisResult: sl(),
        updateTeaAnalysisResult: sl(),
        deleteTeaAnalysisResult: sl(),
      ));

  sl.registerFactory(() => AnalysisCubit(
        loadAnalysisModel: sl(),
        analyzeImage: sl(),
        checkModelLoaded: sl(),
        advancedAnalyzeImage: sl(),
        initializeAdvancedAnalysisEngine: sl(),
      ));

  sl.registerFactory(() => CameraCubit(
        initializeCamera: sl(),
        captureImage: sl(),
        disposeCamera: sl(),
        checkCameraInitialized: sl(),
        cameraRepository: sl(),
      ));

  // クラウド同期サービス
  if (testing) {
    // テストモードではモックHTTPクライアントを使用
    sl.registerLazySingleton<http.Client>(() => _TestHttpClient());
  } else {
    sl.registerLazySingleton<http.Client>(() => http.Client());
  }
  sl.registerLazySingletonAsync<SharedPreferences>(
    () => SharedPreferences.getInstance(),
  );
  sl.registerLazySingletonAsync<CloudSyncService>(
    () async => CloudSyncServiceImpl(
      httpClient: sl(),
      prefs: await sl.getAsync<SharedPreferences>(),
    ),
  );
  sl.registerLazySingletonAsync<OfflineSyncQueue>(
    () async => OfflineSyncQueue(await sl.getAsync<SharedPreferences>()),
  );
  sl.registerLazySingleton<SyncStatusNotifier>(
    () => SyncStatusNotifier(),
  );

  // クラウド同期BLoC
  sl.registerFactoryAsync(() async {
    final cubit = CloudSyncCubit(
      cloudSyncService: await sl.getAsync<CloudSyncService>(),
      offlineSyncQueue: await sl.getAsync<OfflineSyncQueue>(),
      syncStatusNotifier: sl<SyncStatusNotifier>(),
      teaAnalysisRepository: sl(),
      skipInitialization: testing, // テストモードでは初期化をスキップ
    );
    return cubit;
  });
}

/// テスト用のHTTPクライアント
/// すべてのHTTPリクエストに対して即座に成功レスポンスを返す
class _TestHttpClient implements http.Client {
  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return http.Response('{}', 200,
        headers: {'content-type': 'application/json'});
  }

  @override
  Future<http.Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return http.Response('{}', 200,
        headers: {'content-type': 'application/json'});
  }

  @override
  Future<http.Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return http.Response('{}', 200,
        headers: {'content-type': 'application/json'});
  }

  @override
  Future<http.Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return http.Response('{}', 200,
        headers: {'content-type': 'application/json'});
  }

  @override
  Future<http.Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return http.Response('{}', 200,
        headers: {'content-type': 'application/json'});
  }

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) async {
    return http.Response('', 200,
        headers: {'content-type': 'application/json'});
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) async {
    return '{}';
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) async {
    return Uint8List.fromList(utf8.encode('{}'));
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(
      Stream.value(utf8.encode('{}')),
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  @override
  void close() {}
}
