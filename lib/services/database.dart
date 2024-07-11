import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thatsnot/lobby_manager.dart';
import 'package:thatsnot/models/card.dart';
import 'package:thatsnot/models/player.dart';

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
        int posCompare = deck?[key1]['position'].compareTo(deck[key2]['position']);
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

      List<String> cardKeys = sortedDeck.keys.toList().sublist(startIdx, endIdx);
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

  Future updateDrawPile() async {
    var returnMap = await LobbyManager.getPlayersList(lobbyId);
    var documentSnapshot = returnMap['documentSnapshot'];
    Map<String, dynamic>? lobby = documentSnapshot.data();
    Map<String, dynamic> deck = lobby?['deck'];
    Map<String, dynamic> updatedDrawPile = {};
    int pileCount = 0;
    int count = 0;
    lobby?['playerLimit'] == 2 ? pileCount = 45 : pileCount = 65;

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

  Future updateLies(String liedColor, int liedNumber, MapEntry<String, dynamic> choosedcard) async {
    final choosedcardMap = {
      choosedcard.key: choosedcard.value,
    };
    return await lobbyCollection.doc(lobbyId).update({
      'liedColor': liedColor,
      'liedNumber': liedNumber,
      'choosedCard': choosedcardMap,
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
    int isReady,
    Map<String, dynamic> drawPile,
    Map<String, dynamic> discardPile,
    Map<String, dynamic> deck,
    String activePlayer,
      String liedColor,
      int liedNumber,
      Map<String, dynamic> choosedCard,
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
    });
  }
}
