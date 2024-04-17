import 'package:flutter/material.dart';
import 'package:thatsnot/models/card.dart';
import 'package:thatsnot/pages/start_screen.dart';
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {

  _onStartNext() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const StartPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple, Colors.deepOrange],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 25),
            const Text('Game Page', style: TextStyle(color: Colors.white, fontSize: 24)),
            TextButton.icon(
              onPressed: () {
                _onStartNext();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: const Center(
                  child: ElevatedButton(onPressed: shuffleCards, child: Text('kevert kártyák'))
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
