import 'package:dreamkeeper/database/objectbox.dart';
import 'package:dreamkeeper/views/index.dart';
import 'package:dreamkeeper/router.dart';
import 'package:flutter/material.dart';

late ObjectBox objectbox;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  objectbox = await ObjectBox.create();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'dreamkeeper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      onGenerateRoute: Sitemap.generateRoute, // callback for dynamic routing
      home: const Index(), // entry point to the app
    );
  }
}