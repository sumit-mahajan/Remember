class BirthdayModel {
  int? id;
  String? bid;
  final String name;
  final DateTime dateofbirth;
  final String dateString;
  late bool notifyBefore;
  late int days;

  BirthdayModel({
    this.id,
    required this.name,
    required this.dateofbirth,
    required this.dateString,
    this.bid,
    this.notifyBefore = true,
  });

  toMap() {
    return {
      'id': this.id,
      'bid': this.bid,
      'name': this.name,
      'dateString': this.dateString,
      'notifyBefore': this.notifyBefore == false ? 0 : 1,
    };
  }

  factory BirthdayModel.fromMap(Map map) {
    return BirthdayModel(
      id: map['id'],
      bid: map['bid'],
      name: map['name'],
      dateString: map['dateString'],
      dateofbirth: DateTime.parse(map['dateString']),
      notifyBefore: map['notifyBefore'] == 0 ? false : true,
    );
  }
}
