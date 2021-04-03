import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:remember/models/birthday_model.dart';
import 'package:remember/screens/tabs_screen.dart';
import 'package:remember/services/notifications_service.dart';
import 'package:remember/services/database_service.dart';
import 'package:remember/utilities/constants.dart';
import 'package:remember/widgets/custom_button.dart';

class AddbirthdaySheet extends StatefulWidget {
  static const id = 'add_birthday';

  @override
  _AddbirthdaySheetState createState() => _AddbirthdaySheetState();
}

class _AddbirthdaySheetState extends State<AddbirthdaySheet> {
  final formKey = GlobalKey<FormState>();
  String name;
  DateTime birthdate;
  var formatter = new DateFormat('yyyy-MM-dd');
  DbManager dbmanager = new DbManager();
  bool f = false;
  FocusNode _nameNode = FocusNode();
  bool isLoading = false;

  openDatePicker(BuildContext context) {
    showDatePicker(
        context: context,
        initialDate: birthdate == null ? DateTime.now() : birthdate,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        builder: (BuildContext context, Widget child) {
          const MaterialColor buttonTextColor = const MaterialColor(
            0xFF4A5BF6,
            const <int, Color>{
              50: const Color(0xFF4A5BF6),
              100: const Color(0xFF4A5BF6),
              200: const Color(0xFF4A5BF6),
              300: const Color(0xFF4A5BF6),
              400: const Color(0xFF4A5BF6),
              500: const Color(0xFF4A5BF6),
              600: const Color(0xFF4A5BF6),
              700: const Color(0xFF4A5BF6),
              800: const Color(0xFF4A5BF6),
              900: const Color(0xFF4A5BF6),
            },
          );
          return Theme(
            data: ThemeData(
                primarySwatch: buttonTextColor,
                primaryColor: const Color(0xFF4A5BF6),
                accentColor: const Color(0xFF4A5BF6)),
            child: child,
          );
        }).then((date) {
      setState(() {
        birthdate = date;
      });
    });
  }

  _addBirthday() async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (birthdate != null) {
        setState(() {
          isLoading = true;
        });
        final id = await dbmanager.insertBirthday(
            BirthdayModel(name: name, dateString: birthdate.toIso8601String()));

        DateTime nextBirthday;

        if (DateTime(DateTime.now().year, birthdate.month, birthdate.day)
            .isAfter(DateTime.now())) {
          nextBirthday =
              DateTime(DateTime.now().year, birthdate.month, birthdate.day);

          await notificationPlugin.scheduleNotification(
              id * 100, nextBirthday, name, true);
        }

        for (int i = 1; i < 50; i++) {
          nextBirthday =
              DateTime(DateTime.now().year + i, birthdate.month, birthdate.day);
          notificationPlugin.scheduleNotification(
              id * 100 + i, nextBirthday, name, true);
        }
        setState(() {
          isLoading = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TabsScreen(
              preSelected: 2,
            ),
          ),
        );
      } else {
        f = true;
        setState(() {});
      }
    }
  }

  onNotificationClick(String payload) {
    print(payload);
  }

  @override
  void initState() {
    super.initState();
    notificationPlugin.setOnNotificationClick(onNotificationClick);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.transparent,
        child: Container(
          decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r))),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
            top: 20.h,
            left: 20.w,
            right: 20.w,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  autofocus: true,
                  focusNode: _nameNode,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 0.h),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Name of Person',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  onSaved: (value) {
                    name = value;
                  },
                  validator: (input) {
                    if (input == '' ||
                        input.toLowerCase() == input.toUpperCase()) {
                      return 'Name can\'t be empty';
                    } else if (input.length > 25) {
                      return 'Name should be within 25 characters';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        birthdate == null
                            ? 'Please select Birthdate'
                            : formatter.format(birthdate),
                        style: kBody1TextStyle.copyWith(
                            color: birthdate == null && f
                                ? Colors.red
                                : Colors.black),
                      ),
                      CustomButton(
                        text: 'Choose Date',
                        onClick: () {
                          _nameNode.unfocus();
                          openDatePicker(context);
                        },
                      ),
                    ],
                  ),
                ),
                CustomButton(
                  text: isLoading ? 'Loading...' : 'Add',
                  onClick: _addBirthday,
                ),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
