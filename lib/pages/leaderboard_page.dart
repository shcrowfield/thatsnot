import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thatsnot/language.dart';
import 'package:thatsnot/pages/my_leaderboard_page.dart';
import 'package:thatsnot/pages/start_screen.dart';

class LeaderboardPage extends StatefulWidget {
  final User? user;

  const LeaderboardPage({super.key, required this.user});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  _onStartNext() {
    Navigator.pop(
        context, MaterialPageRoute(builder: (context) => const StartPage()));
  }

  _onMyLeaderboardNext() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MyLeaderboardPage(user: widget.user!)));
  }

  Future<List<DocumentSnapshot>> getLeaderboard() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('leaderboard')
        .orderBy('points', descending: true)
        .limit(10)
        .get();
    return snapshot.docs;
  }

  Future<DocumentSnapshot> getPlayerData() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('leaderboard')
    .doc(widget.user!.uid)
        .get();
    return snapshot;
  }

  Map<String, dynamic> sizes(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final buttonWidth = screenWidth * 0.23;
    final buttonHeight = screenHeight * 0.1;
    final textSize = screenWidth * 0.02;
    return {
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
      'buttonWidth': buttonWidth,
      'buttonHeight': buttonHeight,
      'textSize': textSize,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: sizes(context)['screenHeight'],
        width: sizes(context)['screenWidth'],
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple, Colors.deepOrange],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _onStartNext,
                child: Text(languageMap['Back'] ?? '',
                    style: const TextStyle(color: Colors.black))),
            Expanded(
              child: FutureBuilder<List<DocumentSnapshot>>(
                future: getLeaderboard(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No data available');
                  } else {
                    var leaderboard = snapshot.data!;
                    return Column(
                      children: [
                        Text(languageMap['Leaderboard'] ?? '',
                            style:
                            const TextStyle(fontSize: 30, color: Colors.white)),
                        FutureBuilder(
                          future: getPlayerData(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return const Text('Error loading data');
                            } else if (!snapshot.hasData || snapshot.data?.data() == null) {
                              return const Text('No player data available');
                            } else {
                              var data = snapshot.data!.data()
                              as Map<String, dynamic>;
                              String name = data['name'] ?? 'Unknown Player';
                              int points = data['points'] ?? 0;
                              int winCounter = data['winCounter'] ?? 0;
                              return SizedBox(
                                  width: sizes(context)['screenWidth'] * 0.8,
                                  child: InkWell(
                                    onTap: () {
                                      _onMyLeaderboardNext();
                                    },
                                    child: myListTile(
                                        name, points, winCounter, context),
                                  ));
                            }
                          },
                        ),
                        SizedBox(
                          height: sizes(context)['screenHeight'] * 0.4,
                          width: sizes(context)['screenWidth'] * 0.8,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: leaderboard.length,
                            itemBuilder: (context, index) {
                              var data = leaderboard[index].data()
                              as Map<String, dynamic>;
                              String name = data['name'] ?? 'Unknown Player';
                              int points = data['points'] ?? 0;
                              int winCounter = data['winCounter'] ?? 0;
                              return customListTile(
                                  name, points, winCounter, context);
                            },
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget customListTile(
    String name, int points, int winCounter, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.5),
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(name,
                style: const TextStyle(fontSize: 20, color: Colors.white)),
            Text('${languageMap['AllPoints']}: $points',
                style: const TextStyle(fontSize: 20, color: Colors.white)),
            Text('${languageMap['NumberOfWins']}: $winCounter',
                style: const TextStyle(fontSize: 20, color: Colors.white)),
          ],
        ),
      ),
    ),
  );
}

Widget myListTile(String name, int points, int wins, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(name,
                style: const TextStyle(fontSize: 20, color: Colors.black)),
            Text('${languageMap['AllPoints']}: $points',
                style: const TextStyle(fontSize: 20, color: Colors.black)),
            Text('${languageMap['NumberOfWins']}: $wins',
                style: const TextStyle(fontSize: 20, color: Colors.black)),
          ],
        ),
      ),
    ),
  );
}
