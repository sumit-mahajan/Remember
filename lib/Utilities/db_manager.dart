import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'items.dart';
import '../Screens/add_notes.dart';
import 'store_birthday.dart';

class DbManager {
  Database _database;

  Future openDb() async {
    if (_database == null) {
      _database = await openDatabase(join(await getDatabasesPath(), "r.db"),
          version: 1, onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE todoTable (id INTEGER PRIMARY KEY autoincrement, item TEXT, done BOOLEAN default 0)",
        );
        await db.execute(
          "CREATE TABLE noteTable (id INTEGER PRIMARY KEY autoincrement, content TEXT)",
        );
        await db.execute(
          "CREATE TABLE birthTable (id INTEGER PRIMARY KEY autoincrement, name TEXT, dateString DATETIME)",
        );
      });
    }
  }

//ToDo
  Future<int> insertToDo(TodoItem todo) async {
    await openDb();
    return await _database.insert('todoTable', todo.toMap());
  }

  Future<List<TodoItem>> getToDoList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('todoTable');
    List<TodoItem> newList = [];
    for (int i = 0; i < maps.length; i++) {
      newList.add(TodoItem(
          id: maps[i]['id'],
          item: maps[i]['item'],
          done: maps[i]['done'] == 0 ? false : true));
    }
    return newList;
  }

  Future<int> updateToDo(TodoItem todo) async {
    await openDb();
    return await _database.update('todoTable', todo.toMap(),
        where: "id = ?", whereArgs: [todo.id]);
  }

  Future<void> deleteToDo(int id) async {
    await openDb();
    await _database.delete('todoTable', where: "id = ?", whereArgs: [id]);
  }

//Note
  Future<int> insertNote(StoreNote newnote) async {
    await openDb();
    return await _database.insert('noteTable', newnote.toMap());
  }

  Future<List<StoreNote>> getNoteList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('noteTable');
    List<StoreNote> newList = [];
    for (int i = 0; i < maps.length; i++) {
      newList.add(StoreNote(
        id: maps[i]['id'],
        content: maps[i]['content'],
      ));
    }
    return newList;
  }

  Future<int> updateNote(StoreNote newnote) async {
    await openDb();
    return await _database.update('noteTable', newnote.toMap(),
        where: "id = ?", whereArgs: [newnote.id]);
  }

  Future<void> deleteNote(int id) async {
    await openDb();
    await _database.delete('noteTable', where: "id = ?", whereArgs: [id]);
  }

//Birthday
  Future<int> insertBirthday(StoreBirthday sb) async {
    await openDb();
    return await _database.insert('birthTable', sb.toMap());
  }

  Future<List<StoreBirthday>> getBirthList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('birthTable');
    List<StoreBirthday> newList = [];
    for (int i = 0; i < maps.length; i++) {
      newList.add(StoreBirthday(
          id: maps[i]['id'],
          name: maps[i]['name'],
          dateString: maps[i]['dateString']));
    }
    return newList;
  }

  Future<void> deleteBirth(int id) async {
    await openDb();
    await _database.delete('birthTable', where: "id = ?", whereArgs: [id]);
  }

  //Events

}
