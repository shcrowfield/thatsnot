import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thatsnot/language.dart';
import 'package:thatsnot/pages/lobby_details_page.dart';
import 'package:thatsnot/services/database.dart';
import 'start_screen.dart';
import 'package:thatsnot/button_style.dart';
import 'dart:math';
import 'package:thatsnot/models/player.dart';

class LobbyCreationPage extends StatefulWidget {
  const LobbyCreationPage({super.key, this.user, required this.nickName});

  final User? user;
  final String nickName;

  @override
  State<LobbyCreationPage> createState() => _LobbyCreationPageState();
}

class _LobbyCreationPageState extends State<LobbyCreationPage> {
  String _randomId(value) {
    var random = Random();
    var id = random.nextInt(10000);
    return value + id.toString() + DateTime.timestamp().toString();
  }

  late TextEditingController lobbyController;
  int playerLimit = 2;
  String lobbyName = '';
  String lobbyId = '';
  int currentPlayerCount = 1;
  late Player player1;
  late Player player2;
  late Player player3;
  late Player player4;
  bool anonym = true;
  late TextEditingController nickNameController;
  String nickName = '';

  @override
  void initState() {
    nickNameController = TextEditingController();

    super.initState();
    lobbyController = TextEditingController();

    player1 = Player(uid: '', name: '', points: 0, isHost: false);
    player2 = Player(uid: '', name: '', points: 0, isHost: false);
    player3 = Player(uid: '', name: '', points: 0, isHost: false);
    player4 = Player(uid: '', name: '', points: 0, isHost: false);
  }

  @override
  void dispose() {
    lobbyController.dispose();
    super.dispose();
  }

  _onStartNext() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const StartPage()));
  }

  _onLobbyDetailsPageNext() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LobbyDetailsPage(
                lobbyId: lobbyId,
                user: widget.user,
                nickName: widget.nickName)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.deepPurple,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple, Colors.deepPurple],
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 400,
            child: Column(
              children: [
                const SizedBox(height: 25),
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
                    hintText: languageMap['Nickname'],
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
                const SizedBox(height: 10),
                Text(languageMap['CreateLobby'] ?? ''),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: languageMap['LobbyName'] ?? '',
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange, width: 2.0),
                    ),
                  ),
                  controller: lobbyController,
                  onChanged: (String value) {
                    setState(() {
                      lobbyName = lobbyController.text;
                      lobbyId = _randomId(lobbyName);
                    });
                  },
                ),
                Text(languageMap['NumberOfPlayers'] ?? ''),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: playerLimit == 2
                          ? choosedButtonStyle
                          : unchoosedButtonStyle,
                      onPressed: () {
                        setState(() {
                          playerLimit = 2;
                        });
                      },
                      child: const Text('2'),
                    ),
                    ElevatedButton(
                      style: playerLimit == 3
                          ? choosedButtonStyle
                          : unchoosedButtonStyle,
                      onPressed: () {
                        setState(() {
                          playerLimit = 3;
                        });
                      },
                      child: const Text('3'),
                    ),
                    ElevatedButton(
                      style: playerLimit == 4
                          ? choosedButtonStyle
                          : unchoosedButtonStyle,
                      onPressed: () {
                        setState(() {
                          playerLimit = 4;
                        });
                      },
                      child: const Text('4'),
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      lobbyName.isEmpty && nickName.isEmpty
                          ? null
                          : await DatabaseService(lobbyId: lobbyId)
                              .updateLobbyData(
                              lobbyName,
                              playerLimit,
                              currentPlayerCount,
                              player1 = Player(
                                  uid: widget.user!.uid,
                                  name: nickName,
                                  points: 0,
                                  isHost: true),
                              player2,
                              player3,
                              player4,
                            );
                      _onLobbyDetailsPageNext();
                    },
                    style: lobbyName == ''
                        ? menuButtonStyle.copyWith(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white38))
                        : menuButtonStyle,
                    child: Text(languageMap['Next'] ?? ''),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
