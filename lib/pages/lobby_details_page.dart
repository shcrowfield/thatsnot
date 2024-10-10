import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thatsnot/language.dart';
import 'package:thatsnot/lobby_manager.dart';
import 'package:thatsnot/button_style.dart';
import 'package:thatsnot/pages/game_page.dart';
import 'package:thatsnot/pages/lobby_list_page.dart';

class LobbyDetailsPage extends StatefulWidget {
  final String lobbyId;
  final User? user;
  final String nickName;

  const LobbyDetailsPage(
      {super.key, required this.lobbyId, this.user, required this.nickName});

  @override
  State<LobbyDetailsPage> createState() => _LobbyDetailsPageState();
}

class _LobbyDetailsPageState extends State<LobbyDetailsPage> {
  int? currentPlayerCount;
  bool isPressed = false;
  late Stream<DocumentSnapshot> lobbyStream;
  bool _hasNavigated = false;
  late StreamSubscription<DocumentSnapshot> _lobbySubscription;

  @override
  initState() {
    super.initState();
    lobbyStream = FirebaseFirestore.instance
        .collection('lobbies')
        .doc(widget.lobbyId)
        .snapshots();

    _lobbySubscription = lobbyStream.listen((snapshot) {
      if (snapshot.exists && mounted) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (data['isReady'] == data['playerLimit']) {
          _navigateToGamePage();
        }
      }
    });
  }

  void _navigateToGamePage() {
    if (!_hasNavigated) {
      _hasNavigated = true;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: '/game'),
              builder: (context) =>
                  GamePage(lobbyId: widget.lobbyId, user: widget.user)));
    }
  }

  @override
  dispose() {
    _lobbySubscription.cancel();
    super.dispose();
  }

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

  Future<List<String>> getPlayerNumber() async {
    var documentSnapshot = await FirebaseFirestore.instance
        .collection('lobbies')
        .doc(widget.lobbyId)
        .get();
    Map<String, dynamic>? data = documentSnapshot.data();
    List<String> playersNameList = [];
    List<Map<String, dynamic>?> players = [
      data?['player1'],
      data?['player2'],
      data?['player3'],
      data?['player4']
    ];
    for (int i = 0; i < players.length; i++) {
      if (players[i] != null && players[i]!['uid'] != '') {
        playersNameList.add(players[i]!['name']);
      }
    }
    return playersNameList;
  }

  isReadyTransaction() async {
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(
          FirebaseFirestore.instance.collection('lobbies').doc(widget.lobbyId));
      transaction
          .update(snapshot.reference, {'isReady': FieldValue.increment(1)});
    });
  }

  _onLobbyListNext() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LobbiesListPage(user: widget.user)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple, Colors.deepPurple],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                onPressed: () {
                  if (isPressed) {
                    LobbyManager.checkPlayerMap(
                        widget.lobbyId, widget.user, currentPlayerCount);
                    LobbyManager.decreseIsReady(widget.lobbyId);
                    _onLobbyListNext();
                  } else {
                    LobbyManager.checkPlayerMap(
                        widget.lobbyId, widget.user, currentPlayerCount);
                    _onLobbyListNext();
                  }
                },
                icon: const Icon(Icons.arrow_back),
                label: Text(languageMap['Back'] ?? '',
                    style: TextStyle(fontSize: sizes(context)['textSize'])),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: lobbyStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  } else {
                    var lobby = snapshot.data!;
                      currentPlayerCount = lobby['currentPlayerCount'];
                    return Column(
                      children: [
                        ListTile(
                          title: Text(languageMap['LobbyName'] ?? '',
                              style: TextStyle(
                                  fontSize: sizes(context)['textSize'],
                                  color: Colors.white)),
                          subtitle: Text(lobby['lobbyName'],
                              style: TextStyle(
                                  fontSize: sizes(context)['textSize'],
                                  color: Colors.white)),
                        ),
                        ListTile(
                          title: Text(languageMap['Players'] ?? '',
                              style: TextStyle(
                                  fontSize: sizes(context)['textSize'],
                                  color: Colors.white)),
                          subtitle: Text(
                              "${lobby['currentPlayerCount']} / ${lobby['playerLimit']}",
                              style: TextStyle(
                                  fontSize: sizes(context)['textSize'],
                                  color: Colors.white)),
                        ),
                        FutureBuilder<List<String>>(
                          future: getPlayerNumber(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                  child: Text(languageMap['NoPlayersFound'] ?? ''));
                            } else {
                              List<String> playerNames = snapshot.data!;
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(playerNames.length,
                                      (index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size:
                                                sizes(context)['screenWidth'] *
                                                    0.05,
                                          ),
                                          SizedBox(
                                              width: sizes(
                                                      context)['screenWidth'] *
                                                  0.01),
                                          Text(
                                            playerNames[index],
                                            style: TextStyle(
                                                fontSize:
                                                    sizes(context)['textSize'] *
                                                        2,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              );
                            }
                          },
                        ),
                        StatefulBuilder(
                          builder: (context, setState) =>
                           ElevatedButton(
                            onPressed: () {
                              if (!isPressed) {
                                setState(() {
                                  isPressed = true;
                                });
                                isReadyTransaction();
                              }
                            },
                            style: isPressed
                                ? choosedButtonStyle.copyWith(
                                    minimumSize: WidgetStateProperty.all(Size(
                                        sizes(context)['buttonWidth'],
                                        sizes(context)['buttonHeight'])),
                                  )
                                : menuButtonStyle.copyWith(
                                    minimumSize: WidgetStateProperty.all(Size(
                                        sizes(context)['buttonWidth'],
                                        sizes(context)['buttonHeight'])),
                                  ),
                            child: Text(languageMap['Ready'] ?? ''),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
