class NoteModel {
  int id;
  String content;

  NoteModel({this.id, this.content});

  toMap() {
    return {
      'content': this.content,
    };
  }
}
