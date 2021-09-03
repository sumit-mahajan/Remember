import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:remember/widgets/app_scaffold.dart';
import 'package:remember/widgets/custom_button.dart';

import 'package:remember/utilities/constants.dart';
import 'package:remember/models/todo_model.dart';
import 'package:remember/providers/todo_provider.dart';

class ToDoTab extends StatefulWidget {
  @override
  _ToDoTabState createState() => _ToDoTabState();
}

class _ToDoTabState extends State<ToDoTab> {
  final _namecontroller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void _addTask() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      Provider.of<TodoProvider>(context, listen: false).addTask(_namecontroller.text);
      _namecontroller.clear();
    }
  }

  void _onDismiss(BuildContext context, DismissDirection dir, TodoModel currentitem, int index) {
    TodoProvider todoProvider = Provider.of<TodoProvider>(context, listen: false);
    if (dir == DismissDirection.endToStart) {
      // Mark as done
      todoProvider.markAsDone(currentitem);
    } else if (dir == DismissDirection.startToEnd) {
      // Delete todo
      todoProvider.deleteTodo(currentitem, index);
    }
    // Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 800),
        content: Text(dir == DismissDirection.startToEnd ? 'Task Deleted' : 'Marked Complete'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            if (dir == DismissDirection.endToStart) {
              // Mark as Undone
              todoProvider.markAsUnDone(currentitem);
            } else {
              // Restore Todo
              todoProvider.restoreTodo(currentitem, index);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, tProvider, child) {
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
                        tProvider.quoteText,
                        textAlign: TextAlign.center,
                        style: kBody1TextStyle,
                      ),

                      //Quote Author
                      Padding(
                        padding: EdgeInsets.only(top: 10.h),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            tProvider.quoteAuthor == '' ? '- ' + 'Anonymous' : '- ' + tProvider.quoteAuthor,
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
                padding: EdgeInsets.only(top: 15.h),
                child: Container(
                  height: 1.h,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              SizedBox(height: 10.h),
              // Circular percent indicator
              CircularPercentIndicator(
                radius: 115.r,
                lineWidth: 10.w,
                percent: tProvider.taskList.length > 0 ? tProvider.countDone / tProvider.taskList.length : 0,
                center: Text(
                  tProvider.countDone.toString() + ' / ' + tProvider.taskList.length.toString() + ' Done',
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
                      offset: Offset(0, 1.0),
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
                              tProvider.toggleTextField();
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
                                tProvider.visibleTextField ? Icons.remove : Icons.add,
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

                    // Empty task list
                    tProvider.taskList.length == 0
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.r),
                              child: Text(
                                'Please assign some tasks',
                                style: kBody1TextStyle,
                              ),
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.symmetric(vertical: 15.h),
                            child: ListView.separated(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: tProvider.taskList.length,
                              itemBuilder: (context, i) {
                                final TodoModel currentitem = tProvider.taskList[i];
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
                                                Icon(
                                                    tProvider.taskList[i].done!
                                                        ? Icons.check_box
                                                        : Icons.check_box_outline_blank,
                                                    color:
                                                        tProvider.taskList[i].done! ? Colors.green : Colors.blueGrey),
                                              ],
                                            ),
                                            SizedBox(width: 10.w),

                                            // Task name
                                            Flexible(
                                              child: Text(
                                                currentitem.name!,
                                                style: kBody1TextStyle.copyWith(
                                                  decoration:
                                                      tProvider.taskList[i].done! ? TextDecoration.lineThrough : null,
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
                          ),

                    // Add task
                    tProvider.visibleTextField
                        ? Padding(
                            padding: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 10.h),
                            child: Form(
                              key: formKey,
                              child: Row(
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
      },
    );
  }
}
