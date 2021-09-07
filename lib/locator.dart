import 'package:remember/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:remember/providers/birthday_provider.dart';
import 'package:remember/providers/note_provider.dart';
import 'package:remember/providers/todo_provider.dart';
import 'package:remember/services/firebase_service.dart';
import 'package:remember/services/local_database_service.dart';
import 'package:remember/services/local_notification_service.dart';

final locator = GetIt.instance;

Future<void> init() async {
  //Providers

  locator.registerLazySingleton(() => AuthProvider(birthdayProvider: locator(), firebaseService: locator()));
  locator.registerLazySingleton(() => TodoProvider(localDbService: locator(), prefs: locator()));
  locator.registerLazySingleton(() => NoteProvider(localDbService: locator()));
  locator.registerLazySingleton(() => BirthdayProvider(
      uuid: locator(), localDbService: locator(), firebaseService: locator(), notificationService: locator()));

  //Services

  locator.registerLazySingleton(() => LocalDbService());
  locator.registerLazySingleton(() => FirebaseService(auth: locator(), store: locator()));
  locator.registerLazySingleton(() => LocalNotificationService());

  //Variables

  final prefs = await SharedPreferences.getInstance();
  locator.registerLazySingleton(() => prefs);

  final FirebaseAuth auth = FirebaseAuth.instance;
  locator.registerLazySingleton(() => auth);

  final FirebaseFirestore store = FirebaseFirestore.instance;
  locator.registerLazySingleton(() => store);

  const Uuid uuid = Uuid();
  locator.registerLazySingleton(() => uuid);
}
