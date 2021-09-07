import 'package:flutter/cupertino.dart';

import 'package:remember/models/birthday_model.dart';
import 'package:remember/services/firebase_service.dart';
import 'package:remember/services/local_database_service.dart';
import 'package:remember/services/local_notification_service.dart';
import 'package:uuid/uuid.dart';

class BirthdayProvider with ChangeNotifier {
  final Uuid uuid;
  final LocalDbService localDbService;
  final FirebaseService firebaseService;
  final LocalNotificationService notificationService;

  BirthdayProvider(
      {required this.uuid,
      required this.localDbService,
      required this.firebaseService,
      required this.notificationService});

  bool isLoading = false;
  bool selectionMode = false;
  List<int> selectedIndexList = [];
  List<String> fSelectedIDList = [];
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

  Future<BirthdayModel> addBirthday(BirthdayModel _birthday) async {
    isLoading = true;
    notifyListeners();
    _birthday.bid = uuid.v4();
    int id = await localDbService.insertBirthday(_birthday);
    _birthday.id = id;
    DateTime scheduleDate = DateTime(DateTime.now().year, _birthday.dateofbirth.month, _birthday.dateofbirth.day);
    await notificationService.scheduleYearly(
      id,
      'Today we have a birthday!',
      'Wish ' +
          _birthday.name +
          ' on their ' +
          (DateTime.now().year - _birthday.dateofbirth.year).toString() +
          'th birthday',
      'birthday_reminder',
      scheduleDate,
    );
    if (_birthday.notifyBefore) {
      await notificationService.scheduleYearly(
        id,
        'Early reminder for a birthday!',
        '1 Day to go for ' +
            _birthday.name +
            "'s " +
            (DateTime.now().year - _birthday.dateofbirth.year).toString() +
            'th birthday',
        'birthday_reminder',
        scheduleDate.subtract(Duration(days: 1)),
      );
    }
    getBirthList();
    isLoading = false;
    notifyListeners();
    return _birthday;
  }

  Future addBirthdayToFirebase(BirthdayModel birthday) async {
    await firebaseService.addBirthday(birthday);
  }

  Future<void> deleteBirthdays() async {
    isLoading = true;
    notifyListeners();
    selectedIndexList.sort();
    fSelectedIDList = [];
    for (int i in selectedIndexList) {
      fSelectedIDList.add(laterBirthList[i].bid!);
      await localDbService.deleteBirth(laterBirthList[i].id);
      await notificationService.cancelBirthdayNotification(laterBirthList[i].id!);
    }
    changeSelectionMode(false, -1);
    getBirthList();
    isLoading = false;
    notifyListeners();
  }

  Future deleteBirthdaysFromFirebase() async {
    for (String bid in fSelectedIDList) {
      await firebaseService.deleteBirthday(bid);
    }
    fSelectedIDList.clear();
  }

  Future setLocalData(List<BirthdayModel> remoteBirthList) async {
    for (BirthdayModel _birthday in remoteBirthList) {
      int id = await localDbService.insertBirthday(_birthday);
      DateTime scheduleDate = DateTime(DateTime.now().year, _birthday.dateofbirth.month, _birthday.dateofbirth.day);
      await notificationService.scheduleYearly(
        id,
        'Today we have a birthday!',
        'Wish ' +
            _birthday.name +
            ' on their ' +
            (DateTime.now().year - _birthday.dateofbirth.year).toString() +
            'th birthday',
        'birthday_reminder',
        scheduleDate,
      );
      if (_birthday.notifyBefore) {
        await notificationService.scheduleYearly(
          id,
          'Early reminder for a birthday!',
          '1 Day to go for ' +
              _birthday.name +
              "'s " +
              (DateTime.now().year - _birthday.dateofbirth.year).toString() +
              'th birthday',
          'birthday_reminder',
          scheduleDate.subtract(Duration(days: 1)),
        );
      }
    }
    getBirthList();
  }

  Future clearLocalData() async {
    for (int i = 0; i < birthList.length; i++) {
      await localDbService.deleteBirth(birthList[i].id);
    }
    await notificationService.cancelAllNotifications();
    getBirthList();
  }
}
