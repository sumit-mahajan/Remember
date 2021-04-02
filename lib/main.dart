import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:remember/Screens/add_note_screen.dart';
import 'package:remember/screens/tabs_screen.dart';
import 'package:remember/widgets/add_birthday_sheet.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(74, 156.7),
      allowFontScaling: false,
      builder: () => MaterialApp(
        theme: ThemeData.light().copyWith(
          primaryColor: Colors.lightBlue,
          scaffoldBackgroundColor: Color(0xFFFFFFFF),
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
