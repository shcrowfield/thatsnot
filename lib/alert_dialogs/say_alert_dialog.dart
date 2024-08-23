//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thatsnot/services/database.dart';

class SayAlertDialog extends StatefulWidget {
  final String lobbyId;
  final User? user;
  final MapEntry<String, dynamic> choosedCard;
  final VoidCallback onButtonPressed;

  const SayAlertDialog({
    super.key,
    required this.lobbyId,
    required this.user,
    required this.choosedCard,
    required this.onButtonPressed,
  });

  @override
  State<SayAlertDialog> createState() => _SayAlertDialogState();
}

class _SayAlertDialogState extends State<SayAlertDialog> {
  String? selectedColor;
  List<DropdownMenuEntry<String>> dropdownEntries = [];
  String liedColor = '';
  int liedNumber = 0;
  String liedCard = '';

  /*Future<Map<String, dynamic>> _getColorNumber() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('lobbies')
        .doc(widget.lobbyId)
        .get();
    var lobby = snapshot.data();
    String lobbyLiedColor = lobby!['liedColor'];
    int lobbyLiedNumber = lobby['liedNumber'];
    return {'lobbyLiedColor': lobbyLiedColor, 'lobbyLiedNumber': lobbyLiedNumber};
  }

  Future<void> getDropdownEntries() async {
    var lobby = await _getColorNumber();
    String lobbyLiedColor = lobby['lobbyLiedColor'];
    int lobbyLiedNumber = lobby['lobbyLiedNumber'];

    List<DropdownMenuEntry<String>> dropdownMenuEntries;

    if (lobbyLiedColor.isEmpty || lobbyLiedNumber == 9) {
      dropdownMenuEntries = [
        const DropdownMenuEntry(value: 'Purple', label: 'Purple'),
        const DropdownMenuEntry(value: 'Orange', label: 'Orange'),
        const DropdownMenuEntry(value: 'Black', label: 'Black'),
      ];
    } else {
      dropdownMenuEntries = [
        DropdownMenuEntry(value: lobbyLiedColor, label: lobbyLiedColor),
      ];
    }

    if (mounted) {
      setState(() {
        dropdownEntries = dropdownMenuEntries;
        selectedColor = dropdownMenuEntries.first.value;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getDropdownEntries();
  }*/

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Milyen kártya ez?'),
      content: /*FutureBuilder<void>(
        future: getDropdownEntries(),
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
                  dropdownMenuEntries: dropdownEntries,
                ),
                DropdownMenu<int>(
                  enableSearch: false,
                  onSelected: (value) {
                    setState(() {
                      liedNumber = value!;
                    });
                  },
                  dropdownMenuEntries:
                  const [
                    DropdownMenuEntry(value: 1, label: '1'),
                    DropdownMenuEntry(value: 2, label: '2'),
                    DropdownMenuEntry(value: 3, label: '3'),
                    DropdownMenuEntry(value: 4, label: '4'),
                    DropdownMenuEntry(value: 5, label: '5'),
                    DropdownMenuEntry(value: 6, label: '6'),
                    DropdownMenuEntry(value: 7, label: '7'),
                    DropdownMenuEntry(value: 8, label: '8'),
                    DropdownMenuEntry(value: 9, label: '9'),
                  ],
                ),
              ],
            );
          }
        },
      ),*/
      Row(
        children: [
          DropdownMenu(
            enableSearch: false,
            onSelected: (value) {
              setState(() {
                liedColor = value!;
              });
            },
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'Purple', label: 'Purple'),
              DropdownMenuEntry(value: 'Orange', label: 'Orange'),
              DropdownMenuEntry(value: 'Black', label: 'Black'),
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
              DropdownMenuEntry(value: 1, label: '1'),
              DropdownMenuEntry(value: 2, label: '2'),
              DropdownMenuEntry(value: 3, label: '3'),
              DropdownMenuEntry(value: 4, label: '4'),
              DropdownMenuEntry(value: 5, label: '5'),
              DropdownMenuEntry(value: 6, label: '6'),
              DropdownMenuEntry(value: 7, label: '7'),
              DropdownMenuEntry(value: 8, label: '8'),
              DropdownMenuEntry(value: 9, label: '9'),
              DropdownMenuEntry(value: 10, label: '10'),
            ],
          ),
        ],
      ),
      actions: [
        liedColor.isEmpty || liedNumber == 0
            ? const TextButton(
          onPressed: null,
          child: Text('Válassz színt és számot'),
        )
            : TextButton(
          onPressed: () async {
            liedCard = '$liedColor$liedNumber';
            print('Lied card: $liedCard');
            await DatabaseService(lobbyId: widget.lobbyId).updateLies(
              liedColor,
              liedNumber,
              widget.choosedCard,
            );
            setState(() {
              DatabaseService(lobbyId: widget.lobbyId).moveToDiscardPile(
                widget.choosedCard,
                widget.user!,
              );
            });
            widget.onButtonPressed();
            Navigator.pop(context);
            await DatabaseService(lobbyId: widget.lobbyId)
                .incresePassCount();
            await DatabaseService(lobbyId: widget.lobbyId)
                .checkActivePlayer();
            await DatabaseService(lobbyId: widget.lobbyId)
                .updateLastCardPlayer(widget.user!.uid);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
