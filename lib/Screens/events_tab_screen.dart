import 'package:flutter/material.dart';
import 'package:remember/widgets/custom_button.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:remember/services/notifications_service.dart';
import 'package:remember/utilities/constants.dart';

class EventsTab extends StatefulWidget {
  //static const id = 'calendar_page';
  @override
  _EventsTabState createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
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

  onNotificationClick(String payload) {
    print(payload);
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _events = Map<DateTime, List<dynamic>>.from(decodeMap(json.decode(prefs.getString("events") ?? "{}")));
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              title: Center(child: Text("Add Event")),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text field
                  TextField(
                    controller: _eventController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Enter Event',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    autofocus: true,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  // Add Button
                  CustomButton(
                    text: 'Add',
                    onClick: _addEvent,
                  )
                ],
              ),
            ));
    setState(() {
      _selectedEvents = _events[_controller.selectedDay];
    });
  }

  _addEvent() async {
    if (_eventController.text.isEmpty || _eventController.text.toUpperCase() == _eventController.text.toLowerCase())
      return;
    if (_events[_controller.selectedDay] != null) {
      _events[_controller.selectedDay].add(_eventController.text);
      await notificationPlugin.scheduleNotification(0, _controller.selectedDay, _eventController.text, false);
    } else {
      _events[_controller.selectedDay] = [_eventController.text];
      await notificationPlugin.scheduleNotification(0, _controller.selectedDay, _eventController.text, false);
    }
    prefs.setString("events", json.encode(encodeMap(_events)));
    print(json.encode(encodeMap(_events)));
    _eventController.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 30.0,
              ),
              Text(
                'Events',
                style: kTitleTextStyle,
              ),
              GestureDetector(
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30.0,
                ),
                onTap: _showAddDialog,
              )
            ],
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height - 145.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(
                  20.0,
                )),
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
                        decoration: BoxDecoration(color: Color(0xFF5B84FF), borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(color: Colors.white),
                        )),
                    todayDayBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration:
                            BoxDecoration(color: Colors.lightBlueAccent, borderRadius: BorderRadius.circular(10.0)),
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
                                  style: kBoldTextStyle,
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
                                      title: Text(
                                        currentEvent,
                                        style: kSmallTextStyle,
                                      ),
                                      trailing: IconButton(
                                          icon: Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            setState(() {
                                              _events[_controller.selectedDay].removeAt(i);
                                              prefs.setString("events", json.encode(encodeMap(_events)));
                                            });
                                            if (_events[_controller.selectedDay].length == 0 &&
                                                DateTime.now().isBefore(_controller.selectedDay)) {
                                              DateTime eDate = _controller.selectedDay;
                                              int id = (eDate.day * 100 + eDate.month) * 10000 + eDate.year;
                                              await notificationPlugin.cancelNotification(id);
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
                                style: kBodyTextStyle,
                              ),
                            ),
                          )
                    : Container(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
