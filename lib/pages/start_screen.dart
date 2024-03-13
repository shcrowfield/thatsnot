import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thatsnot/pages/rules_screen.dart';
import 'package:thatsnot/button_style.dart';
import 'package:thatsnot/services/google_auth.dart';
import 'package:thatsnot/pages/lobby_creation_page.dart';
import 'package:thatsnot/pages/lobby_list_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  User? user = FirebaseAuth.instance.currentUser;
  final GoogleAuth _googleAuth = GoogleAuth();

  _onRulesNext() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const RulesPage()));
  }

  _onLobbyNext() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LobbyCreationPage()));
  }

  _onLobbyListNext() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LobbiesListPage()));
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
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child:
                    _googleAuth.buildGoogleSignInOutButton(context, () async {
                  await _googleAuth.signIn();
                  setState(() {});
                }, () async {
                  await _googleAuth.signOut();
                  setState(() {});
                }),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/images/logo.png',
                      width: 200, height: 150),
                  ElevatedButton(
                    onPressed: () {_onLobbyNext();},
                    style: menuButtonStyle,
                    child: const Text('Lobbi készítése'),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () {_onLobbyListNext();},
                    style: menuButtonStyle,
                    child: const Text('Aktív lobbik'),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () {},
                    style: menuButtonStyle,
                    child: const Text('Elért eredmények'),
                  ),
                  const SizedBox(height: 5),
                  user == null ? buildSignInButton() : buildSignOutButton(),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        _onRulesNext();
                      },
                      style: menuButtonStyle,
                      child: const Text('Szabályok')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSignInButton() {
    return ElevatedButton(
      onPressed: () async {
        try {
          await FirebaseAuth.instance.signInAnonymously();
          print("Bejelentkezés történt!");
          setState(() {
            user = FirebaseAuth.instance.currentUser;
          });
        } on FirebaseAuthException catch (e) {
          switch (e.code) {
            case "operation-not-allowed":
              print("Anonymous auth hasn't been enabled for this project.");
              break;
            default:
              print("Unknown error.");
          }
        }
      },
      style: menuButtonStyle,
      child: const Text('Bejeletkezés'),
    );
  }

  Widget buildSignOutButton() {
    return Column(
      children: [
        Text("User ID: ${user!.uid}"),
        ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            print("Kijelentkezés történt!");
            setState(() {
              user = FirebaseAuth.instance.currentUser;
            });
          },
          style: menuButtonStyle,
          child: const Text('Kijelentkezés'),
        ),
      ],
    );
  }
}
