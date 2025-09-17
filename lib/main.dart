import 'package:flutter/material.dart';
import 'screens/consoles_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GameControlApp());
}

class GameControlApp extends StatelessWidget {
  const GameControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GameControl V14',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        useMaterial3: true,
      ),
      home: const ConsolesScreen(),
    );
  }
}
