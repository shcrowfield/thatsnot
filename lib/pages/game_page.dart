import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thatsnot/alert_dialogs/end_alert_dialog.dart';
import 'package:thatsnot/alert_dialogs/lie_alert_dialog.dart';
import 'package:thatsnot/alert_dialogs/result_alert_dialog.dart';
import 'package:thatsnot/alert_dialogs/say_alert_dialog.dart';
import 'package:thatsnot/button_style.dart';
import 'package:thatsnot/language.dart';
import 'package:thatsnot/lobby_manager.dart';
import 'package:thatsnot/pages/start_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thatsnot/services/database.dart';

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
  late DatabaseService db;
  StreamSubscription<DocumentSnapshot>? _choosedCardSubscription;
  StreamSubscription<DocumentSnapshot>? _lobbySubscription;
  bool _isResultDialogShowing = false;
  bool _isEndDialogShowing = false;
  bool _isGameStarted = false;
  bool _hasPassedThisTurn = false;
  bool _ableToPutDownCard = true;
  bool _gameEndHandled = false;
  bool _isInitialDataLoaded = false;
  String _currentActivePlayer = '';
  Timer? t;
  int _remainingSeconds = 20;
  String _currentBg = 'assets/images/bg.png';
  late Timer _bgTimer;
  bool _isGifShowing = false;
  final List<String> _bgGifs = [
    'assets/images/left_gif.gif',
    'assets/images/right_gif.gif',
    'assets/images/two_gif.gif',
  ];
  String _previousChoosedCardId = '';

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
    db = DatabaseService(lobbyId: widget.lobbyId);
    _setupChoosedCardSubscription();
    _setupLobbySubscription();
    _startBackgroundChange();
  }

  void _startBackgroundChange() {
    _bgTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!_isGifShowing) {
        String randomGif = _bgGifs[Random().nextInt(_bgGifs.length)];
        setState(() {
          _currentBg = randomGif;
          _isGifShowing = true;
        });
        Timer(const Duration(seconds: 1), () {
          setState(() {
            _currentBg = 'assets/images/bg.png';
            _isGifShowing = false;
          });
        });
      }
    });
  }

  Future<bool> canPass() async {
    var lobby = await _getLobbyData();
    String activePlayer = lobby['activePlayer'];
    bool isPlayerTurn = activePlayer == widget.user?.uid;
    return !isPlayerTurn && !_hasPassedThisTurn;
  }

  void _handlePass() async {
    bool canPassNow = await canPass();
    if (canPassNow) {
      setState(() {
        _hasPassedThisTurn = true;
      });
      await db.incresePassCount();
      await db.checkActivePlayer();
    }
  }

  void _setupLobbySubscription() {
    _lobbySubscription = FirebaseFirestore.instance
        .collection('lobbies')
        .doc(widget.lobbyId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        String newActivePlayer = snapshot.get('activePlayer');
        if (newActivePlayer != _currentActivePlayer) {
          setState(() {
            _currentActivePlayer = newActivePlayer;
            _hasPassedThisTurn = false;
            _ableToPutDownCard = true;
          });
        }
        String answer = snapshot.get('answer');
        Map<String, dynamic> drawPile = snapshot.get('drawPile') ?? [];

        if (answer != '' && !_isResultDialogShowing) {
          _showResultDialog();
        }

        if (!_isGameStarted && drawPile.isNotEmpty) {
          setState(() {
            _isGameStarted = true;
            _isInitialDataLoaded = true;
          });
        }

        if (_isInitialDataLoaded) {
          _checkGameEnd(drawPile);
        }
      }
    });
  }

  void _checkGameEnd(Map<String, dynamic> drawPile) {
    if (_isGameStarted && drawPile.isEmpty && !_gameEndHandled) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            if (!_gameEndHandled) {
              _gameEndHandled = true;
              _showEndAlertDialog();
            }
          });
        }
      });
    }
  }

  void _showResultDialog() {
    if (!_isResultDialogShowing) {
      _isResultDialogShowing = true;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ResultAlertDialog(
          lobbyId: widget.lobbyId,
        ),
      ).then((_) {
        _isResultDialogShowing = false;
      });
    }
  }

  void _showEndAlertDialog() {
    setState(() {
      _isEndDialogShowing = true;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EndAlertDialog(
        lobbyId: widget.lobbyId,
      ),
    ).then((_) {
      setState(() {
        _isEndDialogShowing = false;
      });
    });
  }

  Future<void> _setupChoosedCardSubscription() async {
    _choosedCardSubscription = FirebaseFirestore.instance
        .collection('lobbies')
        .doc(widget.lobbyId)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.exists) {
        Map<String, dynamic> choosedCard = snapshot.get('choosedCard');
        String activePlayer = snapshot.get('activePlayer');
        Map<String, dynamic> drawPile = snapshot.get('drawPile');

        if (choosedCard.isNotEmpty &&
            choosedCard.keys.first != _previousChoosedCardId &&
            activePlayer != widget.user?.uid) {
          _previousChoosedCardId = choosedCard.keys.first;
          _showCardDownGif();
        }

        t?.cancel();
        if (drawPile.isEmpty) return;
        setState(() {
          _remainingSeconds = 30;
        });
        t = Timer.periodic(const Duration(seconds: 1), (timer) async {
          setState(() {
            _remainingSeconds--;
          });
          if (_remainingSeconds <= 0) {
            t?.cancel();
            t = null;
            Navigator.popUntil(
                context, (route) => route.settings.name == '/game');
            if (activePlayer == widget.user?.uid) {
              if (choosedCard.isEmpty) {
                await db.decreaseActivePlayerPoint();
              }
              await db.restoreOpponentId();
              await db.setPassCount();
              await db.checkActivePlayer();
            }
          }
        });
      }
    });
  }

  void _showCardDownGif() {
    setState(() {
      _currentBg = 'assets/images/card_down.gif';
      _isGifShowing = true;
    });
    Timer(const Duration(seconds: 1), () {
      setState(() {
        _currentBg = 'assets/images/bg.png';
        _isGifShowing = false;
      });
    });
  }

  @override
  dispose() {
    super.dispose();
    _choosedCardSubscription?.cancel();
    t?.cancel();
    _lobbySubscription?.cancel();
    _bgTimer.cancel();
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
    String lastCardPlayer = lobby['lastCardPlayer'];
    bool isThereFirstCard = lobby['choosedCard'].isNotEmpty;
    bool isPlayerTurn = activePlayer == uid;
    bool isLastCardPlayer = lastCardPlayer == uid;
    if (isThereFirstCard && !isPlayerTurn && !isLastCardPlayer) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(languageMap['AnotherSaidLie'] ?? ''),
          ),
        );
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
          builder: (BuildContext dialogContext) => LieAlertDialog(
            lobbyId: widget.lobbyId,
            colorMatch: colorMatch,
            numberMatch: numberMatch,
          ),
        );
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
      List<dynamic> dynamicPlayers = snapshot['players'];
      List<Map<String, dynamic>> players = dynamicPlayers
          .map((player) => player as Map<String, dynamic>)
          .toList();
      Map<String, dynamic>? player = players.firstWhere(
        (player) => player['uid'] == uid,
        orElse: () => <String, dynamic>{},
      );
      yield player['points'] ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        key: ValueKey<String>(_currentBg),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_currentBg),
            fit: BoxFit.cover,
          ),
        ),
      ),
      Scaffold(
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
                            '${languageMap['YourPoints']}: ${pointSnapshot.data}',
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
                          lobbyData['currentPlayerCount'] ?? 0);
                      LobbyManager.decreseIsReady(widget.lobbyId);
                      LobbyManager.decresePlayerLimit(widget.lobbyId);
                      onStartNext();
                    },
                    label: Text(languageMap['Exit'] ?? '',
                        style: const TextStyle(fontSize: 20)),
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
                    if (snapshot.hasData && snapshot.data!.exists) {
                      String liedColor =
                          snapshot.data!.get('liedColor') as String? ?? '';
                      String liedNumber =
                          (snapshot.data!.get('liedNumber') ?? '').toString();
                      return Padding(
                        padding: const EdgeInsets.only(right: 220),
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
                                              '${languageMap['Player'] ?? ''}: ${activePlayerSnapshot.data}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        );
                                      } else {
                                        return Text(
                                            languageMap['Loading'] ?? '');
                                      }
                                    },
                                  ),
                                  Text(
                                    liedNumber == '0'
                                        ? ''
                                        : '${languageMap[liedColor] ?? ''} $liedNumber',
                                    style: TextStyle(
                                      color: liedColor == 'Orange'
                                          ? Colors.orange
                                          : liedColor == 'Purple'
                                              ? Colors.purple
                                              : Colors.black,
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
                      return Text(languageMap['Loading'] ?? '');
                    }
                  },
                ),
              ],
            )),
            Expanded(
              child: Container(
                color: Colors.transparent,
                child: Center(
                    child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await lieButtonIsActive(widget.user!.uid)
                            ? lieButton()
                            : ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      languageMap['NotAllowToSayLie'] ?? ''),
                                ),
                              );
                      },
                      style: sideButtonStyle,
                      child: Text(languageMap['LIE'] ?? ''),
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
                            return Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: cardList.length,
                                itemBuilder: (context, index) {
                                  return SizedBox(
                                    width: sizes(context)['cardWidth'],
                                    height: sizes(context)['cardHeight'],
                                    child: InkWell(
                                      onTap: () async {
                                        final lobbyData = await _getLobbyData();
                                        final bool isNotAllowed =
                                            lobbyData['lastCardPlayer'] ==
                                                    widget.user!.uid ||
                                                lobbyData['activePlayer'] !=
                                                    widget.user!.uid ||
                                                !_ableToPutDownCard;
                                        if (isNotAllowed) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(languageMap[
                                                      'YouHaveAlreadyChoosedACard'] ??
                                                  ''),
                                            ),
                                          );
                                        } else {
                                          //_ableToPutDownCard = false;
                                          choosedCard = cardList[index];
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  SayAlertDialog(
                                                    onButtonPressed: () {
                                                      setState(() {
                                                        _ableToPutDownCard = false;
                                                      });
                                                    },
                                                    lobbyId: widget.lobbyId,
                                                    user: widget.user,
                                                    choosedCard: choosedCard,
                                                  ),
                                              routeSettings:
                                                  const RouteSettings(
                                                      name: 'SayAlertDialog'));

                                        }
                                      },
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                            '${cardList[index].value['image']}',
                                            height:
                                                sizes(context)['screenHeight'] *
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
                          return Text(languageMap['YourHandIsEmpty'] ?? '');
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: InkWell(
                          onTap: () async {
                            await db.drawCard(widget.user!.uid);
                          },
                          child: Image.asset(
                            'assets/images/draw.png',
                            height: sizes(context)['screenHeight'] * 0.15,
                          )),
                    ),
                    ElevatedButton(
                      onPressed: () => _handlePass(),
                      style: _hasPassedThisTurn || _currentActivePlayer == widget.user?.uid
                          ? disabledSideButtonStyle
                          : sideButtonStyle,
                      child: Text(languageMap['PASS'] ?? ''),
                    ),
                  ],
                )),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}
