import 'package:hive_flutter/hive_flutter.dart';

class GenericDatabase<T> {
  final String _boxName;
  late Box<T> _box;

  GenericDatabase(this._boxName);

  Future<void> openBox() async {
    _box = await Hive.openBox<T>(_boxName);
  }

  // Create initial data if it doesn't exist
  void createInitialData(List<T> initialData) {
    if (_box.isEmpty) {
      _box.addAll(initialData);
    }
  }

  // Load data from the local database
  List<T> loadData() {
    return _box.values.toList();
  }

  // Update the local database with a list of items of type T
  void updateDataBase(List<T> items) {
    _box.clear(); // Clear the existing data in the box
    _box.addAll(items); // Add the updated list of items to the box
  }

  // Add a single item of type T to the local database
  void addItem(T item) {
    _box.add(item);
  }

  // Clear all items of type T from the database
  void clear() {
    _box.clear();
  }

  // Delete an item at a specific index
  void deleteItem(int index) {
    _box.deleteAt(index);
  }

  // Close the Hive box when it's no longer needed
  Future<void> closeBox() async {
    await _box.close();
  }
}





/*class TaskDataBase {
  List offlineList = [];

  // reference our box
  final _myBox = Hive.box('my_offline_box');

  // run this method if this is the 1st time ever opening this app
  void createInitialData() {
    offlineList = [
      "Ravikant",
      "Elza",
    ];
  }

  // load the data from database
  void loadData() {
    offlineList = _myBox.get("TASK_LIST");
  }

  // update the database
  void updateDataBase() {
    _myBox.put("TASK_LIST", offlineList);
  }
}*/



// import 'package:isar/isar.dart';\
//
// class DatabaseWrapper {
//   Isar isar;
//
//   DatabaseWrapper({required this.isar});
//
//   Future<void> open() async {
//     await isar.open();
//   }
//
//   Future<void> close() async {
//     await isar.close();
//   }
//
//   Future<void> insertTask(Task task) async {
//     await isar.writeTxn((isar) async {
//       await isar.write<Task>().insert(task);
//     });
//   }
//
//   Future<void> updateTask(Task task) async {
//     await isar.writeTxn((isar) async {
//       await isar.write<Task>().update(task);
//     });
//   }
//
//   Future<void> deleteTask(int id) async {
//     await isar.writeTxn((isar) async {
//       final task = await isar.read<Task>().where().idEqualTo(id).findFirst();
//       if (task != null) {
//         await task.delete();
//       }
//     });
//   }
//
//   Future<List<Task>> getAllTasks() async {
//     final tasks = await isar.read<Task>().findAll();
//     return tasks;
//   }
//
//   Future<List<Task>> getCompletedTasks() async {
//     final tasks = await isar.read<Task>().where().isCompletedEqualTo(true).findAll();
//     return tasks;
//   }
//
//   Future<List<Task>> getIncompleteTasks() async {
//     final tasks = await isar.read<Task>().where().isCompletedEqualTo(false).findAll();
//     return tasks;
//   }
//
//   Future<void> watchTasks(void Function(List<Task>) callback) async {
//     final stream = isar.read<Task>().watch();
//     await for (final event in stream) {
//       callback(event);
//     }
//   }
// }