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
  'ajoker11': Cards(color: 'Anti Joker', number: 10, idNumber: 1, position: 0, image: 'assets/cards/ajoker.png'),
  'ajoker12': Cards(color: 'Anti Joker', number: 10, idNumber: 2, position: 0, image: 'assets/cards/ajoker.png'),
  'ajoker13': Cards(color: 'Anti Joker', number: 10, idNumber: 3, position: 0, image: 'assets/cards/ajoker.png'),
  'ajoker14': Cards(color: 'Anti Joker', number: 10, idNumber: 4, position: 0, image: 'assets/cards/ajoker.png'),
  'ajoker15': Cards(color: 'Anti Joker', number: 10, idNumber: 5, position: 0, image: 'assets/cards/ajoker.png'),
  'ajoker16': Cards(color: 'Anti Joker', number: 10, idNumber: 6, position: 0, image: 'assets/cards/ajoker.png'),
  'njoker01': Cards(color: 'Number 1-9', number: 0, idNumber: 1, position: 0, image: 'assets/cards/njoker.png'),
  'njoker02': Cards(color: 'Number 1-9', number: 0, idNumber: 2, position: 0, image: 'assets/cards/njoker.png'),
  'njoker03': Cards(color: 'Number 1-9', number: 0, idNumber: 3, position: 0, image: 'assets/cards/njoker.png'),
  'njoker04': Cards(color: 'Number 1-9', number: 0, idNumber: 4, position: 0, image: 'assets/cards/njoker.png'),
  'cjoker11': Cards(color: 'Color 1-9', number: 10, idNumber: 1, position: 0, image: 'assets/cards/cjoker.png'),
  'cjoker12': Cards(color: 'Color 1-9', number: 10, idNumber: 2, position: 0, image: 'assets/cards/cjoker.png'),
  'cjoker13': Cards(color: 'Color 1-9', number: 10, idNumber: 3, position: 0, image: 'assets/cards/cjoker.png'),
  'cjoker14': Cards(color: 'Color 1-9', number: 10, idNumber: 4, position: 0, image: 'assets/cards/cjoker.png'),
  'purple11': Cards(color: 'Purple', number: 1, idNumber: 1, position: 0, image: 'assets/cards/purple1.PNG'),
  'purple12': Cards(color: 'Purple', number: 1, idNumber: 2, position: 0, image: 'assets/cards/purple1.PNG'),
  'purple13': Cards(color: 'Purple', number: 1, idNumber: 3, position: 0, image: 'assets/cards/purple1.PNG'),
  'purple21': Cards(color: 'Purple', number: 2, idNumber: 1, position: 0, image: 'assets/cards/purple2.PNG'),
  'purple22': Cards(color: 'Purple', number: 2, idNumber: 2, position: 0, image: 'assets/cards/purple2.PNG'),
  'purple23': Cards(color: 'Purple', number: 2, idNumber: 3, position: 0, image: 'assets/cards/purple2.PNG'),
  'purple31': Cards(color: 'Purple', number: 3, idNumber: 1, position: 0, image: 'assets/cards/purple3.PNG'),
  'purple32': Cards(color: 'Purple', number: 3, idNumber: 2, position: 0, image: 'assets/cards/purple3.PNG'),
  'purple33': Cards(color: 'Purple', number: 3, idNumber: 3, position: 0, image: 'assets/cards/purple3.PNG'),
  'purple41': Cards(color: 'Purple', number: 4, idNumber: 1, position: 0, image: 'assets/cards/purple4.PNG'),
  'purple42': Cards(color: 'Purple', number: 4, idNumber: 2, position: 0, image: 'assets/cards/purple4.PNG'),
  'purple43': Cards(color: 'Purple', number: 4, idNumber: 3, position: 0, image: 'assets/cards/purple4.PNG'),
  'purple51': Cards(color: 'Purple', number: 5, idNumber: 1, position: 0, image: 'assets/cards/purple5.PNG'),
  'purple52': Cards(color: 'Purple', number: 5, idNumber: 2, position: 0, image: 'assets/cards/purple5.PNG'),
  'purple53': Cards(color: 'Purple', number: 5, idNumber: 3, position: 0, image: 'assets/cards/purple5.PNG'),
  'purple61': Cards(color: 'Purple', number: 6, idNumber: 1, position: 0, image: 'assets/cards/purple6.PNG'),
  'purple62': Cards(color: 'Purple', number: 6, idNumber: 2, position: 0, image: 'assets/cards/purple6.PNG'),
  'purple63': Cards(color: 'Purple', number: 6, idNumber: 3, position: 0, image: 'assets/cards/purple6.PNG'),
  'purple71': Cards(color: 'Purple', number: 7, idNumber: 1, position: 0, image: 'assets/cards/purple7.PNG'),
  'purple72': Cards(color: 'Purple', number: 7, idNumber: 2, position: 0, image: 'assets/cards/purple7.PNG'),
  'purple73': Cards(color: 'Purple', number: 7, idNumber: 3, position: 0, image: 'assets/cards/purple7.PNG'),
  'purple81': Cards(color: 'Purple', number: 8, idNumber: 1, position: 0, image: 'assets/cards/purple8.PNG'),
  'purple82': Cards(color: 'Purple', number: 8, idNumber: 2, position: 0, image: 'assets/cards/purple8.PNG'),
  'purple83': Cards(color: 'Purple', number: 8, idNumber: 3, position: 0, image: 'assets/cards/purple8.PNG'),
  'purple91': Cards(color: 'Purple', number: 9, idNumber: 1, position: 0, image: 'assets/cards/purple9.PNG'),
  'purple92': Cards(color: 'Purple', number: 9, idNumber: 2, position: 0, image: 'assets/cards/purple9.PNG'),
  'purple93': Cards(color: 'Purple', number: 9, idNumber: 3, position: 0, image: 'assets/cards/purple9.PNG'),
  'orange11': Cards(color: 'Orange', number: 1, idNumber: 1, position: 0, image: 'assets/cards/orange11.PNG'),
  'orange12': Cards(color: 'Orange', number: 1, idNumber: 2, position: 0, image: 'assets/cards/orange11.PNG'),
  'orange13': Cards(color: 'Orange', number: 1, idNumber: 3, position: 0, image: 'assets/cards/orange11.PNG'),
  'orange21': Cards(color: 'Orange', number: 2, idNumber: 1, position: 0, image: 'assets/cards/orange2.png'),
  'orange22': Cards(color: 'Orange', number: 2, idNumber: 2, position: 0, image: 'assets/cards/orange2.png'),
  'orange23': Cards(color: 'Orange', number: 2, idNumber: 3, position: 0, image: 'assets/cards/orange2.png'),
  'orange31': Cards(color: 'Orange', number: 3, idNumber: 1, position: 0, image: 'assets/cards/orange3.PNG'),
  'orange32': Cards(color: 'Orange', number: 2, idNumber: 2, position: 0, image: 'assets/cards/orange3.PNG'),
  'orange33': Cards(color: 'Orange', number: 3, idNumber: 3, position: 0, image: 'assets/cards/orange3.PNG'),
  'orange41': Cards(color: 'Orange', number: 4, idNumber: 1, position: 0, image: 'assets/cards/orange4.PNG'),
  'orange42': Cards(color: 'Orange', number: 4, idNumber: 2, position: 0, image: 'assets/cards/orange4.PNG'),
  'orange43': Cards(color: 'Orange', number: 4, idNumber: 3, position: 0, image: 'assets/cards/orange4.PNG'),
  'orange51': Cards(color: 'Orange', number: 5, idNumber: 1, position: 0, image: 'assets/cards/orange5.PNG'),
  'orange52': Cards(color: 'Orange', number: 5, idNumber: 2, position: 0, image: 'assets/cards/orange5.PNG'),
  'orange53': Cards(color: 'Orange', number: 5, idNumber: 3, position: 0, image: 'assets/cards/orange5.PNG'),
  'orange61': Cards(color: 'Orange', number: 6, idNumber: 1, position: 0, image: 'assets/cards/orange6.PNG'),
  'orange62': Cards(color: 'Orange', number: 6, idNumber: 2, position: 0, image: 'assets/cards/orange6.PNG'),
  'orange63': Cards(color: 'Orange', number: 6, idNumber: 3, position: 0, image: 'assets/cards/orange6.PNG'),
  'orange71': Cards(color: 'Orange', number: 7, idNumber: 1, position: 0, image: 'assets/cards/orange7.PNG'),
  'orange72': Cards(color: 'Orange', number: 7, idNumber: 2, position: 0, image: 'assets/cards/orange7.PNG'),
  'orange73': Cards(color: 'Orange', number: 7, idNumber: 3, position: 0, image: 'assets/cards/orange7.PNG'),
  'orange81': Cards(color: 'Orange', number: 8, idNumber: 1, position: 0, image: 'assets/cards/orange8.PNG'),
  'orange82': Cards(color: 'Orange', number: 8, idNumber: 2, position: 0, image: 'assets/cards/orange8.PNG'),
  'orange83': Cards(color: 'Orange', number: 8, idNumber: 3, position: 0, image: 'assets/cards/orange8.PNG'),
  'orange91': Cards(color: 'Orange', number: 9, idNumber: 1, position: 0, image: 'assets/cards/orange9.PNG'),
  'orange92': Cards(color: 'Orange', number: 9, idNumber: 2, position: 0, image: 'assets/cards/orange9.PNG'),
  'orange93': Cards(color: 'Orange', number: 9, idNumber: 3, position: 0, image: 'assets/cards/orange9.PNG'),
  'black11': Cards(color: 'Black', number: 1, idNumber: 1, position: 0, image: 'assets/cards/black1.PNG'),
  'black12': Cards(color: 'Black', number: 1, idNumber: 2, position: 0, image: 'assets/cards/black1.PNG'),
  'black13': Cards(color: 'Black', number: 1, idNumber: 3, position: 0, image: 'assets/cards/black1.PNG'),
  'black21': Cards(color: 'Black', number: 2, idNumber: 1, position: 0, image: 'assets/cards/black2.PNG'),
  'black22': Cards(color: 'Black', number: 2, idNumber: 2, position: 0, image: 'assets/cards/black2.PNG'),
  'black23': Cards(color: 'Black', number: 2, idNumber: 3, position: 0, image: 'assets/cards/black2.PNG'),
  'black31': Cards(color: 'Black', number: 3, idNumber: 1, position: 0, image: 'assets/cards/black3.PNG'),
  'black32': Cards(color: 'Black', number: 2, idNumber: 2, position: 0, image: 'assets/cards/black3.PNG'),
  'black33': Cards(color: 'Black', number: 3, idNumber: 3, position: 0, image: 'assets/cards/black3.PNG'),
  'black41': Cards(color: 'Black', number: 4, idNumber: 1, position: 0, image: 'assets/cards/black4.PNG'),
  'black42': Cards(color: 'Black', number: 4, idNumber: 2, position: 0, image: 'assets/cards/black4.PNG'),
  'black43': Cards(color: 'Black', number: 4, idNumber: 3, position: 0, image: 'assets/cards/black4.PNG'),
  'black51': Cards(color: 'Black', number: 5, idNumber: 1, position: 0, image: 'assets/cards/black5.PNG'),
  'black52': Cards(color: 'Black', number: 5, idNumber: 2, position: 0, image: 'assets/cards/black5.PNG'),
  'black53': Cards(color: 'Black', number: 5, idNumber: 3, position: 0, image: 'assets/cards/black5.PNG'),
  'black61': Cards(color: 'Black', number: 6, idNumber: 1, position: 0, image: 'assets/cards/black6.PNG'),
  'black62': Cards(color: 'Black', number: 6, idNumber: 2, position: 0, image: 'assets/cards/black6.PNG'),
  'black63': Cards(color: 'Black', number: 6, idNumber: 3, position: 0, image: 'assets/cards/black6.PNG'),
  'black71': Cards(color: 'Black', number: 7, idNumber: 1, position: 0, image: 'assets/cards/black7.PNG'),
  'black72': Cards(color: 'Black', number: 7, idNumber: 2, position: 0, image: 'assets/cards/black7.PNG'),
  'black73': Cards(color: 'Black', number: 7, idNumber: 3, position: 0, image: 'assets/cards/black7.PNG'),
  'black81': Cards(color: 'Black', number: 8, idNumber: 1, position: 0, image: 'assets/cards/black8.PNG'),
  'black82': Cards(color: 'Black', number: 8, idNumber: 2, position: 0, image: 'assets/cards/black8.PNG'),
  'black83': Cards(color: 'Black', number: 8, idNumber: 3, position: 0, image: 'assets/cards/black8.PNG'),
  'black91': Cards(color: 'Black', number: 9, idNumber: 1, position: 0, image: 'assets/cards/black9.PNG'),
  'black92': Cards(color: 'Black', number: 9, idNumber: 2, position: 0, image: 'assets/cards/black9.PNG'),
  'black93': Cards(color: 'Black', number: 9, idNumber: 3, position: 0, image: 'assets/cards/black9.PNG'),
};
