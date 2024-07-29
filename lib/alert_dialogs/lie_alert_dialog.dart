import 'package:flutter/material.dart';
import '../services/database.dart';

class LieAlertDialog extends StatefulWidget {

  final String lobbyId;
  final Map<String, dynamic> lobby;
  final bool colorMatch;
  final bool numberMatch;
  const LieAlertDialog({super.key, required this.lobbyId, required this.lobby, required this.colorMatch, required this.numberMatch});

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
                widget.colorMatch ? print('Igaz Szín') : print('hamis szín');
                Navigator.pop(context);
                await DatabaseService(lobbyId: widget.lobbyId)
                    .incresePassCount();
                await DatabaseService(lobbyId: widget.lobbyId)
                    .checkActivePlayer();
              },
              child: Text('Nem ${widget.lobby['liedColor']}')),
          ElevatedButton(
              onPressed: () async {
                widget.numberMatch ? print('Igaz szám') : print('hamis szám');
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
