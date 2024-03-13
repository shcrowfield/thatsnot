class Card {
  String color;
  int number;
  int idNumber;

  Card({required this.color, required this.number, required this.idNumber});

  Map<String, dynamic> toMap() {
    return {'color': color, 'number': number, 'idNumber': idNumber};
  }
}
