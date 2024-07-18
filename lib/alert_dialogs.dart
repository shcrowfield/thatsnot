import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thatsnot/services/database.dart';

class LieDialog extends StatefulWidget {
  final String lobbyId;
  final User? user;

  String liedColor = '';
   int liedNumber = 0;
   MapEntry<String, dynamic> choosedCard = MapEntry('', '');
   String liedCard = '';


  LieDialog({super.key, required this.lobbyId, this.user});

  @override
  State<LieDialog> createState() => _LieDialogState();
}

class _LieDialogState extends State<LieDialog> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
          'Milyen kártya ez?'),
      content: Row(
        children: [
          DropdownMenu(
            enableSearch: false,
            onSelected: (value) {
              setState(() {
                widget.liedColor = value!;
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
                widget.liedNumber = value!;
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
        widget.liedColor == '' ||
            widget.liedNumber == 0
            ? const TextButton(
            onPressed: null,
            child: Text(
                'Válassz színt és számot'))
            : TextButton(
            onPressed: () async {
              widget.liedCard =
              '$widget.liedColor$widget.liedNumber';
              print(
                  'Lied card: $widget.liedCard');
              await DatabaseService(
                  lobbyId: widget
                      .lobbyId)
                  .updateLies(
                  widget.liedColor,
                  widget.liedNumber,
                  widget.choosedCard);
              setState(() {
                //widget.userCards.remove(widget.choosedCard.key);
              });
              Navigator.pop(
                  context);
            },
            child:
            const Text('OK'))
      ],
    );
  }
}
