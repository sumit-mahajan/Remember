class NoteModel {
  int? id;
  String content;

  NoteModel({this.id, required this.content});

  toMap() {
    return {
      'content': this.content,
    };
  }

  factory NoteModel.fromMap(Map map) {
    return NoteModel(
      id: map['id'],
      content: map['content'],
    );
  }
}
