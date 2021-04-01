import 'package:flutter/material.dart';
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
  List<int> _selectedIndexList = List();
  bool _selectionMode = false;
  List<NoteModel> notes = [];
  DbManager dbmanager = new DbManager();

  void _changeSelection({bool enable, int index}) {
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
        style: TextStyle(color: Colors.redAccent),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        _selectedIndexList.sort();
        for (int i in _selectedIndexList) {
          dbmanager.deleteNote(notes[i].id);
        }
        setState(() {
          _changeSelection(enable: false, index: -1);
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      title: Text("Confirm Deletion"),
      content: Text("Are you sure you want to delete these notes?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _selectionMode
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
                      width: 30.0,
                    ),
              Text(
                'Notes',
                style: titleTextStyle,
              ),
              _selectionMode
                  ? IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.white,
                      onPressed: () {
                        if (_selectedIndexList.length > 0)
                          showAlertDialog(context);
                      },
                    )
                  : GestureDetector(
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30.0,
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, AddNoteScreen.id);
                      },
                    ),
            ],
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height - 135.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0)),
          ),
          child: SingleChildScrollView(
            child: FutureBuilder(
              future: dbmanager.getNoteList(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  notes = snapshot.data;
                  if (notes.length == 0) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 280.0),
                        child: Text(
                          'Add Notes',
                          style: greetTextStyle,
                        ),
                      ),
                    );
                  }
                  return GridView.count(
                    shrinkWrap: true,
                    primary: false,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(18),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 5,
                    crossAxisCount: 2,
                    children: List.generate(notes.length, (index) {
                      if (_selectionMode) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5.0,
                          color: _selectedIndexList.contains(index)
                              ? Colors.white70
                              : Colors.white,
                          child: GestureDetector(
                            onLongPress: () {
                              setState(() {
                                _changeSelection(enable: false, index: -1);
                              });
                            },
                            onTap: () {
                              setState(() {
                                if (_selectedIndexList.contains(index)) {
                                  _selectedIndexList.remove(index);
                                } else {
                                  _selectedIndexList.add(index);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                notes[index].content,
                                style: TextStyle(fontSize: 19.0),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Card(
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: GestureDetector(
                            onLongPress: () {
                              setState(() {
                                _changeSelection(enable: true, index: index);
                              });
                            },
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddNoteScreen(
                                            note: notes[index],
                                          )));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                notes[index].content,
                                style: TextStyle(fontSize: 19.0),
                              ),
                            ),
                          ),
                        );
                      }
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
