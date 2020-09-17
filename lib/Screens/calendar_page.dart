import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'todo_page.dart';
import 'birthday_page.dart';
import 'notes_page.dart';

import '../Utilities/constants.dart';
import '../Utilities/NotificationsPlugin.dart';

class CalendarApp extends StatefulWidget {
  static const id = 'calendar_page';
  @override
  _CalendarAppState createState() => _CalendarAppState();
}

class _CalendarAppState extends State<CalendarApp> {
  CalendarController _controller;
  Map<DateTime, List<dynamic>> _events;
  List<dynamic> _selectedEvents;
  TextEditingController _eventController;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
    _eventController = TextEditingController();
    _events = {};
    _selectedEvents = [];
    initPrefs();
    notificationPlugin.setOnNotificationClick(onNotificationClick);
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _events = Map<DateTime, List<dynamic>>.from(
          decodeMap(json.decode(prefs.getString("events") ?? "{}")));
      _selectedEvents = _events[_controller.selectedDay];
    });
  }

  Map<String, dynamic> encodeMap(Map<DateTime, dynamic> map) {
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = map[key];
    });
    return newMap;
  }

  Map<DateTime, dynamic> decodeMap(Map<String, dynamic> map) {
    Map<DateTime, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[DateTime.parse(key)] = map[key];
    });
    return newMap;
  }

  _showAddDialog() async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              title: Center(child: Text("Add Event")),
              content: TextField(
                controller: _eventController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 5.0),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter Event',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                autofocus: true,
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("Save"),
                  onPressed: () async {
                    if (_eventController.text.isEmpty ||
                        _eventController.text.toUpperCase() ==
                            _eventController.text.toLowerCase()) return;
                    if (_events[_controller.selectedDay] != null) {
                      _events[_controller.selectedDay]
                          .add(_eventController.text);
                      await notificationPlugin.scheduleNotification(
                          0,
                          _controller.selectedDay,
                          _eventController.text,
                          false);
                    } else {
                      _events[_controller.selectedDay] = [
                        _eventController.text
                      ];
                      await notificationPlugin.scheduleNotification(
                          0,
                          _controller.selectedDay,
                          _eventController.text,
                          false);
                    }
                    prefs.setString("events", json.encode(encodeMap(_events)));
                    print(json.encode(encodeMap(_events)));
                    _eventController.clear();
                    Navigator.pop(context);
                  },
                )
              ],
            ));
    setState(() {
      _selectedEvents = _events[_controller.selectedDay];
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xFF5F35FE),
        bottomNavigationBar: CurvedNavigationBar(
          height: 50.0,
          backgroundColor: Colors.white,
          buttonBackgroundColor: Color(0xFF5F35FE),
          color: Color(0xFFeff2f9),
          index: 3,
          items: <Widget>[
            Icon(Icons.check_circle_outline, size: 30),
            Icon(Icons.event_note, size: 30),
            Icon(Icons.card_giftcard, size: 30),
            Icon(
              Icons.calendar_today,
              size: 30,
              color: Colors.white,
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, ToDo.id);
                break;
              case 1:
                Navigator.pushNamed(context, Note.id);
                break;
              case 2:
                Navigator.pushNamed(context, Birthday.id);
                break;
            }
          },
          animationDuration: Duration(
            milliseconds: 200,
          ),
          animationCurve: Curves.bounceInOut,
        ),
        body: ListView(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Center(
              child: Text(
                'Calendar',
                style: titleTextStyle,
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height - 140.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TableCalendar(
                    events: _events,
                    calendarStyle: CalendarStyle(
                      canEventMarkersOverflow: true,
                    ),
                    headerStyle: HeaderStyle(
                      centerHeaderTitle: true,
                      formatButtonDecoration: BoxDecoration(
                        color: Color(0xFF5B84FF),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      formatButtonTextStyle: TextStyle(color: Colors.white),
                      formatButtonShowsNext: false,
                    ),
                    onDaySelected: (date, events) {
                      setState(() {
                        _selectedEvents = events;
                      });
                    },
                    builders: CalendarBuilders(
                      selectedDayBuilder: (context, date, events) => Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Color(0xFF5B84FF),
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(color: Colors.white),
                          )),
                      todayDayBuilder: (context, date, events) => Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.lightBlueAccent,
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                    calendarController: _controller,
                  ),
                  _selectedEvents != null
                      ? _selectedEvents.length != 0
                          ? Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    'Events',
                                    style: TextStyle(
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: _selectedEvents.length,
                                    itemBuilder: (context, i) {
                                      dynamic currentEvent = _selectedEvents[i];
                                      return ListTile(
                                        title: Text(currentEvent),
                                        trailing: IconButton(
                                            icon: Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                            ),
                                            onPressed: () async {
                                              setState(() {
                                                _events[_controller.selectedDay]
                                                    .removeAt(i);
                                                prefs.setString(
                                                    "events",
                                                    json.encode(
                                                        encodeMap(_events)));
                                              });
                                              if (_events[_controller
                                                              .selectedDay]
                                                          .length ==
                                                      0 &&
                                                  DateTime.now().isBefore(
                                                      _controller
                                                          .selectedDay)) {
                                                DateTime eDate =
                                                    _controller.selectedDay;
                                                int id = (eDate.day * 100 +
                                                            eDate.month) *
                                                        10000 +
                                                    eDate.year;
                                                await notificationPlugin
                                                    .cancelNotification(id);
                                              }
                                            }),
                                      );
                                    }),
                              ],
                            )
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  'No Events',
                                  style: greetTextStyle,
                                ),
                              ),
                            )
                      : Container(),
                ],
              ),
            ),
          ),
        ]),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xFF5B84FF),
          child: Icon(Icons.add),
          onPressed: _showAddDialog,
        ),
      ),
    );
  }

  onNotificationClick(String payload) {
    print(payload);
  }
}
