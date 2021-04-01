class BirthdayModel {
  final int id;
  final String name;
  DateTime dateofbirth;
  final String dateString;
  int days;

  BirthdayModel({this.name, this.dateofbirth, this.id, this.dateString});

  toMap() {
    return {
      'name': this.name,
      'dateString': this.dateString,
    };
  }
}
