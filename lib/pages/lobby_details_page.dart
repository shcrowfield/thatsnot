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

  _isReadyCounter() async {
    var documentSnapshot = await FirebaseFirestore.instance
        .collection('lobbies')
        .doc(widget.lobbyId)
        .get();
    Map<String, dynamic>? data = documentSnapshot.data();
    if (data?['isReady'] == data?['playerLimit']) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const GamePage()));
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple, Colors.deepPurple],
            ),
          ),
          child: Column(
            children: [
              TextButton.icon(
                onPressed: () {
                  LobbyManager.checkPlayerMap(
                      widget.lobbyId, widget.user, currentPlayerCount);
                  _onLobbyListNext();
                },
                icon: const Icon(Icons.arrow_back),
                label: Text(languageMap['Back'] ?? ''),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
              ),
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('lobbies')
                    .doc(widget.lobbyId)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  var lobby = snapshot.data!;
                  currentPlayerCount = lobby['currentPlayerCount'];
                  return Column(
                    children: [
                      // Display lobby details
                      ListTile(
                        title: Text(languageMap['LobbyName'] ?? ''),
                        subtitle: Text(lobby['lobbyName']),
                      ),
                      ListTile(
                        title: Text(languageMap['Players'] ?? ''),
                        subtitle: Text(
                            "${lobby['currentPlayerCount']} / ${lobby['playerLimit']}"),
                      ),
                      // Display list of users
                      for (int i = 1; i <= 4; i++)
                        if (lobby['player$i'] != null)
                          Column(
                            children: [
                              Text(languageMap['Player'] ?? '',
                                  style: const TextStyle(
                                      backgroundColor: Colors.white,
                                      fontSize: 20)),
                              Text(
                                lobby['player$i']['name'],
                                style: const TextStyle(
                                    backgroundColor: Colors.white,
                                    fontSize: 20),
                              ),
                            ],
                          ),
                      ElevatedButton(
                        onPressed: () {
                          isPressed
                              ? null
                              : setState(() {
                                  isPressed = true;
                                  lobby.reference.update({
                                    'isReady': FieldValue.increment(1),
                                  });
                                });
                          _isReadyCounter();
                        },
                        style: isPressed ? choosedButtonStyle : menuButtonStyle,
                        child: Text(languageMap['Ready'] ?? ''),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
