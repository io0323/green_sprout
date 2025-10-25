import 'package:flutter/material.dart';

void main() {
  runApp(const SimpleTeaApp());
}

class SimpleTeaApp extends StatelessWidget {
  const SimpleTeaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '茶園管理AI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const SimpleHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SimpleHomePage extends StatelessWidget {
  const SimpleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('茶園管理AI'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.white,
            ],
          ),
        ),
        child: const Center(
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
                '茶葉の成長状態と健康状態を解析',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 32),
              Card(
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 48,
                        color: Colors.green,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'アプリが正常に起動しました！',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Webプラットフォームで動作しています',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('茶園管理AIが動作しています！'),
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
