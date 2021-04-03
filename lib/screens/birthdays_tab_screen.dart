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
        style: kBody1TextStyle.copyWith(color: Colors.red),
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

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete these Birthdays?"),
          actions: [
            cancelButton,
            continueButton,
          ],
        );
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
        padding: const EdgeInsets.all(15.0),
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
              style: kTitleTextStyle,
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
        height: MediaQuery.of(context).size.height - 145.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
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
                        'No Birthdays Found',
                        style: kBody1TextStyle,
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
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: <Widget>[
                      todayList.length != 0
                          ? Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Text(
                                'Today',
                                style: kBoldTextStyle,
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 70.0,
                                    child: Center(
                                      child: ClipOval(
                                        child: Material(
                                          color:
                                              kButtonFillColor, // button color
                                          child: InkWell(
                                            splashColor:
                                                Colors.red, // inkwell color
                                            child: SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: Icon(
                                                  Icons.cake,
                                                  color: Colors.white,
                                                )),
                                            onTap: () {},
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        todayList[i].name,
                                        style: kBody1TextStyle,
                                      ),
                                      Text(
                                        'Turns ' +
                                            (DateTime.now().year -
                                                    todayList[i]
                                                        .dateofbirth
                                                        .year)
                                                .toString() +
                                            ' years old',
                                        style: kSubtitleTextStyle,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          }),
                      laterBirthList.length > 0
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: Text(
                                'Later',
                                style: kBoldTextStyle,
                              ),
                            )
                          : Container(),
                      ListView.separated(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: laterBirthList.length,
                          itemBuilder: (context, i) {
                            return GestureDetector(
                              onTap: () {
                                if (_selectionMode) {
                                  setState(() {
                                    if (_selectedIndexList.contains(i)) {
                                      _selectedIndexList.remove(i);
                                    } else {
                                      _selectedIndexList.add(i);
                                    }
                                  });
                                }
                              },
                              onLongPress: () {
                                if (!_selectionMode) {
                                  setState(() {
                                    _changeSelection(enable: true, index: i);
                                  });
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectionMode &&
                                          _selectedIndexList.contains(i)
                                      ? Colors.lightBlueAccent
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 70,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: <Widget>[
                                          Text(
                                            laterBirthList[i].days.toString(),
                                            style: kBoldTextStyle.copyWith(
                                                fontSize: 25.0),
                                          ),
                                          Text(
                                            'days',
                                            style: kBody1TextStyle.copyWith(
                                                fontSize: 12.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          laterBirthList[i].name,
                                          style: kBody1TextStyle,
                                        ),
                                        SizedBox(
                                          height: 3.0,
                                        ),
                                        Text(
                                          'BirthDate: ' +
                                              formatter
                                                  .format(laterBirthList[i]
                                                      .dateofbirth)
                                                  .toString(),
                                          style: kSubtitleTextStyle,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, i) {
                            return SizedBox(
                              height: 15.0,
                            );
                          }),
                    ],
                  ),
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
