import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thatsnot/language.dart';
import 'package:thatsnot/pages/game_page.dart';
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

  @override
  void initState() {
    super.initState();
    lobbyController = TextEditingController();
    // Initialize player1 here using widget.user.uid
    player1 = Player(pid: widget.user!.uid, name: widget.nickName, points: 0);
    player2 = Player(pid: '', name: '', points: 0);
    player3 = Player(pid: '', name: '', points: 0);
    player4 = Player(pid: '', name: '', points: 0);
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

  _onGamePageNext() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const GamePage()));
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
                  label: Text(language[0]),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(language[1]),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: language[11],
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
                Text(language[10]),
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
                      lobbyName.isEmpty
                          ? null
                          : await DatabaseService(lobbyId: lobbyId)
                              .updateLobbyData(
                              lobbyName,
                              playerLimit,
                              currentPlayerCount,
                              player1,
                              player2,
                              player3,
                              player4,
                            );
                      _onGamePageNext();
                    },
                    style: lobbyName == ''
                        ? menuButtonStyle.copyWith(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white38))
                        : menuButtonStyle,
                    child: Text(language[9]),
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
