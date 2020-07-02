class TodoItem {
  int id;
  String item;
  bool done;
  TodoItem({this.item, this.done, this.id});
  TodoItem.from(TodoItem other)
      : item = other.item,
        done = other.done;

  Map<String, dynamic> toMap() {
    var map = {'item': this.item, 'done': this.done == false ? 0 : 1};
    return map;
  }
}
