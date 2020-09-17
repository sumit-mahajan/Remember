import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'birthday_page.dart';

import '../Utilities/store_birthday.dart';
import '../Utilities/db_manager.dart';
import '../Utilities/NotificationsPlugin.dart';

class Addbirthday extends StatefulWidget {
  static const id = 'add_birthday';

  @override
  _AddbirthdayState createState() => _AddbirthdayState();
}

class _AddbirthdayState extends State<Addbirthday> {
  final formKey = GlobalKey<FormState>();
  String name;
  DateTime birthdate;
  var formatter = new DateFormat('yyyy-MM-dd');
  DbManager dbmanager = new DbManager();

  @override
  void initState() {
    // TODO: implement initState
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
                  topLeft: const Radius.circular(10.0),
                  topRight: const Radius.circular(10.0))),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Name of Person',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
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
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Icon(Icons.calendar_today),
                      Text(
                        birthdate == null
                            ? 'No Date selected'
                            : formatter.format(birthdate),
                        style: TextStyle(
                            color:
                                birthdate == null ? Colors.red : Colors.black),
                      ),
                      RaisedButton(
                          color: Color(0xFF5F35FE),
                          shape: new RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                          child: Text(
                            'Pick a Date',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            showDatePicker(
                                context: context,
                                initialDate: birthdate == null
                                    ? DateTime.now()
                                    : birthdate,
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                builder: (BuildContext context, Widget child) {
                                  const MaterialColor buttonTextColor =
                                      const MaterialColor(
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
                          }),
                    ],
                  ),
                ),
                RaisedButton(
                  color: Color(0xFF5F35FE),
                  shape: new RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: Text(
                    'ADD',
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                  onPressed: () {
                    if (formKey.currentState.validate()) {
                      formKey.currentState.save();
                      if (birthdate != null) {
                        dbmanager
                            .insertBirthday(StoreBirthday(
                                name: name,
                                dateString: birthdate.toIso8601String()))
                            .then((id) async {
                          await notificationPlugin.scheduleNotification(
                              id, birthdate, name, true);
                        });

                        Navigator.pushNamed(context, Birthday.id);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  onNotificationClick(String payload) {
    print(payload);
  }
}
