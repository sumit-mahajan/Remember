class BirthdayModel {
  final int? id;
  final String name;
  final DateTime dateofbirth;
  final String dateString;
  late int days;

  BirthdayModel({this.id, required this.name, required this.dateofbirth, required this.dateString});

  toMap() {
    return {
      'name': this.name,
      'dateString': this.dateString,
    };
  }

  factory BirthdayModel.fromMap(Map map) {
    return BirthdayModel(
      id: map['id'],
      name: map['name'],
      dateString: map['dateString'],
      dateofbirth: DateTime.parse(map['dateString']),
    );
  }
}
