import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:remember/utilities/constants.dart';
import 'package:remember/models/note_model.dart';
import 'package:remember/widgets/app_scaffold.dart';
import 'package:remember/providers/note_provider.dart';
import 'package:remember/screens/add_note_screen.dart';

class NotesTab extends StatefulWidget {
  @override
  _NotesTabState createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete these notes?"),
          actions: [
            TextButton(
              child: Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "DELETE",
                style: kBody1TextStyle.copyWith(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<NoteProvider>(context, listen: false).deleteNotes();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, nProvider, child) {
        bool selectionMode = nProvider.selectionMode;
        List<int> selectedIndexList = nProvider.selectedIndexList;
        List<NoteModel> notesList = nProvider.notesList;

        return AppScaffold(
          leftButton: // Cancel Button
              selectionMode
                  ? IconButton(
                      icon: Icon(Icons.cancel),
                      color: Colors.white,
                      onPressed: () {
                        nProvider.changeSelectionMode(false, -1);
                      },
                    )
                  : SizedBox(
                      width: 30.w,
                    ),
          title: 'Notes',
          rightButton: // Delete Button
              selectionMode
                  ? IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.white,
                      onPressed: () {
                        if (selectedIndexList.length > 0) showAlertDialog(context);
                      },
                    )
                  // Add New Note Button
                  : GestureDetector(
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30.r,
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, AddNoteScreen.id);
                      },
                    ),
          childWidget: notesList.length == 0
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 310.h),
                    child: Text(
                      'No Notes Found',
                      style: kBody1TextStyle,
                    ),
                  ),
                )
              : GridView.count(
                  shrinkWrap: true,
                  primary: false,
                  childAspectRatio: 50 / 13,
                  physics: NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(15),
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  crossAxisCount: 2,
                  children: List.generate(
                    notesList.length,
                    (index) {
                      return GestureDetector(
                        onLongPress: () {
                          selectionMode
                              ? nProvider.changeSelectionMode(false, -1)
                              : nProvider.changeSelectionMode(true, index);
                        },
                        onTap: () {
                          if (selectionMode) {
                            nProvider.toggleNoteSelection(index);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddNoteScreen(
                                  note: notesList[index],
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectionMode && selectedIndexList.contains(index) ? Colors.white70 : Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              selectionMode && selectedIndexList.contains(index)
                                  ? BoxShadow()
                                  : BoxShadow(
                                      blurRadius: 10.r,
                                      offset: Offset(0, 0.2),
                                      color: Colors.black.withOpacity(0.25),
                                    ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10.r),
                            child: Text(
                              notesList[index].content,
                              style: kBody2TextStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}
