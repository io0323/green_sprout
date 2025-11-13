import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
import '../../features/camera/data/datasources/camera_local_datasource.dart';
import '../../features/camera/data/datasources/camera_local_datasource_impl.dart';
import '../../features/camera/data/datasources/web_mock_camera_datasource.dart';
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
Future<void> init() async {
  // データソース - プラットフォームに応じて実装を切り替え
  if (PlatformUtils.isWeb) {
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
      ));

  sl.registerFactory(() => CameraCubit(
        initializeCamera: sl(),
        captureImage: sl(),
        disposeCamera: sl(),
        checkCameraInitialized: sl(),
        cameraRepository: sl(),
      ));

  // クラウド同期サービス
  sl.registerLazySingleton<http.Client>(() => http.Client());
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
  sl.registerFactoryAsync(() async => CloudSyncCubit(
        cloudSyncService: await sl.getAsync<CloudSyncService>(),
        offlineSyncQueue: await sl.getAsync<OfflineSyncQueue>(),
        syncStatusNotifier: sl<SyncStatusNotifier>(),
        teaAnalysisRepository: sl(),
      ));
}
