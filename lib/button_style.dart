import 'package:flutter/material.dart';

final ButtonStyle menuButtonStyle = ElevatedButton.styleFrom(
backgroundColor: Colors.white,
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