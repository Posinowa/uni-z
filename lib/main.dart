import 'package:flutter/material.dart';

void main() {
  runApp(const UnizMobileApp());
}

class UnizMobileApp extends StatelessWidget {
  const UnizMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Uni'z",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text("Uni'z Mobile"),
        ),
      ),
    );
  }
}
