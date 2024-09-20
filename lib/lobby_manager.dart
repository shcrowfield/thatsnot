import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/player.dart';

import 'language.dart';

class LobbyManager {
  static Future<Map<String, dynamic>> getPlayersList(lobbyId) async {
 return getPlayersListStream(lobbyId).first;

  }

  static Stream<Map<String, dynamic>> getPlayersListStream(lobbyId) async* {
    await for (var snapshot in FirebaseFirestore.instance
        .collection('lobbies')
        .doc(lobbyId)
        .snapshots()) {
      Map<String, dynamic>? data = snapshot.data();
      Map<String, dynamic> player1 = data?['player1'];
      Map<String, dynamic> player2 = data?['player2'];
      Map<String, dynamic> player3 = data?['player3'];
      Map<String, dynamic> player4 = data?['player4'];
      List<Map<String, dynamic>> players = [player1, player2, player3, player4];
      Map<String, dynamic> returnMap = {
        'players': players,
        'documentSnapshot': snapshot
      };
      yield returnMap;
    }
  }

  static void checkPlayerMap(lobbyId, user, currentPlayerCount) async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    List<Map<String, dynamic>> players = returnMap['players'];
    var documentSnapshot = returnMap['documentSnapshot'];

    for (int i = 0; i < players.length; i++) {
      if (players[i]['uid'] == user!.uid) {
        Map<String, dynamic> updatedPlayer = {
          ...players[i],
          'cards': [],
          'isHost': false,
          'points': 0,
          'name': '',
          'uid': ''
        };
        String playerFieldName = 'player${i + 1}';
        documentSnapshot.reference.update({playerFieldName: updatedPlayer});
      }
    }

    if (currentPlayerCount != null && currentPlayerCount! > 0) {
      await documentSnapshot.reference.update({
        'currentPlayerCount': FieldValue.increment(-1),
        //'isReady': FieldValue.increment(-1)
      });
    }
    LobbyManager.deletePlayer(lobbyId);
  }

  static void decreseIsReady(lobbyId) async {
    var documentSnapshot = await FirebaseFirestore.instance
        .collection('lobbies')
        .doc(lobbyId)
        .get();
    await documentSnapshot.reference.update({
      'isReady': FieldValue.increment(-1),
    });
  }

  static void decresePlayerLimit(lobbyId) async {
    var documentSnapshot = await FirebaseFirestore.instance
        .collection('lobbies')
        .doc(lobbyId)
        .get();
    await documentSnapshot.reference.update({
      'playerLimit': FieldValue.increment(-1),
    });
  }

  static deletePlayer(lobbyId) async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    var documentSnapshot = returnMap['documentSnapshot'];
    Map<String, dynamic>? data = documentSnapshot.data();
    if (data?['currentPlayerCount'] == 0) {
      await documentSnapshot.reference.delete();
    }
  }

  static String allowToJoin(int currentPlayerCount, int playerLimit,
      String nickName) {
    if (currentPlayerCount < playerLimit && nickName.isNotEmpty) {
      return languageMap['Allow to Enter'] ?? "";
    }
    else if(currentPlayerCount < playerLimit && nickName.isEmpty) {
      return languageMap['EnterNickname'] ?? "";
    }else {
      return languageMap['LobbyIsFull'] ?? "";
    }
  }
}
