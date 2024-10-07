import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thatsnot/language.dart';
import 'package:thatsnot/lobby_manager.dart';
import 'package:thatsnot/services/database.dart';

class ResultAlertDialog extends StatefulWidget {
  final String lobbyId;

  const ResultAlertDialog({
    super.key,
    required this.lobbyId,
  });

  @override
  State<ResultAlertDialog> createState() => _ResultAlertDialogState();
}

class _ResultAlertDialogState extends State<ResultAlertDialog> {
  late Future<Map<String, String>> _dataFuture;
  late Map<String, dynamic> _lobby;

  @override
  void initState() {
    super.initState();
    _dataFuture = _getData();
  }

  Future<Map<String, String>> _getData() async {
    try {
      print("Starting _getData method");
      final lobbyResult = (await FirebaseFirestore.instance
              .collection('lobbies')
              .doc(widget.lobbyId)
              .get())
          .data();
      if (lobbyResult == null) {
        throw Exception('Lobby not found');
      }
      final requiredFields = [
        'winnerId',
        'opponentId',
        'lastCardPlayer',
        'answer',
        'liedColor',
        'liedNumber'
      ];
      for (final field in requiredFields) {
        if (!lobbyResult.containsKey(field)) {
          throw Exception('Missing required field: $field');
        }
      }
      _lobby = lobbyResult;

      String winnerId = lobbyResult['winnerId'];
      String opponentId = lobbyResult['opponentId'];
      String lastCardPlayer = lobbyResult['lastCardPlayer'];
      String answer = lobbyResult['answer'];
      String liedColor = lobbyResult['liedColor'];
      int liedNumberN = lobbyResult['liedNumber'];
      String liedNumber = liedNumberN.toString();

      print("Fetching players list");
      var returnMap = await LobbyManager.getPlayersList(widget.lobbyId);
      print("Players list fetched");

      List<Map<String, dynamic>> players =
          List<Map<String, dynamic>>.from(returnMap['players']);

      String winnerName = '';
      String opponentName = '';
      String lastCardPlayerName = '';

      print("Processing players");
      for (var player in players) {
        if (player['uid'] == winnerId) winnerName = player['name'];
        if (player['uid'] == opponentId) opponentName = player['name'];
        if (player['uid'] == lastCardPlayer)
          lastCardPlayerName = player['name'];
      }

      print("Data processing complete");
      return {
        'winnerName': winnerName,
        'answer': answer,
        'liedColor': liedColor,
        'liedNumber': liedNumber,
        'opponentName': opponentName,
        'lastCardPlayerName': lastCardPlayerName,
      };
    } catch (e, stackTrace) {
      print("Error in _getData: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(languageMap['DuelResult'] ?? ''),
      content: FutureBuilder<Map<String, String>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error loading data: ${snapshot.error}');
          } else if (!snapshot.hasData) {
            return const Text('No data found');
          } else {
            var data = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${data['lastCardPlayerName']} : '),
                    Text(
                      '${languageMap[data['liedColor']]} ${data['liedNumber']}',
                      style: TextStyle(
                        color: data['liedColor'] == 'Orange'
                            ? Colors.orange
                            : data['liedColor'] == 'Purple'
                                ? Colors.purple
                                : Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                        '${data['opponentName']} : ${languageMap['LieBecause']} ${languageMap['Not']}'),
                    Text(
                      ' ${languageMap[data['answer']]}',
                      style: TextStyle(
                        color: data['liedColor'] == 'Orange'
                            ? Colors.orange
                            : data['liedColor'] == 'Purple'
                                ? Colors.purple
                                : Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    const Text('!')
                  ],
                ),
                Text('${languageMap['TheWinnerIs']}: ${data['winnerName']}'),
              ],
            );
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_lobby['winnerName'] != '') {
              DatabaseService(lobbyId: widget.lobbyId).restoreData();
            } else {
              print('Már üres');
            }
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
