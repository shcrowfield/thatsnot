import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thatsnot/models/player.dart';

class DatabaseService {
  String lobbyId;

  DatabaseService({required this.lobbyId});

  final CollectionReference lobbyCollection =
      FirebaseFirestore.instance.collection('lobbies');

  Future updatePlayer(Player player, int currentPlayerCount) async {
    if (currentPlayerCount == 1) {
      return await lobbyCollection.doc(lobbyId).update({
        'currentPlayerCount': currentPlayerCount + 1,
        'player2': player.toMap(),
      });
    } else if (currentPlayerCount == 2) {
      return await lobbyCollection.doc(lobbyId).update({
        'currentPlayerCount': currentPlayerCount + 1,
        'player3': player.toMap(),
      });
    } else if (currentPlayerCount == 3) {
      return await lobbyCollection.doc(lobbyId).update({
        'currentPlayerCount': currentPlayerCount + 1,
        'player4': player.toMap(),
      });
    }
  }

  Future updateCurrentPlayerCount(int currentPlayerCount) async {
    return await lobbyCollection.doc(lobbyId).update({
      'currentPlayerCount': currentPlayerCount,
    });
  }

  Future updateLobbyData(
    String lobbyName,
    int playerLimit,
    int currentPlayerCount,
    Player player1,
    Player player2,
    Player player3,
    Player player4,
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
    });
  }
}
