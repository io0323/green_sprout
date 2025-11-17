import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tea_garden_ai/enhanced_app.dart';
import 'package:tea_garden_ai/core/services/localization_service.dart';
import 'package:tea_garden_ai/core/di/injection_container.dart' as di;

/// 拡張版茶園管理AIアプリのテスト

/// テスト用のHTTPオーバーライド
/// HTTPリクエストを即座に完了させてテスト環境でのタイムアウトを防止
class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
}

/// テスト用のFake HttpClient
class _FakeHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _FakeRequest();

  // Add common aliases (some callers may call these)
  @override
  Future<HttpClientRequest> postUrl(Uri url) async => _FakeRequest();

  // Basic no-op implementations for commonly-used members:
  @override
  void close({bool force = false}) {}

  @override
  set userAgent(String? value) {}

  @override
  String? get userAgent => null;

  @override
  Duration idleTimeout = const Duration(seconds: 1);

  @override
  int? maxConnectionsPerHost;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// テスト用のFake HttpClientRequest
class _FakeRequest implements HttpClientRequest {
  final _controller = StreamController<List<int>>();

  _FakeRequest() {
    // 空のJSONボディを提供
    _controller.add(utf8.encode('{}'));
    _controller.close();
  }

  @override
  Future<HttpClientResponse> close() async => _FakeResponse(_controller.stream);

  // Provide commonly-used members to avoid noSuchMethod surprises:
  @override
  Encoding get encoding => utf8;
  @override
  set encoding(Encoding value) {}

  @override
  HttpHeaders get headers => _FakeHeaders();

  // Add no-op write/add methods so requests don't stall
  @override
  void write(Object? obj) {
    // no-op
  }

  @override
  void add(List<int> data) {
    // no-op
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    // no-op
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// テスト用のFake HttpClientResponse
class _FakeResponse extends Stream<List<int>> implements HttpClientResponse {
  final Stream<List<int>> _stream;

  _FakeResponse(this._stream);

  @override
  int get statusCode => 200;

  @override
  int get contentLength => -1;

  @override
  HttpHeaders get headers => _FakeHeaders();

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError ?? false,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Simple fake headers implementation used by request/response:
class _FakeHeaders implements HttpHeaders {
  final Map<String, List<String>> _map = {};

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    _map.putIfAbsent(name, () => []).add(value.toString());
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _map[name] = [value.toString()];
  }

  @override
  String? value(String name) {
    final list = _map[name];
    return (list == null || list.isEmpty) ? null : list.first;
  }

  // Implement the members the app might call; others can be noSuchMethod:
  @override
  List<String>? operator [](String name) => _map[name];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 特定のウィジェットが表示されるまで待機するヘルパー関数
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    // If any exception occurred during widget build/async, surface it immediately:
    final dynamic testException = tester.takeException();
    if (testException != null) {
      // rethrow so test log shows the underlying error
      throw testException;
    }
    if (tester.any(finder)) {
      return;
    }
  }
  throw Exception('Timed out waiting for $finder');
}

/// ウィジェットが存在することを確認してから最初のマッチをタップするヘルパー関数
/// Finder.firstを呼び出す前にウィジェットの存在を確認することで、StateErrorを防止
Future<void> safeTapFirst(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
  Finder? waitFor,
}) async {
  await pumpUntilFound(tester, finder, timeout: timeout);
  await tester.tap(finder.first);
  await tester.pump(); // let one frame happen
  if (waitFor != null) {
    // Wait for a specific expected widget after tap
    await pumpUntilFound(tester, waitFor, timeout: timeout);
  } else {
    // Fallback: allow a few small pumps, but avoid pumpAndSettle
    // This avoids waiting for all animations/async tasks to complete
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
}

void main() {
  setUpAll(() async {
    // テストバインディングを初期化
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock platform-backed storage (SharedPreferences) before DI initializes
    // This prevents SharedPreferences platform channel calls from blocking during widget tests
    SharedPreferences.setMockInitialValues(<String, Object>{});

    // HTTPオーバーライドを設定してテスト環境でのHTTPリクエストを即座に完了させる
    HttpOverrides.global = _TestHttpOverrides();

    // GetItをリセットしてから初期化
    await GetIt.instance.reset();

    // DIコンテナを初期化（テストモードで初期化）
    await di.init(testing: true);

    // テスト用にローカライゼーションサービスを初期化
    await LocalizationService.instance.loadTranslationsForTest();
    LocalizationService.instance.setLanguage('ja');
  });

  tearDownAll(() async {
    // テスト終了後にGetItをリセット
    await GetIt.instance.reset();
    // Restore HttpOverrides so other tests / environments are not affected
    HttpOverrides.global = null;
  });

  group('EnhancedTeaGardenApp', () {
    testWidgets('アプリが正常に起動する', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const EnhancedTeaGardenApp());
      // Allow one frame, then wait for AppBar (indicator that app finished initial build)
      await tester.pump();
      await pumpUntilFound(tester, find.byType(AppBar),
          timeout: const Duration(seconds: 30));

      // AppBarが表示されることを確認
      expect(find.byType(AppBar), findsOneWidget);

      // タイトルが表示されることを確認（複数表示される可能性があるため）
      expect(
          find.text(
              LocalizationService.instance.translate('enhanced_app_title')),
          findsWidgets);
    });

    testWidgets('タブナビゲーションが表示される', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const EnhancedTeaGardenApp());
      // Allow one frame, then wait for AppBar (indicator that app finished initial build)
      await tester.pump();
      await pumpUntilFound(tester, find.byType(AppBar),
          timeout: const Duration(seconds: 30));

      // タブが表示されることを確認（Keyを使用）
      expect(find.byKey(const Key('tab_dashboard_icon')), findsWidgets);
      expect(find.byKey(const Key('tab_camera_icon')), findsWidgets);
      expect(find.byKey(const Key('tab_charts_icon')), findsWidgets);
      expect(find.byKey(const Key('tab_export_icon')), findsWidgets);
      expect(find.byKey(const Key('tab_settings_icon')), findsWidgets);
    });

    testWidgets('ダッシュボードタブが表示される', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const EnhancedTeaGardenApp());
      // Allow one frame, then wait for AppBar (indicator that app finished initial build)
      await tester.pump();
      await pumpUntilFound(tester, find.byType(AppBar),
          timeout: const Duration(seconds: 30));

      // ダッシュボードタブのコンテンツが表示されることを確認
      expect(
          find.text(
              LocalizationService.instance.translate('enhanced_app_title')),
          findsWidgets);

      // 統計カードが表示されることを確認
      expect(
          find.text(
              LocalizationService.instance.translate('total_analysis_count')),
          findsWidgets);
      expect(find.text(LocalizationService.instance.translate('health_rate')),
          findsWidgets);
      expect(
          find.text(LocalizationService.instance.translate('today_analysis')),
          findsWidgets);
      expect(
          find.text(LocalizationService.instance.translate('avg_confidence')),
          findsWidgets);
    });

    testWidgets('解析タブで解析ボタンが表示される', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const EnhancedTeaGardenApp());
      // Allow one frame, then wait for AppBar (indicator that app finished initial build)
      await tester.pump();
      await pumpUntilFound(tester, find.byType(AppBar),
          timeout: const Duration(seconds: 30));

      // 解析タブをタップ（Keyを使用）- 解析ボタンが表示されるのを待つ
      await safeTapFirst(tester, find.byKey(const Key('tab_camera_icon')),
          timeout: const Duration(seconds: 15),
          waitFor: find.byKey(const Key('btn_take_photo')));

      // 解析ボタンが表示されることを確認（Keyを使用）
      expect(find.byKey(const Key('btn_take_photo')), findsWidgets);
    });

    testWidgets('解析を実行すると結果が追加される', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const EnhancedTeaGardenApp());
      // Allow one frame, then wait for AppBar (indicator that app finished initial build)
      await tester.pump();
      await pumpUntilFound(tester, find.byType(AppBar),
          timeout: const Duration(seconds: 30));

      // 解析タブをタップ（Keyを使用）- 解析ボタンが表示されるのを待つ
      await safeTapFirst(tester, find.byKey(const Key('tab_camera_icon')),
          timeout: const Duration(seconds: 15),
          waitFor: find.byKey(const Key('btn_take_photo')));

      // 解析ボタンをタップ（Keyを使用）- ローディングテキストが表示されるのを待つ
      await safeTapFirst(
        tester,
        find.byKey(const Key('btn_take_photo')),
        timeout: const Duration(seconds: 15),
        waitFor:
            find.text(LocalizationService.instance.translate('ai_analyzing')),
      );

      // ローディング表示を確認（既に待機済み）
      await tester.pump(); // extra frame if needed

      // 解析が完了するまで待機 - 結果が表示されるのを待つ
      await pumpUntilFound(tester,
          find.text(LocalizationService.instance.translate('analysis_history')),
          timeout: const Duration(seconds: 30));

      // 結果が追加されたことを確認
      expect(
          find.text(LocalizationService.instance.translate('analysis_history')),
          findsWidgets);

      // SnackBarが表示されることを確認
      expect(
          find.text(
              LocalizationService.instance.translate('analysis_complete')),
          findsWidgets);
    });

    testWidgets('チャートタブが表示される', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const EnhancedTeaGardenApp());
      // Allow one frame, then wait for AppBar (indicator that app finished initial build)
      await tester.pump();
      await pumpUntilFound(tester, find.byType(AppBar),
          timeout: const Duration(seconds: 30));

      // チャートタブをタップ（Keyを使用）- チャートタイトルが表示されるのを待つ
      await safeTapFirst(tester, find.byKey(const Key('tab_charts_icon')),
          timeout: const Duration(seconds: 15),
          waitFor: find.text(LocalizationService.instance
              .translate('health_status_distribution')));

      // チャートタイトルが表示されることを確認
      expect(
          find.text(LocalizationService.instance
              .translate('health_status_distribution')),
          findsWidgets);
      expect(
          find.text(LocalizationService.instance
              .translate('growth_stage_distribution')),
          findsWidgets);
    });

    testWidgets('エクスポートタブが表示される', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const EnhancedTeaGardenApp());
      // Allow one frame, then wait for AppBar (indicator that app finished initial build)
      await tester.pump();
      await pumpUntilFound(tester, find.byType(AppBar),
          timeout: const Duration(seconds: 30));

      // エクスポートタブをタップ（Keyを使用）- エクスポートセクションが表示されるのを待つ
      await safeTapFirst(tester, find.byKey(const Key('tab_export_icon')),
          timeout: const Duration(seconds: 15),
          waitFor: find.text(LocalizationService.instance.translate('export')));

      // エクスポートセクションが表示されることを確認
      expect(find.text(LocalizationService.instance.translate('export')),
          findsWidgets);
      expect(find.text(LocalizationService.instance.translate('csv')),
          findsWidgets);
      expect(find.text(LocalizationService.instance.translate('json')),
          findsWidgets);
      expect(find.text(LocalizationService.instance.translate('pdf')),
          findsWidgets);
    });

    testWidgets('設定タブが表示される', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const EnhancedTeaGardenApp());
      // Allow one frame, then wait for AppBar (indicator that app finished initial build)
      await tester.pump();
      await pumpUntilFound(tester, find.byType(AppBar),
          timeout: const Duration(seconds: 30));

      // 設定タブをタップ（Keyを使用）- 設定セクションが表示されるのを待つ
      await safeTapFirst(tester, find.byKey(const Key('tab_settings_icon')),
          timeout: const Duration(seconds: 15),
          waitFor: find
              .text(LocalizationService.instance.translate('app_settings')));

      // 設定セクションが表示されることを確認
      expect(find.text(LocalizationService.instance.translate('app_settings')),
          findsWidgets);
      expect(find.text(LocalizationService.instance.translate('save_settings')),
          findsWidgets);
    });

    testWidgets('空の状態が正しく表示される', (WidgetTester tester) async {
      // アプリを構築
      await tester.pumpWidget(const EnhancedTeaGardenApp());
      // Allow one frame, then wait for AppBar (indicator that app finished initial build)
      await tester.pump();
      await pumpUntilFound(tester, find.byType(AppBar),
          timeout: const Duration(seconds: 30));

      // 解析タブをタップ（Keyを使用）- 空の状態メッセージが表示されるのを待つ
      await safeTapFirst(tester, find.byKey(const Key('tab_camera_icon')),
          timeout: const Duration(seconds: 15),
          waitFor: find
              .text(LocalizationService.instance.translate('no_results_yet')));

      // 空の状態メッセージが表示されることを確認
      expect(
          find.text(LocalizationService.instance.translate('no_results_yet')),
          findsWidgets);
    });
  });
}
