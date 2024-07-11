import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thatsnot/pages/start_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thatsnot/services/database.dart';

import '../lobby_manager.dart';

class GamePage extends StatefulWidget {
  final String lobbyId;
  final User? user;

  const GamePage({super.key, required this.lobbyId, this.user});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  MapEntry<String, dynamic> choosedCard = const MapEntry('', '');
  String liedColor = '';
  int liedNumber = 0;
  String liedCard = '';

  _getLobbyData() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('lobbies')
        .doc(widget.lobbyId)
        .get();
    var lobby = snapshot.data();
    return lobby;
  }

  bool _compareColor(String choosedColor, String liedColor) {
    if ((choosedColor == liedColor) || (choosedColor == 'Color 1-9')) {
      return true;
    } else {
      return false;
    }
  }

  bool _compareNumber(int choosedNumber, int liedNumber) {
    if (choosedNumber == liedNumber || choosedNumber == 0) {
      return true;
    } else {
      return false;
    }
  }

  _onStartNext() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const StartPage()));
  }

  Future<Map<String, dynamic>?> getCards(String uid) async {
    Map<String, dynamic> returnMap =
        await LobbyManager.getPlayersList(widget.lobbyId);
    List<Map<String, dynamic>> players = returnMap['players'];
    Map<String, dynamic>? playerCards = {};
    for (int i = 0; i < players.length; i++) {
      if (players[i]['uid'] == uid) {
        playerCards = players[i]['cards'];
      }
    }
    return playerCards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Column(
        children: [
          const SizedBox(height: 15),
          const Text('Game Page',
              style: TextStyle(color: Colors.white, fontSize: 24)),
          TextButton.icon(
            onPressed: () {
              _onStartNext();
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Center(
                  child: Row(
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        var lobby = await _getLobbyData();
                        Map<String, dynamic> choosedCard = lobby['choosedCard'];
                        String choosedColor = choosedCard.values.first['color'];
                        bool colorMatch =
                            _compareColor(choosedColor, lobby['liedColor']);

                        int choosedNumber = choosedCard.values.first['number'];
                        bool numberMatch =
                            _compareNumber(choosedNumber, lobby['liedNumber']);
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text('Miben hazudott?'),
                                  content: Row(
                                    children: [
                                      ElevatedButton(
                                          onPressed: () {
                                            colorMatch
                                                ? print('Igaz Szín')
                                                : print('hamis szín');
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                              'Nem ${lobby['liedColor']}')),
                                      ElevatedButton(
                                          onPressed: () {
                                            numberMatch
                                                ? print('Igaz szám')
                                                : print('hamis szám');
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                              'Nem ${lobby['liedNumber']}')),
                                    ],
                                  ),
                                ));
                      },
                      child: const Text('LIE')),
                  Expanded(
                    child: FutureBuilder<Map<String, dynamic>?>(
                      future: getCards(widget.user!.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          Map<String, dynamic> userCards = snapshot.data!;
                          List<MapEntry<String, dynamic>> cardList =
                              userCards.entries.toList();
                          return SizedBox(
                            width: double.infinity,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: cardList.length,
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  width: MediaQuery.of(context).size.width /
                                      cardList.length,
                                  child: InkWell(
                                    onTap: () {
                                      print('Kártya: ${cardList[index].key}');
                                      choosedCard = cardList[index];
                                      print('Válaszott kártya: $choosedCard');
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                title: const Text(
                                                    'Milyen kártya ez?'),
                                                content: Row(
                                                  children: [
                                                    DropdownMenu(
                                                      enableSearch: false,
                                                      onSelected: (value) {
                                                        setState(() {
                                                          liedColor = value!;
                                                        });
                                                      },
                                                      dropdownMenuEntries: const [
                                                        DropdownMenuEntry(
                                                            value: 'Purple',
                                                            label: 'Purple'),
                                                        DropdownMenuEntry(
                                                            value: 'Orange',
                                                            label: 'Orange'),
                                                        DropdownMenuEntry(
                                                            value: 'Black',
                                                            label: 'Black'),
                                                      ],
                                                    ),
                                                    DropdownMenu(
                                                      enableSearch: false,
                                                      onSelected: (value) {
                                                        setState(() {
                                                          liedNumber = value!;
                                                        });
                                                      },
                                                      dropdownMenuEntries: const [
                                                        DropdownMenuEntry(
                                                            value: 1,
                                                            label: '1'),
                                                        DropdownMenuEntry(
                                                            value: 2,
                                                            label: '1'),
                                                        DropdownMenuEntry(
                                                            value: 3,
                                                            label: '3'),
                                                        DropdownMenuEntry(
                                                            value: 4,
                                                            label: '4'),
                                                        DropdownMenuEntry(
                                                            value: 5,
                                                            label: '5'),
                                                        DropdownMenuEntry(
                                                            value: 6,
                                                            label: '6'),
                                                        DropdownMenuEntry(
                                                            value: 7,
                                                            label: '7'),
                                                        DropdownMenuEntry(
                                                            value: 8,
                                                            label: '8'),
                                                        DropdownMenuEntry(
                                                            value: 9,
                                                            label: '9'),
                                                        DropdownMenuEntry(
                                                            value: 10,
                                                            label: '10'),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  liedColor == '' ||
                                                          liedNumber == 0
                                                      ? const TextButton(
                                                          onPressed: null,
                                                          child: Text(
                                                              'Válassz színt és számot'))
                                                      : TextButton(
                                                          onPressed: () async {
                                                            liedCard =
                                                                '$liedColor$liedNumber';
                                                            print(
                                                                'Lied card: $liedCard');
                                                            await DatabaseService(
                                                                    lobbyId: widget
                                                                        .lobbyId)
                                                                .updateLies(
                                                                    liedColor,
                                                                    liedNumber,
                                                                    choosedCard);
                                                            setState(() {
                                                              userCards.remove(choosedCard.key);
                                                            });
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              const Text('OK'))
                                                ],
                                              ));
                                    },
                                    child: Text(
                                      cardList[index].key.toString(),
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 24),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                        return const Text('Üres a kezed');
                      },
                    ),
                  ),
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }
}
