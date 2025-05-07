import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitpro/firebase_options.dart';
import 'package:fitpro/auth/signup_screen.dart';
import 'package:tiny_storage/tiny_storage.dart';
import 'package:tiny_locator/tiny_locator.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize TinyStorage
  final directory = await getApplicationDocumentsDirectory();
  final storagePath = '${directory.path}/user_data.txt';
  final storage = await TinyStorage.init(storagePath);

  // Register TinyStorage with tiny_locator
  locator.add<TinyStorage>(() => storage);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitPro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SignupScreen(),
    );
  }
}
