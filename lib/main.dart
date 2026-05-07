import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'services/storage_service.dart';
import 'screens/username_screen.dart';
import 'screens/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/score_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  await Hive.initFlutter();

  
  await StorageService.getInstance();
  await ScoreService.getInstance();

  runApp(const WordCrushApp());
}

class WordCrushApp extends StatelessWidget {
  const WordCrushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Crush',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const _RootDecider(),
    );
  }
}


class _RootDecider extends StatelessWidget {
  const _RootDecider();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StorageService>(
      future: StorageService.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final hasUsername = snapshot.data!.hasUsername();
        return hasUsername
            ? const HomeScreen()
            : const UsernameScreen(isFirstTime: true);
      },
    );
  }
}

