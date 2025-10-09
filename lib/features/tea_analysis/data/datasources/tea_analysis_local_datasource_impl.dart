import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/tea_analysis_result.dart';
import '../models/tea_analysis_result_model.dart';
import 'tea_analysis_local_datasource.dart';

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
        id TEXT PRIMARY KEY,
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
  Future<Either<Failure, TeaAnalysisResult>> saveTeaAnalysisResult(TeaAnalysisResult result) async {
    try {
      final db = await database;
      final model = TeaAnalysisResultModel.fromEntity(result);

      await db.insert(
        AppConstants.teaAnalysisTable,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Right(result);
    } catch (e) {
      return Left(CacheFailure('データの保存に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>> getAllTeaAnalysisResults() async {
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
  Future<Either<Failure, Unit>> deleteTeaAnalysisResult(String id) async {
    try {
      final db = await database;
      await db.delete(
        AppConstants.teaAnalysisTable,
        where: 'id = ?',
        whereArgs: [id],
      );

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('データの削除に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, TeaAnalysisResult>> updateTeaAnalysisResult(TeaAnalysisResult result) async {
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
    } catch (e) {
      return Left(CacheFailure('データの更新に失敗しました: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TeaAnalysisResult>>> getTeaAnalysisResultsForDate(DateTime date) async {
    try {
      final db = await database;
      final startOfDay = DateTime(date.year, date.month, date.day);
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
      return Left(CacheFailure('指定日のデータの読み込みに失敗しました: $e'));
    }
  }
}