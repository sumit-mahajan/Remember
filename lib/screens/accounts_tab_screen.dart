import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:remember/providers/auth_provider.dart';

import 'package:remember/widgets/app_scaffold.dart';

class AccountsTab extends StatefulWidget {
  @override
  _AccountsTabState createState() => _AccountsTabState();
}

class _AccountsTabState extends State<AccountsTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, aProvider, child) {
      if (aProvider.firebaseService.auth.currentUser != null) {
        //TODO: Show Profile
        return AppScaffold(
          title: 'Account',
          childWidget: Column(
            children: [
              Text('Signed In'),
              TextButton(
                child: Text(
                  'Logout',
                  style: TextStyle(),
                ),
                onPressed: () {
                  aProvider.logout();
                },
              ),
            ],
          ),
        );
      }
      if (aProvider.state == AuthState.loading) {
        return AppScaffold(
          title: 'Account',
          childWidget: Column(
            children: [
              SizedBox(height: 50, width: 50, child: CircularProgressIndicator()),
            ],
          ),
        );
      }
      return AppScaffold(
        title: 'Account',
        childWidget: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: ElevatedButton.icon(
                icon: FaIcon(
                  FontAwesomeIcons.google,
                  color: Colors.red,
                ),
                label: Text('Sign In with Google'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue.shade50,
                  onPrimary: Colors.lightBlue,
                  minimumSize: Size(
                    double.infinity,
                    50,
                  ),
                ),
                onPressed: () {
                  aProvider.login();
                },
              ),
            ),
            SizedBox(height: 50),
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
    });
  }
}
