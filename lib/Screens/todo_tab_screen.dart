import 'package:flutter/material.dart';
import 'dart:math';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:remember/services/notifications_service.dart';
import 'package:remember/utilities/constants.dart';
import 'package:remember/services/database_service.dart';
import 'package:remember/models/todo_model.dart';
import 'package:remember/utilities/quotes.dart';
import 'package:remember/widgets/reusable_card.dart';

import 'package:remember/screens/birthdays_tab_screen.dart';
import 'package:remember/screens/events_tab_screen.dart';
import 'package:remember/screens/notes_tab_screen.dart';

var random = new Random();
String quoteText;
String author;

class ToDoTab extends StatefulWidget {
  AnimationController progressController;
  Animation animation;
  static const id = 'to_do_page';

  @override
  _ToDoTabState createState() => _ToDoTabState();
}

class _ToDoTabState extends State<ToDoTab> {
  bool visibleTextField = false;
  String newtask = '';
  DbManager dbmanager = new DbManager();
  final _itemcontroller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<TodoModel> itemList = [];
  int countDone = 0;
  TodoModel deletedItem;
  int totaltasks = 0;

  Future getItemList() async {
    List<TodoModel> tp = await dbmanager.getToDoList();
    setState(() {
      totaltasks = tp.length;
      countDone = getDoneCount(tp);
    });
  }

  Future<bool> isFirstTime() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var isFirstTime = pref.getBool('first_time');
    if (isFirstTime != null && !isFirstTime) {
      return false;
    } else {
      pref.setBool('first_time', false);
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
    getItemList();
    int rn = random.nextInt(quoteList.length);
    quoteText = quoteList[rn]['quoteText'];
    author = quoteList[rn]['quoteAuthor'];
    isFirstTime().then((isFirstTime) {
      isFirstTime
          ? notificationPlugin.showDailyAtTime()
          : print("Not first time");
    });
//    notificationPlugin
//        .setListenerForLowerVersions(onNotificationInLowerVersions);
    notificationPlugin.setOnNotificationClick(onNotificationClick);
  }

  int getDoneCount(List<TodoModel> itemList) {
    countDone = 0;
    if (itemList != null) {
      for (int i = 0; i < itemList.length; i++) {
        itemList[i].done ? countDone++ : countDone = countDone;
      }
    }
    return countDone;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Color(0xFF5F35FE),
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.white,
          buttonBackgroundColor: Color(0xFF5F35FE),
          color: Color(0xFFeff2f9),
          index: 0,
          height: 50.0,
          items: <Widget>[
            Icon(
              Icons.check_circle_outline,
              size: 30,
              color: Colors.white,
            ),
            Icon(Icons.event_note, size: 30),
            Icon(Icons.card_giftcard, size: 30),
            Icon(Icons.calendar_today, size: 30),
          ],
          onTap: (index) {
            switch (index) {
              case 1:
                Navigator.pushNamed(context, NotesTab.id);
                break;
              case 2:
                Navigator.pushNamed(context, BirthdayTab.id);
                break;
              case 3:
                Navigator.pushNamed(context, EventsTab.id);
                break;
            }
          },
          animationDuration: Duration(
            milliseconds: 200,
          ),
          animationCurve: Curves.bounceInOut,
        ),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Center(
                child: Text(
                  'ToDo',
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
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 10.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: <Widget>[
                              Text(
                                quoteText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontStyle: FontStyle.italic),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    author == ''
                                        ? '- ' + 'Anonymous'
                                        : '- ' + author,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        height: 1.0,
                        color: Color(0xFF00B4EE),
                      ),
                    ),
                    CircularPercentIndicator(
                      radius: 100.0,
                      lineWidth: 13.0,
                      percent: totaltasks > 0
                          ? countDone == null
                              ? 0
                              : countDone / totaltasks
                          : 0.0,
                      center: Text(countDone.toString() +
                          ' / ' +
                          totaltasks.toString() +
                          ' Done'),
                      progressColor: Color(0xFF5B84FF),
                      circularStrokeCap: CircularStrokeCap.round,
                      animation: true,
                    ),
                    ReusableCard(
                      colour: Color(0xFFeff2f9),
                      cardChild: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'ToDo List',
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                RawMaterialButton(
                                  onPressed: () {
                                    setState(() {
                                      visibleTextField
                                          ? visibleTextField = false
                                          : visibleTextField = true;
                                    });
//                                    await notificationPlugin.showNotification();
//                                    var c = await notificationPlugin
//                                        .getPendingNotificationCount();
//                                    print(c);
                                  },
                                  elevation: 2.0,
                                  fillColor: Color(0xFF5B84FF),
                                  child: Icon(
                                    visibleTextField ? Icons.remove : Icons.add,
                                    size: 30.0,
                                    color: Colors.white,
                                  ),
                                  padding: EdgeInsets.all(10.0),
                                  shape: CircleBorder(),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Container(
                              height: 1.0,
                              color: Color(0xFF00B4EE),
                            ),
                          ),
                          FutureBuilder(
                            future: dbmanager.getToDoList(),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                itemList = snapshot.data;
                                countDone = getDoneCount(itemList);
                                totaltasks = itemList.length;
                                if (itemList.length == 0) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        'Please assign some tasks',
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount:
                                      itemList == null ? 0 : itemList.length,
                                  itemBuilder: (context, i) {
                                    final TodoModel currentitem = itemList[i];
                                    return Dismissible(
                                      key: Key(currentitem.name),
                                      confirmDismiss: (dir) {
                                        setState(
                                          () {
                                            if (dir ==
                                                DismissDirection.endToStart) {
                                              currentitem.done = true;
                                              dbmanager.updateToDo(currentitem);
                                              countDone =
                                                  getDoneCount(itemList);
                                              return false;
                                            } else if (dir ==
                                                DismissDirection.startToEnd) {
                                              deletedItem = currentitem;
                                              itemList.removeAt(i);
                                              dbmanager
                                                  .deleteToDo(currentitem.id);
                                              countDone =
                                                  getDoneCount(itemList);
                                              totaltasks--;
                                              if (totaltasks == 0) {
                                                visibleTextField = true;
                                              }
                                              return true;
                                            }
                                          },
                                        );
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            duration:
                                                Duration(milliseconds: 800),
                                            content: Text(dir ==
                                                    DismissDirection.startToEnd
                                                ? 'Task Deleted'
                                                : 'Marked Complete'),
                                            action: SnackBarAction(
                                                label: 'UNDO',
                                                onPressed: () {
                                                  setState(
                                                    () {
                                                      if (dir ==
                                                          DismissDirection
                                                              .startToEnd) {
                                                        dbmanager.insertToDo(
                                                            deletedItem);
                                                        totaltasks++;
                                                        countDone =
                                                            deletedItem.done ==
                                                                    true
                                                                ? countDone + 1
                                                                : countDone;
                                                      } else {
                                                        currentitem.done =
                                                            false;
                                                        dbmanager.updateToDo(
                                                            currentitem);
                                                        countDone--;
                                                      }
                                                    },
                                                  );
                                                }),
                                          ),
                                        );
                                        return null;
                                      },
                                      background: Container(
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                        color: Colors.red,
                                        alignment: Alignment.centerLeft,
                                      ),
                                      secondaryBackground: Container(
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        ),
                                        color: Colors.green,
                                        alignment: Alignment.centerRight,
                                      ),
                                      child: ReusableCard(
                                        colour: Color(0xFFFFFFFF),
                                        cardChild: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Icon(Icons.arrow_left),
                                                  Icon(
                                                      itemList[i].done
                                                          ? Icons.check_box
                                                          : Icons
                                                              .check_box_outline_blank,
                                                      color: itemList[i].done
                                                          ? Colors.green
                                                          : Colors.blueGrey),
                                                ],
                                              ),
                                              Text(
                                                currentitem.name,
                                                style: TextStyle(
                                                  fontSize: 18.0,
                                                  decoration: itemList[i].done
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : null,
                                                ),
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.red,
                                                  ),
                                                  Icon(Icons.arrow_right),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                          visibleTextField
                              ? Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Form(
                                    key: formKey,
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: TextFormField(
                                            controller: _itemcontroller,
                                            validator: (value) {
                                              if (value == '' ||
                                                  value.toLowerCase() ==
                                                      value.toUpperCase()) {
                                                return 'Please provide a task';
                                              } else if (value.length > 15) {
                                                return 'Task should not exceed 15 characters';
                                              } else {
                                                return null;
                                              }
                                            },
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.only(left: 5.0),
                                              icon: Icon(
                                                Icons.event_note,
                                                color: Colors.green,
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              hintText: 'Enter task',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                            ),
                                            autofocus: true,
                                            onChanged: (value) {
                                              setState(() {
                                                newtask = value;
                                              });
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: SizedBox(
                                            width: 60.0,
                                            child: RaisedButton(
                                              child: Text(
                                                'ADD',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              color: Color(0xFF5B84FF),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  side: BorderSide(
                                                      color: Colors.blue)),
                                              onPressed: () {
                                                _addTask(context);
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }

  void _addTask(BuildContext context) {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      TodoModel newItem = TodoModel(name: _itemcontroller.text, done: false);
      dbmanager.insertToDo(newItem).then((id) => {
            _itemcontroller.clear(),
          });
      setState(() {
        totaltasks++;
        visibleTextField = false;
      });
    } else {}
  }

  onNotificationClick(String payload) {
    print(payload);
  }
}
