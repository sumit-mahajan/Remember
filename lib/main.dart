import 'package:flutter/material.dart';

import 'package:remember/Screens/add_note_screen.dart';
import 'package:remember/screens/birthdays_tab_screen.dart';
import 'package:remember/screens/events_tab_screen.dart';
import 'package:remember/screens/notes_tab_screen.dart';
import 'package:remember/screens/todo_tab_screen.dart';
import 'package:remember/widgets/add_birthday_sheet.dart';

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
      initialRoute: ToDoTab.id,
      routes: {
        ToDoTab.id: (context) {
          return ToDoTab();
        },
        NotesTab.id: (context) {
          return NotesTab();
        },
        BirthdayTab.id: (context) {
          return BirthdayTab();
        },
        AddbirthdaySheet.id: (context) {
          return AddbirthdaySheet();
        },
        AddNoteScreen.id: (context) {
          return AddNoteScreen();
        },
        EventsTab.id: (context) {
          return EventsTab();
        },
      },
    );
  }
}
