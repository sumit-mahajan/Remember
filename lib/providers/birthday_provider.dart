import 'package:flutter/cupertino.dart';

import 'package:remember/models/birthday_model.dart';
import 'package:remember/services/database_service.dart';

class BirthdayProvider with ChangeNotifier {
  final LocalDbService localDbService;

  BirthdayProvider({required this.localDbService});

  bool isLoading = false;
  bool selectionMode = false;
  List<int> selectedIndexList = [];
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

  Future<void> getBirthList() async {
    birthList = await localDbService.getBirthList();
    for (int i = 0; i < birthList.length; i++) {
      birthList[i].dateofbirth = DateTime.parse(birthList[i].dateString!);
    }
    todayList = birthList
        .where((i) => i.dateofbirth!.month == DateTime.now().month && i.dateofbirth!.day == DateTime.now().day)
        .toList();
    laterBirthList = birthList
        .where((i) => !(i.dateofbirth!.month == DateTime.now().month && i.dateofbirth!.day == DateTime.now().day))
        .toList();

    sortLater();
  }

  Future<void> addBirthday(BirthdayModel _birthday) async {
    isLoading = true;
    notifyListeners();
    await localDbService.insertBirthday(_birthday);
    getBirthList();
    //TODO: setup notification
    // DateTime nextBirthday;
    //     if (DateTime(DateTime.now().year, birthdate!.month, birthdate!.day).isAfter(DateTime.now())) {
    //       nextBirthday = DateTime(DateTime.now().year, birthdate!.month, birthdate!.day);
    //     }
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteBirthdays() async {
    isLoading = true;
    notifyListeners();
    selectedIndexList.sort();
    for (int i in selectedIndexList) {
      await localDbService.deleteBirth(laterBirthList[i].id);
    }
    changeSelectionMode(false, -1);
    getBirthList();
    isLoading = false;
    notifyListeners();
  }

  void sortLater() {
    for (int i = 0; i < laterBirthList.length; i++) {
      laterBirthList[i].days = laterBirthList[i]
          .dateofbirth!
          .difference(DateTime(laterBirthList[i].dateofbirth!.year, DateTime.now().month, DateTime.now().day))
          .inDays;
      if (laterBirthList[i].days < 0) {
        laterBirthList[i].days = laterBirthList[i]
            .dateofbirth!
            .difference(DateTime(laterBirthList[i].dateofbirth!.year - 1, DateTime.now().month, DateTime.now().day))
            .inDays;
      }
    }
    laterBirthList.sort((a, b) => a.days.compareTo(b.days));
    notifyListeners();
  }
}
