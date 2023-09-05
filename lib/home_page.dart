import 'package:flutter/material.dart';
import 'package:offline_first/utils/dialog_box.dart';
import 'package:offline_first/utils/task_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List offlineList = ["Ravikant", "Bikash", "Ashim", "Biplab", "Ishwor"];

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
        itemCount: offlineList.length,
        itemBuilder: (context, index) {
          return TaskTile(
            taskName: offlineList[index],
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
      offlineList.add(_controller.text);
      _controller.clear();
    });
    Navigator.of(context).pop();
  }

  //To delete task
  void deleteTask(int index) {
    setState(() {
      offlineList.removeAt(index);
    });
  }
}
