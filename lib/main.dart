import 'views/login.dart'; // Importlogin.dart file
import 'views/registerPage.dart'; // Import register.dart file'
import 'views/newsList.dart'; // Import news_list.dart file
import 'controllers/bookmark_controller.dart'; // Import BookmarkController
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookmarkController()),
        // You can add other global providers here in the future
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const NewsListPage(), // Use const if NewsListPage constructor is const
        '/register': (context) => const RegisterPage(), // Use const if RegisterPage constructor is const
      },
    );
  }
}
