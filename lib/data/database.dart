import 'package:hive_flutter/hive_flutter.dart';

class TaskDataBase {
  List offlineList = [];

  // reference our box
  final _myBox = Hive.box('my_offline_box');

  // run this method if this is the 1st time ever opening this app
  void createInitialData() {
    offlineList = [
      "Ravikant",
      "Elza",
    ];
    // taskList = [
    //   ["Ravikant", false],
    //   ["Elza", false],
    // ];
  }

  // load the data from database
  void loadData() {
    offlineList = _myBox.get("TASK_LIST");
  }

  // update the database
  void updateDataBase() {
    _myBox.put("TASK_LIST", offlineList);
  }
}
