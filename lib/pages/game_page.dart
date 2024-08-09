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

  MapEntry<String, dynamic> choosedCard = const MapEntry('', '');

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

  Future<Map<String, dynamic>?> getCards(String uid) async {
    Map<String, dynamic> returnMap =
    await LobbyManager.getPlayersList(widget.lobbyId);
    List<Map<String, dynamic>> players = returnMap['players'];
    Map<String, dynamic>? playerCards = {};
    for (int i = 0; i < players.length; i++) {
      if (players[i]['uid'] == uid) {
        playerCards = players[i]['cards'];
      }
    }
    return playerCards;
  }

  Future<bool> playerIsActive(String uid) async {
    var lobby = await _getLobbyData();
    String activePlayer = lobby['activePlayer'];
    return activePlayer == uid;
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
            numberMatch: numberMatch));
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
            onPressed: () {
              onStartNext();
            },
            icon: const Icon(Icons.settings),
            label: const Text('Menu'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.deepPurple,
            ),
          ),
          Expanded(
              child: Column(
                children: [
                  CountDown(controller: _controller),
                  ElevatedButton(
                      onPressed: () => _controller.start(),
                      child: const Text('start')),
                  ElevatedButton(
                      onPressed: () async {
                        await DatabaseService(lobbyId: widget.lobbyId).drawCard();
                      },
                      child: const Text('DRAW')),
                ],
              )),
          Expanded(
            //alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.deepOrangeAccent,
              child: Center(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          ElevatedButton(
                              onPressed: reBuild, child: const Text('Ossz')),
                          ElevatedButton(
                              onPressed: () async {
                                await playerIsActive(widget.user!.uid)
                                    ? print('Te vagy az aktív játékos')
                                    : buttonIsAcive();
                              },
                              child: const Text('LIE')),
                        ],
                      ),
                      Expanded(
                        child: FutureBuilder<Map<String, dynamic>?>(
                          future: getCards(widget.user!.uid),
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
                                      width: MediaQuery.of(context).size.width /
                                          cardList.length,
                                      child: InkWell(
                                        onTap: () {
                                          choosedCard = cardList[index];
                                          showDialog(
                                              context: context,
                                              builder: (context) => SayAlertDialog(
                                                lobbyId: widget.lobbyId,
                                                user: widget.user,
                                                choosedCard: choosedCard,
                                              ));
                                        },
                                        child: Card(
                                          child: Column(
                                            children: [
                                              Text(cardList[index].value['color']),
                                              Text(cardList[index]
                                                  .value['number']
                                                  .toString()),
                                            ],
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
                              },
                              child: const Text('PASSZ')),
                        ],
                      ),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }
}