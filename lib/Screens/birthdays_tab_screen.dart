import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remember/models/birthday_model.dart';

import 'package:remember/services/notifications_service.dart';
import 'package:remember/utilities/constants.dart';
import 'package:remember/services/database_service.dart';

import 'package:remember/widgets/add_birthday_sheet.dart';

class BirthdayTab extends StatefulWidget {
  //static const id = 'birthdays_page';

  @override
  _BirthdayTabState createState() => _BirthdayTabState();
}

class _BirthdayTabState extends State<BirthdayTab> {
  List<BirthdayModel> birthList = [];
  List<BirthdayModel> todayList = [];
  List<BirthdayModel> laterBirthList = [];
  var formatter = new DateFormat('dd-MM-yyyy');
  List<Padding> laterWidgets = [];
  List<int> _selectedIndexList = List();
  bool _selectionMode = false;
  DbManager dbmanager = DbManager();

  @override
  void initState() {
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
    return ListView(children: <Widget>[
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
                : SizedBox(
                    width: 30.0,
                  ),
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
                : GestureDetector(
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 30.0,
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => AddbirthdaySheet(),
                      );
                    },
                  ),
          ],
        ),
      ),
      Container(
        height: MediaQuery.of(context).size.height - 140.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
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
                                  fontSize: 25.0, fontWeight: FontWeight.w500),
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
                              ),
                              child: ListTile(
                                leading: ClipOval(
                                  child: Material(
                                    color: Color(0xFF5B84FF), // button color
                                    child: InkWell(
                                      splashColor: Colors.red, // inkwell color
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
                                  fontSize: 25.0, fontWeight: FontWeight.w500),
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
                                            .format(
                                                laterBirthList[i].dateofbirth)
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
                                          .format(laterBirthList[i].dateofbirth)
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
    ]);
  }
}
