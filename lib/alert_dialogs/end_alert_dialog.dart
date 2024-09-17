import 'package:flutter/material.dart';
import 'package:thatsnot/lobby_manager.dart';

import '../pages/start_screen.dart';

class EndAlertDialog extends StatefulWidget {
  final String lobbyId;

  const EndAlertDialog({super.key, required this.lobbyId});

  @override
  State<EndAlertDialog> createState() => _EndAlertDialogState();
}

class _EndAlertDialogState extends State<EndAlertDialog> {
  late Future<List<Map<String, dynamic>>> _playersFuture;

  @override
  void initState() {
    super.initState();
    _playersFuture = getPlayersListByPoints();
  }

  Future<List<Map<String, dynamic>>> getPlayersListByPoints() async {
    var returnMap = await LobbyManager.getPlayersList(widget.lobbyId);
    List<Map<String, dynamic>> players = List<Map<String, dynamic>>.from(returnMap['players']);
    players.sort((a, b) => b['points'].compareTo(a['points']));
    return players;
  }

  onStartNext() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const StartPage()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Game Over'),
      content: SizedBox(
        width: 300,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _playersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Text('Error loading players');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No players found');
            } else {
              var players = snapshot.data!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('The game is over. The list is:'),
                  const SizedBox(height: 10),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        var player = players[index];
                        return ListTile(
                          title: Text(player['name']),
                          trailing: Text('${player['points']} points'),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            onStartNext();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}