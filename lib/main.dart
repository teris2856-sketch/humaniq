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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(),
    );
  }
}