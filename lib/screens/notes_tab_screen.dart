import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:remember/models/note_model.dart';

import 'package:remember/utilities/constants.dart';
import 'package:remember/services/database_service.dart';

import 'package:remember/screens/add_note_screen.dart';

class NotesTab extends StatefulWidget {
  //static const id = 'notes_page';
  @override
  _NotesTabState createState() => _NotesTabState();
}

class _NotesTabState extends State<NotesTab> {
  List<int?> _selectedIndexList = [];
  bool? _selectionMode = false;
  List<NoteModel>? notes = [];
  DbManager dbmanager = new DbManager();

  void _changeSelection({bool? enable, int? index}) {
    _selectionMode = enable;
    _selectedIndexList.add(index);
    if (index == -1) {
      _selectedIndexList.clear();
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("CANCEL"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "DELETE",
        style: kBody1TextStyle.copyWith(color: Colors.red),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        _selectedIndexList.sort();
        for (int? i in _selectedIndexList) {
          dbmanager.deleteNote(notes![i!].id);
        }
        setState(() {
          _changeSelection(enable: false, index: -1);
        });
      },
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete these notes?"),
          actions: [
            cancelButton,
            continueButton,
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(15.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Cancel Button
              _selectionMode!
                  ? IconButton(
                      icon: Icon(Icons.cancel),
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          _changeSelection(enable: false, index: -1);
                        });
                      },
                    )
                  : SizedBox(
                      width: 30.w,
                    ),

              // Title
              Text(
                'Notes',
                style: kTitleTextStyle,
              ),

              // Delete Button
              _selectionMode!
                  ? IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.white,
                      onPressed: () {
                        if (_selectedIndexList.length > 0) showAlertDialog(context);
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
            ],
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height - 157.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
          ),
          child: SingleChildScrollView(
            child: FutureBuilder(
              future: dbmanager.getNoteList(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  notes = snapshot.data;

                  // Empty note list
                  if (notes!.length == 0) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 310.h),
                        child: Text(
                          'No Notes Found',
                          style: kBody1TextStyle,
                        ),
                      ),
                    );
                  }

                  return GridView.count(
                    shrinkWrap: true,
                    primary: false,
                    childAspectRatio: 50 / 13,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(15),
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    crossAxisCount: 2,
                    children: List.generate(notes!.length, (index) {
                      return GestureDetector(
                        onLongPress: () {
                          _selectionMode!
                              ? _changeSelection(enable: false, index: -1)
                              : _changeSelection(enable: true, index: index);
                          setState(() {});
                        },
                        onTap: () {
                          _selectionMode!
                              ? setState(() {
                                  if (_selectedIndexList.contains(index)) {
                                    _selectedIndexList.remove(index);
                                  } else {
                                    _selectedIndexList.add(index);
                                  }
                                })
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddNoteScreen(
                                      note: notes![index],
                                    ),
                                  ),
                                );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                _selectionMode! && _selectedIndexList.contains(index) ? Colors.white60 : Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              _selectionMode! && _selectedIndexList.contains(index)
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
                              notes![index].content!,
                              style: kBody2TextStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        )
      ],
    );
  }
}
