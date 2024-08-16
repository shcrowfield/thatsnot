import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LeaderboardPage extends StatefulWidget {
  final User? user;

  const LeaderboardPage({super.key, required this.user});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  Future<List<DocumentSnapshot>> getLeaderboard() async {
    var snapshot =
        await FirebaseFirestore.instance.collection('leaderboard').get();
    return snapshot.docs;
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder<List<DocumentSnapshot>>(
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
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: leaderboard.length,
                    itemBuilder: (context, index) {
                      var data = leaderboard[index].data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['name'] ?? '', style: TextStyle(fontSize: sizes(context)['textSize'], color: Colors.white)),
                        subtitle: Text('Score: ${data['points'] ?? 0}', style: TextStyle(fontSize: sizes(context)['textSize'], color: Colors.white)),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
