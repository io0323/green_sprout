import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/tea_analysis_result.dart';
import '../models/tea_analysis_result_model.dart';
import 'tea_analysis_local_datasource.dart';
import '../../../../core/utils/app_logger.dart';

/// 茶葉解析のローカルデータソースの実装
class TeaAnalysisLocalDataSourceImpl implements TeaAnalysisLocalDataSource {
  Database? _database;

  /// データベースを取得（遅延初期化）
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// データベースを初期化
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  /// データベース作成時の処理
  /// インデックスとテーブル最適化を含む
  Future<void> _onCreate(Database db, int version) async {
    // メインテーブルの作成
    await db.execute('''
      CREATE TABLE ${AppConstants.teaAnalysisTable} (
        id TEXT PRIMARY KEY,
        image_path TEXT NOT NULL,
        growth_stage TEXT NOT NULL,
        health_status TEXT NOT NULL,
        confidence REAL NOT NULL,
        comment TEXT,
        timestamp INTEGER NOT NULL,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
        updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
      )
    ''');

    // パフォーマンス向上のためのインデックス作成
    await db.execute('''
      CREATE INDEX idx_tea_analysis_timestamp 
      ON ${AppConstants.teaAnalysisTable} (timestamp DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_tea_analysis_growth_stage 
      ON ${AppConstants.teaAnalysisTable} (growth_stage)
    ''');

    await db.execute('''
      CREATE INDEX idx_tea_analysis_health_status 
      ON ${AppConstants.teaAnalysisTable} (health_status)
    ''');

    await db.execute('''
      CREATE INDEX idx_tea_analysis_date 
      ON ${AppConstants.teaAnalysisTable} (date(timestamp/1000, 'unixepoch'))
    ''');
  }

  @override
  Future<Either<Failure, TeaAnalysisResult>> saveTeaAnalysisResult(
      TeaAnalysisResult result) async {
    Database? db;
    try {
      db = await database;

      // トランザクション内で保存処理を実行
      await db.transaction((txn) async {
        final model = TeaAnalysisResultModel.fromEntity(result);
        final now = DateTime.now().millisecondsSinceEpoch;

        // 更新時刻を設定
        final modelMap = model.toMap();
        modelMap['created_at'] = now;
        modelMap['updated_at'] = now;

        await txn.insert(
          AppConstants.teaAnalysisTable,
          modelMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });

      return Right(result);
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        'データ保存エラー（ローカル）',
        e,
        stackTrace,
      );
      return Left(CacheFailure('データの保存に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>>
      getAllTeaAnalysisResults() async {
    Database? db;
    try {
      db = await database;

      // パフォーマンス向上のためLIMITを設定（必要に応じてページネーション）
      final maps = await db.query(
        AppConstants.teaAnalysisTable,
        orderBy: 'timestamp DESC',
        limit: AppConstants.maxQueryResults, // 最大取得件数
      );

      final results = maps
          .map((map) => TeaAnalysisResultModel.fromMap(map).toEntity())
          .toList();
      return Right(results);
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        'データ読み込みエラー（全件）',
        e,
        stackTrace,
      );
      return Left(CacheFailure('データの読み込みに失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTeaAnalysisResult(String id) async {
    try {
      final db = await database;
      await db.delete(
        AppConstants.teaAnalysisTable,
        where: 'id = ?',
        whereArgs: [id],
      );

      return const Right(unit);
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        'データ削除エラー（ローカル）',
        e,
        stackTrace,
      );
      return Left(CacheFailure('データの削除に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, TeaAnalysisResult>> updateTeaAnalysisResult(
      TeaAnalysisResult result) async {
    try {
      final db = await database;
      final model = TeaAnalysisResultModel.fromEntity(result);

      await db.update(
        AppConstants.teaAnalysisTable,
        model.toMap(),
        where: 'id = ?',
        whereArgs: [result.id],
      );

      return Right(result);
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        'データ更新エラー（ローカル）',
        e,
        stackTrace,
      );
      return Left(CacheFailure('データの更新に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>> getTeaAnalysisResultsForDate(
      DateTime date) async {
    Database? db;
    try {
      db = await database;

      // 日付範囲の計算を最適化
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay =
          startOfDay.add(const Duration(days: AppConstants.daysOne));

      final startTimestamp = startOfDay.millisecondsSinceEpoch;
      final endTimestamp = endOfDay.millisecondsSinceEpoch;

      final maps = await db.query(
        AppConstants.teaAnalysisTable,
        where: 'timestamp >= ? AND timestamp < ?',
        whereArgs: [startTimestamp, endTimestamp],
        orderBy: 'timestamp DESC',
      );

      final results = maps
          .map((map) => TeaAnalysisResultModel.fromMap(map).toEntity())
          .toList();
      return Right(results);
    } catch (e, stackTrace) {
      AppLogger.logErrorWithStackTrace(
        'データ読み込みエラー（日付指定）',
        e,
        stackTrace,
      );
      return Left(CacheFailure('指定日のデータの読み込みに失敗しました: $e'));
    }
  }
}
