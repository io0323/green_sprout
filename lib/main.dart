import 'package:flutter/material.dart';

/**
 * 茶園管理AIアプリのメインエントリーポイント
 * クリーンアーキテクチャを採用したアプリケーション
 */
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const TeaGardenApp());
}

/**
 * アプリケーションのルートウィジェット
 * クリーンアーキテクチャに基づいた構造
 */
class TeaGardenApp extends StatelessWidget {
  const TeaGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '茶園管理AI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomePage(),
    );
  }
}

/**
 * ホームページ
 * 基本的なUIを表示
 */
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('茶園管理AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: 日誌一覧画面への遷移
            },
            tooltip: '日誌一覧',
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 24),
            Text(
              '茶園管理AI',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'クリーンアーキテクチャ版',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 32),
            Text(
              'アプリの基本構造は完成しています',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '詳細な機能実装は順次追加予定です',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: カメラ画面への遷移
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('カメラ機能は実装中です'),
              backgroundColor: Colors.green,
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}