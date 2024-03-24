import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thatsnot/language.dart';
import 'package:thatsnot/pages/start_screen.dart';

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

  _checkPlayerMap() async {
    var documentSnapshot = await FirebaseFirestore.instance
        .collection('lobbies')
        .doc(widget.lobbyId)
        .get();
    Map<String, dynamic>? data = documentSnapshot.data();
    Map<String, dynamic> player1 = data?['player1'];
    Map<String, dynamic> player2 = data?['player2'];
    Map<String, dynamic> player3 = data?['player3'];
    Map<String, dynamic> player4 = data?['player4'];
    List<Map<String, dynamic>> players = [player1, player2, player3, player4];

    for (int i = 0; i < players.length; i++) {
      if (players[i]['uid'] == widget.user!.uid) {
        Map<String, dynamic> updatedPlayer = {
          ...players[i],
          'cards': [],
          'isHost': false,
          'points': 0,
          'name': '',
          'uid': ''
        };
        String playerFieldName = 'player${i + 1}';
        documentSnapshot.reference.update({playerFieldName: updatedPlayer});
      }
    }

    if (currentPlayerCount != null && currentPlayerCount! > 0) {
      await documentSnapshot.reference.update({
        'currentPlayerCount': FieldValue.increment(-1),
      });
    }
    _deletePlayer();
  }

  _deletePlayer() async {
    var documentSnapshot = await FirebaseFirestore.instance
        .collection('lobbies')
        .doc(widget.lobbyId)
        .get();
    Map<String, dynamic>? data = documentSnapshot.data();
    if (data?['currentPlayerCount'] == 0) {
      await documentSnapshot.reference.delete();
    }
  }

  _onStartNext() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const StartPage()));
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
                  _checkPlayerMap();
                  _onStartNext();
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
                          Row(children: [
                            Text(languageMap['Player'] ?? '',
                                style: const TextStyle(
                                    backgroundColor: Colors.white)),
                            Text(
                              lobby['player$i']['name'],
                              style: const TextStyle(
                                  backgroundColor: Colors.white),
                            ),
                          ]),
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
