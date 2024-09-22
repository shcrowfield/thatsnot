import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thatsnot/language.dart';
import 'package:thatsnot/pages/leaderboard_page.dart';
import 'package:d_chart/d_chart.dart';

class MyLeaderboardPage extends StatefulWidget {
  final User? user;

  const MyLeaderboardPage({super.key, required this.user});

  @override
  State<MyLeaderboardPage> createState() => _MyLeaderboardPageState();
}

class _MyLeaderboardPageState extends State<MyLeaderboardPage> {
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

  late Future<Map<String, dynamic>> playerBoardFuture;

  @override
  void initState() {
    playerBoardFuture = getLeaderboard();
    super.initState();
  }

  _onLeaderboardNext() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LeaderboardPage(user: widget.user)));
  }

  Future<Map<String, dynamic>> getLeaderboard() async {
    final playerLeaderBoard = await FirebaseFirestore.instance
        .collection('leaderboard')
        .doc(widget.user!.uid)
        .get();
    return playerLeaderBoard.data()!;
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
      child: Column(children: [
        ElevatedButton(
            onPressed: _onLeaderboardNext,
            child: Text(languageMap['Back'] ?? '',
                style: const TextStyle(color: Colors.black))),
        const Text('My Leaderboard',
            style: TextStyle(fontSize: 30, color: Colors.white)),
        SizedBox(
          height: sizes(context)['screenHeight'] * 0.2,
          child: FutureBuilder(
              future: playerBoardFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Text('Error loading data');
                } else if (!snapshot.hasData) {
                  return const Text('No data found');
                } else {
                  final data = snapshot.data;
                  final wins = data?['wins'] ?? [];
                  return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: wins.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: sizes(context)['screenWidth'] * 0.13,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                          ),
                          // Adjust width as needed
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          child: ListTile(
                            title: Text('${index + 1}. játék',
                                style: const TextStyle(color: Colors.white)),
                            subtitle: Text('Points: ${wins[index]}',
                                style: const TextStyle(color: Colors.white)),
                          ),
                        );
                      });
                }
              }),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: SizedBox(
              height: sizes(context)['screenHeight'] * 0.5,
              width: sizes(context)['screenWidth'] * 0.8,
              child: Container(
                child: FutureBuilder(
                    future: playerBoardFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Text('Error loading data');
                      } else if (!snapshot.hasData) {
                        return const Text('No data found');
                      } else {
                        final data = snapshot.data;
                        final wins = data?['wins'] ?? [];
                        return AspectRatio(
                          aspectRatio: 20 / 5,
                          child: DChartLineN(
                            groupList: [
                              NumericGroup(
                                color: Colors.blue,
                                id: 'wins',
                                data: List.generate(wins.length, (index) {
                                  return NumericData(
                                    domain: index+1,
                                    measure: wins[index]  is num ? wins[index] : 0,
                                  );
                                }),
                              ),
                            ],
                          ),
                        );
                      }
                    }),
              )),
        ),
      ]),
    ));
  }
}
