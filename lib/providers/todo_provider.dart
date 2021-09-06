import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:remember/models/todo_model.dart';
import 'package:remember/services/local_database_service.dart';
import 'package:remember/utilities/quotes.dart';

class TodoProvider with ChangeNotifier {
  final SharedPreferences prefs;
  final LocalDbService localDbService;

  TodoProvider({required this.prefs, required this.localDbService});

  bool visibleTextField = false;
  List<TodoModel> taskList = [];
  int countDone = 0;
  String quoteText = '';
  String quoteAuthor = '';
  var random = new Random();

  void toggleTextField() {
    visibleTextField = !visibleTextField;
    notifyListeners();
  }

  bool isFirstTime() {
    var isFirstTime = prefs.getBool('first_time');
    if (isFirstTime != null && !isFirstTime) {
      return false;
    } else {
      prefs.setBool('first_time', false);
      return true;
    }
  }

  void getDoneCount(List<TodoModel> itemList) {
    countDone = 0;
    for (int i = 0; i < itemList.length; i++) {
      if (itemList[i].done) {
        countDone++;
      }
    }
    notifyListeners();
  }

  Future<void> getTaskList() async {
    taskList = await localDbService.getToDoList();
    getDoneCount(taskList);
    notifyListeners();
  }

  void getRandomQuote() {
    int rn = random.nextInt(quoteList.length);
    quoteText = quoteList[rn]['quoteText'];
    quoteAuthor = quoteList[rn]['quoteAuthor'];
  }

  Future<void> addTask(String taskName) async {
    TodoModel newItem = TodoModel(name: taskName, done: false);
    await localDbService.insertToDo(newItem);
    await getTaskList();
    visibleTextField = false;
    notifyListeners();
  }

  Future<void> markAsDone(TodoModel currentitem) async {
    currentitem.done = true;
    await localDbService.updateToDo(currentitem);
    getDoneCount(taskList);
    notifyListeners();
  }

  Future<void> markAsUnDone(TodoModel currentitem) async {
    currentitem.done = false;
    await localDbService.updateToDo(currentitem);
    countDone--;
    notifyListeners();
  }

  Future<void> deleteTodo(TodoModel currentitem, int index) async {
    taskList.removeAt(index);
    await localDbService.deleteToDo(currentitem.id);
    getDoneCount(taskList);
    await Future.delayed(Duration(seconds: 1));
    if (taskList.length == 0) {
      visibleTextField = true;
    }
    notifyListeners();
  }

  Future<void> restoreTodo(TodoModel currentitem, int index) async {
    await localDbService.insertToDo(currentitem);
    taskList.insert(index, currentitem);
    countDone = currentitem.done == true ? countDone + 1 : countDone;
    notifyListeners();
  }
}
