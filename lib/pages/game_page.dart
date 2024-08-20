// lib/pages/game_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thatsnot/alert_dialogs/lie_alert_dialog.dart';
import 'package:thatsnot/alert_dialogs/say_alert_dialog.dart';
import 'package:thatsnot/countdown.dart';
import 'package:thatsnot/pages/start_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thatsnot/services/database.dart';
import 'package:timer_count_down/timer_controller.dart';
import '../lobby_manager.dart';

class GamePage extends StatefulWidget {
  final String lobbyId;
  final User? user;

  const GamePage({super.key, required this.lobbyId, this.user});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final CountdownController _controller = CountdownController(autoStart: false);

  Map<String, dynamic> sizes(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final buttonWidth = screenWidth * 0.23;
    final buttonHeight = screenHeight * 0.1;
    final textSize = screenWidth * 0.02;
    final cardWidth = screenWidth * 0.13;
    final cardHeight = screenHeight * 0.3;
    return {
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
      'buttonWidth': buttonWidth,
      'buttonHeight': buttonHeight,
      'textSize': textSize,
      'cardWidth': cardWidth,
      'cardHeight': cardHeight,
    };
  }

  MapEntry<String, dynamic> choosedCard = const MapEntry('', '');

  @override
  initState() {
    super.initState();
    DatabaseService(lobbyId: widget.lobbyId)
        .updateDeck();
    DatabaseService(lobbyId: widget.lobbyId)
        .dealCards();
    DatabaseService(lobbyId: widget.lobbyId)
        .updateDrawPile();
  }

  dispose() {
    super.dispose();
  }

  _getLobbyData() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('lobbies')
        .doc(widget.lobbyId)
        .get();
    var lobby = snapshot.data();
    return lobby;
  }

  bool compareColor(String choosedColor, String liedColor) {
    return choosedColor == liedColor || choosedColor == 'Color 1-9';
  }

  bool compareNumber(int choosedNumber, int liedNumber) {
    return choosedNumber == liedNumber || choosedNumber == 0;
  }

  onStartNext() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const StartPage()));
  }

  Stream<Map<String, dynamic>?> getCards(String uid) async* {
    Map<String, dynamic> returnMap =
        await LobbyManager.getPlayersList(widget.lobbyId);
    List<Map<String, dynamic>> players = returnMap['players'];
    for (int i = 0; i < players.length; i++) {
      if (players[i]['uid'] == uid) {
        yield players[i]['cards'];
      }
    }
  }

  Future<bool> LieButtonIsActive(String uid) async {
    var lobby = await _getLobbyData();
    String activePlayer = lobby['activePlayer'];
    bool isThereFirstCard = lobby['choosedCard'].isNotEmpty;
    bool isPlayerTurn = activePlayer == uid;
    if (isThereFirstCard && isPlayerTurn) {
      return true;
    } else {
      return false;
    }
  }

  void buttonIsAcive() async {
    DatabaseService(lobbyId: widget.lobbyId).updateOpponentId(widget.user!.uid);
    var lobby = await _getLobbyData();
    Map<String, dynamic> choosedCard = lobby['choosedCard'];
    String choosedColor = choosedCard.values.first['color'];
    bool colorMatch = compareColor(choosedColor, lobby['liedColor']);
    int choosedNumber = choosedCard.values.first['number'];
    bool numberMatch = compareNumber(choosedNumber, lobby['liedNumber']);
    showDialog(
        context: context,
        builder: (context) => LieAlertDialog(
            lobbyId: widget.lobbyId,
            lobby: lobby,
            colorMatch: colorMatch,
            numberMatch: numberMatch,
            onButtonPressed: reBuild));
  }

  Future getActivePlayerName(String activePlayerId) async {
    var lobby = await _getLobbyData();
    String activePlayerId = lobby['activePlayer'];
    Map<String, dynamic> returnMap =
        await LobbyManager.getPlayersList(widget.lobbyId);
    List<Map<String, dynamic>> players = returnMap['players'];
    for (int i = 0; i < players.length; i++) {
      if (players[i]['uid'] == activePlayerId) {
        return players[i]['name'];
      }
    }
  }

  Future getPlayerPoints(String uid) async {
    Map<String, dynamic> returnMap =
        await LobbyManager.getPlayersList(widget.lobbyId);
    List<Map<String, dynamic>> players = returnMap['players'];
    for (int i = 0; i < players.length; i++) {
      if (players[i]['uid'] == uid) {
        return players[i]['points'];
      }
    }
  }

  void reBuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 15),
          TextButton.icon(
            onPressed: () async {
              var lobbyData = await _getLobbyData();
              LobbyManager.checkPlayerMap(
                  widget.lobbyId, widget.user, lobbyData['currentPlayerCount']);
              LobbyManager.decreseIsReady(widget.lobbyId);
              LobbyManager.decresePlayerLimit(widget.lobbyId);
              onStartNext();
            },
            icon: const Icon(Icons.settings),
            label: const Text('Menu'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.deepPurple,
            ),
          ),
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('lobbies')
                    .doc(widget.lobbyId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    String activePlayerId = snapshot.data?['activePlayer'];
                    return FutureBuilder(
                      future: getActivePlayerName(activePlayerId),
                      builder: (context, activePlayerSnapshot) {
                        if (activePlayerSnapshot.hasData) {
                          return Column(
                            children: [
                              Text(
                                  'Aktív játékos: ${activePlayerSnapshot.data}'),
                              FutureBuilder(
                                  future: getPlayerPoints(widget.user!.uid),
                                  builder: (context, pointSnapshot) {
                                    if (pointSnapshot.hasData) {
                                      return Text(
                                          'Pontok Lacikám: ${pointSnapshot.data}');
                                    } else {
                                      return Text('Loading...');
                                    }
                                  }),
                            ],
                          );
                        } else {
                          return Text('Loading...');
                        }
                      },
                    );
                  } else {
                    return Text('Loading...');
                  }
                },
              ),
              Column(
                children: [
                  CountDown(controller: _controller),
                  ElevatedButton(
                      onPressed: () => _controller.start(),
                      child: const Text('start')),
                  ElevatedButton(
                      onPressed: () async {
                        await DatabaseService(lobbyId: widget.lobbyId)
                            .drawCard();
                        reBuild();
                      },
                      child: const Text('DRAW')),
                ],
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('lobbies')
                    .doc(widget.lobbyId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    String liedColor = snapshot.data?['liedColor'];
                    String? liedNumber =
                        snapshot.data?['liedNumber'].toString();
                    return Text('Bemondott: $liedColor $liedNumber');
                  } else {
                    return Text('Loading...');
                  }
                },
              ),
            ],
          )),
          Expanded(
            //alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.deepOrangeAccent,
              child: Center(
                  child: SizedBox(
                height: sizes(context)['screenHeight'] * 0.5,
                child: Row(
                  children: [
                    Column(
                      children: [
                        ElevatedButton(
                            onPressed: reBuild,
                            child: const Icon(Icons.refresh)),
                        ElevatedButton(
                            onPressed: () async {
                              await LieButtonIsActive(widget.user!.uid)
                                  ? buttonIsAcive()
                                  : print(
                                      'Te vagy az aktív játékos vagy nincs kártya kiválasztva');
                            },
                            child: const Text('LIE')),
                      ],
                    ),
                    Expanded(
                      child: StreamBuilder<Map<String, dynamic>?>(
                        stream: getCards(widget.user!.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            Map<String, dynamic> userCards = snapshot.data!;
                            List<MapEntry<String, dynamic>> cardList =
                                userCards.entries.toList();
                            return SizedBox(
                              width: double.infinity,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: cardList.length,
                                itemBuilder: (context, index) {
                                  return SizedBox(
                                    width: sizes(context)['cardWidth'],
                                    height: sizes(context)['cardHeight'],
                                    child: InkWell(
                                      onTap: () {
                                        choosedCard = cardList[index];
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                SayAlertDialog(
                                                  lobbyId: widget.lobbyId,
                                                  user: widget.user,
                                                  choosedCard: choosedCard,
                                                  onButtonPressed: reBuild,
                                                ));
                                        reBuild();
                                      },
                                      child: Card(
                                        color: Colors.black,
                                        child: Center(
                                          child: Image.asset(
                                            '${cardList[index].value['image']}',
                                            width: sizes(context)['cardWidth'] *
                                                1.2,
                                            height:
                                                sizes(context)['cardHeight'] *
                                                    1.2,
                                          ),
                                          /*Column(
                                                children: [
                                                  Text(cardList[index].value['color']),
                                                  Text(cardList[index]
                                                      .value['number']
                                                      .toString()),
                                                ],
                                              ),*/
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                          return const Text('Üres a kezed');
                        },
                      ),
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              await DatabaseService(lobbyId: widget.lobbyId)
                                  .incresePassCount();
                              await DatabaseService(lobbyId: widget.lobbyId)
                                  .checkActivePlayer();
                              reBuild();
                            },
                            child: const Text('PASSZ')),
                      ],
                    ),
                  ],
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
