class StoreBirthday {
  final int id;
  final String name;
  DateTime dateofbirth;
  final String dateString;
  int days;

  StoreBirthday({this.name, this.dateofbirth, this.id, this.dateString});

  Map<String, dynamic> toMap() {
    var map = {'name': this.name, 'dateString': this.dateString};
    return map;
  }
}
