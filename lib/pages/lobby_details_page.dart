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

  _isReadyCounter() async {
    var documentSnapshot = await FirebaseFirestore.instance
        .collection('lobbies')
        .doc(widget.lobbyId)
        .get();
    Map<String, dynamic>? data = documentSnapshot.data();
    if (data?['isReady'] == data?['playerLimit']) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  GamePage(lobbyId: widget.lobbyId, user: widget.user)));
      print('All players are ready');
    }
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
                stream: FirebaseFirestore.instance
                    .collection('lobbies')
                    .doc(widget.lobbyId)
                    .snapshots(),
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
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                List.generate(currentPlayerCount!, (index) {
                              int playerIndex = index + 1;
                              return lobby['player$playerIndex'] != null
                                  ? Padding(
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
                                            lobby['player$playerIndex']['name'],
                                            style: TextStyle(
                                                fontSize:
                                                    sizes(context)['textSize'] *
                                                        2,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container();
                            }),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (!isPressed) {
                              setState(() {
                                isPressed = true;
                              });
                              lobby.reference.update({
                                'isReady': FieldValue.increment(1),
                              });
                            }
                            _isReadyCounter();
                           /* DatabaseService(lobbyId: lobby['lobbyId'])
                                .updateDeck();
                            DatabaseService(lobbyId: lobby['lobbyId'])
                                .dealCards();
                            DatabaseService(lobbyId: lobby['lobbyId'])
                                .updateDrawPile();*/
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
