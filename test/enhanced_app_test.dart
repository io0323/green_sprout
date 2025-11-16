import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
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
    if (tester.any(finder)) {
      return;
    }
  }
  throw Exception('Timed out waiting for $finder');
}

void main() {
  setUpAll(() async {
    // テストバインディングを初期化
    TestWidgetsFlutterBinding.ensureInitialized();

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
  });

  group('EnhancedTeaGardenApp', () {
    testWidgets('アプリが正常に起動する', (WidgetTester tester) async {
      // アプリを構築（非同期初期化を許可）
      await tester.runAsync(() async {
        await tester.pumpWidget(const EnhancedTeaGardenApp());

        // FutureBuilderが完了するまで待機
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      });

      // AppBarが表示されるまで待機（タイムアウトを増やす）
      await pumpUntilFound(tester, find.byType(AppBar),
          timeout: const Duration(seconds: 15));

      // AppBarが表示されることを確認
      expect(find.byType(AppBar), findsOneWidget);

      // タイトルが表示されることを確認（複数表示される可能性があるため）
      expect(
          find.text(
              LocalizationService.instance.translate('enhanced_app_title')),
          findsWidgets);
    });

    testWidgets('タブナビゲーションが表示される', (WidgetTester tester) async {
      // アプリを構築（非同期初期化を許可）
      await tester.runAsync(() async {
        await tester.pumpWidget(const EnhancedTeaGardenApp());
        // CI環境での遅い初期化を完了させるためにタイムアウトを増やす
        await tester.pumpAndSettle(const Duration(seconds: 12));
      });

      // タブが表示されることを確認
      expect(find.byIcon(Icons.dashboard), findsWidgets);
      expect(find.byIcon(Icons.camera_alt), findsWidgets);
      expect(find.byIcon(Icons.bar_chart), findsWidgets);
      expect(find.byIcon(Icons.download), findsWidgets);
      expect(find.byIcon(Icons.settings), findsWidgets);
    });

    testWidgets('ダッシュボードタブが表示される', (WidgetTester tester) async {
      // アプリを構築（非同期初期化を許可）
      await tester.runAsync(() async {
        await tester.pumpWidget(const EnhancedTeaGardenApp());
        // CI環境での遅い初期化を完了させるためにタイムアウトを増やす
        await tester.pumpAndSettle(const Duration(seconds: 12));
      });

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
      // アプリを構築（非同期初期化を許可）
      await tester.runAsync(() async {
        await tester.pumpWidget(const EnhancedTeaGardenApp());
        // CI環境での遅い初期化を完了させるためにタイムアウトを増やす
        await tester.pumpAndSettle(const Duration(seconds: 12));
      });

      // 解析タブをタップ
      final analysisTab = find.byIcon(Icons.camera_alt).first;
      await tester.tap(analysisTab);
      await tester.runAsync(() async {
        await tester.pump();
        await tester.pumpAndSettle(const Duration(seconds: 12));
      });

      // 解析ボタンが表示されることを確認
      expect(find.text(LocalizationService.instance.translate('take_photo')),
          findsWidgets);
    });

    testWidgets('解析を実行すると結果が追加される', (WidgetTester tester) async {
      // アプリを構築（非同期初期化を許可）
      await tester.runAsync(() async {
        await tester.pumpWidget(const EnhancedTeaGardenApp());
        // CI環境での遅い初期化を完了させるためにタイムアウトを増やす
        await tester.pumpAndSettle(const Duration(seconds: 12));
      });

      // 解析タブをタップ
      final analysisTab = find.byIcon(Icons.camera_alt).first;
      await tester.tap(analysisTab);
      await tester.runAsync(() async {
        await tester.pump();
        await tester.pumpAndSettle(const Duration(seconds: 12));
      });

      // 解析ボタンをタップ
      final analyzeButton =
          find.text(LocalizationService.instance.translate('take_photo'));
      await tester.tap(analyzeButton);

      // ローディング表示を確認
      await tester.pump();
      expect(find.text(LocalizationService.instance.translate('ai_analyzing')),
          findsWidgets);

      // 解析が完了するまで待機
      await tester.runAsync(() async {
        await tester.pumpAndSettle(const Duration(seconds: 12));
      });

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
      // アプリを構築（非同期初期化を許可）
      await tester.runAsync(() async {
        await tester.pumpWidget(const EnhancedTeaGardenApp());
        // CI環境での遅い初期化を完了させるためにタイムアウトを増やす
        await tester.pumpAndSettle(const Duration(seconds: 12));
      });

      // チャートタブをタップ
      final chartsTab = find.byIcon(Icons.bar_chart).first;
      await tester.tap(chartsTab);
      await tester.runAsync(() async {
        await tester.pump();
        await tester.pumpAndSettle(const Duration(seconds: 12));
      });

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
      // アプリを構築（非同期初期化を許可）
      await tester.runAsync(() async {
        await tester.pumpWidget(const EnhancedTeaGardenApp());
        // CI環境での遅い初期化を完了させるためにタイムアウトを増やす
        await tester.pumpAndSettle(const Duration(seconds: 12));
      });

      // エクスポートタブをタップ
      final exportTab = find.byIcon(Icons.download).first;
      await tester.tap(exportTab);
      await tester.runAsync(() async {
        await tester.pump();
        await tester.pumpAndSettle(const Duration(seconds: 12));
      });

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
      // アプリを構築（非同期初期化を許可）
      await tester.runAsync(() async {
        await tester.pumpWidget(const EnhancedTeaGardenApp());
        // CI環境での遅い初期化を完了させるためにタイムアウトを増やす
        await tester.pumpAndSettle(const Duration(seconds: 12));
      });

      // 設定タブをタップ
      final settingsTab = find.byIcon(Icons.settings).first;
      await tester.tap(settingsTab);
      await tester.runAsync(() async {
        await tester.pump();
        await tester.pumpAndSettle(const Duration(seconds: 12));
      });

      // 設定セクションが表示されることを確認
      expect(find.text(LocalizationService.instance.translate('app_settings')),
          findsWidgets);
      expect(find.text(LocalizationService.instance.translate('save_settings')),
          findsWidgets);
    });

    testWidgets('空の状態が正しく表示される', (WidgetTester tester) async {
      // アプリを構築（非同期初期化を許可）
      await tester.runAsync(() async {
        await tester.pumpWidget(const EnhancedTeaGardenApp());
        // CI環境での遅い初期化を完了させるためにタイムアウトを増やす
        await tester.pumpAndSettle(const Duration(seconds: 12));
      });

      // 解析タブをタップ
      final analysisTab = find.byIcon(Icons.camera_alt).first;
      await tester.tap(analysisTab);
      await tester.runAsync(() async {
        await tester.pump();
        await tester.pumpAndSettle(const Duration(seconds: 12));
      });

      // 空の状態メッセージが表示されることを確認
      expect(
          find.text(LocalizationService.instance.translate('no_results_yet')),
          findsWidgets);
    });
  });
}
