import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:remember/providers/auth_provider.dart';

import 'package:remember/utilities/constants.dart';
import 'package:remember/widgets/app_scaffold.dart';
import 'package:remember/widgets/add_birthday_sheet.dart';
import 'package:remember/providers/birthday_provider.dart';

class BirthdayTab extends StatefulWidget {
  @override
  _BirthdayTabState createState() => _BirthdayTabState();
}

class _BirthdayTabState extends State<BirthdayTab> {
  var formatter = new DateFormat('dd-MM-yyyy');

  showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete these Birthdays?"),
          actions: [
            TextButton(
              child: Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "DELETE",
                style: kBody1TextStyle.copyWith(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<BirthdayProvider>(context, listen: false).deleteBirthdays();
                Provider.of<BirthdayProvider>(context, listen: false).deleteBirthdaysFromFirebase();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BirthdayProvider>(
      builder: (context, bProvider, child) {
        return AppScaffold(
          leftButton: bProvider.selectionMode
              ? IconButton(
                  icon: Icon(Icons.cancel),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      bProvider.changeSelectionMode(false, -1);
                    });
                  },
                )
              : SizedBox(
                  width: 30.w,
                ),
          title: 'Birthdays',
          rightButton: bProvider.selectionMode
              ? IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.white,
                  onPressed: () {
                    if (bProvider.selectedIndexList.length > 0) showAlertDialog(context);
                  },
                )
              : GestureDetector(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 30.r,
                  ),
                  onTap: () {
                    if (Provider.of<AuthProvider>(context, listen: false).firebaseService.auth.currentUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Log in to add birthdays')));
                    } else {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => AddbirthdaySheet(),
                      );
                    }
                  },
                ),
          childWidget: bProvider.birthList.length == 0
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 310.h),
                    child: Text(
                      'No Birthdays Found',
                      style: kBody1TextStyle,
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: <Widget>[
                      bProvider.todayList.length != 0
                          ? Padding(
                              padding: EdgeInsets.only(top: 15.h),
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
                        itemCount: bProvider.todayList.length,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: EdgeInsets.only(top: 15.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 75.w,
                                  child: Center(
                                    child: ClipOval(
                                      child: Material(
                                        color: kButtonFillColor, // button color
                                        child: InkWell(
                                          splashColor: Colors.red, // inkwell color
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
                                SizedBox(width: 10.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bProvider.todayList[i].name,
                                      style: kBody1TextStyle,
                                    ),
                                    Text(
                                      'Turned ' +
                                          (DateTime.now().year - bProvider.todayList[i].dateofbirth.year).toString() +
                                          ' years old',
                                      style: kSubtitleTextStyle,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                      bProvider.laterBirthList.length > 0
                          ? Padding(
                              padding: EdgeInsets.symmetric(vertical: 15.h),
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
                        itemCount: bProvider.laterBirthList.length,
                        itemBuilder: (context, i) {
                          return GestureDetector(
                            onTap: () {
                              if (bProvider.selectionMode) {
                                setState(() {
                                  if (bProvider.selectedIndexList.contains(i)) {
                                    bProvider.selectedIndexList.remove(i);
                                  } else {
                                    bProvider.selectedIndexList.add(i);
                                  }
                                });
                              }
                            },
                            onLongPress: () {
                              if (!bProvider.selectionMode) {
                                setState(() {
                                  bProvider.changeSelectionMode(true, i);
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: bProvider.selectionMode && bProvider.selectedIndexList.contains(i)
                                    ? Colors.lightBlueAccent
                                    : Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 75.w,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: <Widget>[
                                        Text(
                                          bProvider.laterBirthList[i].days.toString(),
                                          style: kBoldTextStyle.copyWith(fontSize: 28.sp),
                                        ),
                                        Text(
                                          'days',
                                          style: kBody1TextStyle.copyWith(fontSize: 14.sp),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bProvider.laterBirthList[i].name,
                                        style: kBody1TextStyle,
                                      ),
                                      SizedBox(
                                        height: 5.h,
                                      ),
                                      Text(
                                        'Birthdate: ' +
                                            formatter.format(bProvider.laterBirthList[i].dateofbirth).toString(),
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
                            height: 15.h,
                          );
                        },
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
