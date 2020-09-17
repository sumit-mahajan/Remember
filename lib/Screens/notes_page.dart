import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../Utilities/constants.dart';
import 'todo_page.dart';
import 'birthday_page.dart';
import 'add_notes.dart';
import 'calendar_page.dart';
import '../Utilities/db_manager.dart';
import 'edit_note.dart';

class Note extends StatefulWidget {
  static const id = 'notes_page';
  @override
  _NoteState createState() => _NoteState();
}

class _NoteState extends State<Note> {
  List<int> _selectedIndexList = List();
  bool _selectionMode = false;
  List<StoreNote> notes = [];
  DbManager dbmanager = new DbManager();

  void _changeSelection({bool enable, int index}) {
    _selectionMode = enable;
    _selectedIndexList.add(index);
    if (index == -1) {
      _selectedIndexList.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            backgroundColor: Color(0xFF5B84FF),
            child: Icon(
              Icons.add,
              size: 30.0,
            ),
            onPressed: () {
              Navigator.pushNamed(context, AddNote.id);
            }),
        bottomNavigationBar: CurvedNavigationBar(
          height: 50.0,
          backgroundColor: Colors.white,
          buttonBackgroundColor: Color(0xFF5F35FE),
          color: Color(0xFFeff2f9),
          index: 1,
          items: <Widget>[
            Icon(Icons.check_circle_outline, size: 30),
            Icon(
              Icons.event_note,
              size: 30,
              color: Colors.white,
            ),
            Icon(Icons.card_giftcard, size: 30),
            Icon(Icons.calendar_today, size: 30),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, ToDo.id);
                break;
              case 2:
                Navigator.pushNamed(context, Birthday.id);
                break;
              case 3:
                Navigator.pushNamed(context, CalendarApp.id);
                break;
            }
          },
          animationDuration: Duration(
            milliseconds: 200,
          ),
          animationCurve: Curves.bounceInOut,
        ),
        backgroundColor: Color(0xFF5F35FE),
        body: ListView(
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
                      : Container(),
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
                      : Container(),
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
                            padding:
                                const EdgeInsets.symmetric(vertical: 280.0),
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
                                    _changeSelection(
                                        enable: true, index: index);
                                  });
                                },
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditNote(
                                                editnote: notes[index],
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
        ),
      ),
    );
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
}
