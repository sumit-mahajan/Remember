import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:remember/screens/tabs_screen.dart';

import 'package:remember/utilities/constants.dart';
import 'package:remember/services/database_service.dart';
import 'package:remember/models/note_model.dart';

class AddNoteScreen extends StatefulWidget {
  static const id = 'add_note';
  final NoteModel note;

  AddNoteScreen({this.note});

  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final DbManager dbmanager = new DbManager();
  NoteModel newNote;

  @override
  void initState() {
    widget.note != null
        ? newNote = widget.note
        : newNote = NoteModel(content: '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppPrimaryColor,
        title: Text(
          widget.note == null ? 'Add Note' : 'Edit Note',
          style: kBody2TextStyle.copyWith(
              color: Colors.white, fontWeight: FontWeight.w500),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(15.r),
            child: ButtonTheme(
              padding: EdgeInsets.symmetric(
                  vertical: 2.h,
                  horizontal: 8.w), //adds padding inside the button
              materialTapTargetSize: MaterialTapTargetSize
                  .shrinkWrap, //limits the touch area to the button area
              minWidth: 0, //wraps child's width
              height: 0,
              child: OutlineButton(
                child: Text(
                  widget.note == null ? 'Add' : 'Edit',
                  style: kBody1TextStyle.copyWith(color: Colors.white),
                ),
                borderSide: BorderSide(color: Colors.white),
                shape: new RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.r)),
                onPressed: () {
                  if (newNote.content != '' &&
                      newNote.content.toLowerCase() !=
                          newNote.content.toUpperCase()) {
                    if (widget.note == null) {
                      dbmanager.insertNote(newNote).then((id) => {
                            print('Note added at $id'),
                          });
                    } else {
                      dbmanager.updateNote(newNote).then((id) => {
                            print('Note updated at $id'),
                          });
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TabsScreen(
                          preSelected: 1,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          )
        ],
      ),
      body: TextFormField(
        initialValue: newNote.content,
        decoration: InputDecoration(
            hintText: 'Tap here to Write',
            hintStyle: kBody2TextStyle,
            border: OutlineInputBorder(borderSide: BorderSide.none)),
        keyboardType: TextInputType.multiline,
        maxLines: null,
        style: kBody2TextStyle,
        onChanged: (value) {
          newNote.content = value;
        },
      ),
    );
  }
}
