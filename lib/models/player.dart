import 'package:thatsnot/models/card.dart';

class Player {
 final String uid;
 final String name;
 final int points;
 final bool isActive;
 late Map<String, Cards> cards;

 Player({required this.uid, required this.name, required this.points, required this.isActive, Map<String, Cards>? cards}) {
  this.cards = cards ?? {};
 }

 Map<String, dynamic> toMap() {
  return {
   'uid': uid,
   'name': name,
   'points': points,
    'isActive': isActive,
   'cards': cards.map((key, card) => MapEntry(key, card.toMap())),
  };
 }

/* factory Player.fromMap(Map<String, dynamic> data) {
  return Player(
   uid: data['uid'],
   name: data['name'],
   points: data['points'],
    isActive: data['isActive'],
   cards: Map<String, Cards>.from(data['cards']),
  );
 }*/
}
