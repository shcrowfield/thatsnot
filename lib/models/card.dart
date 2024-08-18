import 'dart:math';


class Cards {
  String color;
  int number;
  int idNumber;
  int position;
  String image;

  Cards({required this.color, required this.number, required this.idNumber, required this.position, required this.image});

  Map<String, dynamic> toMap() {
    return {'color': color, 'number': number, 'idNumber': idNumber, 'position': position, 'image': image};
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
  'ajoker11': Cards(color: 'Anti Joker', number: 10, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'ajoker12': Cards(color: 'Anti Joker', number: 10, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'ajoker13': Cards(color: 'Anti Joker', number: 10, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'ajoker14': Cards(color: 'Anti Joker', number: 10, idNumber: 4, position: 0, image: 'assets/orange1.png'),
  'ajoker15': Cards(color: 'Anti Joker', number: 10, idNumber: 5, position: 0, image: 'assets/orange1.png'),
  'ajoker16': Cards(color: 'Anti Joker', number: 10, idNumber: 6, position: 0, image: 'assets/orange1.png'),
  'njoker01': Cards(color: 'Number 1-9', number: 0, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'njoker02': Cards(color: 'Number 1-9', number: 0, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'njoker03': Cards(color: 'Number 1-9', number: 0, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'njoker04': Cards(color: 'Number 1-9', number: 0, idNumber: 4, position: 0, image: 'assets/orange1.png'),
  'cjoker11': Cards(color: 'Color 1-9', number: 10, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'cjoker12': Cards(color: 'Color 1-9', number: 10, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'cjoker13': Cards(color: 'Color 1-9', number: 10, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'cjoker14': Cards(color: 'Color 1-9', number: 10, idNumber: 4, position: 0, image: 'assets/orange1.png'),
  'purple11': Cards(color: 'Purple', number: 1, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'purple12': Cards(color: 'Purple', number: 1, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'purple13': Cards(color: 'Purple', number: 1, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'purple21': Cards(color: 'Purple', number: 2, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'purple22': Cards(color: 'Purple', number: 2, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'purple23': Cards(color: 'Purple', number: 2, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'purple31': Cards(color: 'Purple', number: 3, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'purple32': Cards(color: 'Purple', number: 2, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'purple33': Cards(color: 'Purple', number: 3, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'purple41': Cards(color: 'Purple', number: 4, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'purple42': Cards(color: 'Purple', number: 4, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'purple43': Cards(color: 'Purple', number: 4, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'purple51': Cards(color: 'Purple', number: 5, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'purple52': Cards(color: 'Purple', number: 5, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'purple53': Cards(color: 'Purple', number: 5, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'purple61': Cards(color: 'Purple', number: 6, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'purple62': Cards(color: 'Purple', number: 6, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'purple63': Cards(color: 'Purple', number: 6, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'purple71': Cards(color: 'Purple', number: 7, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'purple72': Cards(color: 'Purple', number: 7, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'purple73': Cards(color: 'Purple', number: 7, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'purple81': Cards(color: 'Purple', number: 8, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'purple82': Cards(color: 'Purple', number: 8, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'purple83': Cards(color: 'Purple', number: 8, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'purple91': Cards(color: 'Purple', number: 9, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'purple92': Cards(color: 'Purple', number: 9, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'purple93': Cards(color: 'Purple', number: 9, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'orange11': Cards(color: 'Orange', number: 1, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'orange12': Cards(color: 'Orange', number: 1, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'orange13': Cards(color: 'Orange', number: 1, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'orange21': Cards(color: 'Orange', number: 2, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'orange22': Cards(color: 'Orange', number: 2, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'orange23': Cards(color: 'Orange', number: 2, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'orange31': Cards(color: 'Orange', number: 3, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'orange32': Cards(color: 'Orange', number: 2, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'orange33': Cards(color: 'Orange', number: 3, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'orange41': Cards(color: 'Orange', number: 4, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'orange42': Cards(color: 'Orange', number: 4, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'orange43': Cards(color: 'Orange', number: 4, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'orange51': Cards(color: 'Orange', number: 5, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'orange52': Cards(color: 'Orange', number: 5, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'orange53': Cards(color: 'Orange', number: 5, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'orange61': Cards(color: 'Orange', number: 6, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'orange62': Cards(color: 'Orange', number: 6, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'orange63': Cards(color: 'Orange', number: 6, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'orange71': Cards(color: 'Orange', number: 7, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'orange72': Cards(color: 'Orange', number: 7, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'orange73': Cards(color: 'Orange', number: 7, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'orange81': Cards(color: 'Orange', number: 8, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'orange82': Cards(color: 'Orange', number: 8, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'orange83': Cards(color: 'Orange', number: 8, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'orange91': Cards(color: 'Orange', number: 9, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'orange92': Cards(color: 'Orange', number: 9, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'orange93': Cards(color: 'Orange', number: 9, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'black11': Cards(color: 'Black', number: 1, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'black12': Cards(color: 'Black', number: 1, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'black13': Cards(color: 'Black', number: 1, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'black21': Cards(color: 'Black', number: 2, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'black22': Cards(color: 'Black', number: 2, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'black23': Cards(color: 'Black', number: 2, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'black31': Cards(color: 'Black', number: 3, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'black32': Cards(color: 'Black', number: 2, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'black33': Cards(color: 'Black', number: 3, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'black41': Cards(color: 'Black', number: 4, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'black42': Cards(color: 'Black', number: 4, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'black43': Cards(color: 'Black', number: 4, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'black51': Cards(color: 'Black', number: 5, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'black52': Cards(color: 'Black', number: 5, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'black53': Cards(color: 'Black', number: 5, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'black61': Cards(color: 'Black', number: 6, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'black62': Cards(color: 'Black', number: 6, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'black63': Cards(color: 'Black', number: 6, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'black71': Cards(color: 'Black', number: 7, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'black72': Cards(color: 'Black', number: 7, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'black73': Cards(color: 'Black', number: 7, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'black81': Cards(color: 'Black', number: 8, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'black82': Cards(color: 'Black', number: 8, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'black83': Cards(color: 'Black', number: 8, idNumber: 3, position: 0, image: 'assets/orange1.png'),
  'black91': Cards(color: 'Black', number: 9, idNumber: 1, position: 0, image: 'assets/orange1.png'),
  'black92': Cards(color: 'Black', number: 9, idNumber: 2, position: 0, image: 'assets/orange1.png'),
  'black93': Cards(color: 'Black', number: 9, idNumber: 3, position: 0, image: 'assets/orange1.png'),
};
