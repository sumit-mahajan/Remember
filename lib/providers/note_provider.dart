import 'package:flutter/cupertino.dart';

import 'package:remember/models/note_model.dart';
import 'package:remember/services/local_database_service.dart';

class NoteProvider with ChangeNotifier {
  final LocalDbService localDbService;

  NoteProvider({required this.localDbService});

  bool selectionMode = false;
  List<int> selectedIndexList = [];
  List<NoteModel> notesList = [];

  void changeSelectionMode(bool enable, int index) {
    selectionMode = enable;
    selectedIndexList.add(index);
    if (index == -1) {
      selectedIndexList.clear();
    }
    notifyListeners();
  }

  void toggleNoteSelection(int index) {
    if (selectedIndexList.contains(index)) {
      selectedIndexList.remove(index);
    } else {
      selectedIndexList.add(index);
    }
    notifyListeners();
  }

  Future<void> getNotesList() async {
    notesList = await localDbService.getNoteList();
    notifyListeners();
  }

  Future<void> insertNote(NoteModel note) async {
    await localDbService.insertNote(note);
    getNotesList();
  }

  Future<void> updateNote(NoteModel note) async {
    await localDbService.updateNote(note);
    getNotesList();
  }

  Future<void> deleteNotes() async {
    selectedIndexList.sort();
    for (int i in selectedIndexList) {
      await localDbService.deleteNote(notesList[i].id);
    }
    changeSelectionMode(false, -1);
    getNotesList();
    notifyListeners();
  }
}
