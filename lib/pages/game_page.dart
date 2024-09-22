import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thatsnot/alert_dialogs/lie_alert_dialog.dart';
import 'package:thatsnot/alert_dialogs/say_alert_dialog.dart';
import 'package:thatsnot/button_style.dart';
import 'package:thatsnot/language.dart';
import 'package:thatsnot/pages/start_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thatsnot/services/database.dart';
import '../lobby_manager.dart';

class GamePage extends StatefulWidget {
  final String lobbyId;
  final User? user;

  const GamePage({super.key, required this.lobbyId, this.user});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late Stream<Map<String, dynamic>?> _getCardsStream;
  late Stream<DocumentSnapshot> _snapshotStream;
  late Future<int> _passCountFuture;
  late DatabaseService db;
  StreamSubscription<DocumentSnapshot>? _choosedCardSubscription;
  Timer? t;
  int _remainingSeconds = 10;

  Map<String, dynamic> sizes(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final buttonWidth = screenWidth * 0.23;
    final buttonHeight = screenHeight * 0.1;
    final textSize = screenWidth * 0.02;
    return {
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
      'buttonWidth': buttonWidth,
      'buttonHeight': buttonHeight,
      'textSize': textSize,
    };
  }

  MapEntry<String, dynamic> choosedCard = const MapEntry('', '');
  Map<String, dynamic> previousChoosedCard = {};

  @override
  initState() {
    super.initState();
    _getCardsStream = getCards(widget.user!.uid).asBroadcastStream();
    _snapshotStream = FirebaseFirestore.instance
        .collection('lobbies')
        .doc(widget.lobbyId)
        .snapshots()
        .asBroadcastStream();
    _passCountFuture = getPassCount();
    db = DatabaseService(lobbyId: widget.lobbyId);
    _setupChoosedCardSubscription();
  }

  bool _areKeysEqual(Set<String> keys1, Set<String> keys2) {
    if (keys1.length != keys2.length) return false;
    return keys1.every((key) => keys2.contains(key));
  }

  Future<void> _setupChoosedCardSubscription() async {
    _choosedCardSubscription = FirebaseFirestore.instance
        .collection('lobbies')
        .doc(widget.lobbyId)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.exists) {
        Map<String, dynamic> choosedCard = snapshot.get('choosedCard');
        int passCount = snapshot.get('passCount');
        String opponentId = snapshot.get('opponentId') ?? '';
        String activePlayer = snapshot.get('activePlayer');
        int playerLimit = snapshot.get('playerLimit');

        t?.cancel();
        if (choosedCard.isNotEmpty) {
          previousChoosedCard = Map<String, dynamic>.from(choosedCard);

          if (!_areKeysEqual(
              choosedCard.keys.toSet(), previousChoosedCard.keys.toSet())) {
            setState(() {
              _remainingSeconds = 10;
            });
            t = Timer.periodic(const Duration(seconds: 1), (timer) async {
              setState(() {
                _remainingSeconds--;
              });
            });
            if (passCount >= playerLimit ||
                opponentId.isNotEmpty ||
                _remainingSeconds <= 0) {
              t?.cancel();
              t = null;
              if (_remainingSeconds <= 0 && activePlayer == widget.user?.uid) {
                await db.setPassCount();
                await db.checkActivePlayer();
              }
            }
          }
        }
      }
    });
  }

  @override
  dispose() {
    super.dispose();
    _choosedCardSubscription?.cancel();
    t?.cancel();
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
    return choosedColor == liedColor || choosedColor == 'Color Joker';
  }

  bool compareNumber(int choosedNumber, int liedNumber) {
    return choosedNumber == liedNumber || choosedNumber == 0;
  }

  onStartNext() {
    Navigator.pop(
        context, MaterialPageRoute(builder: (context) => const StartPage()));
  }

  Future<int> getPassCount() async {
    var lobby = await _getLobbyData();
    return lobby['passCount'];
  }

  Stream<Map<String, dynamic>?> getCards(String uid) async* {
    await db.updateDeck();
    await db.dealCards();
    await db.updateDrawPile();
    await for (var snapshot
        in LobbyManager.getPlayersListStream(widget.lobbyId)) {
      List<Map<String, dynamic>> players = snapshot['players'];
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
      late DocumentSnapshot lobbyDoc;
      final result =
          await FirebaseFirestore.instance.runTransaction((transaction) async {
        lobbyDoc = await transaction.get(FirebaseFirestore.instance
            .collection('lobbies')
            .doc(widget.lobbyId));

        if (lobbyDoc.get('opponentId') != '' &&
            lobbyDoc.get('opponentId') != widget.user?.uid) {
          return false;
        }
        transaction.update(
          lobbyDoc.reference,
          {
            'opponentId': widget.user!.uid,
          },
        );
        return true;
      });
      if (!result) {
        showDialog(
            context: context,
            builder: (context) => const AlertDialog(
                  title: Text('Már valaki más mond'),
                ));
      } else {
        Map<String, dynamic> choosedCard = lobbyDoc.get('choosedCard');
        String choosedColor = choosedCard.values.first['color'];
        bool colorMatch = compareColor(choosedColor, lobbyDoc.get('liedColor'));
        int choosedNumber = choosedCard.values.first['number'];
        bool numberMatch =
            compareNumber(choosedNumber, lobbyDoc.get('liedNumber'));
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => LieAlertDialog(
                lobbyId: widget.lobbyId,
                colorMatch: colorMatch,
                numberMatch: numberMatch,
                onButtonPressed: reBuild));
      }
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

  Stream getPlayerPoints(String uid) async* {
    await for (var snapshot
        in LobbyManager.getPlayersListStream(widget.lobbyId)) {
      List<Map<String, dynamic>> players = snapshot['players'];
      for (int i = 0; i < players.length; i++) {
        if (players[i]['uid'] == uid) {
          yield players[i]['points'];
        }
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
                  StreamBuilder(
                      stream: getPlayerPoints(widget.user!.uid),
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
                StreamBuilder(
                  stream: _snapshotStream,
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
                                                fontSize: 10,
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
                                    liedNumber == '0'
                                        ? 'Bemondott: '
                                        : 'Bemondott: ${languageMap[liedColor]} $liedNumber',
                                    style: const TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text('$_remainingSeconds'),
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
                      await db.drawCard(widget.user!.uid);
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
                            //style: sideButtonStyle,
                            child: const Text('LIE'),
                          ),
                        ],
                      ),
                      Expanded(
                        child: StreamBuilder<Map<String, dynamic>?>(
                          stream: _getCardsStream,
                          key: const Key('cards'),
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
                                              lobbyData['lastCardPlayer'] ==
                                                      widget.user!.uid ||
                                                  lobbyData['activePlayer'] !=
                                                      widget.user!.uid;
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
                                                      //onButtonPressed: reBuild,
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
                              await db.incresePassCount();
                              await db.checkActivePlayer();
                              reBuild();
                            },
                            style: sideButtonStyle,
                            child: const Text('PASSZ'),
                          ),
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
