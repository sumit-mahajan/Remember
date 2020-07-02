import 'package:flutter/material.dart';
import './Screens/todo_page.dart';
import './Screens/notes_page.dart';
import './Screens/birthday_page.dart';
import './Screens/add_birthday.dart';
import './Screens/add_notes.dart';
import './Screens/calendar_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.lightBlue,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        canvasColor: Colors.transparent,
      ),
      initialRoute: ToDo.id,
      routes: {
        ToDo.id: (context) {
          return ToDo();
        },
        Note.id: (context) {
          return Note();
        },
        Birthday.id: (context) {
          return Birthday();
        },
        Addbirthday.id: (context) {
          return Addbirthday();
        },
        AddNote.id: (context) {
          return AddNote();
        },
        CalendarApp.id: (context) {
          return CalendarApp();
        },
      },
    );
  }
}
