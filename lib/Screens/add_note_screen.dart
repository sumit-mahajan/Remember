import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/services.dart';

import 'package:remember/utilities/constants.dart';
import 'package:remember/services/database_service.dart';
import 'package:remember/models/note_model.dart';

import 'package:remember/screens/birthdays_tab_screen.dart';
import 'package:remember/screens/events_tab_screen.dart';
import 'package:remember/screens/notes_tab_screen.dart';
import 'package:remember/screens/todo_tab_screen.dart';

class AddNoteScreen extends StatelessWidget {
  static const id = 'add_note';
  NoteModel newNote = NoteModel(content: '');
  DbManager dbmanager = new DbManager();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF5F35FE),
          title: Text(
            'Add a Note',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: ButtonTheme(
                padding: EdgeInsets.symmetric(
                    vertical: 2.0,
                    horizontal: 8.0), //adds padding inside the button
                materialTapTargetSize: MaterialTapTargetSize
                    .shrinkWrap, //limits the touch area to the button area
                minWidth: 0, //wraps child's width
                height: 0,
                child: OutlineButton(
                  child: Text(
                    'ADD',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  borderSide: BorderSide(color: Colors.white),
                  shape: new RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  onPressed: () {
                    if (newNote.content != '' &&
                        newNote.content.toLowerCase() !=
                            newNote.content.toUpperCase()) {
                      dbmanager.insertNote(newNote).then((id) => {
                            print('Note added at $id'),
                          });
                      Navigator.pushNamed(context, NotesTab.id);
                    }
                  },
                ),
              ),
            )
          ],
        ),
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
                Navigator.pushNamed(context, ToDoTab.id);
                break;
              case 1:
                Navigator.pop(context);
                break;
              case 2:
                Navigator.pushNamed(context, BirthdayTab.id);
                break;
              case 3:
                Navigator.pushNamed(context, EventsTab.id);
                break;
            }
          },
          animationDuration: Duration(
            milliseconds: 200,
          ),
          animationCurve: Curves.bounceInOut,
        ),
        body: TextField(
          decoration: InputDecoration(
              hintText: 'Tap here to Write',
              hintStyle: greetTextStyle,
              border: OutlineInputBorder(borderSide: BorderSide.none)),
          keyboardType: TextInputType.multiline,
          maxLines: null,
          style: greetTextStyle,
          onChanged: (value) {
            newNote.content = value;
          },
        ),
      ),
      onWillPop: () async {
        if (newNote.content != '' &&
            newNote.content.toLowerCase() != newNote.content.toUpperCase()) {
          dbmanager.insertNote(newNote).then((id) => {
                print('Note added at $id'),
              });
          Navigator.pushNamed(context, NotesTab.id);
        } else {
          Navigator.pop(context);
        }
        return false;
      },
    );
  }
}
