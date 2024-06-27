import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thatsnot/pages/rules_screen.dart';
import 'package:thatsnot/button_style.dart';
import 'package:thatsnot/services/google_auth.dart';
import 'package:thatsnot/pages/lobby_creation_page.dart';
import 'package:thatsnot/pages/lobby_list_page.dart';
import 'package:thatsnot/language.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  User? user = FirebaseAuth.instance.currentUser;
  final GoogleAuth _googleAuth = GoogleAuth();
  String nickName = '';
  late TextEditingController nickNameController;
  String dropdownValue = 'Hun';

  @override
  initState() {
    super.initState();
    nickNameController = TextEditingController();
    if (user == null || user!.uid.isEmpty) {
      _loginAnonymously();
    }
  }

  @override
  dispose() {
    nickNameController.dispose();
    super.dispose();
  }

  _onRulesNext() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const RulesPage()));
  }

  _onLobbyNext() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LobbyCreationPage(user: user, nickName: nickName)));
  }

  _onLobbyListNext() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => LobbiesListPage(user: user)));
  }

  @override
  Widget build(BuildContext context) {
    /* Size screenSize = MediaQuery.of(context).size;
    double containerWidth = screenSize.width * 0.5;
    double containerHeight = screenSize.height * 0.3;*/
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
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: _googleAuth.buildGoogleSignInOutButton(context,
                        () async {
                      await _googleAuth.signIn();
                      setState(() {});
                    }, () async {
                      await _googleAuth.signOut();
                      setState(() {});
                    }),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/images/logo.png',
                      width: 200, height: 140),
                  ElevatedButton(
                    onPressed: () {
                      _onLobbyNext();
                    },
                    style: menuButtonStyle,
                    child: Text(languageMap['CreateLobby'] ?? ''),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () {
                      _onLobbyListNext();
                    },
                    style: menuButtonStyle,
                    child: Text(languageMap['ActiveLobbies'] ?? ''),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () {},
                    style: menuButtonStyle,
                    child: Text(languageMap['Results'] ?? ''),
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
                    child: Text(languageMap['Rules'] ?? ''),
                  ),
                  DropdownButton<String>(
                    icon: const Icon(Icons.menu),
                    style: const TextStyle(color: Colors.deepPurple),
                    value: lang,
                    onChanged: (String? newValue) {
                      setState(() {
                        lang = newValue!;
                        if (lang == 'Hun') {
                          setLanguage('Hun');
                        } else {
                          setLanguage(lang);
                        }
                      });
                    },
                    items: <String>['Hun', 'Eng', 'Tur']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSignInButton() {
    Map<String, String> languageMap = changeLanguageMap();
    return ElevatedButton(
      onPressed: () async {
        try {
          await FirebaseAuth.instance.signInAnonymously();
          setState(() {
            user = FirebaseAuth.instance.currentUser;
          });
        } on FirebaseAuthException catch (e) {
          print(e);
        }
      },
      style: menuButtonStyle,
      child: Text(languageMap['SignIn'] ?? ''),
    );
  }

  Widget buildSignOutButton() {
    Map<String, String> languageMap = changeLanguageMap();
    return Column(
      children: [
        //Text("User ID: ${user!.uid}"),
        ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            setState(() {
              user = FirebaseAuth.instance.currentUser;
            });
          },
          style: menuButtonStyle,
          child: Text(languageMap['SignOut'] ?? ''),
        ),
      ],
    );
  }

  Future<void> _loginAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      setState(() {
        user = FirebaseAuth.instance.currentUser;
      });
      print("Signed in with temporary account.");
    } catch (e) {
      print("Failed to sign in anonymously: $e");
    }
  }
}
