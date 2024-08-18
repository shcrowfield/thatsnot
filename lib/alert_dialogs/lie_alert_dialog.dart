import 'package:flutter/material.dart';
import '../lobby_manager.dart';
import '../services/database.dart';

class LieAlertDialog extends StatefulWidget {
  final String lobbyId;
  final Map<String, dynamic> lobby;
  final bool colorMatch;
  final bool numberMatch;
  final VoidCallback onButtonPressed;

  const LieAlertDialog(
      {super.key,
      required this.lobbyId,
      required this.lobby,
      required this.colorMatch,
      required this.numberMatch,
      required this.onButtonPressed});

  @override
  State<LieAlertDialog> createState() => _LieAlertDialogState();
}

class _LieAlertDialogState extends State<LieAlertDialog> {
  bool answerPressed = false;
  String winner = '';
  String? winnerName;

  _getChoosedCard() {
    var firstEntry = widget.lobby['choosedCard'].entries.first;
    String color = firstEntry.value['color'];
    int number = firstEntry.value['number'];
    return {'color': color, 'number': number};
  }

  _getWinnerName(String winner) async {
      Map<String, dynamic> returnMap =
      await LobbyManager.getPlayersList(widget.lobbyId);
      List<Map<String, dynamic>> players = returnMap['players'];
      for (int i = 0; i < players.length; i++) {
        if (players[i]['uid'] == winner) {
          return players[i]['name'];
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Miben hazudott?'),
      content: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                  onPressed: () async {
                    if (widget.colorMatch) {
                      DatabaseService(lobbyId: widget.lobbyId)
                          .increseWinnerPoints(widget.lobby['lastCardPlayer']);
                      winner = widget.lobby['lastCardPlayer'];
                      winnerName = await _getWinnerName(winner);
                      DatabaseService(lobbyId: widget.lobbyId)
                          .isHandEmpty(widget.lobby['lastCardPlayer']);
                      DatabaseService(lobbyId: widget.lobbyId)
                          .drawForLoser(widget.lobby['opponentId']);
                    } else {
                      DatabaseService(lobbyId: widget.lobbyId)
                          .increseWinnerPoints(widget.lobby['opponentId']);
                      winner = widget.lobby['opponentId'];
                      winnerName = await _getWinnerName(winner);
                      DatabaseService(lobbyId: widget.lobbyId)
                          .drawForLoser(widget.lobby['lastCardPlayer']);
                    }
                    setState(() {
                      answerPressed = true;
                    });
                    await DatabaseService(lobbyId: widget.lobbyId)
                        .incresePassCount();
                    await DatabaseService(lobbyId: widget.lobbyId)
                        .checkActivePlayer();
                  },
                  child: Text('Nem ${widget.lobby['liedColor']}')),
              ElevatedButton(
                  onPressed: () async {
                    if (widget.numberMatch) {
                      DatabaseService(lobbyId: widget.lobbyId)
                          .increseWinnerPoints(widget.lobby['lastCardPlayer']);
                      winner = widget.lobby['lastCardPlayer'];
                      winnerName = await _getWinnerName(winner);
                      DatabaseService(lobbyId: widget.lobbyId)
                          .isHandEmpty(widget.lobby['lastCardPlayer']);
                      DatabaseService(lobbyId: widget.lobbyId)
                          .drawForLoser(widget.lobby['opponentId']);
                    } else {
                      DatabaseService(lobbyId: widget.lobbyId)
                          .increseWinnerPoints(widget.lobby['opponentId']);
                      winner = widget.lobby['opponentId'];
                      winnerName = await _getWinnerName(winner);
                      DatabaseService(lobbyId: widget.lobbyId)
                          .drawForLoser(widget.lobby['lastCardPlayer']);
                    }
                    setState(() {
                      answerPressed = true;
                    });
                    await DatabaseService(lobbyId: widget.lobbyId)
                        .incresePassCount();
                    await DatabaseService(lobbyId: widget.lobbyId)
                        .checkActivePlayer();
                  },
                  child: Text('Nem ${widget.lobby['liedNumber']}')),
            ],
          ),
          Text(answerPressed
              ? 'A bemondott lap: ${widget.lobby['liedColor']} ${widget.lobby['liedNumber']}'
              : 'A bemondott lap: '),
          Text(answerPressed
              ? 'A valós lap: ${_getChoosedCard()['color']} ${_getChoosedCard()['number']}'
              : 'A valós lap: '),
          Text(answerPressed ? 'A nyertes: $winnerName' : 'A nyertes: '),
          ElevatedButton(
              onPressed: () {
                widget.onButtonPressed();
                Navigator.pop(context);
              },
              child: const Text('OK'))
        ],
      ),
    );
  }
}
