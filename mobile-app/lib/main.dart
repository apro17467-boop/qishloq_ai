import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qishloq_ai_mobile/app/app.dart';

void main() {
  runApp(
    const ProviderScope(
      child: QishloqAiApp(),
    ),
  );
}
