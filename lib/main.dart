import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'locator.dart';
import 'locator.dart' as di;

import 'package:remember/screens/add_note_screen.dart';
import 'package:remember/screens/tabs_screen.dart';
import 'package:remember/widgets/add_birthday_sheet.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init();

  runApp(
    MultiProvider(
      providers: [
        // ChangeNotifierProvider<ThemeProvider>(
        //   create: (context) => locator<ThemeProvider>(),
        // ),
        // ChangeNotifierProvider<AuthProvider>(
        //   create: (context) => locator<AuthProvider>(),
        // ),
        StreamProvider<User?>(
          initialData: null,
          create: (context) => FirebaseAuth.instance.userChanges(),
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
