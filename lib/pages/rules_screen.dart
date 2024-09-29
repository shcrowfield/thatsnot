import 'package:flutter/material.dart';
import 'package:thatsnot/language.dart';
import 'package:thatsnot/pages/start_screen.dart';

class RulesPage extends StatefulWidget {
  const RulesPage({super.key});

  @override
  State<RulesPage> createState() => _RulesPageState();
}

class _RulesPageState extends State<RulesPage> {
  _onRulesNext() {
    Navigator.pop(
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
          child: Column(children: [
            const SizedBox(height: 50),
            TextButton.icon(
              onPressed: () {
                _onRulesNext();
              },
              icon: const Icon(Icons.arrow_back),
              label: Text(languageMap['Back'] ?? ''),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
              ),
            ),
            Text(
              languageMap['GameRules'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 30),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(35.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // Aligning text properly
                    children: [
                      Text(
                        languageMap['RuleText1'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      // Add spacing between text blocks
                      Text(
                        languageMap['RuleText2'] ?? '',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        languageMap['RuleText3'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        languageMap['RuleText4'] ?? '',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        languageMap['RuleText5'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        languageMap['RuleText6'] ?? '',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        languageMap['RuleText7'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        languageMap['RuleText8'] ?? '',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        languageMap['RuleText9'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        languageMap['RuleText10'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        languageMap['RuleText11'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        languageMap['RuleText12'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        languageMap['RuleText13'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(languageMap['RuleText14'] ?? '',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(languageMap['RuleText15'] ?? '',
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 5),
                      Text(languageMap['RuleText16'] ?? '',
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 5),
                      Text(languageMap['RuleText17'] ?? '',
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 5),
                      Text(languageMap['RuleText18'] ?? '',
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
