import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remember/models/birthday_model.dart';
import 'package:remember/screens/tabs_screen.dart';
import 'package:remember/services/notifications_service.dart';
import 'package:remember/services/database_service.dart';
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

  _addBirthday() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (birthdate != null) {
        dbmanager.insertBirthday(BirthdayModel(name: name, dateString: birthdate.toIso8601String())).then((id) async {
          await notificationPlugin.scheduleNotification(id, birthdate, name, true);
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TabsScreen(
              preSelected: 2,
            ),
          ),
        );
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
              borderRadius:
                  new BorderRadius.only(topLeft: const Radius.circular(20.0), topRight: const Radius.circular(20.0))),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
            top: 20.0,
            left: 20.0,
            right: 20.0,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  autofocus: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Name of Person',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onSaved: (value) {
                    name = value;
                  },
                  validator: (input) {
                    if (input == '' || input.toLowerCase() == input.toUpperCase()) {
                      return 'Name can\'t be empty';
                    } else if (input.length > 25) {
                      return 'Name should be within 25 characters';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        birthdate == null ? 'Please select Birthdate' : formatter.format(birthdate),
                        style: TextStyle(color: Colors.black),
                      ),
                      CustomButton(
                        text: 'Choose Date',
                        onClick: () {
                          openDatePicker(context);
                        },
                      ),
                    ],
                  ),
                ),
                CustomButton(
                  text: 'Add',
                  onClick: _addBirthday,
                ),
                //SizedBox(height: 10.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
