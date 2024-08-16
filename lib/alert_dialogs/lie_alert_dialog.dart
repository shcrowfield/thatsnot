import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Miben hazudott?'),
      content: Row(
        children: [
          ElevatedButton(
              onPressed: () async {
                if (widget.colorMatch) {
                  DatabaseService(lobbyId: widget.lobbyId)
                      .increseWinnerPoints(widget.lobby['lastCardPlayer']);
                  DatabaseService(lobbyId: widget.lobbyId)
                      .isHandEmpty(widget.lobby['lastCardPlayer']);
                  DatabaseService(lobbyId: widget.lobbyId)
                      .drawForLoser(widget.lobby['opponentId']);
                } else {
                  DatabaseService(lobbyId: widget.lobbyId)
                      .increseWinnerPoints(widget.lobby['opponentId']);
                  DatabaseService(lobbyId: widget.lobbyId)
                      .drawForLoser(widget.lobby['lastCardPlayer']);
                }
                widget.onButtonPressed();
                Navigator.pop(context);
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
                  DatabaseService(lobbyId: widget.lobbyId)
                      .isHandEmpty(widget.lobby['lastCardPlayer']);
                  DatabaseService(lobbyId: widget.lobbyId)
                      .drawForLoser(widget.lobby['opponentId']);
                } else {
                  DatabaseService(lobbyId: widget.lobbyId)
                      .increseWinnerPoints(widget.lobby['opponentId']);
                  DatabaseService(lobbyId: widget.lobbyId)
                      .drawForLoser(widget.lobby['lastCardPlayer']);
                }
                widget.onButtonPressed();
                Navigator.pop(context);
                await DatabaseService(lobbyId: widget.lobbyId)
                    .incresePassCount();
                await DatabaseService(lobbyId: widget.lobbyId)
                    .checkActivePlayer();
              },
              child: Text('Nem ${widget.lobby['liedNumber']}')),
        ],
      ),
    );
  }
}
