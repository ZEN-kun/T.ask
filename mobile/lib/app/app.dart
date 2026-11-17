import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_mobile/app/routes.dart';
import 'package:task_mobile/app/theme.dart';
import 'package:task_mobile/app/theme_provider.dart';
import 'package:task_mobile/core/constants/app_constants.dart';

class TaskApp extends ConsumerWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
