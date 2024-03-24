import 'package:thatsnot/models/card.dart';

class Player {
 final String uid;
 final String name;
 final int points;
 final bool isHost;
 late Map<String, Card> cards;

 Player({required this.uid, required this.name, required this.points, required this.isHost, Map<String, Card>? cards}) {
  this.cards = cards ?? {};
 }

 Map<String, dynamic> toMap() {
  return {
   'uid': uid,
   'name': name,
   'points': points,
    'isHost': isHost,
   'cards': cards.map((key, card) => MapEntry(key, card.toMap())),
  };
 }

 factory Player.fromMap(Map<String, dynamic> data) {
  return Player(
   uid: data['uid'],
   name: data['name'],
   points: data['points'],
    isHost: data['isHost'],
   cards: Map<String, Card>.from(data['cards']),
  );
 }
}
