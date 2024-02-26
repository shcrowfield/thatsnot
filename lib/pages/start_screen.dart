import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:thatsnot/pages/rules_screen.dart';
import 'package:thatsnot/button_style.dart';



class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  User? user = FirebaseAuth.instance.currentUser;
  User? gUser;

  _onRulesNext() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const RulesPage()));
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
                child: buildGoogleSignInOutButton(),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/images/logo.png',
                      width: 200, height: 150),
                  ElevatedButton(
                    onPressed: () {},
                    style: menuButtonStyle,
                    child: const Text('Lobbi készítése'),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () {},
                    style: menuButtonStyle,
                    child: const Text('Lobbi keresése'),
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
                      child: Text('Szabályok'),
                      style: menuButtonStyle),
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

  googleSignIn() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);
        setState(() {
          gUser = authResult
              .user; // Update the Google user state upon successful sign-in
        });
      }
    } catch (e) {
      print(e);
    }
  }

  signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    setState(() {
      gUser = null; // Reset the Google user state upon sign-out
    });
  }

  Widget buildGoogleSignInOutButton() {
    if (gUser == null) {
      // Google user not signed in, show sign-in button
      return ElevatedButton.icon(
        onPressed: () async {
          googleSignIn();
        },
        style: googleButtonStyle,
        icon: const Icon(FontAwesomeIcons.google),
        label: const Text('Google bejelentkezés'),
      );
    } else {
      // Google user is signed in, show sign-out button
      return ElevatedButton.icon(
        onPressed: () {
          signOut();
        },
        style: googleButtonStyle,
        icon: const Icon(FontAwesomeIcons.google),
        label: const Text('Kijelentkezés Googleból'),
      );
    }
  }
}
