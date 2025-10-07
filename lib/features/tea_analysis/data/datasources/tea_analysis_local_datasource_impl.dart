import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/tea_analysis_result.dart';
import '../models/tea_analysis_result_model.dart';
import '../datasources/tea_analysis_local_datasource.dart';

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
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.teaAnalysisTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_path TEXT NOT NULL,
        growth_stage TEXT NOT NULL,
        health_status TEXT NOT NULL,
        confidence REAL NOT NULL,
        comment TEXT,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  @override
  Future<Either<Failure, void>> saveAnalysisResult(TeaAnalysisResult result) async {
    try {
      final db = await database;
      final model = TeaAnalysisResultModel.fromEntity(result);
      
      await db.insert(
        AppConstants.teaAnalysisTable,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      return Right(null);
    } catch (e) {
      return Left(CacheFailure('データの保存に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>> getAnalysisResults() async {
    try {
      final db = await database;
      final maps = await db.query(
        AppConstants.teaAnalysisTable,
        orderBy: 'timestamp DESC',
      );
      
      final results = maps.map((map) => TeaAnalysisResultModel.fromMap(map).toEntity()).toList();
      return Right(results);
    } catch (e) {
      return Left(CacheFailure('データの読み込みに失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAnalysisResult(int id) async {
    try {
      final db = await database;
      await db.delete(
        AppConstants.teaAnalysisTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      return Right(null);
    } catch (e) {
      return Left(CacheFailure('データの削除に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateAnalysisResult(TeaAnalysisResult result) async {
    try {
      final db = await database;
      final model = TeaAnalysisResultModel.fromEntity(result);
      
      await db.update(
        AppConstants.teaAnalysisTable,
        model.toMap(),
        where: 'id = ?',
        whereArgs: [result.id],
      );
      
      return Right(null);
    } catch (e) {
      return Left(CacheFailure('データの更新に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>> getTodayAnalysisResults() async {
    try {
      final db = await database;
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final maps = await db.query(
        AppConstants.teaAnalysisTable,
        where: 'timestamp >= ? AND timestamp < ?',
        whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
        orderBy: 'timestamp DESC',
      );
      
      final results = maps.map((map) => TeaAnalysisResultModel.fromMap(map).toEntity()).toList();
      return Right(results);
    } catch (e) {
      return Left(CacheFailure('今日のデータの読み込みに失敗しました: $e'));
    }
  }
}