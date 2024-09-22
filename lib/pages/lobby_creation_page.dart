import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thatsnot/language.dart';
import 'package:thatsnot/models/card.dart';
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
  late TextEditingController nickNameController;
  String nickName = '';
  int isReady = 0;
  Map<String, Cards> drawPile = {};
  Map<String, Cards> discardPile = {};
  Map<String, Cards> deck = {};
  String activePlayer = '';
  String liedColor = '';
  int liedNumber = 0;
  Map<String, dynamic> choosedCard = {};
  int passCount = 0;
  String oppoentId = '';
  String lastCardPlayer = '';
  String winnerId = '';
  String answer = '';

  @override
  void initState() {
    super.initState();
    nickNameController = TextEditingController();
    lobbyController = TextEditingController();

    player1 = Player(uid: '', name: '', points: 0, isActive: false);
    player2 = Player(uid: '', name: '', points: 0, isActive: false);
    player3 = Player(uid: '', name: '', points: 0, isActive: false);
    player4 = Player(uid: '', name: '', points: 0, isActive: false);
  }

  @override
  void dispose() {
    lobbyController.dispose();
    super.dispose();
  }

  _onStartNext() {
    Navigator.pop(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.deepPurple,
      body: SingleChildScrollView(
        child: Container(
          height: sizes(context)['screenHeight'],
          width: sizes(context)['screenWidth'],
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple, Colors.deepPurple],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () {
                  _onStartNext();
                },
                icon: const Icon(Icons.arrow_back),
                label: Text(languageMap['Back'] ?? '', style: TextStyle(fontSize: sizes(context)['textSize'])),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
              ),
              Center(
                child: SizedBox(
                  width: sizes(context)['screenWidth'] * 0.6,
                  height: sizes(context)['screenHeight'] * 0.9,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(height: 10),
                      Text(languageMap['Nickname'] ?? '',
                          style:
                              TextStyle(fontSize: sizes(context)['textSize'], color: Colors.white)),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: languageMap['Nickname'],
                          hintStyle: TextStyle( fontSize: sizes(context)['textSize']),
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 2.0),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.orange, width: 2.0),
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
                      Text(languageMap['LobbyName'] ?? '',
                          style:
                              const TextStyle(fontSize: 20, color: Colors.white)),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: languageMap['LobbyName'] ?? '',
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 2.0),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.orange, width: 2.0),
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
                      Text(languageMap['NumberOfPlayers'] ?? '',
                          style:
                              const TextStyle(fontSize: 20, color: Colors.white)),
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
                    ],
                  ),
                ),
              ),
              ElevatedButton(
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
                        isActive: true),
                    player2,
                    player3,
                    player4,
                    isReady,
                    drawPile,
                    discardPile,
                    deck,
                    activePlayer = widget.user!.uid,
                    liedColor,
                    liedNumber,
                    choosedCard,
                    passCount,
                    oppoentId,
                    lastCardPlayer,
                    winnerId,
                    answer,
                  );
                  _onLobbyDetailsPageNext();
                },
                style: lobbyName == ''
                    ? menuButtonStyle.copyWith(
                    backgroundColor:
                    WidgetStateProperty.all(Colors.white38))
                    : menuButtonStyle,
                child: Text(languageMap['Next'] ?? ''),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
