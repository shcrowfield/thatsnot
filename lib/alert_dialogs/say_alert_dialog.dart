//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thatsnot/language.dart';
import 'package:thatsnot/services/database.dart';

class SayAlertDialog extends StatefulWidget {
  final String lobbyId;
  final User? user;
  final MapEntry<String, dynamic> choosedCard;

  const SayAlertDialog({
    super.key,
    required this.lobbyId,
    required this.user,
    required this.choosedCard,
  });

  @override
  State<SayAlertDialog> createState() => _SayAlertDialogState();
}

class _SayAlertDialogState extends State<SayAlertDialog> {
  String? selectedColor;
  int? selectedNumber;
  List<DropdownMenuEntry<String>> colorDropdownEntries = [];
  List<DropdownMenuEntry<int>> numberDropdownEntries = [];
  String liedColor = '';
  int liedNumber = 0;
  String liedCard = '';
  Future<void> _dropdownEntriesFuture = Future<void>.value();
  late DatabaseService db;

  @override
  void initState() {
    super.initState();
    _dropdownEntriesFuture = getDropdownEntries();
    db = DatabaseService(lobbyId: widget.lobbyId);
  }

  @override
  dispose() {
    super.dispose();
  }

  Future<Map<String, dynamic>> _getColorAndNumber() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('lobbies')
        .doc(widget.lobbyId)
        .get();
    var lobby = snapshot.data();
    String lobbyLiedColor = lobby!['liedColor'];
    int lobbyLiedNumber = lobby['liedNumber'];
    return {
      'lobbyLiedColor': lobbyLiedColor,
      'lobbyLiedNumber': lobbyLiedNumber
    };
  }

  Future<void> getDropdownEntries() async {
    try {
      var lastCard = await _getColorAndNumber();
      String lobbyLiedColor = lastCard['lobbyLiedColor'];
      int lobbyLiedNumber = lastCard['lobbyLiedNumber'];

      List<DropdownMenuEntry<String>> colorDropdownMenuEntries;

      if (lobbyLiedColor.isEmpty || lobbyLiedNumber == 9) {
        colorDropdownMenuEntries = [
          DropdownMenuEntry(value: 'Purple', label: '${languageMap['Purple']}'),
          DropdownMenuEntry(value: 'Orange', label: '${languageMap['Orange']}'),
          DropdownMenuEntry(value: 'Black', label: '${languageMap['Black']}'),
        ];
      } else {
        colorDropdownMenuEntries = [
          DropdownMenuEntry(value: lobbyLiedColor, label: '${languageMap[lobbyLiedColor]}'),
        ];
      }

      if (lobbyLiedNumber == 0 || lobbyLiedNumber == 9) {
        numberDropdownEntries = const [
          DropdownMenuEntry(value: 1, label: '1'),
          DropdownMenuEntry(value: 2, label: '2'),
          DropdownMenuEntry(value: 3, label: '3'),
        ];
      } else {
        numberDropdownEntries = List.generate(9 - lobbyLiedNumber, (index) {
          return DropdownMenuEntry(
              value: lobbyLiedNumber + index + 1,
              label: (lobbyLiedNumber + index + 1).toString());
        });
      }

      if (mounted) {
        setState(() {
          colorDropdownEntries = colorDropdownMenuEntries;
          selectedColor = colorDropdownMenuEntries.first.value;
          numberDropdownEntries = numberDropdownEntries;
          selectedNumber = numberDropdownEntries.first.value;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(languageMap['WhatKindOfCard'] ?? ''),
      content: FutureBuilder<void>(
        future: _dropdownEntriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Error loading data');
          } else {
            return Row(
              children: [
                DropdownMenu<String>(
                  enableSearch: false,
                  onSelected: (value) {
                    setState(() {
                      liedColor = value!;
                    });
                  },
                  dropdownMenuEntries: colorDropdownEntries,
                ),
                DropdownMenu<int>(
                  enableSearch: false,
                  onSelected: (value) {
                    setState(() {
                      liedNumber = value!;
                    });
                  },
                  dropdownMenuEntries: numberDropdownEntries,
                ),
              ],
            );
          }
        },
      ),
      actions: [
        liedColor.isEmpty || liedNumber == 0
            ? TextButton(
                onPressed: null,
                child: Text(languageMap['ChooseColorAndNumber'] ?? ''),
              )
            : TextButton(
                onPressed: () async {
                  liedCard = '$liedColor$liedNumber';
                  print('Lied card: $liedCard');
                  await db.updateLies(
                    liedColor,
                    liedNumber,
                    widget.choosedCard,
                  );
                  setState(() {
                    db.moveToDiscardPile(
                      widget.choosedCard,
                      widget.user!,
                    );
                  });
                 // widget.onButtonPressed();
                  Navigator.pop(context);
                  await db.incresePassCount();
                  await db.checkActivePlayer();
                  await db.updateLastCardPlayer(widget.user!.uid);
                },
                child: const Text('OK'),
              ),
      ],
    );
  }
}
