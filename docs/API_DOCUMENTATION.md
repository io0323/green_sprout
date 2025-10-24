# Tea Garden AI - API Documentation

## 概要

Tea Garden AIは、TensorFlow Liteを使用した茶葉の成長段階と健康状態を分析するFlutterアプリケーションです。このドキュメントでは、アプリケーションのAPIとアーキテクチャについて説明します。

## アーキテクチャ

### Clean Architecture

アプリケーションはClean Architectureパターンに従って設計されており、以下の層に分かれています：

- **Presentation Layer**: UIとユーザーインタラクション
- **Domain Layer**: ビジネスロジックとエンティティ
- **Data Layer**: データソースとリポジトリ実装
- **Core Layer**: 共通ユーティリティとサービス

### 依存関係注入

GetItを使用して依存関係注入を実装しています。

## API Reference

### Core Services

#### LocalizationService

国際化対応のためのサービス。

```dart
class LocalizationService {
  static LocalizationService get instance;
  
  Future<void> loadTranslations();
  String translate(String key);
  void setLanguage(String languageCode);
  String get currentLanguage;
  List<String> get supportedLanguages;
}
```

**メソッド:**
- `loadTranslations()`: 翻訳ファイルを読み込む
- `translate(String key)`: キーに対応する翻訳を取得
- `setLanguage(String languageCode)`: 言語を設定
- `currentLanguage`: 現在の言語を取得
- `supportedLanguages`: サポートされている言語のリストを取得

#### PerformanceUtils

パフォーマンス監視のためのユーティリティ。

```dart
class PerformanceUtils {
  static PerformanceUtils get instance;
  
  double getCurrentMemoryUsage();
  void startTimer(String name);
  double stopTimer(String name);
  void logMemoryUsage(String operation);
  List<MemoryLog> getMemoryLogs();
  String generatePerformanceReport();
  void cleanup();
}
```

**メソッド:**
- `getCurrentMemoryUsage()`: 現在のメモリ使用量を取得
- `startTimer(String name)`: タイマーを開始
- `stopTimer(String name)`: タイマーを停止して経過時間を取得
- `logMemoryUsage(String operation)`: メモリ使用量をログに記録
- `getMemoryLogs()`: メモリログのリストを取得
- `generatePerformanceReport()`: パフォーマンスレポートを生成
- `cleanup()`: リソースをクリーンアップ

#### SecurityUtils

セキュリティ機能のためのユーティリティ。

```dart
class SecurityUtils {
  static String encrypt(String data);
  static String decrypt(String encryptedData);
  static String hashPassword(String password, {String? salt});
  static bool verifyPassword(String password, String hash, String salt);
  static String generateSecureRandomString(int length);
  static bool verifyIntegrity(String data, String checksum);
  static String calculateChecksum(String data);
  static Future<void> secureStore(String key, String value);
  static Future<String?> secureRetrieve(String key);
  static Future<void> secureDelete(String key);
  static Map<String, bool> checkSecurityStatus();
  static void logSecurityEvent(String event, {Map<String, dynamic>? details});
}
```

**メソッド:**
- `encrypt(String data)`: データを暗号化
- `decrypt(String encryptedData)`: データを復号化
- `hashPassword(String password, {String? salt})`: パスワードをハッシュ化
- `verifyPassword(String password, String hash, String salt)`: パスワードを検証
- `generateSecureRandomString(int length)`: セキュアなランダム文字列を生成
- `verifyIntegrity(String data, String checksum)`: データの整合性を検証
- `calculateChecksum(String data)`: データのチェックサムを計算
- `secureStore(String key, String value)`: セキュアなストレージにデータを保存
- `secureRetrieve(String key)`: セキュアなストレージからデータを取得
- `secureDelete(String key)`: セキュアなストレージからデータを削除
- `checkSecurityStatus()`: セキュリティ状態をチェック
- `logSecurityEvent(String event, {Map<String, dynamic>? details})`: セキュリティイベントをログに記録

### Tea Analysis Feature

#### AnalysisLocalDataSourceImpl

TensorFlow Liteモデルを使用した茶葉解析のデータソース。

```dart
class AnalysisLocalDataSourceImpl implements AnalysisLocalDataSource {
  Future<AnalysisResult> analyzeImage(String imagePath);
  bool get isModelLoaded;
  Future<void> loadModel();
  void dispose();
}
```

**メソッド:**
- `analyzeImage(String imagePath)`: 画像を解析して結果を返す
- `isModelLoaded`: モデルが読み込まれているかどうか
- `loadModel()`: TensorFlow Liteモデルを読み込む
- `dispose()`: リソースを解放

#### AnalysisResult

解析結果を表すデータクラス。

```dart
class AnalysisResult {
  final String growthStage;
  final String healthStatus;
  final double confidence;
  final String imagePath;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
}
```

**プロパティ:**
- `growthStage`: 成長段階（例: "新芽", "若葉", "成熟葉"）
- `healthStatus`: 健康状態（例: "健康", "軽度の病気", "重度の病気"）
- `confidence`: 信頼度（0.0-1.0）
- `imagePath`: 解析した画像のパス
- `timestamp`: 解析時刻
- `metadata`: 追加のメタデータ

### UI Components

#### ModernUIComponents

モダンなUIコンポーネントのコレクション。

```dart
class AnimatedCard extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
}

class LoadingIndicator extends StatelessWidget {
  final String message;
  final double size;
  final Color color;
}

class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
}

class SuccessMessage extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Duration autoHideDuration;
}

class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Widget? icon;
}

class ModernTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
}
```

### Theme System

#### TeaGardenTheme

アプリケーションのテーマシステム。

```dart
class TeaGardenTheme {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color accentGreen = Color(0xFF8BC34A);
  static const Color lightGreen = Color(0xFFC8E6C9);
  static const Color darkGreen = Color(0xFF1B5E20);
  
  static ThemeData get lightTheme;
  static ThemeData get darkTheme;
  
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
  
  static bool isMobile(double width);
  static bool isTablet(double width);
  static bool isDesktop(double width);
}
```

## データベーススキーマ

### tea_analysis_results テーブル

```sql
CREATE TABLE tea_analysis_results (
  id TEXT PRIMARY KEY,
  imagePath TEXT NOT NULL,
  growthStage TEXT NOT NULL,
  healthStatus TEXT NOT NULL,
  confidence REAL NOT NULL,
  comment TEXT,
  timestamp TEXT NOT NULL,
  metadata TEXT
);
```

**カラム:**
- `id`: 一意の識別子
- `imagePath`: 画像ファイルのパス
- `growthStage`: 成長段階
- `healthStatus`: 健康状態
- `confidence`: 信頼度
- `comment`: ユーザーのコメント
- `timestamp`: 作成日時
- `metadata`: 追加のメタデータ（JSON形式）

## エラーハンドリング

### AnalysisException

解析処理中のエラーを表す例外クラス。

```dart
class AnalysisException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  AnalysisException(this.message, {this.code, this.originalError});
}
```

### エラーコード

- `MODEL_LOAD_ERROR`: モデルの読み込みエラー
- `IMAGE_PROCESSING_ERROR`: 画像処理エラー
- `ANALYSIS_ERROR`: 解析処理エラー
- `DATABASE_ERROR`: データベースエラー
- `CAMERA_ERROR`: カメラエラー

## 設定とコンフィギュレーション

### 環境変数

以下の環境変数を設定できます：

- `TFLITE_MODEL_PATH`: TensorFlow Liteモデルのパス
- `DATABASE_PATH`: データベースファイルのパス
- `LOG_LEVEL`: ログレベル（DEBUG, INFO, WARNING, ERROR）
- `ENABLE_ANALYTICS`: アナリティクスの有効/無効

### 設定ファイル

`lib/core/constants/app_constants.dart`でアプリケーションの定数を設定できます。

## テスト

### ユニットテスト

```bash
flutter test
```

### 統合テスト

```bash
flutter test integration_test/
```

### カバレッジレポート

```bash
flutter test --coverage
```

## パフォーマンス最適化

### メモリ管理

- 画像処理後のメモリ解放
- データベース接続の適切な管理
- 不要なオブジェクトの即座な解放

### 画像処理最適化

- 適切な画像サイズへのリサイズ
- 非同期処理の活用
- キャッシュの実装

### データベース最適化

- インデックスの適切な設定
- バッチ処理の実装
- 接続プールの管理

## セキュリティ

### データ保護

- ローカルデータの暗号化
- セキュアなストレージの使用
- データの整合性チェック

### ネットワークセキュリティ

- HTTPS通信の強制
- 証明書ピニングの実装
- リクエストの検証

## トラブルシューティング

### よくある問題

1. **モデルの読み込みエラー**
   - モデルファイルのパスを確認
   - ファイルの存在を確認
   - 権限を確認

2. **画像処理エラー**
   - 画像ファイルの形式を確認
   - ファイルサイズを確認
   - メモリ使用量を確認

3. **データベースエラー**
   - データベースファイルのパスを確認
   - 権限を確認
   - ディスク容量を確認

### ログの確認

アプリケーションのログを確認して問題を特定できます：

```dart
// デバッグモードでのログ出力
if (kDebugMode) {
  print('Debug message');
}
```

## コントリビューション

### コードスタイル

- Dartの公式スタイルガイドに従う
- 適切なコメントを記述
- テストを書く

### プルリクエスト

1. フィーチャーブランチを作成
2. 変更をコミット
3. プルリクエストを作成
4. コードレビューを受ける

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。
