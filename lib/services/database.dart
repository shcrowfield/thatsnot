import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thatsnot/lobby_manager.dart';
import 'package:thatsnot/models/player.dart';

class DatabaseService {
  String lobbyId;

  DatabaseService({required this.lobbyId});

  final CollectionReference lobbyCollection =
      FirebaseFirestore.instance.collection('lobbies');

  Future updatePlayer(Player player, int currentPlayerCount) async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    List<Map<String, dynamic>> players = returnMap['players'];

    for (int i = 0; i < players.length; i++) {
      if (players[i]['uid'] == '') {
        return await lobbyCollection.doc(lobbyId).update({
          'currentPlayerCount': currentPlayerCount + 1,
          'player${i + 1}': player.toMap()
        });
      }
    }
  }

  Future updateLobbyData(
    String lobbyName,
    int playerLimit,
    int currentPlayerCount,
    Player player1,
    Player player2,
    Player player3,
    Player player4,
    int isReady,
    Map<String, dynamic> deck,
    String activePlayer,
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
      'deck': deck,
      'activePlayer': activePlayer,
    });
  }
}
