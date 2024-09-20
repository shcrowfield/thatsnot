import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thatsnot/alert_dialogs/result_alert_dialog.dart';
import 'package:thatsnot/services/database.dart';

class LieAlertDialog extends StatefulWidget {
  final String lobbyId;
  final bool colorMatch;
  final bool numberMatch;
  final VoidCallback onButtonPressed;

  const LieAlertDialog({
    super.key,
    required this.lobbyId,
    required this.colorMatch,
    required this.numberMatch,
    required this.onButtonPressed,
  });

  @override
  State<LieAlertDialog> createState() => _LieAlertDialogState();
}

class _LieAlertDialogState extends State<LieAlertDialog> {
  bool answerPressed = false;
  late DatabaseService db;
  late Map<String, dynamic> _lobby;
  late Future <Map<String, dynamic>> _lobbyDataFuture;

  @override
  void initState() {
    super.initState();
    db = DatabaseService(lobbyId: widget.lobbyId);
    _lobbyDataFuture = _getLobby();
  }

  Future<Map<String, dynamic>> _getLobby() async {
    try {
      final lobbyResult = (await FirebaseFirestore.instance
              .collection('lobbies')
              .doc(widget.lobbyId)
              .get())
          .data();
      if (lobbyResult == null) {
        throw Exception('Lobby not found');
      }
      _lobby = lobbyResult;
    } catch (e) {
      print('Anyád: $e');
    }
    return _lobby;
  }

  void _onResultNext() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultAlertDialog(
          lobbyId: widget.lobbyId,
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getChoosedCard() async {
    var firstEntry = _lobby['choosedCard'].entries.first;
    String color = firstEntry.value['color'];
    int number = firstEntry.value['number'];
    return {'color': color, 'number': number};
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Miben hazudott?'),
      content: FutureBuilder<Map<String, dynamic>>(
        future: _lobbyDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error loading data: ${snapshot.error}');
          } else if (!snapshot.hasData) {
            return const Text('No data found');
          } else {
            final data = snapshot.data;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (widget.colorMatch) {
                          await db.updateResult(
                              _lobby['lastCardPlayer'], _lobby['liedColor']);
                          await db
                              .increseWinnerPoints(_lobby['lastCardPlayer']);
                          await db.isHandEmpty(_lobby['lastCardPlayer']);
                          await db.drawForLoser(_lobby['opponentId']);
                        } else {
                          await db.updateResult(
                              _lobby['opponentId'], _lobby['liedColor']);
                          await db.increseWinnerPoints(_lobby['opponentId']);
                          await db.drawForLoser(_lobby['lastCardPlayer']);
                        }
                        setState(() {
                          answerPressed = true;
                        });
                        await db.incresePassCount();
                        await db.checkActivePlayer();
                        _onResultNext();
                      },
                      child: Text('Nem ${_lobby['liedColor']}'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (widget.numberMatch) {
                          await db.updateResult(_lobby['lastCardPlayer'],
                              _lobby['liedNumber'].toString());
                          await db
                              .increseWinnerPoints(_lobby['lastCardPlayer']);
                          await db.isHandEmpty(_lobby['lastCardPlayer']);
                          await db.drawForLoser(_lobby['opponentId']);
                        } else {
                          await db.updateResult(_lobby['opponentId'],
                              _lobby['liedNumber'].toString());
                          await db.increseWinnerPoints(_lobby['opponentId']);
                          await db.drawForLoser(_lobby['lastCardPlayer']);
                        }
                        setState(() {
                          answerPressed = true;
                        });
                        await db.incresePassCount();
                        await db.checkActivePlayer();
                        _onResultNext();
                      },
                      child: Text('Nem ${_lobby['liedNumber'].toString()}'),
                    ),
                  ],
                ),
                Text(answerPressed
                    ? 'A bemondott lap: ${_lobby['liedColor']} ${_lobby['liedNumber']}'
                    : 'A bemondott lap: '),
                Text(answerPressed
                    ? 'A valós lap:' /*${_getChoosedCard()} ${_getChoosedCard()}'*/
                    : 'A valós lap: '),
                Text(answerPressed ? 'A nyertes:' : 'A nyertes: '),
                ElevatedButton(
                  onPressed: widget.onButtonPressed,
                  child: const Text('OK'),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
