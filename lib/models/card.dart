import 'dart:math';

class Cards {
  String color;
  int number;
  int idNumber;

  Cards({required this.color, required this.number, required this.idNumber});

  Map<String, dynamic> toMap() {
    return {'color': color, 'number': number, 'idNumber': idNumber};
  }
}

Map<String, Cards> shuffleCards() {
  List<MapEntry<String, Cards>> entries = cardsMap.entries.toList();
  entries.shuffle(Random());
  Map<String, Cards> shuffledCards = Map.fromEntries(entries);
  return shuffledCards;
}

Map<String, Cards> createDrawPile() {
  Map<String, Cards> originalMap = shuffleCards();
  Map<String, Cards> drawPile = {};
  int count = 0;
  originalMap.forEach((key, value) {
    if (count < 5) {
      drawPile[key] = value;
      count++;
    }
  });
  return drawPile;
}

Map<String, Cards> cardsMap = {
  'ajoker11': Cards(color: 'Anti Joker', number: 1, idNumber: 1),
  'ajoker12': Cards(color: 'Anti Joker', number: 1, idNumber: 2),
  'ajoker13': Cards(color: 'Anti Joker', number: 1, idNumber: 3),
  'ajoker14': Cards(color: 'Anti Joker', number: 1, idNumber: 4),
  'ajoker15': Cards(color: 'Anti Joker', number: 1, idNumber: 5),
  'ajoker16': Cards(color: 'Anti Joker', number: 1, idNumber: 6),
  'njoker11': Cards(color: 'Number 1-9', number: 1, idNumber: 1),
  'njoker12': Cards(color: 'Number 1-9', number: 1, idNumber: 2),
  'njoker13': Cards(color: 'Number 1-9', number: 1, idNumber: 3),
  'njoker14': Cards(color: 'Number 1-9', number: 1, idNumber: 4),
  'cjoker11': Cards(color: 'Color 1-9', number: 1, idNumber: 1),
  'cjoker12': Cards(color: 'Color 1-9', number: 1, idNumber: 2),
  'cjoker13': Cards(color: 'Color 1-9', number: 1, idNumber: 3),
  'cjoker14': Cards(color: 'Color 1-9', number: 1, idNumber: 4),
  'purple11': Cards(color: 'Purple', number: 1, idNumber: 1),
  'purple12': Cards(color: 'Purple', number: 1, idNumber: 2),
  'purple13': Cards(color: 'Purple', number: 1, idNumber: 3),
  'purple21': Cards(color: 'Purple', number: 2, idNumber: 1),
  'purple22': Cards(color: 'Purple', number: 2, idNumber: 2),
  'purple23': Cards(color: 'Purple', number: 2, idNumber: 3),
  'purple31': Cards(color: 'Purple', number: 3, idNumber: 1),
  'purple32': Cards(color: 'Purple', number: 2, idNumber: 2),
  'purple33': Cards(color: 'Purple', number: 3, idNumber: 3),
  'purple41': Cards(color: 'Purple', number: 4, idNumber: 1),
  'purple42': Cards(color: 'Purple', number: 4, idNumber: 2),
  'purple43': Cards(color: 'Purple', number: 4, idNumber: 3),
  'purple51': Cards(color: 'Purple', number: 5, idNumber: 1),
  'purple52': Cards(color: 'Purple', number: 5, idNumber: 2),
  'purple53': Cards(color: 'Purple', number: 5, idNumber: 3),
  'purple61': Cards(color: 'Purple', number: 6, idNumber: 1),
  'purple62': Cards(color: 'Purple', number: 6, idNumber: 2),
  'purple63': Cards(color: 'Purple', number: 6, idNumber: 3),
  'purple71': Cards(color: 'Purple', number: 7, idNumber: 1),
  'purple72': Cards(color: 'Purple', number: 7, idNumber: 2),
  'purple73': Cards(color: 'Purple', number: 7, idNumber: 3),
  'purple81': Cards(color: 'Purple', number: 8, idNumber: 1),
  'purple82': Cards(color: 'Purple', number: 8, idNumber: 2),
  'purple83': Cards(color: 'Purple', number: 8, idNumber: 3),
  'purple91': Cards(color: 'Purple', number: 9, idNumber: 1),
  'purple92': Cards(color: 'Purple', number: 9, idNumber: 2),
  'purple93': Cards(color: 'Purple', number: 9, idNumber: 3),
  'orange11': Cards(color: 'Orange', number: 1, idNumber: 1),
  'orange12': Cards(color: 'Orange', number: 1, idNumber: 2),
  'orange13': Cards(color: 'Orange', number: 1, idNumber: 3),
  'orange21': Cards(color: 'Orange', number: 2, idNumber: 1),
  'orange22': Cards(color: 'Orange', number: 2, idNumber: 2),
  'orange23': Cards(color: 'Orange', number: 2, idNumber: 3),
  'orange31': Cards(color: 'Orange', number: 3, idNumber: 1),
  'orange32': Cards(color: 'Orange', number: 2, idNumber: 2),
  'orange33': Cards(color: 'Orange', number: 3, idNumber: 3),
  'orange41': Cards(color: 'Orange', number: 4, idNumber: 1),
  'orange42': Cards(color: 'Orange', number: 4, idNumber: 2),
  'orange43': Cards(color: 'Orange', number: 4, idNumber: 3),
  'orange51': Cards(color: 'Orange', number: 5, idNumber: 1),
  'orange52': Cards(color: 'Orange', number: 5, idNumber: 2),
  'orange53': Cards(color: 'Orange', number: 5, idNumber: 3),
  'orange61': Cards(color: 'Orange', number: 6, idNumber: 1),
  'orange62': Cards(color: 'Orange', number: 6, idNumber: 2),
  'orange63': Cards(color: 'Orange', number: 6, idNumber: 3),
  'orange71': Cards(color: 'Orange', number: 7, idNumber: 1),
  'orange72': Cards(color: 'Orange', number: 7, idNumber: 2),
  'orange73': Cards(color: 'Orange', number: 7, idNumber: 3),
  'orange81': Cards(color: 'Orange', number: 8, idNumber: 1),
  'orange82': Cards(color: 'Orange', number: 8, idNumber: 2),
  'orange83': Cards(color: 'Orange', number: 8, idNumber: 3),
  'orange91': Cards(color: 'Orange', number: 9, idNumber: 1),
  'orange92': Cards(color: 'Orange', number: 9, idNumber: 2),
  'orange93': Cards(color: 'Orange', number: 9, idNumber: 3),
  'black11': Cards(color: 'Black', number: 1, idNumber: 1),
  'black12': Cards(color: 'Black', number: 1, idNumber: 2),
  'black13': Cards(color: 'Black', number: 1, idNumber: 3),
  'black21': Cards(color: 'Black', number: 2, idNumber: 1),
  'black22': Cards(color: 'Black', number: 2, idNumber: 2),
  'black23': Cards(color: 'Black', number: 2, idNumber: 3),
  'black31': Cards(color: 'Black', number: 3, idNumber: 1),
  'black32': Cards(color: 'Black', number: 2, idNumber: 2),
  'black33': Cards(color: 'Black', number: 3, idNumber: 3),
  'black41': Cards(color: 'Black', number: 4, idNumber: 1),
  'black42': Cards(color: 'Black', number: 4, idNumber: 2),
  'black43': Cards(color: 'Black', number: 4, idNumber: 3),
  'black51': Cards(color: 'Black', number: 5, idNumber: 1),
  'black52': Cards(color: 'Black', number: 5, idNumber: 2),
  'black53': Cards(color: 'Black', number: 5, idNumber: 3),
  'black61': Cards(color: 'Black', number: 6, idNumber: 1),
  'black62': Cards(color: 'Black', number: 6, idNumber: 2),
  'black63': Cards(color: 'Black', number: 6, idNumber: 3),
  'black71': Cards(color: 'Black', number: 7, idNumber: 1),
  'black72': Cards(color: 'Black', number: 7, idNumber: 2),
  'black73': Cards(color: 'Black', number: 7, idNumber: 3),
  'black81': Cards(color: 'Black', number: 8, idNumber: 1),
  'black82': Cards(color: 'Black', number: 8, idNumber: 2),
  'black83': Cards(color: 'Black', number: 8, idNumber: 3),
  'black91': Cards(color: 'Black', number: 9, idNumber: 1),
  'black92': Cards(color: 'Black', number: 9, idNumber: 2),
  'black93': Cards(color: 'Black', number: 9, idNumber: 3),
};
