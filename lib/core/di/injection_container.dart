import 'package:get_it/get_it.dart';
import '../features/tea_analysis/data/datasources/analysis_local_datasource.dart';
import '../features/tea_analysis/data/datasources/analysis_local_datasource_impl.dart';
import '../features/tea_analysis/data/datasources/tea_analysis_local_datasource.dart';
import '../features/tea_analysis/data/datasources/tea_analysis_local_datasource_impl.dart';
import '../features/tea_analysis/data/repositories/analysis_repository_impl.dart';
import '../features/tea_analysis/data/repositories/tea_analysis_repository_impl.dart';
import '../features/tea_analysis/domain/repositories/analysis_repository.dart';
import '../features/tea_analysis/domain/repositories/tea_analysis_repository.dart';
import '../features/tea_analysis/domain/usecases/analysis_usecases.dart';
import '../features/tea_analysis/domain/usecases/tea_analysis_usecases.dart';
import '../features/camera/data/datasources/camera_local_datasource.dart';
import '../features/camera/data/datasources/camera_local_datasource_impl.dart';
import '../features/camera/data/repositories/camera_repository_impl.dart';
import '../features/camera/domain/repositories/camera_repository.dart';
import '../features/camera/domain/usecases/camera_usecases.dart';
import '../features/tea_analysis/presentation/bloc/tea_analysis_cubit.dart';
import '../features/tea_analysis/presentation/bloc/analysis_cubit.dart';
import '../features/camera/presentation/bloc/camera_cubit.dart';

/**
 * 依存性注入コンテナ
 * GetItを使用してDIを管理
 */
final GetIt sl = GetIt.instance;

/**
 * 依存性注入の初期化
 * アプリ起動時に呼び出される
 */
Future<void> init() async {
  // データソース
  sl.registerLazySingleton<TeaAnalysisLocalDataSource>(
    () => TeaAnalysisLocalDataSourceImpl(),
  );
  
  sl.registerLazySingleton<AnalysisLocalDataSource>(
    () => AnalysisLocalDataSourceImpl(),
  );
  
  sl.registerLazySingleton<CameraLocalDataSource>(
    () => CameraLocalDataSourceImpl(),
  );

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
  sl.registerLazySingleton(() => GetAllTeaAnalyses(sl()));
  sl.registerLazySingleton(() => GetTeaAnalysis(sl()));
  sl.registerLazySingleton(() => SaveTeaAnalysis(sl()));
  sl.registerLazySingleton(() => UpdateTeaAnalysis(sl()));
  sl.registerLazySingleton(() => DeleteTeaAnalysis(sl()));
  sl.registerLazySingleton(() => GetTeaAnalysesByDateRange(sl()));
  sl.registerLazySingleton(() => GetTeaAnalysesByGrowthStage(sl()));
  sl.registerLazySingleton(() => GetTodayTeaAnalyses(sl()));
  sl.registerLazySingleton(() => GetRecentTeaAnalyses(sl()));

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
    getAllTeaAnalyses: sl(),
    getTodayTeaAnalyses: sl(),
    getRecentTeaAnalyses: sl(),
    saveTeaAnalysis: sl(),
    updateTeaAnalysis: sl(),
    deleteTeaAnalysis: sl(),
  ));
  
  sl.registerFactory(() => AnalysisCubit(
    loadModel: sl(),
    analyzeImage: sl(),
    checkModelLoaded: sl(),
  ));
  
  sl.registerFactory(() => CameraCubit(
    initializeCamera: sl(),
    captureImage: sl(),
    disposeCamera: sl(),
    checkCameraInitialized: sl(),
  ));
}
