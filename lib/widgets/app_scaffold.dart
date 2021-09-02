import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:remember/utilities/constants.dart';

class AppScaffold extends StatelessWidget {
  final Widget? leftButton;
  final String? title;
  final Widget? rightButton;
  final Widget? childWidget;

  const AppScaffold({this.leftButton, this.title, this.rightButton, this.childWidget});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(15.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Left Button
              leftButton ?? Container(),

              // Title
              Text(
                title!,
                style: kTitleTextStyle,
              ),

              // Right Button
              rightButton ?? Container()
            ],
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height - 157.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(title == 'ToDo' ? 15.r : 0),
              child: childWidget ?? Container(),
            ),
          ),
        ),
      ],
    );
  }
}
