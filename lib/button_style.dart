import 'package:flutter/material.dart';

final ButtonStyle menuButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.white,
  foregroundColor: Colors.black,
);

final ButtonStyle disabledMenuButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.white38,
  foregroundColor: Colors.black,
  minimumSize: const Size(200, 40),
);

final ButtonStyle googleButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.red,
  foregroundColor: Colors.white,
  minimumSize: const Size(200, 40),
);

final ButtonStyle choosedButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.orange,
  foregroundColor: Colors.white,
);

final ButtonStyle unchoosedButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.white,
  foregroundColor: Colors.black,
);

final ButtonStyle gameButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.white,
  foregroundColor: Colors.purple,
);
final ButtonStyle diabledGameButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.white38,
  foregroundColor: Colors.black,
);
final ButtonStyle sideButtonStyle = ElevatedButton.styleFrom(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15.0),
  ),
  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
);
