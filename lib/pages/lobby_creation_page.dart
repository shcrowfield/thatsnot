import 'package:flutter/material.dart';
import 'package:thatsnot/services/database.dart';
import 'start_screen.dart';
import 'package:thatsnot/button_style.dart';
import 'dart:math';
import 'package:thatsnot/models/player.dart';

class LobbyCreationPage extends StatefulWidget {
  const LobbyCreationPage({super.key});

  @override
  State<LobbyCreationPage> createState() => _LobbyCreationPageState();
}

class _LobbyCreationPageState extends State<LobbyCreationPage> {
  _onStartNext() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const StartPage()));
  }

  String _randomId(value) {
    var random = Random();
    var id = random.nextInt(10000);
    return value + id.toString();
  }

  late TextEditingController controller;
  int playerLimit = 2;
  String lobbyName = '';
  String lobbyId = '';
  int currentPlayerCount = 1;
  Map<String, Player> players = {};

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
                  label: const Text('Vissza'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                ),
                const Text('Lobby készítése'),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Lobbi neve',
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange, width: 2.0),
                    ),
                  ),
                  controller: controller,
                  onChanged: (String value) {
                    setState(() {
                      lobbyName = controller.text;
                      lobbyId = _randomId(lobbyName);
                    });
                  },
                ),
                const Text('Játékosok száma: '),
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
                                .updateLobbyData(lobbyName, playerLimit,
                                    currentPlayerCount, players);
                      },
                      style: lobbyName == ''
                          ? menuButtonStyle.copyWith(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white38))
                          : menuButtonStyle,
                      child: const Text('Tovább')),
                ),
                Text('Játékosok száma: $playerLimit'),
                Text('Lobbi neve: $lobbyName'),
                Text('Lobbi azonosító: $lobbyId'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
