import 'package:flutter/material.dart';
import 'package:thatsnot/pages/start_screen.dart';



class RulesPage extends StatefulWidget {
  const RulesPage({super.key});

  @override
  State<RulesPage> createState() => _RulesPageState();
}

class _RulesPageState extends State<RulesPage> {
  _onRulesNext() {
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
            colors: [Colors.purple, Colors.deepPurple],
          ),
        ),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              TextButton.icon(
                onPressed: () {_onRulesNext();},
                icon: const Icon(Icons.arrow_back),
                label: const Text('Vissza'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
              ),
              const Text('Játékszabályok'),
            ],
          ),
        ),
      ),
    );
  }
}
