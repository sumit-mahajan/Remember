import 'dart:async';
import 'package:path/path.dart';
import 'package:remember/models/birthday_model.dart';
import 'package:sqflite/sqflite.dart';

import 'package:remember/models/note_model.dart';
import 'package:remember/models/todo_model.dart';

class DbManager {
  Database _database;

  Future openDb() async {
    if (_database == null) {
      _database = await openDatabase(join(await getDatabasesPath(), "r.db"),
          version: 1, onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE todoTable (id INTEGER PRIMARY KEY autoincrement, name TEXT, done BOOLEAN default 0)",
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
  Future<int> insertToDo(TodoModel todo) async {
    await openDb();
    return await _database.insert('todoTable', todo.toMap());
  }

  Future<List<TodoModel>> getToDoList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('todoTable');
    List<TodoModel> newList = [];
    for (int i = 0; i < maps.length; i++) {
      newList.add(TodoModel(
          id: maps[i]['id'],
          name: maps[i]['name'],
          done: maps[i]['done'] == 0 ? false : true));
    }
    return newList;
  }

  Future<int> updateToDo(TodoModel todo) async {
    await openDb();
    return await _database.update('todoTable', todo.toMap(),
        where: "id = ?", whereArgs: [todo.id]);
  }

  Future<void> deleteToDo(int id) async {
    await openDb();
    await _database.delete('todoTable', where: "id = ?", whereArgs: [id]);
  }

//Note
  Future<int> insertNote(NoteModel newnote) async {
    await openDb();
    return await _database.insert('noteTable', newnote.toMap());
  }

  Future<List<NoteModel>> getNoteList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('noteTable');
    List<NoteModel> newList = [];
    for (int i = 0; i < maps.length; i++) {
      newList.add(NoteModel(
        id: maps[i]['id'],
        content: maps[i]['content'],
      ));
    }
    return newList;
  }

  Future<int> updateNote(NoteModel newnote) async {
    await openDb();
    return await _database.update('noteTable', newnote.toMap(),
        where: "id = ?", whereArgs: [newnote.id]);
  }

  Future<void> deleteNote(int id) async {
    await openDb();
    await _database.delete('noteTable', where: "id = ?", whereArgs: [id]);
  }

//Birthday
  Future<int> insertBirthday(BirthdayModel sb) async {
    await openDb();
    return await _database.insert('birthTable', sb.toMap());
  }

  Future<List<BirthdayModel>> getBirthList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('birthTable');
    List<BirthdayModel> newList = [];
    for (int i = 0; i < maps.length; i++) {
      newList.add(BirthdayModel(
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
