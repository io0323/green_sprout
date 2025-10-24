# Tea Garden AI - 開発者ガイド

## 目次

1. [プロジェクト概要](#プロジェクト概要)
2. [開発環境のセットアップ](#開発環境のセットアップ)
3. [アーキテクチャ](#アーキテクチャ)
4. [開発ワークフロー](#開発ワークフロー)
5. [テスト戦略](#テスト戦略)
6. [デバッグとトラブルシューティング](#デバッグとトラブルシューティング)
7. [パフォーマンス最適化](#パフォーマンス最適化)
8. [セキュリティ](#セキュリティ)
9. [デプロイメント](#デプロイメント)
10. [コントリビューション](#コントリビューション)

## プロジェクト概要

Tea Garden AIは、TensorFlow Liteを使用して茶葉の成長段階と健康状態を分析するFlutterアプリケーションです。Clean Architectureパターンに従って設計され、高い保守性と拡張性を提供します。

### 主要機能

- **AI解析**: TensorFlow Liteを使用した茶葉の成長段階と健康状態の分析
- **画像処理**: 高度な画像前処理と特徴抽出
- **データ管理**: SQLiteを使用したローカルデータベース
- **国際化**: 英語と日本語の多言語対応
- **モダンUI**: Material Design 3に基づく美しいユーザーインターフェース
- **アクセシビリティ**: 包括的なアクセシビリティ対応
- **クラウド同期**: データのクラウド同期機能
- **ウェアラブル対応**: Wear OSとwatchOSのサポート

## 開発環境のセットアップ

### 必要なツール

1. **Flutter SDK** (3.24.0以上)
2. **Dart SDK** (3.5.0以上)
3. **Android Studio** または **VS Code**
4. **Git**

### セットアップ手順

1. **リポジトリのクローン**
   ```bash
   git clone https://github.com/io0323/green_sprout.git
   cd green_sprout
   ```

2. **依存関係のインストール**
   ```bash
   flutter pub get
   ```

3. **Flutter Doctorの実行**
   ```bash
   flutter doctor
   ```

4. **開発環境の確認**
   ```bash
   flutter analyze
   flutter test
   ```

### IDE設定

#### VS Code

推奨拡張機能：
- Flutter
- Dart
- Flutter Intl
- GitLens
- Error Lens

#### Android Studio

推奨プラグイン：
- Flutter
- Dart
- Git Integration

## アーキテクチャ

### Clean Architecture

アプリケーションは以下の層に分かれています：

```
lib/
├── core/                    # 共通ユーティリティとサービス
│   ├── constants/           # 定数定義
│   ├── di/                 # 依存関係注入
│   ├── errors/             # エラー定義
│   ├── usecases/           # ユースケース
│   ├── utils/              # ユーティリティ
│   ├── services/           # コアサービス
│   ├── widgets/            # 共通ウィジェット
│   ├── theme/              # テーマシステム
│   ├── security/           # セキュリティ機能
│   └── monitoring/         # 監視機能
├── features/               # 機能別モジュール
│   ├── camera/             # カメラ機能
│   ├── tea_analysis/       # 茶葉解析機能
│   └── logs/               # ログ機能
└── main.dart               # エントリーポイント
```

### 依存関係注入

GetItを使用して依存関係注入を実装：

```dart
// lib/core/di/injection_container.dart
final getIt = GetIt.instance;

void init() {
  // Services
  getIt.registerLazySingleton<LocalizationService>(() => LocalizationService.instance);
  getIt.registerLazySingleton<PerformanceUtils>(() => PerformanceUtils.instance);
  
  // Data sources
  getIt.registerLazySingleton<AnalysisLocalDataSource>(
    () => AnalysisLocalDataSourceImpl(),
  );
  
  // Repositories
  getIt.registerLazySingleton<AnalysisRepository>(
    () => AnalysisRepositoryImpl(getIt()),
  );
}
```

### 状態管理

BLoCパターンを使用して状態管理を実装：

```dart
// lib/features/tea_analysis/presentation/bloc/analysis_bloc.dart
class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  final AnalyzeTeaUseCase _analyzeTeaUseCase;
  
  AnalysisBloc(this._analyzeTeaUseCase) : super(AnalysisInitial()) {
    on<AnalyzeTeaEvent>(_onAnalyzeTea);
  }
  
  Future<void> _onAnalyzeTea(
    AnalyzeTeaEvent event,
    Emitter<AnalysisState> emit,
  ) async {
    emit(AnalysisLoading());
    
    final result = await _analyzeTeaUseCase(event.imagePath);
    
    result.fold(
      (failure) => emit(AnalysisError(failure.message)),
      (result) => emit(AnalysisSuccess(result)),
    );
  }
}
```

## 開発ワークフロー

### Git ワークフロー

1. **ブランチ戦略**
   - `main`: 本番環境
   - `develop`: 開発環境
   - `feature/*`: 機能開発
   - `hotfix/*`: 緊急修正

2. **コミットメッセージ**
   ```
   feat: 新機能の追加
   fix: バグ修正
   docs: ドキュメント更新
   style: コードスタイル修正
   refactor: リファクタリング
   test: テスト追加
   chore: その他の変更
   ```

3. **プルリクエスト**
   - 機能ブランチからdevelopブランチへ
   - コードレビュー必須
   - テスト通過必須

### コードスタイル

1. **Dart公式スタイルガイドに従う**
2. **適切なコメントを記述**
3. **意味のある変数名を使用**
4. **関数は単一責任の原則に従う**

```dart
/**
 * 茶葉の画像を解析して成長段階と健康状態を判定する
 * @param imagePath 解析する画像のパス
 * @return 解析結果
 */
Future<AnalysisResult> analyzeTeaImage(String imagePath) async {
  // 実装
}
```

## テスト戦略

### テストの種類

1. **ユニットテスト**: 個別の関数やクラスのテスト
2. **ウィジェットテスト**: UIコンポーネントのテスト
3. **統合テスト**: アプリケーション全体のテスト

### テストの実行

```bash
# 全テストの実行
flutter test

# カバレッジ付きテスト
flutter test --coverage

# 特定のテストファイル
flutter test test/features/tea_analysis/

# 統合テスト
flutter test integration_test/
```

### テストの書き方

```dart
// test/features/tea_analysis/data/datasources/analysis_local_datasource_impl_test.dart
void main() {
  group('AnalysisLocalDataSourceImpl', () {
    late AnalysisLocalDataSourceImpl dataSource;

    setUp(() {
      dataSource = AnalysisLocalDataSourceImpl();
    });

    tearDown(() {
      dataSource.dispose();
    });

    test('画像解析が正しく動作する', () async {
      // Arrange
      const imagePath = 'test_image.jpg';
      
      // Act
      final result = await dataSource.analyzeImage(imagePath);
      
      // Assert
      expect(result, isA<AnalysisResult>());
      expect(result.growthStage, isNotEmpty);
      expect(result.healthStatus, isNotEmpty);
      expect(result.confidence, inInclusiveRange(0.0, 1.0));
    });
  });
}
```

## デバッグとトラブルシューティング

### デバッグツール

1. **Flutter Inspector**: UIの構造を視覚的に確認
2. **Dart DevTools**: パフォーマンス分析
3. **Logging**: 適切なログ出力

### ログの実装

```dart
import 'package:flutter/foundation.dart';

class Logger {
  static void debug(String message) {
    if (kDebugMode) {
      print('[DEBUG] $message');
    }
  }
  
  static void info(String message) {
    if (kDebugMode) {
      print('[INFO] $message');
    }
  }
  
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[ERROR] $message');
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }
  }
}
```

### よくある問題と解決方法

1. **モデルの読み込みエラー**
   ```dart
   // 解決方法: モデルファイルのパスを確認
   const modelPath = 'assets/models/tea_model.tflite';
   ```

2. **画像処理エラー**
   ```dart
   // 解決方法: 画像ファイルの存在を確認
   final file = File(imagePath);
   if (!await file.exists()) {
     throw AnalysisException('Image file not found');
   }
   ```

3. **データベースエラー**
   ```dart
   // 解決方法: データベースの初期化を確認
   await database.initialize();
   ```

## パフォーマンス最適化

### メモリ管理

1. **画像処理後のメモリ解放**
   ```dart
   void dispose() {
     _image?.dispose();
     _image = null;
   }
   ```

2. **データベース接続の管理**
   ```dart
   Future<void> close() async {
     await _database.close();
   }
   ```

### 画像処理最適化

1. **適切な画像サイズへのリサイズ**
   ```dart
   Future<ui.Image> resizeImage(ui.Image image, int maxSize) async {
     final ratio = maxSize / math.max(image.width, image.height);
     if (ratio >= 1.0) return image;
     
     final newWidth = (image.width * ratio).round();
     final newHeight = (image.height * ratio).round();
     
     return await _resizeImage(image, newWidth, newHeight);
   }
   ```

2. **非同期処理の活用**
   ```dart
   Future<AnalysisResult> analyzeImage(String imagePath) async {
     final image = await _loadImage(imagePath);
     final processedImage = await _processImage(image);
     return await _analyzeImage(processedImage);
   }
   ```

### データベース最適化

1. **インデックスの設定**
   ```sql
   CREATE INDEX idx_timestamp ON tea_analysis_results(timestamp);
   CREATE INDEX idx_growth_stage ON tea_analysis_results(growthStage);
   ```

2. **バッチ処理の実装**
   ```dart
   Future<void> batchInsert(List<AnalysisResult> results) async {
     final batch = _database.batch();
     for (final result in results) {
       batch.insert('tea_analysis_results', result.toMap());
     }
     await batch.commit();
   }
   ```

## セキュリティ

### データ保護

1. **ローカルデータの暗号化**
   ```dart
   Future<void> storeSecureData(String key, String value) async {
     final encryptedValue = SecurityUtils.encrypt(value);
     await _secureStorage.write(key: key, value: encryptedValue);
   }
   ```

2. **セキュアなストレージの使用**
   ```dart
   final secureStorage = FlutterSecureStorage(
     aOptions: AndroidOptions(
       encryptedSharedPreferences: true,
     ),
     iOptions: IOSOptions(
       accessibility: KeychainAccessibility.first_unlock_this_device,
     ),
   );
   ```

### ネットワークセキュリティ

1. **HTTPS通信の強制**
   ```dart
   class SecureHttpClient {
     Future<http.Response> get(String url) async {
       final uri = Uri.parse(url);
       if (uri.scheme != 'https') {
         throw SecurityException('HTTPS required');
       }
       return await _client.get(uri);
     }
   }
   ```

2. **証明書ピニングの実装**
   ```dart
   class CertificatePinning {
     static bool validateCertificate(X509Certificate cert) {
       final expectedHash = 'expected_certificate_hash';
       final actualHash = sha256.convert(cert.der).toString();
       return actualHash == expectedHash;
     }
   }
   ```

## デプロイメント

### Android

1. **APKのビルド**
   ```bash
   flutter build apk --release
   ```

2. **AABのビルド**
   ```bash
   flutter build appbundle --release
   ```

### iOS

1. **iOSアプリのビルド**
   ```bash
   flutter build ios --release
   ```

2. **App Store Connectへのアップロード**
   ```bash
   flutter build ipa --release
   ```

### Web

1. **Webアプリのビルド**
   ```bash
   flutter build web --release
   ```

2. **デプロイ**
   ```bash
   # Firebase Hosting
   firebase deploy
   
   # GitHub Pages
   gh-pages -d build/web
   ```

## コントリビューション

### コントリビューションの手順

1. **リポジトリをフォーク**
2. **フィーチャーブランチを作成**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **変更をコミット**
   ```bash
   git commit -m 'feat: add amazing feature'
   ```
4. **ブランチにプッシュ**
   ```bash
   git push origin feature/amazing-feature
   ```
5. **プルリクエストを作成**

### コードレビューのガイドライン

1. **機能性**: コードが期待通りに動作するか
2. **可読性**: コードが理解しやすいか
3. **保守性**: コードが保守しやすいか
4. **パフォーマンス**: パフォーマンスに問題がないか
5. **セキュリティ**: セキュリティに問題がないか

### イシューの報告

1. **バグレポート**
   - 環境情報を含める
   - 再現手順を明確にする
   - エラーメッセージを含める

2. **機能リクエスト**
   - 問題を明確にする
   - 解決策を提案する
   - 実装の複雑さを考慮する

## 参考資料

- [Flutter公式ドキュメント](https://flutter.dev/docs)
- [Dart公式ドキュメント](https://dart.dev/guides)
- [TensorFlow Lite公式ドキュメント](https://www.tensorflow.org/lite)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BLoC Pattern](https://bloclibrary.dev/)

## サポート

問題や質問がある場合は、以下の方法でサポートを受けることができます：

- [GitHub Issues](https://github.com/io0323/green_sprout/issues)
- [GitHub Discussions](https://github.com/io0323/green_sprout/discussions)
- [Email](mailto:support@teagardenai.com)

---

**Tea Garden AI** - 茶園管理をAIで革新 🌱✨
