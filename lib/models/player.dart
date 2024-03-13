import 'package:thatsnot/models/card.dart';

class Player {
 final String pid;
 final String name;
 final int points;
 late Map<String, Card> cards;

 Player({required this.pid, required this.name, required this.points, Map<String, Card>? cards}) {
  this.cards = cards ?? {};
 }

 Map<String, dynamic> toMap() {
  return {
   'pid': pid,
   'name': name,
   'points': points,
   'cards': cards.map((key, card) => MapEntry(key, card.toMap())),
  };
 }
}
