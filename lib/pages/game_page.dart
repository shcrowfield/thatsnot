import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thatsnot/alert_dialogs/lie_alert_dialog.dart';
import 'package:thatsnot/alert_dialogs/say_alert_dialog.dart';
import 'package:thatsnot/button_style.dart';
import 'package:thatsnot/countdown.dart';
import 'package:thatsnot/models/card.dart';
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
  bool _initialized = false;

  Map<String, dynamic> sizes(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final buttonWidth = screenWidth * 0.23;
    final buttonHeight = screenHeight * 0.1;
    final textSize = screenWidth * 0.02;
    //final cardWidth = screenWidth * 0.10;
    // final cardHeight = screenHeight * 0.2;
    return {
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
      'buttonWidth': buttonWidth,
      'buttonHeight': buttonHeight,
      'textSize': textSize,
      //'cardWidth': cardWidth,
      //'cardHeight': cardHeight,
    };
  }

  MapEntry<String, dynamic> choosedCard = const MapEntry('', '');

  @override
  initState() {
    super.initState();
    // cardsStream = getCards(widget.user!.uid);
  }

  @override
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
    if (!_initialized) {
      await DatabaseService(lobbyId: widget.lobbyId).updateDeck();
      await DatabaseService(lobbyId: widget.lobbyId).dealCards();
      await DatabaseService(lobbyId: widget.lobbyId).updateDrawPile();
      Map<String, dynamic> returnMap =
          await LobbyManager.getPlayersList(widget.lobbyId);
      List<Map<String, dynamic>> players = returnMap['players'];
      for (int i = 0; i < players.length; i++) {
        if (players[i]['uid'] == uid) {
          yield players[i]['cards'];
        }
      }
      _initialized = true;
    } else {
      Map<String, dynamic> returnMap =
          await LobbyManager.getPlayersList(widget.lobbyId);
      List<Map<String, dynamic>> players = returnMap['players'];
      for (int i = 0; i < players.length; i++) {
        if (players[i]['uid'] == uid) {
          yield players[i]['cards'];
        }
      }
    }
  }

  Future<bool> lieButtonIsActive(String uid) async {
    var lobby = await _getLobbyData();
    String activePlayer = lobby['activePlayer'];
    bool isThereFirstCard = lobby['choosedCard'].isNotEmpty;
    bool isPlayerTurn = activePlayer == uid;
    if (isThereFirstCard && !isPlayerTurn) {
      return true;
    } else {
      return false;
    }
  }

  void lieButton() async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot lobbyDoc = await transaction.get(FirebaseFirestore
            .instance
            .collection('lobbies')
            .doc(widget.lobbyId));

        if (lobbyDoc.get('opponentId') != '' && lobbyDoc.get('opponentId') != widget.user?.uid) {
          showDialog(
              context: context,
              builder: (context) => const AlertDialog(
                    title: Text('Már valaki más mond'),
                  ));
          return;
        }
        transaction.update(
          lobbyDoc.reference,
          {
            'opponentId': widget.user!.uid,
          },
        );
        Map<String, dynamic> choosedCard = lobbyDoc.get('choosedCard');
        String choosedColor = choosedCard.values.first['color'];
        bool colorMatch = compareColor(choosedColor, lobbyDoc.get('liedColor'));
        int choosedNumber = choosedCard.values.first['number'];
        bool numberMatch =
            compareNumber(choosedNumber, lobbyDoc.get('liedNumber'));
        showDialog(
            context: context,
            builder: (context) => LieAlertDialog(
                lobbyId: widget.lobbyId,
                lobby: lobbyDoc.data() as Map<String, dynamic>,
                colorMatch: colorMatch,
                numberMatch: numberMatch,
                onButtonPressed: reBuild));
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future getActivePlayerName() async {
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

  late Stream<Map<String, dynamic>?> cardsStream;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FutureBuilder(
                      future: getPlayerPoints(widget.user!.uid),
                      builder: (context, pointSnapshot) {
                        if (pointSnapshot.hasData) {
                          return Text(
                            'Pontjaid: ${pointSnapshot.data}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          );
                        } else {
                          return const Text('Loading...');
                        }
                      }),
                  TextButton.icon(
                    onPressed: () async {
                      var lobbyData = await _getLobbyData();
                      LobbyManager.checkPlayerMap(widget.lobbyId, widget.user,
                          lobbyData['currentPlayerCount']);
                      LobbyManager.decreseIsReady(widget.lobbyId);
                      LobbyManager.decresePlayerLimit(widget.lobbyId);
                      onStartNext();
                    },
                    label:
                        const Text('Kilépés', style: TextStyle(fontSize: 20)),
                    icon: const Icon(Icons.arrow_forward),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //const Spacer(),
                /*CountDown(controller: _controller),
                    ElevatedButton(
                        onPressed: () => _controller.start(),
                        child: const Text('start')),*/

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
                      return Padding(
                        padding: const EdgeInsets.only(right: 100),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  FutureBuilder(
                                    future: getActivePlayerName(),
                                    builder: (context, activePlayerSnapshot) {
                                      if (activePlayerSnapshot.hasData) {
                                        return Column(
                                          children: [
                                            Text(
                                              'Soron lévő játékos: ${activePlayerSnapshot.data}',
                                              style: const TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        );
                                      } else {
                                        return const Text('Loading...');
                                      }
                                    },
                                  ),
                                  Text(
                                    'Bemondott: $liedColor $liedNumber',
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Text('Loading...');
                    }
                  },
                ),
                const Spacer(),
                InkWell(
                    onTap: () async {
                      await DatabaseService(lobbyId: widget.lobbyId)
                          .drawCard(widget.user!.uid);
                      //reBuild();
                    },
                    child: Image.asset(
                      'assets/images/draw.webp',
                      height: sizes(context)['screenHeight'] * 0.07,
                    )),
              ],
            )),
            Expanded(
              //alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.transparent,
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
                              await lieButtonIsActive(widget.user!.uid)
                                  ? lieButton()
                                  : ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Te vagy az aktív játékos vagy nincs kártya az asztalon'),
                                      ),
                                    );
                            },
                            child: const Text('LIE'),
                          ),
                        ],
                      ),
                      Expanded(
                        child: StreamBuilder<Map<String, dynamic>?>(
                          stream: getCards(widget.user!.uid),
                          builder: (context, snapshot) {
                            ('snapshot: $snapshot');
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
                                        onTap: () async {
                                          final lobbyData =
                                              await _getLobbyData();
                                          final bool isNotAllowed =
                                              lobbyData['lastCardPlayer'] == widget.user!.uid ||
                                                  lobbyData['activePlayer'] != widget.user!.uid;
                                          if (isNotAllowed) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Már tettél le lapot vagy nem te vagy soron'),
                                              ),
                                            );
                                          } else {
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
                                          }
                                        },
                                        //child: Card(
                                        //color: Colors.black,
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset(
                                              '${cardList[index].value['image']}',
                                              /*width: sizes(context)['screenWidth'] *
                                                    0.13,*/
                                              height: sizes(
                                                      context)['screenHeight'] *
                                                  0.29,
                                            ),
                                          ),
                                        ),
                                        //),
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
      ),
    );
  }
}
