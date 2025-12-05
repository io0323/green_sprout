import 'package:flutter/material.dart';
import 'core/utils/app_initialization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // グローバルエラーハンドラーの設定
  AppInitialization.setupGlobalErrorHandler();

  // 非同期エラーハンドラーの設定とアプリ実行
  await AppInitialization.runWithErrorHandling(() async {
    // 国際化サービスの初期化
    await AppInitialization.initializeLocalization();

    // エラーワジェットの設定（コンストラクタをconstにするためmainに移動）
    AppInitialization.setupErrorWidget();

    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final appDefaults = AppInitialization.getMaterialAppDefaults();
    return MaterialApp(
      title: '茶園管理AI',
      theme: appDefaults.theme,
      darkTheme: appDefaults.darkTheme,
      themeMode: appDefaults.themeMode,
      localizationsDelegates: appDefaults.localizationsDelegates,
      supportedLocales: appDefaults.supportedLocales,
      debugShowCheckedModeBanner: appDefaults.debugShowCheckedModeBanner,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final List<String> _analysisResults = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('茶園管理AI'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.eco,
              size: 100,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              '茶園管理AIが正常に動作しています！',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '解析回数: $_counter',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _analyzeTea,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('茶葉を解析'),
            ),
            const SizedBox(height: 20),
            if (_analysisResults.isNotEmpty) ...[
              const Text(
                '最近の解析結果:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                width: 300,
                child: ListView.builder(
                  itemCount: _analysisResults.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.all(5),
                      child: ListTile(
                        leading: Icon(Icons.eco, color: colorScheme.primary),
                        title: Text(_analysisResults[index]),
                        subtitle: const Text('解析完了'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _analyzeTea,
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.add, color: colorScheme.onPrimary),
      ),
    );
  }

  void _analyzeTea() {
    setState(() {
      _counter++;
      _analysisResults.insert(
          0, '解析結果 #$_counter - ${DateTime.now().toString().substring(0, 19)}');
      if (_analysisResults.length > 5) {
        _analysisResults.removeLast();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('茶葉の解析が完了しました！'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
