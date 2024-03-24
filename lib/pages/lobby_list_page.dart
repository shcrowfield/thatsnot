import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thatsnot/language.dart';
import 'package:thatsnot/pages/start_screen.dart';
import 'package:thatsnot/services/database.dart';
import '../models/player.dart';
import 'lobby_details_page.dart';

class LobbiesListPage extends StatefulWidget {
  const LobbiesListPage({super.key, required this.user});

  final User? user;

  @override
  State<LobbiesListPage> createState() => _LobbiesListPageState();
}

class _LobbiesListPageState extends State<LobbiesListPage> {
  late TextEditingController nickNameController;
  String nickName = '';
  late Player player;

  _onStartNext() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const StartPage()));
  }

  bool _isLobbyFull(int currentPlayerCount, int playerLimit) {
    if (currentPlayerCount < playerLimit) {
      return false;
    } else {
      return true;
    }
  }


  @override
  void initState() {
    nickNameController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple, Colors.deepPurple],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 25),
            Text(languageMap['ActiveLobbies'] ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 24)),
            TextButton.icon(
              onPressed: () {
                _onStartNext();
              },
              icon: const Icon(Icons.arrow_back),
              label: Text(languageMap['Back'] ?? ''),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                hintText: languageMap['Nickname'] ?? '',
                fillColor: Colors.white,
                filled: true,
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange, width: 2.0),
                ),
              ),
              controller: nickNameController,
              onChanged: (String value) {
                setState(() {
                  nickName = nickNameController.text;
                });
              },
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('lobbies')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((document) {
                      return ListTile(
                        title: Text(document['lobbyName'],
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                            "${document['currentPlayerCount']} / ${document['playerLimit']} players ${_isLobbyFull(document['currentPlayerCount'], document['playerLimit']) ? 'Full' : 'Not Full'}",
                            style: const TextStyle(color: Colors.white)),
                        onTap: () async {
                          _isLobbyFull(document['currentPlayerCount'],
                                  document['playerLimit'])
                              ? player = Player(
                                  name: '',
                                  points: 0,
                                  uid: '',
                                  isHost: false,
                                )
                              : player = Player(
                                  name: nickName,
                                  points: 0,
                                  uid: widget.user!.uid,
                                  isHost: false,
                                );
                          _isLobbyFull(document['currentPlayerCount'],
                                  document['playerLimit'])
                              ? null
                              : await DatabaseService(lobbyId: document.id)
                                  .updatePlayer(
                                      player, document['currentPlayerCount']);
                          _isLobbyFull(document['currentPlayerCount'],
                                  document['playerLimit'])
                              ? null
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LobbyDetailsPage(
                                        lobbyId: document.id,
                                        user: widget.user,
                                        nickName: nickName),
                                  ),
                                );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
