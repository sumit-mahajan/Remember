class TodoModel {
  int id;
  String name;
  bool done;

  TodoModel({this.name, this.done, this.id});

  TodoModel.from(TodoModel other)
      : name = other.name,
        done = other.done;

  toMap() {
    return {
      'name': this.name,
      'done': this.done == false ? 0 : 1,
    };
  }

  factory TodoModel.fromMap(Map map) {
    return TodoModel(
      id: map['id'],
      name: map['name'],
      done: map['done'] == 0 ? false : true,
    );
  }
}
