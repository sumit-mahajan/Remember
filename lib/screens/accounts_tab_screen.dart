import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:remember/providers/auth_provider.dart';
import 'package:remember/utilities/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:remember/widgets/app_scaffold.dart';
import 'package:remember/widgets/custom_button.dart';

class AccountsTab extends StatefulWidget {
  @override
  _AccountsTabState createState() => _AccountsTabState();
}

class _AccountsTabState extends State<AccountsTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, aProvider, child) {
        if (aProvider.firebaseService.auth.currentUser != null) {
          User _user = aProvider.firebaseService.auth.currentUser!;
          // Image.network(_user.photoURL!)
          return AppScaffold(
            title: 'Account',
            childWidget: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 5,
                ),
                CircleAvatar(
                  radius: 50.r,
                  backgroundColor: Colors.transparent,
                  child: Image.asset('assets/profile_icon.png'),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  _user.displayName!,
                  style: kBody2TextStyle,
                ),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  _user.email!,
                  style: kBody1TextStyle,
                ),
                SizedBox(
                  height: 20.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.r),
                  child: CustomButton(
                    text: 'Logout',
                    onClick: () {
                      aProvider.logout();
                    },
                  ),
                ),
                // TextButton(
                //   child: Text(
                //     'Logout',
                //     style: TextStyle(),
                //   ),
                //   onPressed: () {
                //     aProvider.logout();
                //   },
                // ),
              ],
            ),
          );
        }
        if (aProvider.state == AuthState.loading) {
          return AppScaffold(
            title: 'Account',
            childWidget: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                ),
                SizedBox(height: 50.h, width: 50.w, child: CircularProgressIndicator()),
              ],
            ),
          );
        }
        return AppScaffold(
          title: 'Account',
          childWidget: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 3,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.r),
                child: ElevatedButton.icon(
                  icon: FaIcon(
                    FontAwesomeIcons.google,
                    color: Colors.red,
                  ),
                  label: Text(
                    'Sign In with Google',
                    style: kBody1TextStyle.copyWith(fontWeight: FontWeight.w300),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white70,
                    onPrimary: Colors.black,
                    minimumSize: Size(
                      double.infinity,
                      50.h,
                    ),
                  ),
                  onPressed: () {
                    aProvider.login();
                  },
                ),
              ),
              SizedBox(height: 20.h),
              aProvider.state == AuthState.error
                  ? Text(
                      'Something went wrong',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    )
                  : Container(),
            ],
          ),
        );
      },
    );
  }
}
