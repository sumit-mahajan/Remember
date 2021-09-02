import 'package:flutter/material.dart';
import 'dart:math';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:remember/widgets/app_scaffold.dart';
import 'package:remember/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:remember/utilities/constants.dart';
import 'package:remember/services/database_service.dart';
import 'package:remember/models/todo_model.dart';
import 'package:remember/utilities/quotes.dart';

var random = new Random();
String? quoteText;
String? author;

class ToDoTab extends StatefulWidget {
  @override
  _ToDoTabState createState() => _ToDoTabState();
}

class _ToDoTabState extends State<ToDoTab> {
  final _namecontroller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  DbManager dbmanager = new DbManager();
  bool visibleTextField = false;
  String newtask = '';
  List<TodoModel>? itemList = [];
  int countDone = 0;
  late TodoModel deletedItem;
  int totaltasks = 0;

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

  int getDoneCount(List<TodoModel>? itemList) {
    countDone = 0;
    if (itemList != null) {
      for (int i = 0; i < itemList.length; i++) {
        itemList[i].done! ? countDone++ : countDone = countDone;
      }
    }
    return countDone;
  }

  Future getItemList() async {
    List<TodoModel> tp = await dbmanager.getToDoList();
    setState(() {
      totaltasks = tp.length;
      countDone = getDoneCount(tp);
    });
  }

  void _onDismiss(BuildContext context, DismissDirection dir, TodoModel currentitem, int i) {
    setState(
      () {
        if (dir == DismissDirection.endToStart) {
          // Mark as done
          currentitem.done = true;
          dbmanager.updateToDo(currentitem);
          countDone = getDoneCount(itemList);
        } else if (dir == DismissDirection.startToEnd) {
          // Delete todo
          deletedItem = currentitem;
          itemList!.removeAt(i);
          dbmanager.deleteToDo(currentitem.id);
          countDone = getDoneCount(itemList);
          totaltasks--;
          if (totaltasks == 0) {
            visibleTextField = true;
          }
        }
      },
    );
    // Snackbar
    Scaffold.of(context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 800),
        content: Text(dir == DismissDirection.startToEnd ? 'Task Deleted' : 'Marked Complete'),
        action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              setState(
                () {
                  if (dir == DismissDirection.startToEnd) {
                    dbmanager.insertToDo(deletedItem);
                    totaltasks++;
                    countDone = deletedItem.done == true ? countDone + 1 : countDone;
                  } else {
                    currentitem.done = false;
                    dbmanager.updateToDo(currentitem);
                    countDone--;
                  }
                },
              );
            }),
      ),
    );
  }

  void _addTask() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      TodoModel newItem = TodoModel(name: _namecontroller.text, done: false);
      dbmanager.insertToDo(newItem).then((id) => {
            _namecontroller.clear(),
          });
      setState(() {
        totaltasks++;
        visibleTextField = false;
      });
    } else {}
  }

  @override
  void initState() {
    super.initState();
    getItemList();
    int rn = random.nextInt(quoteList.length);
    quoteText = quoteList[rn]['quoteText'];
    author = quoteList[rn]['quoteAuthor'];
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ToDo',
      childWidget: Column(
        children: <Widget>[
          // Quote Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.r),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10.r,
                  offset: Offset(0.0, 2.0),
                  color: Colors.black.withOpacity(0.25),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(15.r),
              child: Column(
                children: <Widget>[
                  // Quote Text
                  Text(
                    quoteText!,
                    textAlign: TextAlign.center,
                    style: kBody1TextStyle,
                  ),

                  //Quote Author
                  Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        author == '' ? '- ' + 'Anonymous' : '- ' + author!,
                        textAlign: TextAlign.right,
                        style: kBody1TextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Horizontal Line
          Padding(
            padding: EdgeInsets.only(top: 15.h, bottom: 5.h),
            child: Container(
              height: 1.h,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          SizedBox(height: 5.h),
          // Circular percent indicator
          CircularPercentIndicator(
            radius: 115.r,
            lineWidth: 10.w,
            percent: totaltasks > 0
                ? countDone == null
                    ? 0
                    : countDone / totaltasks
                : 0.0,
            center: Text(
              countDone.toString() + ' / ' + totaltasks.toString() + ' Done',
              style: kBody1TextStyle.copyWith(fontSize: 16.sp),
            ),
            progressColor: kButtonFillColor,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
          ),
          // Custom padding
          SizedBox(height: 10.h),

          // ToDo list block
          Container(
            decoration: BoxDecoration(
              color: kNavBarColor,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10.r,
                  offset: Offset(0, 2.0),
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Row for Title
                Padding(
                  padding: EdgeInsets.all(10.r),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Title
                      Text('ToDo List', style: kBoldTextStyle),

                      // New item button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            visibleTextField ? visibleTextField = false : visibleTextField = true;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(5.r),
                          decoration: BoxDecoration(
                            color: kButtonFillColor,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10.r,
                                offset: Offset(0.0, 2.0),
                                color: Colors.black.withOpacity(0.25),
                              ),
                            ],
                          ),
                          child: Icon(
                            visibleTextField ? Icons.remove : Icons.add,
                            size: 40.r,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Horizontal line
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Container(
                    height: 1.h,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                // Task Listview
                FutureBuilder(
                  future: dbmanager.getToDoList(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      itemList = snapshot.data;
                      countDone = getDoneCount(itemList);
                      totaltasks = itemList!.length;

                      // Empty task list
                      if (itemList!.length == 0) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(10.r),
                            child: Text(
                              'Please assign some tasks',
                              style: kBody1TextStyle,
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        child: ListView.separated(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: itemList == null ? 0 : itemList!.length,
                          itemBuilder: (context, i) {
                            final TodoModel currentitem = itemList![i];
                            // Dismissible Widget
                            return Dismissible(
                              key: UniqueKey(),
                              onDismissed: (dir) {
                                _onDismiss(context, dir, currentitem, i);
                              },
                              // On swiping left to right (delete)
                              background: Container(
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                                color: Colors.red,
                                alignment: Alignment.centerLeft,
                              ),
                              // On swiping right to left (mark as done)
                              secondaryBackground: Container(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                                color: Colors.green,
                                alignment: Alignment.centerRight,
                              ),
                              // Task List Tile
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.r),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 10.r,
                                        offset: Offset(0.0, 2.0),
                                        color: Colors.black.withOpacity(0.25),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(10.r),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Icon(Icons.arrow_left),
                                            Icon(itemList![i].done! ? Icons.check_box : Icons.check_box_outline_blank,
                                                color: itemList![i].done! ? Colors.green : Colors.blueGrey),
                                          ],
                                        ),
                                        SizedBox(width: 10.w),

                                        // Task name
                                        Flexible(
                                          child: Text(
                                            currentitem.name!,
                                            style: kBody1TextStyle.copyWith(
                                              decoration: itemList![i].done! ? TextDecoration.lineThrough : null,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        SizedBox(width: 10.w),
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
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => SizedBox(
                            height: 15.h,
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                // Add task
                visibleTextField
                    ? Padding(
                        padding: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 10.h),
                        child: Form(
                          key: formKey,
                          child: Row(
                            // mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              // Add task Textfield
                              Flexible(
                                child: TextFormField(
                                  controller: _namecontroller,
                                  validator: (value) {
                                    if (value == '' || value!.toLowerCase() == value.toUpperCase()) {
                                      return 'Please enter a task';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.w),
                                    hintStyle: kBody1TextStyle,
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: 'Enter task',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
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
                              SizedBox(width: 10.w),
                              // Add task Button
                              CustomButton(
                                text: 'Add',
                                onClick: _addTask,
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
    );
  }
}
