import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'core/di/injection_container.dart' as di;
import 'features/tea_analysis/presentation/bloc/tea_analysis_cubit.dart';
import 'features/tea_analysis/presentation/bloc/analysis_cubit.dart';
import 'features/camera/presentation/bloc/camera_cubit.dart';
import 'features/tea_analysis/presentation/pages/home_page.dart';
import 'features/camera/presentation/pages/camera_page.dart';
import 'features/logs/presentation/pages/log_list_page.dart';
import 'features/tea_analysis/presentation/pages/analysis_result_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const TeaGardenApp());
}

class TeaGardenApp extends StatelessWidget {
  const TeaGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TeaAnalysisCubit>(
          create: (context) => GetIt.I<TeaAnalysisCubit>(),
        ),
        BlocProvider<AnalysisCubit>(
          create: (context) => GetIt.I<AnalysisCubit>(),
        ),
        BlocProvider<CameraCubit>(
          create: (context) => GetIt.I<CameraCubit>(),
        ),
      ],
      child: MaterialApp(
        title: '茶園管理AI',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/camera': (context) => const CameraPage(),
          '/logs': (context) => const LogListPage(),
          '/analysis': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as String;
            return AnalysisResultPage(imagePath: args);
          },
        },
      ),
    );
  }
}