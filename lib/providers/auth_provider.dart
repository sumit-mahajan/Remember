import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:remember/models/birthday_model.dart';
import 'package:remember/providers/birthday_provider.dart';
import 'package:remember/services/firebase_service.dart';

enum AuthState { empty, loading, success, error }

class AuthProvider with ChangeNotifier {
  final BirthdayProvider birthdayProvider;
  final FirebaseService firebaseService;

  AuthProvider({required this.birthdayProvider, required this.firebaseService});
  AuthState state = AuthState.empty;

  Future login() async {
    try {
      _handleLoading();
      await firebaseService.login();

      final List<BirthdayModel> remoteBirthList = await firebaseService.getBirthList();

      await birthdayProvider.setLocalData(remoteBirthList);

      _handleSuccess();
    } catch (err) {
      _handleError();
    }
  }

  Future logout() async {
    try {
      _handleLoading();
      for (BirthdayModel birthday in birthdayProvider.birthList) {
        await firebaseService.addBirthday(birthday);
      }
      await firebaseService.logout();

      await birthdayProvider.clearLocalData();

      _handleSuccess();
    } catch (err) {
      _handleError();
    }
  }

  void _handleSuccess() {
    state = AuthState.success;
    notifyListeners();
  }

  void _handleLoading() {
    state = AuthState.loading;
    notifyListeners();
  }

  void _handleError() {
    state = AuthState.error;
    notifyListeners();
  }
}
