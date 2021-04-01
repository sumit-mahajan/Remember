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
}
