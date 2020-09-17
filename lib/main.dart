import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';

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
      initialRoute: "0",
      routes: {
        "0": (context) {
          return SplashScr();
        },
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

class SplashScr extends StatefulWidget {
  @override
  _SplashScrState createState() => _SplashScrState();
}

class _SplashScrState extends State<SplashScr> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushNamed(context, ToDo.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlareActor("assets/check.flr",
          alignment: Alignment.center,
          fit: BoxFit.contain,
          animation: "Untitled"),
    );
  }
}
