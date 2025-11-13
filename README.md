# Tea Garden AI 🌱

茶園管理アプリ - Flutter + TensorFlow Lite を使用した茶葉の成長状態・健康状態をAI解析するアプリケーション

## 📱 概要

Tea Garden AIは、茶葉や茶樹の芽の写真を撮影し、端末上でTensorFlow Liteモデルを使用して成長状態・葉の健康状態を分類し、結果を日誌として保存するアプリケーションです。ネット接続不要で動作します。

## ✨ 主な機能

### 🏠 ホーム画面
- 今日の茶葉解析結果一覧表示
- 「写真を撮る」ボタンでカメラ画面へ遷移
- 解析結果のサマリー表示

### 📸 写真撮影画面
- カメラで茶葉撮影
- 「解析開始」ボタンでTFLiteモデル呼び出し
- 撮影ガイド表示

### 🔍 解析結果画面
- 成長状態・葉色の表示
- 信頼度の表示
- ユーザーコメント入力欄
- 「保存」ボタンで日誌に登録

### 📋 日誌一覧画面
- 過去の記録一覧表示
- 日付・成長状態でフィルター機能
- 詳細情報の表示

### 🌐 Web拡張版（enhanced_app.dart）
- タブベースのナビゲーション（ダッシュボード、解析、チャート、エクスポート、設定）
- ローカルストレージによるデータ永続化
- チャート・グラフ機能（健康状態の推移、成長段階の分布）
- データエクスポート機能（CSV、JSON、PDF、画像）
- 設定機能（データ保持期間、通知設定など）

## 🏗️ アーキテクチャ

このプロジェクトは**Clean Architecture**を採用しています：

```
lib/
├── core/                    # 共通機能・DI設定
│   ├── constants/           # アプリ定数
│   ├── di/                 # 依存性注入設定
│   ├── errors/             # エラーハンドリング
│   ├── utils/              # ユーティリティ関数
│   └── usecases/           # ユースケース基底クラス
├── features/               # 機能別モジュール
│   ├── tea_analysis/       # 茶葉解析機能
│   │   ├── data/          # データ層
│   │   ├── domain/         # ドメイン層
│   │   └── presentation/   # プレゼンテーション層
│   ├── camera/             # カメラ機能
│   └── logs/               # ログ機能
└── main.dart               # アプリエントリーポイント
```

### 層の役割

- **Presentation Layer**: UI、状態管理（BLoC）
- **Domain Layer**: コアビジネスロジック、エンティティ、ユースケース、リポジトリインターフェース
- **Data Layer**: リポジトリ実装、データソース（ローカル、TFLite）、データモデル
- **Core Layer**: 共通ユーティリティ、エラーハンドリング、依存性注入設定

## 🛠️ 技術スタック

- **Flutter**: UI フレームワーク
- **Dart**: プログラミング言語
- **TensorFlow Lite**: オンデバイスAI推論
- **SQLite**: ローカルデータベース
- **BLoC**: 状態管理
- **GetIt**: 依存性注入
- **Dartz**: 関数型プログラミング（Either型）

## 📦 主要パッケージ

```yaml
dependencies:
  flutter:
    sdk: flutter
  # カメラ・画像処理
  camera: ^0.10.6
  image_picker: ^1.2.0
  image: ^4.5.4
  
  # AI・機械学習
  tflite_flutter: ^0.10.4
  
  # データベース
  sqflite: ^2.4.2
  path: ^1.9.1
  path_provider: ^2.1.5
  
  # 状態管理・DI
  flutter_bloc: ^8.1.6
  get_it: ^7.7.0
  dartz: ^0.10.1
  
  # UI・ユーティリティ
  intl: ^0.18.1
```

## 🚀 セットアップ

### 前提条件

- Flutter SDK (3.0.0以上)
- Android Studio / Xcode
- Android SDK 26以上（TFLite Flutterの要件）
- iOS 11.0以上

### インストール手順

1. **リポジトリのクローン**
   ```bash
   git clone https://github.com/io0323/green_sprout.git
   cd green_sprout
   ```

2. **依存関係のインストール**
   ```bash
   flutter pub get
   ```

3. **TFLiteモデルの配置**
   ```
   assets/models/tea_model.tflite  # TFLiteモデルファイル
   ```

4. **アプリの実行**
   ```bash
   # Android
   flutter run -d android
   
   # iOS
   flutter run -d ios
   
   # Web
   flutter run -d chrome
   ```

## 📱 対応プラットフォーム

- ✅ **Android** (API 26以上)
- ✅ **iOS** (11.0以上)
- ✅ **Web** (Chrome, Safari, Firefox) - 条件付きインポート対応
- ✅ **macOS** (10.14以上)

### Webプラットフォーム対応
- 条件付きインポートによるWeb/モバイル実装の分離
- ローカルストレージによるデータ永続化
- HTMLベースの完全機能版Webアプリも提供

## 🔧 開発

### プロジェクト構造

```
lib/
├── core/                           # 共通機能
│   ├── constants/app_constants.dart    # アプリ定数
│   ├── di/injection_container.dart     # DI設定
│   ├── errors/failures.dart             # エラー定義
│   ├── utils/app_utils.dart            # ユーティリティ
│   └── usecases/usecase.dart           # ユースケース基底
├── features/tea_analysis/          # 茶葉解析機能
│   ├── data/
│   │   ├── datasources/           # データソース
│   │   ├── models/                # データモデル
│   │   └── repositories/          # リポジトリ実装
│   ├── domain/
│   │   ├── entities/              # エンティティ
│   │   ├── repositories/         # リポジトリインターフェース
│   │   └── usecases/             # ユースケース
│   └── presentation/
│       ├── bloc/                 # BLoC状態管理
│       ├── pages/                # 画面
│       └── widgets/              # ウィジェット
└── main.dart                      # エントリーポイント
```

### ビルド

```bash
# デバッグビルド
flutter build apk --debug
flutter build ios --debug

# リリースビルド
flutter build apk --release
flutter build ios --release
```

## 🤖 AIモデル

### 対応する分類

- **成長状態**: 芽、若葉、成葉、老葉
- **健康状態**: 健康、軽微な損傷、損傷、病気

### モデル要件

- **入力**: 224x224x3 RGB画像
- **出力**: 分類確率（8クラス）
- **形式**: TensorFlow Lite (.tflite)

## 📊 データベーススキーマ

```sql
CREATE TABLE tea_analysis_results (
  id TEXT PRIMARY KEY,
  imagePath TEXT,
  growthStage TEXT,
  healthStatus TEXT,
  confidence REAL,
  comment TEXT,
  timestamp TEXT
);
```

## 🧪 テスト

```bash
# ユニットテスト
flutter test

# 統合テスト
flutter test integration_test/

# 特定のテストファイル
flutter test test/widget_test.dart
flutter test test/enhanced_app_test.dart
flutter test test/src/web_storage_test.dart
```

### テストカバレッジ
- ウィジェットテスト: アプリの基本機能とUIコンポーネント
- 拡張版アプリテスト: タブナビゲーション、解析機能、チャート表示
- Webストレージ機能テスト: ローカルストレージとファイルダウンロード
- 統合テスト: エンドツーエンドのユーザーフロー

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 🤝 コントリビューション

1. このリポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add some amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📞 サポート

問題や質問がある場合は、[Issues](https://github.com/io0323/green_sprout/issues)で報告してください。

## 🎯 今後の予定

- [ ] より高精度なAIモデルの実装
- [x] 複数言語対応 ✅ (v1.3.0で実装完了)
- [ ] クラウド同期機能
- [ ] 茶園管理の高度な分析機能
- [ ] ウェアラブルデバイス対応

---

**Tea Garden AI** - 茶園管理をAIで革新 🌱✨