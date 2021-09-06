import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:remember/models/birthday_model.dart';
import 'package:remember/providers/birthday_provider.dart';
import 'package:remember/screens/tabs_screen.dart';
import 'package:remember/utilities/constants.dart';
import 'package:remember/widgets/custom_button.dart';

class AddbirthdaySheet extends StatefulWidget {
  static const id = 'add_birthday';

  @override
  _AddbirthdaySheetState createState() => _AddbirthdaySheetState();
}

class _AddbirthdaySheetState extends State<AddbirthdaySheet> {
  final formKey = GlobalKey<FormState>();
  var formatter = new DateFormat('dd-MM-yyyy');
  FocusNode _nameNode = FocusNode();
  String? name;
  DateTime birthdate = DateTime.now();
  bool isLoading = false;

  openDatePicker(BuildContext context) async {
    birthdate = await showDatePicker(
          context: context,
          initialDate: birthdate,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (BuildContext context, Widget? child) {
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
              child: child!,
            );
          },
        ) ??
        DateTime.now();
    setState(() {});
  }

  _addBirthday() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      int id = await Provider.of<BirthdayProvider>(context, listen: false)
          .addBirthday(BirthdayModel(name: name!, dateofbirth: birthdate, dateString: birthdate.toIso8601String()));
      Provider.of<BirthdayProvider>(context, listen: false).addBirthdayToFirebase(
          BirthdayModel(id: id, name: name!, dateofbirth: birthdate, dateString: birthdate.toIso8601String()));
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.transparent,
        child: Container(
          decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r))),
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0.h),
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
                    if (input == '' || input!.toLowerCase() == input.toUpperCase()) {
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
                        formatter.format(birthdate),
                        style: kBody1TextStyle.copyWith(color: Colors.black),
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
