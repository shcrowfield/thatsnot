import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thatsnot/lobby_manager.dart';
import 'package:thatsnot/models/card.dart';
import 'package:thatsnot/models/player.dart';
import 'package:thatsnot/services/leaderboard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DatabaseService {
  String lobbyId;

  DatabaseService({required this.lobbyId});

  final CollectionReference lobbyCollection =
      FirebaseFirestore.instance.collection('lobbies');

  Future updateDeck() async {
    Map<String, dynamic> updatedDeck = shuffleCards();
    return await lobbyCollection.doc(lobbyId).update({'deck': updatedDeck});
  }

  Future<Map<String, dynamic>> sortDeck() async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    var documentSnapshot = returnMap['documentSnapshot'];
    Map<String, dynamic>? lobby = documentSnapshot.data();
    Map<String, dynamic>? deck = lobby?['deck'];

    var sortedCards = SplayTreeMap<String, dynamic>.from(
      deck ?? {},
      (key1, key2) {
        int posCompare =
            deck?[key1]['position'].compareTo(deck[key2]['position']);
        return posCompare;
      },
    );
    return sortedCards;
  }

  Future<void> dealCards() async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    var documentSnapshot = returnMap['documentSnapshot'];
    Map<String, dynamic>? lobby = documentSnapshot.data();

    Map<String, dynamic> sortedDeck = await sortDeck();
    int playerLimit = lobby?['playerLimit'] ?? 0;
    int cardsPerPlayer = 6;
    int totalCards = playerLimit * cardsPerPlayer;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference lobbyDoc = firestore.collection('lobbies').doc(lobbyId);
    WriteBatch batch = firestore.batch();

    Map<String, dynamic> updates = {};

    for (int i = 0; i < playerLimit; i++) {
      Map<String, Map<String, dynamic>> playerCards = {};
      int startIdx = i * cardsPerPlayer;
      int endIdx = (i + 1) * cardsPerPlayer;

      List<String> cardKeys =
          sortedDeck.keys.toList().sublist(startIdx, endIdx);
      for (String key in cardKeys) {
        playerCards[key] = sortedDeck[key] as Map<String, dynamic>;
      }
      String playerId = 'player${i + 1}';
      updates['$playerId.cards'] = playerCards;
    }

    if (lobby?['deck'] != null) {
      Map<String, dynamic> updatedDeck = Map.from(lobby!['deck']);
      updatedDeck.removeWhere((key, value) => value['position'] <= totalCards);
      updates['deck'] = updatedDeck;
    }
    batch.update(lobbyDoc, updates);
    await batch.commit();


  }

  Future<void> updateDrawPile() async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    var documentSnapshot = returnMap['documentSnapshot'];
    Map<String, dynamic>? lobby = documentSnapshot.data();
    Map<String, dynamic> deck = await sortDeck();
    Map<String, dynamic> updatedDrawPile = {};
    int pileCount = 0;
    int count = 0;
    lobby?['playerLimit'] == 2 ? pileCount = 45 /*20*/ /*5*/ : pileCount = 65;

    deck.forEach((key, value) {
      if (count < pileCount) {
        updatedDrawPile[key] = value;
        count++;
      }
    });
    return await lobbyCollection
        .doc(lobbyId)
        .update({'drawPile': updatedDrawPile});
  }

  Future sortDrawPile() async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    var documentSnapshot = returnMap['documentSnapshot'];
    Map<String, dynamic>? lobby = documentSnapshot.data();
    Map<String, dynamic>? drawPile = lobby?['drawPile'];

    var sortedDrawPile = SplayTreeMap<String, dynamic>.from(
      drawPile ?? {},
      (key1, key2) {
        int posCompare =
            drawPile?[key1]['position'].compareTo(drawPile[key2]['position']);
        return posCompare;
      },
    );
    return sortedDrawPile;
  }

  Future<void> drawCard(String uid) async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    var documentSnapshot = returnMap['documentSnapshot'];
    Map<String, dynamic>? lobby = documentSnapshot.data();
    List<Map<String, dynamic>> players = returnMap['players'];
    Map<String, dynamic> sortedDrawPile = await sortDrawPile();
    int currentPlayerCount = lobby?['currentPlayerCount'] ?? 0;

    bool equal = uid == lobby?['activePlayer'];

    for (int i = 0; i < players.length; i++) {
      if (players[i]['uid'] == lobby?['activePlayer'] && equal) {
        Map<String, dynamic> player = players[i];
        Map<String, dynamic> playerCards = player['cards'];
        MapEntry<String, dynamic> drawCard = sortedDrawPile.entries.first;
        playerCards[drawCard.key] = drawCard.value;
        player['cards'] = playerCards;
        sortedDrawPile.remove(drawCard.key);
        await lobbyCollection.doc(lobbyId).update({
          'player${i + 1}.cards': playerCards,
          'drawPile': sortedDrawPile,
          'passCount': currentPlayerCount,
        });
        drawPileIsEmpty(player);
        break;
      } else {
        print('Nem a te köröd van');
      }

    }
    checkActivePlayer();
  }

  Future<void> drawPileIsEmpty(Map<String, dynamic> player) async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    var documentSnapshot = returnMap['documentSnapshot'];
    Map<String, dynamic>? lobby = documentSnapshot.data();
    Map<String, dynamic>? drawPile = lobby?['drawPile'];
    if (drawPile!.isEmpty) {
      endGameHandNotEmpty();
        updateLeaderBoard(player);

    }
  }

  Future<Map<String, dynamic>> isPlayerWinner() async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    List<Map<String, dynamic>> players = returnMap['players'];
  players.sort((a, b) =>  b['points'].compareTo(a['points']));
    return players.first;
  }

  Future updateLeaderBoard(player) async {
    Map<String, dynamic> winner = await isPlayerWinner();
    LeaderboardService(player, winner)
        .newOrExistingUser(player['uid'], player['name'], player['points']);
  }

  Future<void> updateDocument() async {
    const url =
        'http://10.0.2.2:5001/thatsnot-71ba4/us-central1/on_request_example';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Request failed with error: $e.');
    }
  }

  Future<void> postData() async {
    const url =
        'http://10.0.2.2:5001/thatsnot-71ba4/us-central1/upload_data_from_flutter';
    try {
      final Map<String, dynamic> data = {
        'title': 'Sir',
        'name': 'BuleeAlee',
        'number': 1,
      };
      final response = await http.post(Uri.parse(url),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(data));
      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Request failed with error: $e.');
    }
  }

  Future<void> postUpdatePlayer(Player player, int currentPlayerCount) async {
    const url =
        'http://10.0.2.2:5001/thatsnot-71ba4/us-central1/update_player_hard';
    //final url = 'https://us-central1-thatsnot-71ba4.cloudfunctions.net/update_player_hard';

    try {
      final Map<String, dynamic> data = {
        'lobbyId': lobbyId,
        'player': player.toMap(),
        'currentPlayerCount': currentPlayerCount,
      };
      final response = await http.post(Uri.parse(url),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(data));
      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
      } else {
        print(
            'Request failed with status: ${response.statusCode} ${response.body}.');
      }
    } catch (e) {
      print('Request failed with error: $e.');
    }
  }

  Future<void> updatePlayer(Player player, int currentPlayerCount) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot lobbyDoc =
          await transaction.get(lobbyCollection.doc(lobbyId));

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

      for (int i = 0; i < players.length; i++) {
        if (players[i]['uid'] == '') {
          transaction.update(lobbyDoc.reference, {
            'currentPlayerCount': FieldValue.increment(1),
            'player${i + 1}': player.toMap(),
          });
          return;
        }
      }
    });
  }

  Future<void> updateLies(String liedColor, int liedNumber,
      MapEntry<String, dynamic> choosedCard) async {
    final choosedCardMap = {
      choosedCard.key: choosedCard.value,
    };
    return await lobbyCollection.doc(lobbyId).update({
      'liedColor': liedColor,
      'liedNumber': liedNumber,
      'choosedCard': choosedCardMap,
    });
  }

  Future<void> updateOpponentId(String opponentId) async {
    return await lobbyCollection.doc(lobbyId).update({
      'opponentId': opponentId,
    });
  }

  Future<void> restoreOpponentId() async {
    return await lobbyCollection.doc(lobbyId).update({
      'opponentId': '',
    });
  }

  Future<void> updateLastCardPlayer(String lastCardPlayer) async {
    return await lobbyCollection.doc(lobbyId).update({
      'lastCardPlayer': lastCardPlayer,
    });
  }

  Future<void> updateResult(String winnerId, String answer) async {
    return await lobbyCollection.doc(lobbyId).update({
      'winnerId': winnerId,
      'answer': answer,
    });
  }

  Future<void> increseWinnerPoints(String id) async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    List<Map<String, dynamic>> players = returnMap['players'];
    Map<String, dynamic> lobby = returnMap['documentSnapshot'].data();
    for (int i = 0; i < players.length; i++) {
      if (players[i]['uid'] == id) {
        return await lobbyCollection.doc(lobbyId).update({
          'player${i + 1}.points':
              FieldValue.increment(lobby['discardPile'].length),
        });
      }
    }
  }

  Future<void> restoreData() async {
    return await lobbyCollection.doc(lobbyId).update({
      'discardPile': {},
      'choosedCard': {},
      'lastCardPlayer': '',
      'liedColor': '',
      'liedNumber': 0,
      'opponentId': '',
      'answer': '',
      'winnerId': '',

    });
  }

  Future<void> drawForLoser(String uid) async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    List<Map<String, dynamic>> players = returnMap['players'];
    Map<String, dynamic> drawPile = await sortDrawPile();
    for (int i = 0; i < players.length; i++) {
      if (players[i]['uid'] == uid) {
        Map<String, dynamic> loserCards = players[i]['cards'];
        Map<String, dynamic> drawnCards =
            Map.fromEntries(drawPile.entries.take(2));
        loserCards.addAll(drawnCards);
        drawPile.removeWhere((key, value) => drawnCards.containsKey(key));
        await lobbyCollection.doc(lobbyId).update({
          'player${i + 1}.cards': loserCards,
          'drawPile': drawPile,
          'activePlayer': uid,
        });
        drawPileIsEmpty(players[i]);
        break;
      }

    }
  }

  Future isHandEmpty() async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    List<Map<String, dynamic>> players = returnMap['players'];
    Map<String, dynamic> drawPile = await sortDrawPile();
    for (int i = 0; i < players.length; i++) {
     // if (players[i]['uid'] == uid) {
        if (players[i]['cards'].isEmpty) {
          Map<String, dynamic> player = players[i];
          Map<String, dynamic> playerCards = player['cards'];
          int points = player['points'];
          Map<String, dynamic> drawnCards =
              Map.fromEntries(drawPile.entries.take(6));
          playerCards.addAll(drawnCards);
          drawPile.removeWhere((key, value) => drawnCards.containsKey(key));
          await lobbyCollection.doc(lobbyId).update({
            'player${i + 1}.cards': playerCards,
            'player${i + 1}.points': FieldValue.increment(points + 10),
            'drawPile': drawPile,
          });
          drawPileIsEmpty(player);
          break;
        }
      //}
    }
  }

  Future endGameHandNotEmpty() async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    List<Map<String, dynamic>> players = returnMap['players'];
    for (int i = 0; i < players.length; i++) {
      Map<String, dynamic> playersCards = players[i]['cards'];
      if (players[i]['cards'].isNotEmpty) {
        int cardsCount = players[i]['cards'].length;
        int antiCardCount = 0;
        playersCards.forEach((key, card) async {
          if (card['color'] == 'Anti Joker') {
            antiCardCount += 1;
            await lobbyCollection.doc(lobbyId).update({
              'player${i + 1}.points':
                  FieldValue.increment(-1 * (cardsCount + antiCardCount * 9)),
            });
          }
        });
      }
    }
  }

  Future<void> moveToDiscardPile(
      MapEntry<String, dynamic> choosedCard, User user) async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    List<Map<String, dynamic>> players = returnMap['players'];
    for (int i = 0; i < players.length; i++) {
      if (players[i]['uid'] == user.uid) {
        return await lobbyCollection.doc(lobbyId).update({
          'player${i + 1}.cards.${choosedCard.key}': FieldValue.delete(),
          'discardPile.${choosedCard.key}': choosedCard.value,
        });
      }
    }
  }

  Future<void> incresePassCount() async {
    return await lobbyCollection.doc(lobbyId).update({
      'passCount': FieldValue.increment(1),
    });
  }

  Future<void> setPassCount() async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    int currentPlayerCount = returnMap['documentSnapshot'].data()['currentPlayerCount'];
    return await lobbyCollection.doc(lobbyId).update({
      'passCount': currentPlayerCount,
    });
  }
  Future<void> decreaseActivePlayerPoint() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    List<Map<String, dynamic>> players = returnMap['players'];
    for (int i = 0; i < players.length; i++) {
      if (players[i]['uid'] == uid) {
        return await lobbyCollection.doc(lobbyId).update({
          'player${i + 1}.points': FieldValue.increment(-2),
        });
      }
    }
  }

  Future<void> checkActivePlayer() async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    List<Map<String, dynamic>> players = returnMap['players'];
    Map<String, dynamic> lobby = returnMap['documentSnapshot'].data();
    int idx = 0;
    bool foundActive = false;
    if (lobby['passCount'] >= lobby['currentPlayerCount']) {
      isHandEmpty();
      while (idx < lobby['currentPlayerCount'] && !foundActive) {
        if (players[idx]['isActive']) {
          foundActive = true;
        } else {
          idx++;
        }
      }
      if (idx <= 2) {
        if (players[idx + 1]['uid'] != '') {
          Map<String, dynamic> nextPlayer = players[idx + 1];
          await lobbyCollection.doc(lobbyId).update({
            'activePlayer': nextPlayer['uid'],
            'passCount': 0,
            'player${idx + 2}.isActive': true,
            'player${idx + 1}.isActive': false,
          });
          return;
        } else {
          await lobbyCollection.doc(lobbyId).update({
            'activePlayer': players[0]['uid'],
            'passCount': 0,
            'player1.isActive': true,
            'player${idx + 1}.isActive': false,
          });
          return;
        }
      } else {
        await lobbyCollection.doc(lobbyId).update({
          'activePlayer': players[0]['uid'],
          'passCount': 0,
          'player1.isActive': true,
          'player${idx + 1}.isActive': false,
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
    Map<String, dynamic> drawPile,
    Map<String, dynamic> discardPile,
    Map<String, dynamic> deck,
    String activePlayer,
    String liedColor,
    int liedNumber,
    Map<String, dynamic> choosedCard,
    int passCount,
    String oppoentId,
    String lastCardPlayer,
      String winnerId,
      String answer,
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
      'drawPile': drawPile,
      'discardPile': discardPile,
      'deck': deck,
      'activePlayer': activePlayer,
      'liedColor': liedColor,
      'liedNumber': liedNumber,
      'choosedCard': choosedCard,
      'passCount': passCount,
      'opponentId': oppoentId,
      'lastCardPlayer': lastCardPlayer,
      'winnerId': winnerId,
      'answer': answer,
    });
  }
}
