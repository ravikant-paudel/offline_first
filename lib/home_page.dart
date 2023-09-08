import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:offline_first/data/database.dart';
import 'package:offline_first/model/offline_model.dart';
import 'package:offline_first/service/dio_wrapper.dart';
import 'package:offline_first/utils/connectivity_plus.dart';
import 'package:offline_first/utils/dialog_box.dart';
import 'package:offline_first/utils/task_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // Create a database for OfflineModel
  final offlineDatabase = GenericDatabase<OfflineModel>('offline_model_box');
  final _myOfflineBox = Hive.box('my_offline_box');

  final ConnectivityService _connectivityService = ConnectivityService();
  final DioWrapper dioWrapper = DioWrapper();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _connectivityService.connectivityStream.listen((result) {
      if (result == ConnectivityResult.none) {
        print('Connection -- NONE');
        // Handle no internet connection
      } else {
        print('Connection -- $result');
        _syncData(); // Sync data when internet is available
      }
    });
  }

  void _initializeData() async {
    if (_myOfflineBox.get("TASK_LIST") == null) {
      final initialData = [
        OfflineModel(name: 'Alice', age: 25),
        OfflineModel(name: 'Bob', age: 30),
        // Add more initial data items as needed
      ];
      offlineDatabase.createInitialData(initialData);
    } else {
      // Data exists, load it from the local database
      offlineDatabase.loadData();
    }
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
        itemCount: offlineDatabase.loadData().length,
        itemBuilder: (context, index) {
          final tasks = offlineDatabase.loadData();
          final taskName = tasks[index].name ?? '';
          return TaskTile(
            taskName: taskName,
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
      },
    );
  }

  void onDataSave() {
    final newItem = OfflineModel(
      name: _controller.text,
      age: 0, // You can set an appropriate value for age
    );

    offlineDatabase.addItem(newItem); // Add the new item to the local database

    setState(() {
      _controller.clear();
    });

    Navigator.of(context).pop();
  }

  void deleteTask(int index) {
    final List<OfflineModel> tasks = offlineDatabase.loadData();
    tasks.removeAt(index); // Remove the item from the list

    offlineDatabase.updateDataBase(tasks); // Update the local database

    setState(() {
      // No need to set state when using a FutureBuilder
    });
  }


  Future<void> _syncData() async {
    // Implement data synchronization with the server using DioWrapper
    // This is where you would send your data to the server when online
    // You can use dioWrapper to make HTTP requests to your server
    try {
      final List<OfflineModel> dataToSync = offlineDatabase.loadData();
      // Send dataToSync to the server using dioWrapper
      // Example: await dioWrapper.syncData(dataToSync);
      // After successful sync, you can clear the local data if needed
      offlineDatabase.clear();
    } catch (e) {
      print('Error syncing data: $e');
      // Handle any errors during data sync
    }
  }
}
