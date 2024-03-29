import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:remember/providers/auth_provider.dart';
import 'package:remember/providers/birthday_provider.dart';
import 'package:remember/providers/note_provider.dart';
import 'package:remember/providers/todo_provider.dart';
import 'locator.dart';
import 'locator.dart' as di;

import 'package:remember/screens/add_note_screen.dart';
import 'package:remember/screens/tabs_screen.dart';
import 'package:remember/widgets/add_birthday_sheet.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => locator<AuthProvider>(),
        ),
        ChangeNotifierProvider<TodoProvider>(
          create: (context) => locator<TodoProvider>(),
        ),
        ChangeNotifierProvider<NoteProvider>(
          create: (context) => locator<NoteProvider>(),
        ),
        ChangeNotifierProvider<BirthdayProvider>(
          create: (context) => locator<BirthdayProvider>(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      builder: () => MaterialApp(
        theme: ThemeData.light().copyWith(
          primaryColor: Colors.lightBlue, //Color(0xFF00B4EE)
          scaffoldBackgroundColor: Colors.white,
          canvasColor: Colors.transparent,
        ),
        initialRoute: TabsScreen.id,
        routes: {
          TabsScreen.id: (context) {
            return TabsScreen();
          },
          AddbirthdaySheet.id: (context) {
            return AddbirthdaySheet();
          },
          AddNoteScreen.id: (context) {
            return AddNoteScreen();
          },
        },
      ),
    );
  }
}
