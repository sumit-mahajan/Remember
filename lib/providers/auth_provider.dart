// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';

// import '../repositories/auth_service.dart';

// enum AuthState { empty, loading, success, error }

// class AuthProvider with ChangeNotifier {
//   AuthProvider({
//     required this.authService,
//   });

// //Service
//   AuthenticationService authService;
//   //State
//   AuthState state = AuthState.empty;
//   //Error Message
//   AuthErrorMessage errMessage = AuthErrorMessage();

//   Future<void> login(String email, String password) async {
//     _handleLoading();

//     try {
//       await isConnectedToInternet();
//       await authService.signIn(email: email.trim(), password: password);
//       state = AuthState.success;
//       errMessage.clear();

//       _handleSuccess();

//       return;
//     } catch (err) {
//       debugPrint('Error at AuthProvider -> login');

//       _handleError(err.toString());
//     }
//   }

//   Future<void> register({required AppUser user}) async {
//     errMessage.clear();

//     _handleLoading();

//     try {
//       await isConnectedToInternet();
//       await authService.signUp(
//         user: user,
//       );

//       _handleSuccess();

//       return;
//     } catch (err) {
//       debugPrint('Error at AuthProvider -> login');

//       _handleError(err.toString());
//     }
//   }

//   Future<void> logout() async {
//     _handleLoading();

//     try {
//       await authService.logOut();
//       //notify
//       _handleSuccess();

//       return;
//     } catch (err) {
//       debugPrint('Error at AuthProvider -> logout');

//       _handleError(err.toString());
//     }
//   }

//   void handleEmpty() {
//     state = AuthState.empty;
//     notifyListeners();
//   }

//   void _handleSuccess() {
//     state = AuthState.success;
//     notifyListeners();
//   }

//   void _handleLoading() {
//     state = AuthState.loading;
//     notifyListeners();
//   }

//   void _handleError(String message) {
//     state = AuthState.error;

//     clearMessage();

//     if (message.contains('Username')) {
//       errMessage.username = message;
//     } else if (message.contains('email') || message.contains('User')) {
//       errMessage.email = message;
//     } else if (message.contains('password') || message.contains('Password')) {
//       errMessage.password = message;
//     } else {
//       errMessage.general = message;
//     }

//     notifyListeners();
//   }

//   void clearMessage() => errMessage.clear();
// }

// class AuthErrorMessage {
//   String email = '';
//   String password = '';
//   String general = '';
//   String name = '';
//   String username = '';

//   void clear() {
//     email = '';
//     password = '';
//     general = '';
//     name = '';
//     username = '';
//   }
// }

