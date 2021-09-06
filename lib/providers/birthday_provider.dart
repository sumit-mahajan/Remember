import 'package:flutter/cupertino.dart';

import 'package:remember/models/birthday_model.dart';
import 'package:remember/services/firebase_service.dart';
import 'package:remember/services/local_database_service.dart';
import 'package:remember/services/local_notification_service.dart';

class BirthdayProvider with ChangeNotifier {
  final LocalDbService localDbService;
  final FirebaseService firebaseService;
  final LocalNotificationService notificationService;

  BirthdayProvider({required this.localDbService, required this.firebaseService, required this.notificationService});

  bool isLoading = false;
  bool selectionMode = false;
  List<int> selectedIndexList = [];
  List<int> fSelectedIndexList = [];
  List<BirthdayModel> birthList = [];
  List<BirthdayModel> todayList = [];
  List<BirthdayModel> laterBirthList = [];

  void changeSelectionMode(bool enable, int index) {
    selectionMode = enable;
    selectedIndexList.add(index);
    if (index == -1) {
      selectedIndexList.clear();
    }
    notifyListeners();
  }

  void toggleBirthSelection(int index) {
    if (selectedIndexList.contains(index)) {
      selectedIndexList.remove(index);
    } else {
      selectedIndexList.add(index);
    }
    notifyListeners();
  }

  void sortLater() {
    for (int i = 0; i < laterBirthList.length; i++) {
      laterBirthList[i].days = laterBirthList[i]
          .dateofbirth
          .difference(DateTime(laterBirthList[i].dateofbirth.year, DateTime.now().month, DateTime.now().day))
          .inDays;
      if (laterBirthList[i].days < 0) {
        laterBirthList[i].days = laterBirthList[i]
            .dateofbirth
            .difference(DateTime(laterBirthList[i].dateofbirth.year - 1, DateTime.now().month, DateTime.now().day))
            .inDays;
      }
    }
    laterBirthList.sort((a, b) => a.days.compareTo(b.days));
    notifyListeners();
  }

  Future<void> getBirthList() async {
    birthList = await localDbService.getBirthList();
    todayList = birthList
        .where((i) => i.dateofbirth.month == DateTime.now().month && i.dateofbirth.day == DateTime.now().day)
        .toList();
    laterBirthList = birthList
        .where((i) => !(i.dateofbirth.month == DateTime.now().month && i.dateofbirth.day == DateTime.now().day))
        .toList();

    sortLater();
  }

  Future<int> addBirthday(BirthdayModel _birthday) async {
    isLoading = true;
    notifyListeners();
    int id = await localDbService.insertBirthday(_birthday);
    // await notificationService.scheduleYearly(
    //   _birthday.id!,
    //   _birthday.name,
    //   'Wish ' +
    //       _birthday.name +
    //       ' on their ' +
    //       (DateTime.now().year - _birthday.dateofbirth.year).toString() +
    //       'th birthday',
    //   'birthday_reminder',
    //   _birthday.dateofbirth,
    // );
    getBirthList();
    isLoading = false;
    notifyListeners();
    return id;
  }

  Future addBirthdayToFirebase(BirthdayModel birthday) async {
    await firebaseService.addBirthday(birthday);
  }

  Future<void> deleteBirthdays() async {
    isLoading = true;
    notifyListeners();
    selectedIndexList.sort();
    fSelectedIndexList = selectedIndexList;
    for (int i in selectedIndexList) {
      await localDbService.deleteBirth(laterBirthList[i].id);
    }
    changeSelectionMode(false, -1);
    getBirthList();
    isLoading = false;
    notifyListeners();
  }

  Future deleteBirthdaysFromFirebase() async {
    for (int i in selectedIndexList) {
      await firebaseService.deleteBirthday(laterBirthList[i]);
    }
    fSelectedIndexList.clear();
  }

  Future setLocalData(List<BirthdayModel> remoteBirthList) async {
    for (int i = 0; i < remoteBirthList.length; i++) {
      await localDbService.insertBirthday(remoteBirthList[i]);
    }
    getBirthList();
  }

  Future clearLocalData() async {
    for (int i = 0; i < birthList.length; i++) {
      await localDbService.deleteBirth(birthList[i].id);
    }
    getBirthList();
  }
}
