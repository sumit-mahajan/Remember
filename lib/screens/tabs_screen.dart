import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remember/locator.dart';
import 'package:remember/providers/birthday_provider.dart';
import 'package:remember/providers/note_provider.dart';
import 'package:remember/providers/todo_provider.dart';
import 'package:remember/screens/birthdays_tab_screen.dart';
import 'package:remember/screens/accounts_tab_screen.dart';
import 'package:remember/screens/notes_tab_screen.dart';
import 'package:remember/screens/todo_tab_screen.dart';
import 'package:remember/services/local_notification_service.dart';
import 'package:remember/utilities/constants.dart';

class TabsScreen extends StatefulWidget {
  static String id = 'tabs_screen';
  final int? preSelected;
  TabsScreen({this.preSelected});

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int? selectedTab;
  LocalNotificationService notificationService = locator<LocalNotificationService>();
  List<Widget> tabsList = [
    ToDoTab(),
    NotesTab(),
    BirthdayTab(),
    AccountsTab(),
  ];

  @override
  void initState() {
    super.initState();
    widget.preSelected == null ? selectedTab = 0 : selectedTab = widget.preSelected;
    // Fetch Todos and Quote
    TodoProvider tProvider = Provider.of<TodoProvider>(context, listen: false);
    tProvider.getTaskList();
    tProvider.getRandomQuote();

    // Setup daily Notification
    // if (tProvider.isFirstTime()) {
    notificationService.cancelDailyNotification();
    notificationService.scheduleDaily();
    // }

    // Fetch Notes
    Provider.of<NoteProvider>(context, listen: false).getNotesList();

    // Fetch Birthdays
    Provider.of<BirthdayProvider>(context, listen: false).getBirthList();

    // Listen Notifications
    listenNotifications();
  }

  void listenNotifications() async {
    notificationService.onNotification.stream.listen((payload) {
      if (payload == 'birthday_reminder') {
        selectedTab = 2;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppPrimaryColor,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        buttonBackgroundColor: kAppPrimaryColor,
        color: kNavBarColor,
        index: selectedTab!,
        height: 50,
        items: <Widget>[
          Icon(
            Icons.check_circle_outline,
            size: 30,
            color: selectedTab == 0 ? Colors.white : Colors.black,
          ),
          Icon(
            Icons.event_note,
            size: 30,
            color: selectedTab == 1 ? Colors.white : Colors.black,
          ),
          Icon(
            Icons.card_giftcard,
            size: 30,
            color: selectedTab == 2 ? Colors.white : Colors.black,
          ),
          Icon(
            Icons.person,
            size: 30,
            color: selectedTab == 3 ? Colors.white : Colors.black,
          ),
        ],
        onTap: (index) {
          setState(() {
            selectedTab = index;
          });
        },
        animationDuration: Duration(
          milliseconds: 100,
        ),
        animationCurve: Curves.bounceInOut,
      ),
      body: tabsList[selectedTab!],
    );
  }
}
