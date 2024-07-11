import 'dart:math';


class Cards {
  String color;
  int number;
  int idNumber;
  int position;

  Cards({required this.color, required this.number, required this.idNumber, required this.position});

  Map<String, dynamic> toMap() {
    return {'color': color, 'number': number, 'idNumber': idNumber, 'position': position};
  }
}

Map<String, dynamic> shuffleCards() {
  var serialMap = cardsMap.map((key, value) => MapEntry(key, value.toMap()));
  List<MapEntry<String, dynamic>> entries = serialMap.entries.toList();
  entries.shuffle(Random());
  for(int i =0; i < entries.length; i++) {
    entries[i].value['position'] = i+1;
  }
  Map<String, dynamic> shuffledCards = Map.fromEntries(entries);
  return shuffledCards;
}

Map<String, Cards> cardsMap = {
  'ajoker11': Cards(color: 'Anti Joker', number: 10, idNumber: 1, position: 0),
  'ajoker12': Cards(color: 'Anti Joker', number: 10, idNumber: 2, position: 0),
  'ajoker13': Cards(color: 'Anti Joker', number: 10, idNumber: 3, position: 0),
  'ajoker14': Cards(color: 'Anti Joker', number: 10, idNumber: 4, position: 0),
  'ajoker15': Cards(color: 'Anti Joker', number: 10, idNumber: 5, position: 0),
  'ajoker16': Cards(color: 'Anti Joker', number: 10, idNumber: 6, position: 0),
  'njoker01': Cards(color: 'Number 1-9', number: 0, idNumber: 1, position: 0),
  'njoker02': Cards(color: 'Number 1-9', number: 0, idNumber: 2, position: 0),
  'njoker03': Cards(color: 'Number 1-9', number: 0, idNumber: 3, position: 0),
  'njoker04': Cards(color: 'Number 1-9', number: 0, idNumber: 4, position: 0),
  'cjoker11': Cards(color: 'Color 1-9', number: 10, idNumber: 1, position: 0),
  'cjoker12': Cards(color: 'Color 1-9', number: 10, idNumber: 2, position: 0),
  'cjoker13': Cards(color: 'Color 1-9', number: 10, idNumber: 3, position: 0),
  'cjoker14': Cards(color: 'Color 1-9', number: 10, idNumber: 4, position: 0),
  'purple11': Cards(color: 'Purple', number: 1, idNumber: 1, position: 0),
  'purple12': Cards(color: 'Purple', number: 1, idNumber: 2, position: 0),
  'purple13': Cards(color: 'Purple', number: 1, idNumber: 3, position: 0),
  'purple21': Cards(color: 'Purple', number: 2, idNumber: 1, position: 0),
  'purple22': Cards(color: 'Purple', number: 2, idNumber: 2, position: 0),
  'purple23': Cards(color: 'Purple', number: 2, idNumber: 3, position: 0),
  'purple31': Cards(color: 'Purple', number: 3, idNumber: 1, position: 0),
  'purple32': Cards(color: 'Purple', number: 2, idNumber: 2, position: 0),
  'purple33': Cards(color: 'Purple', number: 3, idNumber: 3, position: 0),
  'purple41': Cards(color: 'Purple', number: 4, idNumber: 1, position: 0),
  'purple42': Cards(color: 'Purple', number: 4, idNumber: 2, position: 0),
  'purple43': Cards(color: 'Purple', number: 4, idNumber: 3, position: 0),
  'purple51': Cards(color: 'Purple', number: 5, idNumber: 1, position: 0),
  'purple52': Cards(color: 'Purple', number: 5, idNumber: 2, position: 0),
  'purple53': Cards(color: 'Purple', number: 5, idNumber: 3, position: 0),
  'purple61': Cards(color: 'Purple', number: 6, idNumber: 1, position: 0),
  'purple62': Cards(color: 'Purple', number: 6, idNumber: 2, position: 0),
  'purple63': Cards(color: 'Purple', number: 6, idNumber: 3, position: 0),
  'purple71': Cards(color: 'Purple', number: 7, idNumber: 1, position: 0),
  'purple72': Cards(color: 'Purple', number: 7, idNumber: 2, position: 0),
  'purple73': Cards(color: 'Purple', number: 7, idNumber: 3, position: 0),
  'purple81': Cards(color: 'Purple', number: 8, idNumber: 1, position: 0),
  'purple82': Cards(color: 'Purple', number: 8, idNumber: 2, position: 0),
  'purple83': Cards(color: 'Purple', number: 8, idNumber: 3, position: 0),
  'purple91': Cards(color: 'Purple', number: 9, idNumber: 1, position: 0),
  'purple92': Cards(color: 'Purple', number: 9, idNumber: 2, position: 0),
  'purple93': Cards(color: 'Purple', number: 9, idNumber: 3, position: 0),
  'orange11': Cards(color: 'Orange', number: 1, idNumber: 1, position: 0),
  'orange12': Cards(color: 'Orange', number: 1, idNumber: 2, position: 0),
  'orange13': Cards(color: 'Orange', number: 1, idNumber: 3, position: 0),
  'orange21': Cards(color: 'Orange', number: 2, idNumber: 1, position: 0),
  'orange22': Cards(color: 'Orange', number: 2, idNumber: 2, position: 0),
  'orange23': Cards(color: 'Orange', number: 2, idNumber: 3, position: 0),
  'orange31': Cards(color: 'Orange', number: 3, idNumber: 1, position: 0),
  'orange32': Cards(color: 'Orange', number: 2, idNumber: 2, position: 0),
  'orange33': Cards(color: 'Orange', number: 3, idNumber: 3, position: 0),
  'orange41': Cards(color: 'Orange', number: 4, idNumber: 1, position: 0),
  'orange42': Cards(color: 'Orange', number: 4, idNumber: 2, position: 0),
  'orange43': Cards(color: 'Orange', number: 4, idNumber: 3, position: 0),
  'orange51': Cards(color: 'Orange', number: 5, idNumber: 1, position: 0),
  'orange52': Cards(color: 'Orange', number: 5, idNumber: 2, position: 0),
  'orange53': Cards(color: 'Orange', number: 5, idNumber: 3, position: 0),
  'orange61': Cards(color: 'Orange', number: 6, idNumber: 1, position: 0),
  'orange62': Cards(color: 'Orange', number: 6, idNumber: 2, position: 0),
  'orange63': Cards(color: 'Orange', number: 6, idNumber: 3, position: 0),
  'orange71': Cards(color: 'Orange', number: 7, idNumber: 1, position: 0),
  'orange72': Cards(color: 'Orange', number: 7, idNumber: 2, position: 0),
  'orange73': Cards(color: 'Orange', number: 7, idNumber: 3, position: 0),
  'orange81': Cards(color: 'Orange', number: 8, idNumber: 1, position: 0),
  'orange82': Cards(color: 'Orange', number: 8, idNumber: 2, position: 0),
  'orange83': Cards(color: 'Orange', number: 8, idNumber: 3, position: 0),
  'orange91': Cards(color: 'Orange', number: 9, idNumber: 1, position: 0),
  'orange92': Cards(color: 'Orange', number: 9, idNumber: 2, position: 0),
  'orange93': Cards(color: 'Orange', number: 9, idNumber: 3, position: 0),
  'black11': Cards(color: 'Black', number: 1, idNumber: 1, position: 0),
  'black12': Cards(color: 'Black', number: 1, idNumber: 2, position: 0),
  'black13': Cards(color: 'Black', number: 1, idNumber: 3, position: 0),
  'black21': Cards(color: 'Black', number: 2, idNumber: 1, position: 0),
  'black22': Cards(color: 'Black', number: 2, idNumber: 2, position: 0),
  'black23': Cards(color: 'Black', number: 2, idNumber: 3, position: 0),
  'black31': Cards(color: 'Black', number: 3, idNumber: 1, position: 0),
  'black32': Cards(color: 'Black', number: 2, idNumber: 2, position: 0),
  'black33': Cards(color: 'Black', number: 3, idNumber: 3, position: 0),
  'black41': Cards(color: 'Black', number: 4, idNumber: 1, position: 0),
  'black42': Cards(color: 'Black', number: 4, idNumber: 2, position: 0),
  'black43': Cards(color: 'Black', number: 4, idNumber: 3, position: 0),
  'black51': Cards(color: 'Black', number: 5, idNumber: 1, position: 0),
  'black52': Cards(color: 'Black', number: 5, idNumber: 2, position: 0),
  'black53': Cards(color: 'Black', number: 5, idNumber: 3, position: 0),
  'black61': Cards(color: 'Black', number: 6, idNumber: 1, position: 0),
  'black62': Cards(color: 'Black', number: 6, idNumber: 2, position: 0),
  'black63': Cards(color: 'Black', number: 6, idNumber: 3, position: 0),
  'black71': Cards(color: 'Black', number: 7, idNumber: 1, position: 0),
  'black72': Cards(color: 'Black', number: 7, idNumber: 2, position: 0),
  'black73': Cards(color: 'Black', number: 7, idNumber: 3, position: 0),
  'black81': Cards(color: 'Black', number: 8, idNumber: 1, position: 0),
  'black82': Cards(color: 'Black', number: 8, idNumber: 2, position: 0),
  'black83': Cards(color: 'Black', number: 8, idNumber: 3, position: 0),
  'black91': Cards(color: 'Black', number: 9, idNumber: 1, position: 0),
  'black92': Cards(color: 'Black', number: 9, idNumber: 2, position: 0),
  'black93': Cards(color: 'Black', number: 9, idNumber: 3, position: 0),
};
