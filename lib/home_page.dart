import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:offline_first/data/database.dart';
import 'package:offline_first/utils/connectivity_plus.dart';
import 'package:offline_first/utils/dialog_box.dart';
import 'package:offline_first/utils/task_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _myOfflineBox = Hive.box('my_offline_box');
  TaskDataBase db = TaskDataBase();
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void initState() {
    // is Initial
    if (_myOfflineBox.get("TASK_LIST") == null) {
      db.createInitialData();
    } else {
      //data exist
      db.loadData();
    }
    super.initState();

    // Subscribe to connectivity changes
    _connectivityService.connectivityStream.listen((result) {
      if (result == ConnectivityResult.none) {
        print('Connection -- NONE');
        // Handle no internet connection
      } else {
        print('PRESENT NOT NULL $result');
        // Handle internet connection
      }
    });
  }

  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: const Text('Offline First'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: db.offlineList.length,
        itemBuilder: (context, index) {
          return TaskTile(
            taskName: db.offlineList[index],
            deleteFunction: (context) => deleteTask(index),
          );
        },
      ),
    );
  }

  void createNewTask() {
    showDialog(
        context: context,
        builder: (context) {
          return DialogBox(
            controller: _controller,
            onSave: onDataSave,
            onCancel: () {
              _controller.clear();
              Navigator.of(context).pop();
            },
          );
        });
  }

  void onDataSave() {
    setState(() {
      db.offlineList.add(_controller.text);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDataBase();
  }

  //To delete task
  void deleteTask(int index) {
    setState(() {
      db.offlineList.removeAt(index);
    });
    db.updateDataBase();
  }
}
