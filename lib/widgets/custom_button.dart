import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:remember/utilities/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function onClick;

  const CustomButton({
    Key key,
    @required this.text,
    @required this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        height: 45,
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: kButtonFillColor,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            text,
            style: kBody1TextStyle.copyWith(
                color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
