import 'package:flutter/material.dart';
import 'package:offline_first/database/database.dart';
import 'package:offline_first/my_home_page.dart';

import 'locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Locator.init();
  locator.offlineDbase.init();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

