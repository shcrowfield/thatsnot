import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thatsnot/button_style.dart';
import 'package:thatsnot/language.dart';
import 'package:thatsnot/services/database.dart';

class LieAlertDialog extends StatefulWidget {
  final String lobbyId;
  final bool colorMatch;
  final bool numberMatch;

  const LieAlertDialog({
    super.key,
    required this.lobbyId,
    required this.colorMatch,
    required this.numberMatch,
  });

  @override
  State<LieAlertDialog> createState() => _LieAlertDialogState();
}

class _LieAlertDialogState extends State<LieAlertDialog> {
  bool answerPressed = false;
  late DatabaseService db;
  late Map<String, dynamic> _lobby;
  late Future<Map<String, dynamic>> _lobbyDataFuture;

  @override
  void initState() {
    super.initState();
    db = DatabaseService(lobbyId: widget.lobbyId);
    _lobbyDataFuture = _getLobby();
  }

  void _handleButtonPress(bool isColorButton) async {
    final winningPlayer = isColorButton
        ? (widget.colorMatch ? _lobby['lastCardPlayer'] : _lobby['opponentId'])
        : (widget.numberMatch
            ? _lobby['lastCardPlayer']
            : _lobby['opponentId']);
    final losingPlayer = winningPlayer == _lobby['lastCardPlayer']
        ? _lobby['opponentId']
        : _lobby['lastCardPlayer'];
    final liedAttribute =
        isColorButton ? _lobby['liedColor'] : _lobby['liedNumber'].toString();

    Navigator.pop(context);
      await db.updateResult(winningPlayer, liedAttribute);
      await db.increseWinnerPoints(winningPlayer);
      await db.isHandEmpty(/*winningPlayer*/);
      await db.drawForLoser(losingPlayer);
      await db.incresePassCount();
      await db.checkActivePlayer();
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
      print('Error: $e');
    }
    return _lobby;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(languageMap['WhatIsTheLie'] ?? ''),
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
            // final data = snapshot.data;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          answerPressed ? null : _handleButtonPress(true),
                      style: answerPressed
                          ? disabledGameButtonStyle
                          : gameButtonStyle,
                      child: Row(
                        children: [
                          Text('${languageMap['Not']} '),
                          Text(
                            '${languageMap[_lobby['liedColor']]}',
                            style: TextStyle(
                              color: _lobby['liedColor'] == 'Orange'
                                  ? Colors.orange
                                  : _lobby['liedColor'] == 'Purple'
                                      ? Colors.purple
                                      : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          answerPressed ? null : _handleButtonPress(false),
                      style: answerPressed
                          ? disabledGameButtonStyle
                          : gameButtonStyle,
                      child: Text(
                          '${languageMap['Not']} ${_lobby['liedNumber'].toString()}'),
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
