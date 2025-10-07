import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/camera_cubit.dart';
import '../../tea_analysis/presentation/pages/analysis_result_page.dart';

/**
 * カメラページ
 * クリーンアーキテクチャに基づいたカメラ画面
 */
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  void initState() {
    super.initState();
    // カメラの初期化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CameraCubit>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('茶葉撮影'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: BlocListener<CameraCubit, CameraBlocState>(
        listener: (context, state) {
          if (state is CameraCaptured) {
            // 撮影完了後、解析画面に遷移
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AnalysisResultPage(
                  imagePath: state.imagePath,
                ),
              ),
            );
          } else if (state is CameraError) {
            // エラー表示
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<CameraCubit, CameraBlocState>(
          builder: (context, state) {
            if (state is CameraInitializing) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'カメラを初期化中...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            }

            if (state is CameraInitialized) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      size: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'カメラ準備完了',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<CameraCubit>().capture();
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('撮影'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is CameraCapturing) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      '撮影中...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            }

            if (state is CameraError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CameraCubit>().initialize();
                      },
                      child: const Text('再試行'),
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: Text(
                'カメラの準備中...',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}
