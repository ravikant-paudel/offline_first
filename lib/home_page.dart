import 'package:flutter/material.dart';
import 'package:offline_first/utils/task_tile.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: const Text('Offline First'),
      ),
      body: ListView(
        children: const [
          TaskTile(),
        ],
      ),
    );
  }
}
