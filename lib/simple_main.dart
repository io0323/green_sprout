import 'package:flutter/material.dart';
import 'core/theme/tea_garden_theme.dart';

void main() {
  runApp(const SimpleTeaApp());
}

class SimpleTeaApp extends StatelessWidget {
  const SimpleTeaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '茶園管理AI',
      theme: TeaGardenTheme.lightTheme,
      darkTheme: TeaGardenTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SimpleHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SimpleHomePage extends StatelessWidget {
  const SimpleHomePage({super.key});

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: TeaGardenTheme.backgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.eco,
                size: 100,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                '茶園管理AI',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '茶葉の成長状態と健康状態を解析',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurface.withOpacity(0.6),
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
                        color: colorScheme.primary,
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
                          color: colorScheme.onSurface.withOpacity(0.6),
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
            SnackBar(
              content: const Text('茶園管理AIが動作しています！'),
              backgroundColor: colorScheme.primary,
            ),
          );
        },
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.camera_alt, color: colorScheme.onPrimary),
      ),
    );
  }
}
