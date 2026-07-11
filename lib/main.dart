import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/services/hive_service.dart';
import 'features/subject/presentation/bloc/subject_bloc.dart';
import 'features/subject/presentation/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HiveService.hiveInit();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrepPilot Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFE5E5E5),
        primaryColor: const Color(0xFFE5E5E5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE5E5E5),
          brightness: Brightness.light,
          primary: const Color(0xFFE5E5E5),
          secondary: const Color(0xFF6E48AA), // slightly deeper purple for light bg
          surface: const Color(0xFFF7F7F8),
        ),
        textTheme: const TextTheme(
          displayMedium: TextStyle(
            color: Color(0xFF0D0D0D),
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          bodyLarge: TextStyle(color: Color(0xFF0D0D0D)),
          bodyMedium: TextStyle(color: Color(0xFF676767)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE5E5E5),
          foregroundColor: Color(0xFF0D0D0D),
          elevation: 0,
        ),
      ),
      home: BlocProvider<SubjectBloc>(
        create: (context) => SubjectBloc(),
        child: const DashboardScreen(),
      ),
    );
  }
}
