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

  @override
  initState() {
    super.initState();
    nickNameController = TextEditingController();
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
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => LobbyCreationPage(user: user, nickName: nickName)));
  }

  _onLobbyListNext() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const LobbiesListPage()));
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
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: language[12],
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 2.0),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange, width: 2.0),
                        ),
                      ),
                      controller: nickNameController,
                      onChanged: (String value) {
                        setState(() {
                          nickName = nickNameController.text;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/images/logo.png',
                      width: 200, height: 140),
                  ElevatedButton(
                    onPressed: () { nickName == '' ? null : _onLobbyNext(); },
                    style:nickName == '' ? disabledMenuButtonStyle : menuButtonStyle,
                    child: Text(language[1]),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () { nickName == '' ? null : _onLobbyListNext(); },
                    style: nickName == '' ? disabledMenuButtonStyle : menuButtonStyle,
                    child: Text(language[2]),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () {},
                    style: menuButtonStyle,
                    child: Text(language[3]),
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
                    child: Text(language[8]),
                  ),
                  Switch(
                    value: lang,
                    onChanged: (value) {
                      setState(() {
                        lang = value;
                        setLanguage(lang);
                        changeLanguage();
                      });
                    },
                  ),
                  Text(
                    'Nyelv: ${lang ? 'English' : 'Magyar'}',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
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
    List<String> language = changeLanguage();
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
      child: Text(language[4]),
    );
  }

  Widget buildSignOutButton() {
    List<String> language = changeLanguage();
    return Column(
      children: [
        Text("User ID: ${user!.uid}"),
        ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            setState(() {
              user = FirebaseAuth.instance.currentUser;
            });
          },
          style: menuButtonStyle,
          child: Text(language[5]),
        ),
      ],
    );
  }
}
