import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:remember/screens/birthdays_tab_screen.dart';
import 'package:remember/screens/events_tab_screen.dart';
import 'package:remember/screens/notes_tab_screen.dart';
import 'package:remember/screens/todo_tab_screen.dart';

class TabsScreen extends StatefulWidget {
  static String id = 'tabs_screen';
  final int preSelected;
  TabsScreen({this.preSelected});

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int selectedTab;
  List<Widget> tabsList = [
    ToDoTab(),
    NotesTab(),
    BirthdayTab(),
    EventsTab(),
  ];

  @override
  void initState() {
    widget.preSelected == null
        ? selectedTab = 0
        : selectedTab = widget.preSelected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF5F35FE),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        buttonBackgroundColor: Color(0xFF5F35FE),
        color: Color(0xFFeff2f9),
        index: selectedTab,
        height: 50.0,
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
            Icons.calendar_today,
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
      body: tabsList[selectedTab],
    );
  }
}
