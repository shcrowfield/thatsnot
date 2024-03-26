import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thatsnot/models/player.dart';

class DatabaseService {
  String lobbyId;

  DatabaseService({required this.lobbyId});

  final CollectionReference lobbyCollection =
      FirebaseFirestore.instance.collection('lobbies');

  Future updatePlayer(Player player, int currentPlayerCount) async {
    var documentSnapshot = await FirebaseFirestore.instance
        .collection('lobbies')
        .doc(lobbyId)
        .get();
    Map<String, dynamic>? data = documentSnapshot.data();
    Map<String, dynamic> player1 = data?['player1'];
    Map<String, dynamic> player2 = data?['player2'];
    Map<String, dynamic> player3 = data?['player3'];
    Map<String, dynamic> player4 = data?['player4'];
    List<Map<String, dynamic>> players = [player1, player2, player3, player4];
    for (int i = 0; i < 4; i++) {
      if (players[i]['uid'] == '') {
        return await lobbyCollection.doc(lobbyId).update({
          'currentPlayerCount': currentPlayerCount + 1,
          'player${i + 1}': player.toMap()
        });
      }
    }
  }


  /*Future updateCurrentPlayerCount(int currentPlayerCount) async {
    return await lobbyCollection.doc(lobbyId).update({
      'currentPlayerCount': currentPlayerCount,
    });
  }*/

  Future updateLobbyData(
    String lobbyName,
    int playerLimit,
    int currentPlayerCount,
    Player player1,
    Player player2,
    Player player3,
    Player player4,
    int isReady,
  ) async {
    return await lobbyCollection.doc(lobbyId).set({
      'lobbyId': lobbyId,
      'lobbyName': lobbyName,
      'playerLimit': playerLimit,
      'currentPlayerCount': currentPlayerCount,
      'player1': player1.toMap(),
      'player2': player2.toMap(),
      'player3': player3.toMap(),
      'player4': player4.toMap(),
      'isReady': isReady,
    });
  }
}
