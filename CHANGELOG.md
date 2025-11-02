# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2024-12-20

### Added
- 拡張版Webアプリ（enhanced_app.dart）の実装
  - タブベースのナビゲーション（ダッシュボード、解析、チャート、エクスポート、設定）
  - ローカルストレージによるデータ永続化
  - チャート・グラフ機能（健康状態の推移、成長段階の分布）
  - データエクスポート機能（CSV、JSON、PDF、画像）
- Webストレージ機能の実装（条件付きインポート対応）
  - Webプラットフォーム用の実装（dart:html）
  - モバイルプラットフォーム用のスタブ実装
  - プラットフォーム選択ファイルによる自動切り替え
- HTMLベースの完全機能版Webアプリ（web/enhanced_index.html）
- 包括的なテストスイート
  - enhanced_app_test.dart: 拡張版アプリのテスト（21テスト）
  - web_storage_test.dart: Webストレージ機能のテスト（12テスト）
  - widget_test.dart: ウィジェットテストの改善・拡張

### Fixed
- Webプラットフォームでの白画面問題を解決
- CIリンターエラーの修正
  - unused_local_variable警告の解決
  - slash_for_doc_comments警告の解決
  - avoid_web_libraries_in_flutter警告の解決
- 条件付きインポートによるプラットフォーム対応の改善

### Changed
- Webプラットフォーム対応の最適化
- テストコードの改善と拡張
- ドキュメントの更新

### Technical Details
- **Web Support**: 条件付きインポートとプラットフォーム選択ファイルの実装
- **Testing**: 包括的なテストカバレッジの追加
- **Code Quality**: すべてのCIリンターエラーの解決
- **Architecture**: Web/モバイルプラットフォームの実装分離

## [1.1.0] - 2024-12-19

### Added
- Comprehensive test suite implementation
- UI/UX improvements with modern design
- Enhanced error handling and user feedback
- Code quality improvements and lint fixes

### Changed
- Improved home page design with gradient background
- Enhanced error display with better visual feedback
- Updated loading states with descriptive messages
- Refined app bar styling with green theme

### Technical Details
- **Testing**: Added unit tests for core components
- **UI/UX**: Modern Material Design implementation
- **Code Quality**: Resolved lint warnings and improved code structure
- **Error Handling**: Enhanced user experience for error states

## [1.0.0] - 2024-12-19

### Added
- Initial implementation of Tea Garden AI application
- Clean Architecture implementation with proper layer separation
- Flutter + TensorFlow Lite integration for on-device AI inference
- Multi-platform support (Android, iOS, Web, macOS)
- SQLite database for local data persistence
- BLoC state management pattern
- GetIt dependency injection
- Camera functionality for tea leaf photography
- AI analysis for growth stage and health status classification
- Result logging and history management
- Comprehensive README documentation
- Proper .gitignore configuration
- Code quality improvements and lint fixes

### Technical Details
- **Architecture**: Clean Architecture with Domain, Data, and Presentation layers
- **State Management**: BLoC pattern with Cubit
- **Dependency Injection**: GetIt service locator
- **Database**: SQLite with sqflite package
- **AI/ML**: TensorFlow Lite for on-device inference
- **Camera**: Camera plugin for photo capture
- **Image Processing**: Image package for preprocessing
- **Functional Programming**: Dartz for Either type error handling

### Platform Support
- **Android**: API 26+ (Android 8.0+)
- **iOS**: 11.0+
- **Web**: Chrome, Safari, Firefox
- **macOS**: 10.14+

### Dependencies
- Flutter SDK 3.32.6
- TensorFlow Lite 0.10.4
- SQLite (sqflite) 2.4.2
- BLoC 8.1.6
- GetIt 7.7.0
- Dartz 0.10.1
- Camera 0.10.6
- Image Picker 1.2.0
- Image 4.5.4

## [0.1.0] - 2024-10-07

### Added
- Initial project setup
- Basic project structure
- Core architecture implementation
- Feature modules (tea_analysis, camera, logs)
- UI screens and widgets
- Data models and entities
- Repository pattern implementation
- Use case implementations
- Error handling system
- Utility functions
- Constants and configuration
