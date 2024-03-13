import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thatsnot/models/player.dart';


class DatabaseService {
  String lobbyId;

  DatabaseService({required this.lobbyId});

  final CollectionReference lobbyCollection =
      FirebaseFirestore.instance.collection('lobbies');

  Future updateLobbyData(String lobbyName, int playerLimit,
      int currentPlayerCount, Map<String, Player> players) async {
    Map<String, Map<String, dynamic>> serializedPlayers = {};
    players.forEach((key, value) {
      serializedPlayers[key] = value.toMap();
    });

    return await lobbyCollection.doc(lobbyId).set({
      'lobbyId': lobbyId,
      'lobbyName': lobbyName,
      'playerLimit': playerLimit,
      'currentPlayerCount': currentPlayerCount,
      'players': serializedPlayers,
    });
  }
}
