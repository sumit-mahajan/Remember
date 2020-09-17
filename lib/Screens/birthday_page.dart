import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'todo_page.dart';
import 'notes_page.dart';
import 'add_birthday.dart';
import 'calendar_page.dart';

import '../Utilities/db_manager.dart';
import '../Utilities/store_birthday.dart';
import '../Utilities/constants.dart';
import '../Utilities/NotificationsPlugin.dart';

class Birthday extends StatefulWidget {
  static const id = 'birthdays_page';

  @override
  _BirthdayState createState() => _BirthdayState();
}

class _BirthdayState extends State<Birthday> {
  List<StoreBirthday> birthList = [];
  List<StoreBirthday> todayList = [];
  List<StoreBirthday> laterBirthList = [];
  var formatter = new DateFormat('dd-MM-yyyy');
  List<Padding> laterWidgets = [];
  List<int> _selectedIndexList = List();
  bool _selectionMode = false;
  DbManager dbmanager = DbManager();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationPlugin.setOnNotificationClick(onNotificationClick);
  }

  void _changeSelection({bool enable, int index}) {
    _selectionMode = enable;
    _selectedIndexList.add(index);
    if (index == -1) {
      _selectedIndexList.clear();
    }
  }

  void sortLater() {
    for (int i = 0; i < laterBirthList.length; i++) {
      laterBirthList[i].days = laterBirthList[i]
          .dateofbirth
          .difference(DateTime(laterBirthList[i].dateofbirth.year,
              DateTime.now().month, DateTime.now().day))
          .inDays;
      if (laterBirthList[i].days < 0) {
        laterBirthList[i].days = laterBirthList[i]
            .dateofbirth
            .difference(DateTime(laterBirthList[i].dateofbirth.year - 1,
                DateTime.now().month, DateTime.now().day))
            .inDays;
      }
    }
    laterBirthList.sort((a, b) => a.days.compareTo(b.days));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Color(0xFF5F35FE),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Color(0xFF5B84FF),
            child: Icon(
              Icons.add,
              size: 30.0,
            ),
            onPressed: () {
              showModalBottomSheet(
                  context: context, builder: (context) => Addbirthday());
            }),
        bottomNavigationBar: CurvedNavigationBar(
          height: 50.0,
          backgroundColor: Colors.white,
          buttonBackgroundColor: Color(0xFF5F35FE),
          color: Color(0xFFeff2f9),
          index: 2,
          items: <Widget>[
            Icon(Icons.check_circle_outline, size: 30),
            Icon(
              Icons.event_note,
              size: 30,
            ),
            Icon(
              Icons.card_giftcard,
              size: 30,
              color: Colors.white,
            ),
            Icon(Icons.calendar_today, size: 30),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, ToDo.id);
                break;
              case 1:
                Navigator.pushNamed(context, Note.id);
                break;
              case 3:
                Navigator.pushNamed(context, CalendarApp.id);
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
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _selectionMode
                    ? IconButton(
                        icon: Icon(Icons.cancel),
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            _changeSelection(enable: false, index: -1);
                          });
                        },
                      )
                    : Container(),
                Text(
                  'Birthdays',
                  style: titleTextStyle,
                ),
                _selectionMode
                    ? IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.white,
                        onPressed: () {
                          if (_selectedIndexList.length > 0)
                            showAlertDialog(context);
                        },
                      )
                    : Container(),
              ],
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
              child: FutureBuilder(
                future: dbmanager.getBirthList(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    birthList = snapshot.data;
                    if (birthList.length == 0) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 280.0),
                          child: Text(
                            'Add Birthdays',
                            style: greetTextStyle,
                          ),
                        ),
                      );
                    }
                    for (int i = 0; i < birthList.length; i++) {
                      birthList[i].dateofbirth =
                          DateTime.parse(birthList[i].dateString);
                    }
                    todayList = birthList
                        .where((i) =>
                            i.dateofbirth.month == DateTime.now().month &&
                            i.dateofbirth.day == DateTime.now().day)
                        .toList();
                    laterBirthList = birthList
                        .where((i) =>
                            !(i.dateofbirth.month == DateTime.now().month &&
                                i.dateofbirth.day == DateTime.now().day))
                        .toList();

                    sortLater();
                    return Column(
                      children: <Widget>[
                        todayList.length != 0
                            ? Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Text(
                                  'Today',
                                  style: TextStyle(
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            : Container(),
                        ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: todayList.length,
                            itemBuilder: (context, i) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.0),
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFF6A315),
                                          Color(0xFFFE636B),
                                        ],
                                        stops: [0.0, 0.9],
                                      )),
                                  child: ListTile(
                                    leading: ClipOval(
                                      child: Material(
                                        color:
                                            Color(0xFF5B84FF), // button color
                                        child: InkWell(
                                          splashColor:
                                              Colors.red, // inkwell color
                                          child: SizedBox(
                                              width: 56,
                                              height: 56,
                                              child: Icon(
                                                Icons.cake,
                                                color: Colors.white,
                                              )),
                                          onTap: () {},
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      todayList[i].name,
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text(
                                      'Turns ' +
                                          (DateTime.now().year -
                                                  todayList[i].dateofbirth.year)
                                              .toString() +
                                          ' years old',
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              );
                            }),
                        laterBirthList.length > 0
                            ? Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Text(
                                  'Later',
                                  style: TextStyle(
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            : Container(),
                        ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: laterBirthList.length,
                            itemBuilder: (context, i) {
                              if (_selectionMode) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_selectedIndexList.contains(i)) {
                                        _selectedIndexList.remove(i);
                                      } else {
                                        _selectedIndexList.add(i);
                                      }
                                    });
                                  },
                                  child: Container(
                                    color: _selectedIndexList.contains(i)
                                        ? Colors.lightBlueAccent
                                        : Colors.white,
                                    child: ListTile(
                                      leading: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: <Widget>[
                                          Text(
                                            laterBirthList[i].days.toString(),
                                            style: TextStyle(
                                                fontSize: 28.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            'days',
                                            style: TextStyle(fontSize: 14.0),
                                          ),
                                        ],
                                      ),
                                      title: Text(
                                        laterBirthList[i].name,
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      subtitle: Text(
                                        'BirthDate: ' +
                                            formatter
                                                .format(laterBirthList[i]
                                                    .dateofbirth)
                                                .toString(),
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return GestureDetector(
                                  onLongPress: () {
                                    setState(() {
                                      _changeSelection(enable: true, index: i);
                                    });
                                  },
                                  child: ListTile(
                                    leading: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: <Widget>[
                                        Text(
                                          laterBirthList[i].days.toString(),
                                          style: TextStyle(
                                              fontSize: 28.0,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          'days',
                                          style: TextStyle(fontSize: 14.0),
                                        ),
                                      ],
                                    ),
                                    title: Text(
                                      laterBirthList[i].name,
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                    subtitle: Text(
                                      'BirthDate: ' +
                                          formatter
                                              .format(
                                                  laterBirthList[i].dateofbirth)
                                              .toString(),
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                  ),
                                );
                              }
                            }),
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("CANCEL"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "DELETE",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        _selectedIndexList.sort();
        for (int i in _selectedIndexList) {
          dbmanager.deleteBirth(laterBirthList[i].id);
          notificationPlugin.cancelNotification(laterBirthList[i].id);
        }
        setState(() {
          _changeSelection(enable: false, index: -1);
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      title: Text("Confirm Deletion"),
      content: Text("Are you sure you want to delete these Birthdays?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  onNotificationClick(String payload) {
    print(payload);
  }
}
