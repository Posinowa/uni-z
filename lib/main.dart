import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(const UnizMobileApp());
}

class UnizMobileApp extends StatelessWidget {
  const UnizMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Uni'z",
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Center(
          child: Text("Uni'z Mobile"),
        ),
      ),
    );
  }
}

