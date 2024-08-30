import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thatsnot/lobby_manager.dart';
import 'package:thatsnot/models/card.dart';
import 'package:thatsnot/models/player.dart';
import 'package:thatsnot/services/leaderboard.dart';

class DatabaseService {
  String lobbyId;

  DatabaseService({required this.lobbyId});

  final CollectionReference lobbyCollection =
      FirebaseFirestore.instance.collection('lobbies');

  Future updateDeck() async {
    Map<String, dynamic> originalMap = shuffleCards();
    Map<String, dynamic> updatedDeck = {};
    int count = 0;
    originalMap.forEach((key, value) {
      if (count < cardsMap.length) {
        updatedDeck[key] = value;
        count++;
      }
    });
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
    batch.update(lobbyDoc, updates);
    await batch.commit();

    if (lobby?['deck'] != null) {
      Map<String, dynamic> deck = lobby?['deck'];
      deck.removeWhere((key, value) => value['position'] < totalCards + 1);
    }
  }

  Future<void> updateDrawPile() async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    var documentSnapshot = returnMap['documentSnapshot'];
    Map<String, dynamic>? lobby = documentSnapshot.data();
    Map<String, dynamic> deck = lobby?['deck'];
    Map<String, dynamic> updatedDrawPile = {};
    int pileCount = 0;
    int count = 0;
    lobby?['playerLimit'] == 2 ? pileCount = /*45*/ 20 : pileCount = 65;

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

    var sortedCards = SplayTreeMap<String, dynamic>.from(
      drawPile ?? {},
      (key1, key2) {
        int posCompare =
            drawPile?[key1]['position'].compareTo(drawPile[key2]['position']);
        return posCompare;
      },
    );
    return sortedCards;
  }

  Future<void> drawCard() async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    var documentSnapshot = returnMap['documentSnapshot'];
    Map<String, dynamic>? lobby = documentSnapshot.data();
    List<Map<String, dynamic>> players = returnMap['players'];
    Map<String, dynamic> sortedDrawPile = await sortDrawPile();

    for (int i = 0; i < players.length; i++) {
      if (players[i]['uid'] == lobby?['activePlayer']) {
        Map<String, dynamic> player = players[i];
        Map<String, dynamic> playerCards = player['cards'];
        MapEntry<String, dynamic> drawCard = sortedDrawPile.entries.first;
        playerCards[drawCard.key] = drawCard.value;
        player['cards'] = playerCards;
        sortedDrawPile.remove(drawCard.key);
        await lobbyCollection.doc(lobbyId).update({
          'player${i + 1}.cards': playerCards,
          'drawPile': sortedDrawPile,
        });
        drawPileIsEmpty(player);
        break;
      }else{
        print('Nem a te köröd van');
      }
    }
  }

  Future<void> drawPileIsEmpty(Map<String, dynamic> player) async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    var documentSnapshot = returnMap['documentSnapshot'];
    Map<String, dynamic>? lobby = documentSnapshot.data();
    Map<String, dynamic>? drawPile = lobby?['drawPile'];
    if (drawPile!.isEmpty) {
      endGameHandNotEmpty();
      if(player['points'] != 0){
        updateLeaderBoard(player);
      }
      print('Vége a Játéknak');
    }
  }

  Future updateLeaderBoard(player) async {
      LeaderboardService(player).newOrExistingUser(player['uid'], player['name'], player['points']);
  }

  Future<void> updatePlayer(Player player, int currentPlayerCount) async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    List<Map<String, dynamic>> players = returnMap['players'];
    int randomDelay = Random().nextInt(500) + 100;

    for (int i = 0; i < players.length; i++) {
      if (players[i]['uid'] == '') {
        await Future.delayed(Duration(milliseconds: randomDelay));
        return await lobbyCollection.doc(lobbyId).update({
          'currentPlayerCount': currentPlayerCount + 1,
          'player${i + 1}': player.toMap()
        });
      }
    }
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

  Future<void> updateLastCardPlayer(String lastCardPlayer) async {
    return await lobbyCollection.doc(lobbyId).update({
      'lastCardPlayer': lastCardPlayer,
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
          'discardPile': {},
          'choosedCard': {},
        });
      }
    }
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
        return await lobbyCollection.doc(lobbyId).update({
          'player${i + 1}.cards': loserCards,
          'drawPile': drawPile,
          'activePlayer': uid,
          'opponentId': '',
        });
      }
    }
  }

  Future isHandEmpty(String uid) async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    List<Map<String, dynamic>> players = returnMap['players'];
    Map<String, dynamic> drawPile = await sortDrawPile();
    for (int i = 0; i < players.length; i++) {
      if (players[i]['uid'] == uid) {
        if (players[i]['cards'].isEmpty) {
          Map<String, dynamic> player = players[i];
          Map<String, dynamic> playerCards = player['cards'];
          int points = player['points'];
          Map<String, dynamic> drawnCards = Map.fromEntries(drawPile.entries.take(6));
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
      }
    }
  }

  Future endGameHandNotEmpty() async{
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    List<Map<String, dynamic>> players = returnMap['players'];
    for(int i = 0; i < players.length; i++){
      Map<String, dynamic> playersCards = players[i]['cards'];
      if(players[i]['cards'].isNotEmpty){
        int cardsCount = players[i]['cards'].length;
        int antiCardCount = 0;
        for(int j = 0; j < cardsCount; j++){
          if(playersCards[j]['color'] == 'Anti Joker'){
            antiCardCount += 1;
            await lobbyCollection.doc(lobbyId).update({
              'player${i + 1}.points': FieldValue.increment(cardsCount + antiCardCount * 9),
            });

          }
        }
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

  Future<void> checkActivePlayer() async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    List<Map<String, dynamic>> players = returnMap['players'];
    Map<String, dynamic> lobby = returnMap['documentSnapshot'].data();
    int idx = 0;
    bool foundActive = false;
    if (lobby['passCount'] >= lobby['currentPlayerCount']) {
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
    });
  }
}
