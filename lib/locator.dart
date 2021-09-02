import 'package:uuid/uuid.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final locator = GetIt.instance;

Future<void> init() async {
  //Providers

  // locator.registerLazySingleton(() =>
  //     ProfileProvider(gProvider: locator(), dataService: locator(), dailyProvider: locator()));

  //Services

  // locator.registerLazySingleton(() => ProfileDataService(
  //       store: locator(),
  //       auth: locator(),
  //       prefs: locator(),
  //     ));

  //External

  // locator.registerLazySingleton(() => NotificationService(locator()));

  final prefs = await SharedPreferences.getInstance();
  locator.registerLazySingleton(() => prefs);

  final FirebaseAuth auth = FirebaseAuth.instance;
  locator.registerLazySingleton(() => auth);

  final FirebaseFirestore store = FirebaseFirestore.instance;
  locator.registerLazySingleton(() => store);

  const Uuid uuid = Uuid();
  locator.registerLazySingleton(() => uuid);
}
