import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thatsnot/language.dart';
import'package:thatsnot/pages/start_screen.dart';

class LobbiesListPage extends StatefulWidget {
  const LobbiesListPage({super.key});

  @override
  State<LobbiesListPage> createState() => _LobbiesListPageState();
}

class _LobbiesListPageState extends State<LobbiesListPage> {
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
            colors: [Colors.purple, Colors.deepPurple],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 25),
            Text(language[3], style: const TextStyle(color: Colors.white, fontSize: 24)),
            TextButton.icon(
              onPressed: () {
                _onStartNext();
              },
              icon: const Icon(Icons.arrow_back),
              label:Text(language[0]),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('lobbies').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();

                  return ListView(
                    children: snapshot.data!.docs.map((document) {
                      return ListTile(
                        title: Text(document['lobbyName'], style: const TextStyle(color: Colors.white)),
                        subtitle: Text("${document['currentPlayerCount']} / ${document['playerLimit']} players", style: const TextStyle(color: Colors.white)),
                        onTap: () {
                          //Navigator.push(context, MaterialPageRoute(builder: (context) => LobbyDetailsPage(lobbyId: document.id)));
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
