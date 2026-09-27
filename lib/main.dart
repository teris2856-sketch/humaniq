import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:swiftspeak/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env first
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp();
  print("Firebase initialized");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const bannerBlue = Colors.blueAccent;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: bannerBlue),
        appBarTheme: const AppBarTheme(
          backgroundColor: bannerBlue,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: bannerBlue,
            foregroundColor: Colors.white,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: bannerBlue,
          foregroundColor: Colors.white,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: bannerBlue,
        ),
      ),
      home: const Login(),
    );
  }
}