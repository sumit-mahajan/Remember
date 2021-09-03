import 'package:remember/providers/birthday_provider.dart';
import 'package:remember/providers/note_provider.dart';
import 'package:remember/providers/todo_provider.dart';
import 'package:remember/services/database_service.dart';
import 'package:uuid/uuid.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final locator = GetIt.instance;

Future<void> init() async {
  //Providers

  locator.registerLazySingleton(() => TodoProvider(prefs: locator(), localDbService: locator()));
  locator.registerLazySingleton(() => NoteProvider(localDbService: locator()));
  locator.registerLazySingleton(() => BirthdayProvider(localDbService: locator()));

  //Services

  locator.registerLazySingleton(() => LocalDbService());
  // locator.registerLazySingleton(() => NotificationService(locator()));

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
