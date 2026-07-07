import 'package:flutter/material.dart';
import 'package:qishloq_ai_mobile/app/router.dart';
import 'package:qishloq_ai_mobile/core/theme/app_theme.dart';

class QishloqAiApp extends StatelessWidget {
  const QishloqAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'QISHLOQ AI',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
