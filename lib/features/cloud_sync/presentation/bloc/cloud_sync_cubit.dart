import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/cloud_sync_service.dart';
import '../../../../core/errors/failures.dart';
import '../../../../features/tea_analysis/domain/repositories/tea_analysis_repository.dart';
import '../../../../core/utils/app_logger.dart';

/// クラウド同期の状態
abstract class CloudSyncState {}

/// 初期状態
class CloudSyncInitial extends CloudSyncState {}

/// 接続確認中
class CloudSyncCheckingConnection extends CloudSyncState {}

/// 接続済み
class CloudSyncConnected extends CloudSyncState {}

/// オフライン
class CloudSyncOffline extends CloudSyncState {}

/// 同期中
class CloudSyncSyncing extends CloudSyncState {
  final int pendingItems;
  final String message;

  CloudSyncSyncing({
    this.pendingItems = 0,
    this.message = '同期中...',
  });
}

/// 同期成功
class CloudSyncSuccess extends CloudSyncState {
  final String message;
  final int syncedItems;

  CloudSyncSuccess({
    this.message = '同期完了',
    this.syncedItems = 0,
  });
}

/// 同期エラー
class CloudSyncError extends CloudSyncState {
  final String message;

  CloudSyncError(this.message);
}

/// 自動同期設定状態
class CloudSyncAutoSyncState extends CloudSyncState {
  final bool enabled;

  CloudSyncAutoSyncState(this.enabled);
}

/// クラウド同期のCubit
/// クラウド同期機能の状態管理とビジネスロジック
class CloudSyncCubit extends Cubit<CloudSyncState> {
  final CloudSyncService cloudSyncService;
  final OfflineSyncQueue offlineSyncQueue;
  final SyncStatusNotifier syncStatusNotifier;
  final TeaAnalysisRepository teaAnalysisRepository;

  CloudSyncCubit({
    required this.cloudSyncService,
    required this.offlineSyncQueue,
    required this.syncStatusNotifier,
    required this.teaAnalysisRepository,
    bool skipInitialization = false,
  }) : super(CloudSyncInitial()) {
    if (!skipInitialization) {
      _initialize();
    }
  }

  /// 初期化処理
  Future<void> _initialize() async {
    await checkConnection();
    await loadAutoSyncStatus();
  }

  /// 接続状態を確認
  Future<void> checkConnection() async {
    emit(CloudSyncCheckingConnection());
    try {
      final isConnected = await cloudSyncService.isConnected();
      if (isConnected) {
        emit(CloudSyncConnected());
        syncStatusNotifier.setStatus(SyncStatus.idle);
      } else {
        emit(CloudSyncOffline());
        syncStatusNotifier.setOffline();
      }
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        '接続確認エラー',
        e,
        stackTrace,
      );
      emit(CloudSyncOffline());
      syncStatusNotifier.setOffline();
    }
  }

  /// クラウドに同期
  Future<void> syncToCloud() async {
    try {
      // 接続確認
      final isConnected = await cloudSyncService.isConnected();
      if (!isConnected) {
        emit(CloudSyncOffline());
        syncStatusNotifier.setOffline();
        return;
      }

      // ローカルの全データを取得
      final localResults =
          await teaAnalysisRepository.getAllTeaAnalysisResults();
      if (localResults.isLeft()) {
        emit(CloudSyncError('データの取得に失敗しました'));
        return;
      }

      final results = localResults.fold(
        (failure) => <dynamic>[],
        (results) => results,
      );

      if (results.isEmpty) {
        emit(CloudSyncSuccess(message: '同期するデータがありません'));
        return;
      }

      // 同期開始
      emit(CloudSyncSyncing(
        pendingItems: results.length,
        message: 'クラウドに同期中...',
      ));
      syncStatusNotifier.setSyncing(pendingItems: results.length);

      // クラウドに送信
      await cloudSyncService.syncToCloud(
        results.cast(),
      );

      // オフラインキューをクリア
      await offlineSyncQueue.clearQueue();

      emit(CloudSyncSuccess(
        message: '同期が完了しました',
        syncedItems: results.length,
      ));
      syncStatusNotifier.setSuccess(
        message: '${results.length}件のデータを同期しました',
      );
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        'クラウド同期エラー（送信）',
        e,
        stackTrace,
      );
      final errorMessage =
          e is ServerFailure ? e.message : '同期エラー: ${e.toString()}';
      emit(CloudSyncError(errorMessage));
      syncStatusNotifier.setError(errorMessage);
    }
  }

  /// クラウドから同期
  Future<void> syncFromCloud() async {
    try {
      // 接続確認
      final isConnected = await cloudSyncService.isConnected();
      if (!isConnected) {
        emit(CloudSyncOffline());
        syncStatusNotifier.setOffline();
        return;
      }

      emit(CloudSyncSyncing(message: 'クラウドから同期中...'));
      syncStatusNotifier.setSyncing();

      // クラウドから取得
      final cloudResults = await cloudSyncService.syncFromCloud();

      if (cloudResults.isEmpty) {
        emit(CloudSyncSuccess(message: '新しいデータはありません'));
        syncStatusNotifier.setSuccess(message: '最新の状態です');
        return;
      }

      // ローカルに保存
      for (final result in cloudResults) {
        await teaAnalysisRepository.saveTeaAnalysisResult(result);
      }

      emit(CloudSyncSuccess(
        message: '${cloudResults.length}件のデータを取得しました',
        syncedItems: cloudResults.length,
      ));
      syncStatusNotifier.setSuccess(
        message: '${cloudResults.length}件のデータを取得しました',
      );
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        'クラウド同期エラー（受信）',
        e,
        stackTrace,
      );
      final errorMessage =
          e is ServerFailure ? e.message : '同期エラー: ${e.toString()}';
      emit(CloudSyncError(errorMessage));
      syncStatusNotifier.setError(errorMessage);
    }
  }

  /// 双方向同期
  Future<void> syncBothWays() async {
    try {
      // まずクラウドに送信
      await syncToCloud();
      // 次にクラウドから取得
      await syncFromCloud();
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        '双方向同期エラー',
        e,
        stackTrace,
      );
      emit(CloudSyncError('同期エラー: ${e.toString()}'));
    }
  }

  /// 自動同期を有効化/無効化
  Future<void> toggleAutoSync(bool enabled) async {
    await cloudSyncService.enableAutoSync(enabled);
    emit(CloudSyncAutoSyncState(enabled));
  }

  /// 自動同期の状態を読み込み
  Future<void> loadAutoSyncStatus() async {
    final enabled = await cloudSyncService.isAutoSyncEnabled();
    emit(CloudSyncAutoSyncState(enabled));
  }

  /// オフラインキューを処理
  Future<void> processOfflineQueue() async {
    try {
      final isConnected = await cloudSyncService.isConnected();
      if (!isConnected) {
        return;
      }

      final queue = await offlineSyncQueue.getQueue();
      if (queue.isEmpty) {
        return;
      }

      emit(CloudSyncSyncing(
        pendingItems: queue.length,
        message: 'オフラインキューを処理中...',
      ));

      await cloudSyncService.syncToCloud(queue);
      await offlineSyncQueue.clearQueue();

      emit(CloudSyncSuccess(
        message: '${queue.length}件のデータを同期しました',
        syncedItems: queue.length,
      ));
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        'オフラインキュー処理エラー',
        e,
        stackTrace,
      );
      emit(CloudSyncError('オフラインキューの処理に失敗しました'));
    }
  }
}
